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

	# título em cima, fogueira no meio (a do fundo, ou uma imagem própria), opções embaixo
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_top = 64
	box.offset_bottom = -28
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var t := UiTheme.make_label("Acampamento", 44, Palette.BONE_LIGHT, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var s := UiTheme.make_label("Uma fogueira baixa, longe das trilhas. Vida: %d / %d" % [RunState.hp, RunState.max_hp], 17, Palette.PAPER)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(s)

	# meio livre: o fundo do acampamento já tem a fogueira. Uma imagem em assets/art/camp/campfire.png
	# aparece ali por cima; sem fundo e sem imagem, fica o círculo desenhado em código.
	var middle := CenterContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(middle)
	var fire_art := Database.get_art("camp", &"campfire")
	if fire_art != null:
		middle.add_child(_art_rect(fire_art, 170))
	elif Database.get_art("backgrounds", &"camp") == null:
		middle.add_child(IconView.create(&"energy", Palette.BONE, 90))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	var heal := int(ceil(RunState.max_hp * HEAL_FRACTION))
	row.add_child(_option(&"rest", "Descansar", "Recupere %d de vida." % heal, _rest.bind(heal), RunState.hp < RunState.max_hp))
	row.add_child(_option(&"upgrade", "Aprimorar", "Melhore permanentemente uma carta do baralho desta expedição.",
		_upgrade, not RunState.get_upgradable_cards().is_empty()))
	row.add_child(_option(&"purge", "Purgar", "Remova uma carta do baralho da expedição.", _purge, RunState.deck.size() > MIN_DECK))


## Opção do acampamento; o ícone vem de assets/art/camp/<art_id>.png, se existir.
func _option(art_id: StringName, title: String, desc: String, cb: Callable, enabled: bool) -> Control:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(250, 160)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var art := Database.get_art("camp", art_id)
	if art != null:
		var r := _art_rect(art, 96)
		if not enabled:
			r.modulate = Color(0.55, 0.55, 0.55, 0.8)
		v.add_child(r)
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


static func _art_rect(tex: Texture2D, px: int) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(px, px)
	r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
