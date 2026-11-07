extends Control
## Laboratório (hub entre expedições): estações e prateleira de materiais.


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Color("#25231F")) as BackgroundView
	bg.glow_color = Palette.MOSS
	bg.glow_center = Vector2(0.5, 0.3)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 32
	root.offset_right = -32
	root.offset_top = 20
	root.offset_bottom = -20
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	titles.add_child(UiTheme.make_label("Laboratório", 38, Palette.BONE_LIGHT, true))
	titles.add_child(UiTheme.make_label("Bancadas manchadas, frascos rotulados e o cheiro persistente de formol.", 15, Palette.TEXT_DIM))
	top.add_child(UiTheme.make_button("Menu", func(): Game.goto("menu")))

	# atributos do caçador
	var stats := PanelContainer.new()
	root.add_child(stats)
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 28)
	stats.add_child(sh)
	sh.add_child(_stat("Vida máxima", str(Profile.get_max_hp()), Palette.BLOOD_BRIGHT))
	sh.add_child(_stat("Energia", str(Profile.get_max_energy()), Palette.PETROL_BRIGHT))
	sh.add_child(_stat("Incisões", str(Profile.get_incisions()), Palette.BONE_LIGHT))
	sh.add_child(_stat("Mutações", "%d / %d" % [Profile.mutations.size(), Profile.MAX_MUTATIONS], Palette.VIOLET_BRIGHT))
	var corr := _stat("Corrupção", str(Profile.get_corruption()), Palette.VIOLET_BRIGHT)
	corr.tooltip_text = "A cada %d pontos, você inicia cada combate com 1 de Corrupção." % Profile.CORRUPTION_STEP
	sh.add_child(corr)
	sh.add_child(_stat("Cartas catalogadas", "%d / %d" % [Profile.unlocked_cards.size(), Database.cards.size()], Palette.MOSS_BRIGHT))

	# estações
	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	root.add_child(grid)
	var exp_name: String = Database.expeditions[Database.DEFAULT_EXPEDITION].display_name if Database.expeditions.has(Database.DEFAULT_EXPEDITION) else "?"
	grid.add_child(_station("Mesa de Expedição", &"scalpel", Palette.BLOOD_BRIGHT,
		"Partir para %s. Baralho inicial de %d cartas." % [exp_name, Profile.starting_deck.size()], "Partir", Game.start_expedition))
	grid.add_child(_station("Bancada de Baralho", &"notes", Palette.BONE,
		"Monte o baralho inicial com as cartas que você já catalogou.", "Montar baralho", func(): Game.goto("deck")))
	grid.add_child(_station("Câmara de Mutação", &"heart", Palette.VIOLET_BRIGHT,
		"Implante tecidos coletados no próprio corpo. Mais poder, mais corrupção.", "Abrir câmara", func(): Game.goto("mutations")))
	grid.add_child(_station("Arquivo de Espécimes", &"eye", Palette.PETROL_BRIGHT,
		"Bestiário, partes conhecidas e a coleção completa de cartas.", "Consultar arquivo", func(): Game.goto("archive")))

	# prateleira de materiais
	var shelf := PanelContainer.new()
	shelf.add_theme_stylebox_override("panel", UiTheme.panel_style(Color("#2F2A22"), Palette.BONE.darkened(0.45), 1, 6, 12))
	root.add_child(shelf)
	var sv := VBoxContainer.new()
	shelf.add_child(sv)
	sv.add_child(UiTheme.make_label("Prateleira de espécimes", 17, Palette.BONE, true))
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 6)
	sv.add_child(flow)
	if Profile.materials.is_empty():
		flow.add_child(UiTheme.make_label("Vazia. Disseque criaturas e retorne com seus materiais.", 14, Palette.TEXT_DIM))
	for id in Profile.materials:
		var part := Database.get_part(id)
		if part == null:
			continue
		flow.add_child(material_chip(part, Profile.get_material(id)))


func _stat(label: String, value: String, color: Color) -> Control:
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_STOP
	v.add_child(UiTheme.make_label(label, 12, Palette.TEXT_DIM))
	v.add_child(UiTheme.make_label(value, 22, color, true))
	return v


func _station(title: String, motif: StringName, accent: Color, desc: String, action: String, cb: Callable) -> Control:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	p.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.CHARCOAL, accent.darkened(0.5), 1, 8, 14))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var art := MotifArt.new()
	art.custom_minimum_size = Vector2(0, 150)
	art.setup(motif, accent)
	v.add_child(art)
	v.add_child(UiTheme.make_label(title, 20, Palette.BONE_LIGHT, true))
	var d := UiTheme.make_label(desc, 14, Palette.PAPER)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(d)
	var b := UiTheme.make_button(action, cb)
	b.custom_minimum_size.y = 42
	v.add_child(b)
	return p


static func material_chip(part: AnatomyPart, amount: int, needed: int = -1) -> Control:
	var chip := PanelContainer.new()
	var ok := needed < 0 or amount >= needed
	chip.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.CHARCOAL_DEEP,
		Family.get_dark_color(part.family) if ok else Palette.BLOOD, 1, 4, 4))
	var owner := Database.get_part_owner(part.id)
	chip.tooltip_text = "%s (%s)\n%s" % [part.display_name, owner.display_name if owner else "?", part.description]
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	chip.add_child(h)
	var icon := MotifArt.new()
	icon.paper = false
	icon.custom_minimum_size = Vector2(26, 26)
	icon.setup(part.art_motif, Family.get_color(part.family), part.icon)
	h.add_child(icon)
	var txt := "%s ×%d" % [part.display_name, amount] if needed < 0 else "%s %d/%d" % [part.display_name, amount, needed]
	h.add_child(UiTheme.make_label(txt, 14, Palette.PAPER if ok else Palette.BLOOD_BRIGHT))
	return chip
