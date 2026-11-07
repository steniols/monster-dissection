extends Control
## Evento narrativo do mapa. Resolve uma EventChoice (dados) e mostra o resultado.

var event: EventData
var _choices_box: VBoxContainer
var _result_box: VBoxContainer
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rng.randomize()
	if not RunState.active:
		RunState.start(Database.expeditions[Database.DEFAULT_EXPEDITION])
	if RunState.current == null or RunState.current.event == null:
		RunState.current = RunState.get_available_nodes()[0]
		RunState.current.event = Database.events.values()[0]
	event = RunState.current.event

	var bg := UiTheme.add_background(self, Color("#211F1C"), String(RunState.expedition.id) if RunState.expedition else "", 0.55) as BackgroundView
	bg.glow_color = event.accent.darkened(0.4)
	bg.glow_center = Vector2(0.3, 0.45)

	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 60
	root.offset_right = -60
	root.offset_top = 50
	root.offset_bottom = -50
	root.add_theme_constant_override("separation", 40)
	add_child(root)

	var art := MotifArt.new()
	art.custom_minimum_size = Vector2(380, 380)
	art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	art.setup(event.art_motif, event.accent, Database.get_art("events", event.id))
	root.add_child(art)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 14)
	root.add_child(col)
	col.add_child(UiTheme.make_label("Mistério", 15, Palette.TEXT_DIM))
	col.add_child(UiTheme.make_label(event.title, 38, Palette.BONE_LIGHT, true))
	var text := UiTheme.make_label(event.text, 18, Palette.PAPER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(text)
	col.add_child(UiTheme.make_label("Vida: %d / %d" % [RunState.hp, RunState.max_hp], 15, Palette.BLOOD_BRIGHT))

	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 8)
	col.add_child(_choices_box)
	for c in event.choices:
		_choices_box.add_child(_choice_button(c))

	_result_box = VBoxContainer.new()
	_result_box.add_theme_constant_override("separation", 12)
	_result_box.visible = false
	col.add_child(_result_box)


func _choice_button(c: EventChoice) -> Button:
	var b := Button.new()
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size.y = 52
	b.text = c.label if c.description.is_empty() else "%s  —  %s" % [c.label, c.description]
	b.add_theme_font_size_override("font_size", 16)
	b.disabled = not c.is_available(RunState.hp)
	if b.disabled:
		b.tooltip_text = "Vida insuficiente."
	if c.remove_card and RunState.deck.size() <= 5:
		b.disabled = true
		b.tooltip_text = "Baralho pequeno demais."
	if c.upgrade_card and RunState.get_upgradable_cards().is_empty():
		b.disabled = true
		b.tooltip_text = "Nenhuma carta pode ser aprimorada."
	b.pressed.connect(_resolve.bind(c))
	return b


func _resolve(c: EventChoice) -> void:
	_choices_box.visible = false
	var success := _rng.randf() < c.success_chance
	var lines: PackedStringArray = []
	if success:
		lines.append(c.result_text)
		if c.max_hp_change != 0:
			RunState.change_max_hp(c.max_hp_change)
			lines.append("%+d de vida máxima." % c.max_hp_change)
		if c.hp_change != 0:
			RunState.change_hp(c.hp_change)
			lines.append("%+d de vida." % c.hp_change)
		for p in c.gain_parts:
			var new_card := RunState.gather(p)
			lines.append("Material obtido: %s." % p.display_name)
			if new_card:
				lines.append("Nova carta catalogada: %s." % p.unlocks_card.display_name)
		for card in c.add_cards:
			RunState.deck.append(card.id)
			lines.append("Carta adicionada: %s." % card.display_name)
		Sfx.play(&"unlock" if not c.gain_parts.is_empty() else &"heal" if c.hp_change > 0 else &"click")
	else:
		lines.append(c.fail_text)
		if c.fail_hp_change != 0:
			RunState.change_hp(c.fail_hp_change)
			lines.append("%+d de vida." % c.fail_hp_change)
		Sfx.play(&"fail")

	_result_box.visible = true
	var res := UiTheme.make_label("\n".join(lines), 18, Palette.MOSS_BRIGHT if success else Palette.BLOOD_BRIGHT)
	res.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_box.add_child(res)

	var fight: Array[MonsterData] = c.fight if success else c.fail_fight
	if not fight.is_empty():
		_add_continue("Lutar!", func(): Game.start_event_fight(fight))
	elif success and c.remove_card:
		_add_continue("Escolher carta para remover", _pick_remove)
	elif success and c.upgrade_card:
		_add_continue("Escolher carta para aprimorar", _pick_upgrade)
	else:
		_add_continue("Continuar", func(): Game.goto("map"))


func _add_continue(label: String, cb: Callable) -> void:
	var b := UiTheme.make_button(label, cb, 260)
	b.custom_minimum_size.y = 46
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_result_box.add_child(b)


func _pick_remove() -> void:
	var o := CardGridOverlay.open(self, "Remover uma carta", RunState.get_deck_cards(), true, "Clique na carta que deseja remover.")
	o.card_chosen.connect(func(card: CardData, _i: int):
		RunState.deck.erase(card.id)
		Game.goto("map"))


func _pick_upgrade() -> void:
	open_upgrade_picker(self, func(): Game.goto("map"))


## Picker compartilhado (evento e acampamento): mostra as cartas já aprimoradas.
static func open_upgrade_picker(parent: Node, on_done: Callable) -> void:
	var originals := RunState.get_upgradable_cards()
	var previews: Array[CardData] = []
	for c in originals:
		previews.append(Database.get_card(StringName(String(c.id) + CardData.UPGRADE_SUFFIX)))
	var o := CardGridOverlay.open(parent, "Aprimorar uma carta", previews, true, "As cartas abaixo já mostram a versão aprimorada.")
	o.card_chosen.connect(func(_card: CardData, i: int):
		RunState.upgrade_card(originals[i].id)
		Sfx.play(&"unlock")
		on_done.call())
