extends Control
## Arquivo de espécimes: bestiário (caderno de campo) e coleção de cartas.


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UiTheme.add_background(self, Color("#23262A"), "lab", 0.7)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 28
	root.offset_right = -28
	root.offset_top = 16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)
	var t := UiTheme.make_label("Arquivo de Espécimes", 32, Palette.PETROL_BRIGHT, true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(t)
	top.add_child(UiTheme.make_button("Voltar ao laboratório", func(): Game.goto("lab")))

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)
	var best := _bestiary()
	best.name = "Bestiário"
	tabs.add_child(best)
	var coll := _collection()
	coll.name = "Coleção de cartas"
	tabs.add_child(coll)


func _bestiary() -> Control:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	for m in Database.get_sorted_monsters():
		list.add_child(_page(m))
	return scroll


func _page(m: MonsterData) -> Control:
	var known := Profile.is_monster_known(m.id)
	var p := PanelContainer.new()
	# página de caderno de campo
	p.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.PAPER if known else Palette.PAPER.darkened(0.55), Palette.INK_SOFT, 1, 4, 14))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 18)
	p.add_child(h)
	var art := MonsterArt.new()
	art.custom_minimum_size = Vector2(240, 180)
	art.setup(m)
	if not known:
		art.modulate = Color(0, 0, 0, 0.75)
		art.animate = false
	h.add_child(art)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	h.add_child(v)
	var tier: String = ["", " · Elite", " · Matriarca"][m.tier]
	if not known:
		v.add_child(UiTheme.make_label("Espécime não catalogado%s" % tier, 22, Palette.INK, true))
		v.add_child(UiTheme.make_label("Família: %s. Abata um exemplar para registrar sua anatomia." % Family.get_name_of(m.family), 14, Palette.INK))
		return p
	var e: Dictionary = Profile.bestiary.get(m.id, {})
	v.add_child(UiTheme.make_label("%s%s" % [m.display_name, tier], 24, Palette.INK, true))
	v.add_child(UiTheme.make_label("%s — %s · Abatidos: %d · Vida: %d" % [Family.get_name_of(m.family), Family.EPITHETS.get(m.family, ""), e.get("kills", 0), m.max_hp], 13, Family.get_dark_color(m.family).darkened(0.2)))
	var lore := UiTheme.make_label(m.lore, 14, Palette.INK)
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(lore)
	if not m.weakness_note.is_empty():
		var wk := UiTheme.make_label("Nota de campo: " + m.weakness_note, 14, Palette.BLOOD)
		wk.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(wk)
	var parts := HFlowContainer.new()
	parts.add_theme_constant_override("h_separation", 8)
	parts.add_theme_constant_override("v_separation", 6)
	v.add_child(parts)
	for part in m.parts:
		var lbl: Label
		if Profile.is_part_known(part.id):
			lbl = UiTheme.make_label("◆ %s (%s) → %s" % [part.display_name, AnatomyPart.region_name(part.region), part.unlocks_card.display_name if part.unlocks_card else "-"], 13, Palette.INK)
		else:
			lbl = UiTheme.make_label("◇ ??? (%s)" % AnatomyPart.region_name(part.region), 13, Palette.INK_SOFT)
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		parts.add_child(lbl)
	return p


func _collection() -> Control:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var grid := GridContainer.new()
	grid.columns = 7
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	for card in Database.get_sorted_cards():
		var v := CardView.create(card)
		v.interactive = false
		v.mouse_default_cursor_shape = Control.CURSOR_ARROW
		if not Profile.is_card_unlocked(card.id):
			v.modulate = Color(0.25, 0.24, 0.26)
			v.set_note("?")
			v.ready.connect(func(): v.tooltip_text = "Não catalogada. Origem: %s" % card.get_origin_label())
		grid.add_child(v)
	return scroll
