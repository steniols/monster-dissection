extends Control
## Acampamento: descansar (cura), aprimorar uma carta ou purgar uma carta do baralho.

const EventScreen := preload("res://scripts/ui/screens/event_screen.gd")
const HEAL_FRACTION := 0.3
const MIN_DECK := 5


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if not RunState.active:
		RunState.start(Database.expeditions.get(Database.DEFAULT_EXPEDITION))
	var bg := UiTheme.add_background(self, Color("#24231F"), "camp", 0.3) as BackgroundView
	bg.glow_color = Palette.BONE
	bg.glow_center = Vector2(0.5, 0.62)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)

	var t := UiTheme.make_label("Acampamento", 44, Palette.BONE_LIGHT, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var s := UiTheme.make_label("Uma fogueira baixa, longe das trilhas. Vida: %d / %d" % [RunState.hp, RunState.max_hp], 17, Palette.TEXT_DIM)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(s)

	var fire := IconView.create(&"energy", Palette.BONE, 90)
	fire.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(fire)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	var heal := int(ceil(RunState.max_hp * HEAL_FRACTION))
	row.add_child(_option("Descansar", "Recupere %d de vida." % heal, _rest.bind(heal), RunState.hp < RunState.max_hp))
	row.add_child(_option("Aprimorar", "Melhore permanentemente uma carta do baralho desta expedição.",
		_upgrade, not RunState.get_upgradable_cards().is_empty()))
	row.add_child(_option("Purgar", "Remova uma carta do baralho da expedição.", _purge, RunState.deck.size() > MIN_DECK))


func _option(title: String, desc: String, cb: Callable, enabled: bool) -> Control:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(250, 160)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	v.add_child(UiTheme.make_label(title, 26, Palette.BONE_LIGHT, true))
	var d := UiTheme.make_label(desc, 15, Palette.PAPER)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(d)
	var b := UiTheme.make_button(title, cb)
	b.disabled = not enabled
	v.add_child(b)
	return p


func _rest(amount: int) -> void:
	RunState.change_hp(amount)
	Sfx.play(&"heal")
	Game.goto("map")


func _upgrade() -> void:
	EventScreen.open_upgrade_picker(self, func(): Game.goto("map"))


func _purge() -> void:
	var o := CardGridOverlay.open(self, "Purgar uma carta", RunState.get_deck_cards(), true, "Clique na carta que deseja remover.")
	o.card_chosen.connect(func(card: CardData, _i: int):
		RunState.deck.erase(card.id)
		Game.goto("map"))
