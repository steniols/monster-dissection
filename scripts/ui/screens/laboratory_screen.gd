extends Control
## Laboratório (hub entre expedições): estações e prateleira de materiais.


## Ilustração de cada estação em assets/art/stations/<arquivo>.png.
const STATION_ART := {
	"Mesa de Expedição": "expedition",
	"Bancada de Baralho": "deck",
	"Estação de Experimentação": "experiment",
	"Câmara de Mutação": "mutation",
	"Oficina": "workshop",
	"Arquivo de Espécimes": "archive",
}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Color("#25231F"), "lab", 0.35) as BackgroundView
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
	if RunState.has_save():
		var cont := UiTheme.make_button("Continuar expedição", Game.continue_expedition)
		cont.theme_type_variation = "MossButton"
		top.add_child(cont)
	top.add_child(UiTheme.make_button("Opções", func(): Game.open_options("lab")))
	top.add_child(UiTheme.make_button("Menu", func(): Game.goto("menu")))

	# atributos do caçador
	var stats := PanelContainer.new()
	stats.add_theme_stylebox_override("panel", UiTheme.panel_style(Color("#2F2A22", 0.94), Palette.BONE.darkened(0.45), 1, 6, 10))
	root.add_child(stats)
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 0)
	stats.add_child(sh)
	var n_cards := Profile.unlocked_cards.size()
	var tiles := [
		_stat(&"heart", "Vida máxima", str(Profile.get_max_hp()), Palette.BLOOD_BRIGHT,
			"Vida com que você começa cada expedição."),
		_stat(&"energy", "Energia", str(Profile.get_max_energy()), Palette.PETROL_BRIGHT,
			"Energia por turno para jogar cartas."),
		_stat(&"attack", "Incisões", str(Profile.get_incisions()), Palette.BONE_LIGHT,
			"Cortes disponíveis em cada dissecação."),
		_stat(&"vial", "Mutações", "%d / %d" % [Profile.mutations.size(), Profile.MAX_MUTATIONS], Palette.VIOLET_BRIGHT,
			"Tecidos implantados na Câmara de Mutação.", float(Profile.mutations.size()) / Profile.MAX_MUTATIONS),
		_stat(&"debuff", "Corrupção", str(Profile.get_corruption()), Palette.VIOLET_BRIGHT,
			"A cada %d pontos, você inicia cada combate com 1 de Corrupção." % Profile.CORRUPTION_STEP),
		_stat(&"card", "Cartas catalogadas", "%d / %d" % [n_cards, Database.cards.size()], Palette.MOSS_BRIGHT,
			"Cartas que você já pode pôr no baralho inicial.", float(n_cards) / maxi(1, Database.cards.size())),
	]
	for i in tiles.size():
		if i > 0:
			var sep := ColorRect.new()
			sep.color = Palette.BONE.darkened(0.55)
			sep.custom_minimum_size.x = 1
			sh.add_child(sep)
		sh.add_child(tiles[i])

	# estações
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 12)
	root.add_child(grid)
	grid.add_child(_station("Mesa de Expedição", &"scalpel", Palette.BLOOD_BRIGHT,
		"Escolha uma região e parta. Baralho inicial de %d cartas." % Profile.starting_deck.size(), "Partir", _choose_region))
	grid.add_child(_station("Bancada de Baralho", &"notes", Palette.BONE,
		"Monte o baralho inicial com as cartas catalogadas.", "Montar baralho", func(): Game.goto("deck")))
	grid.add_child(_station("Estação de Experimentação", &"gland", Palette.MOSS_BRIGHT,
		"Combine partes de espécies diferentes e descubra cartas híbridas (%d/%d)." % [Profile.discovered_recipes.size(), Database.recipes.size()],
		"Experimentar", func(): Game.goto("experiment")))
	grid.add_child(_station("Câmara de Mutação", &"heart", Palette.VIOLET_BRIGHT,
		"Implante tecidos no próprio corpo. Mais poder, mais corrupção.", "Abrir câmara", func(): Game.goto("mutations")))
	grid.add_child(_station("Oficina", &"plates", Palette.BONE_LIGHT,
		"Melhore ferramentas e instalações (%d/%d construídas)." % [Profile.lab_upgrades.size(), Database.lab_upgrades.size()],
		"Abrir oficina", func(): Game.goto("workshop")))
	grid.add_child(_station("Arquivo de Espécimes", &"eye", Palette.PETROL_BRIGHT,
		"Bestiário, partes conhecidas e a coleção de cartas.", "Consultar arquivo", func(): Game.goto("archive")))

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


## Um atributo: ícone, número grande, rótulo e (opcional) barra de progresso.
func _stat(icon: StringName, label: String, value: String, color: Color, tip: String, progress: float = -1.0) -> Control:
	var tile := MarginContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.tooltip_text = tip
	for side in ["left", "right"]:
		tile.add_theme_constant_override("margin_" + side, 14)
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 12)
	tile.add_child(h)
	var ic := IconView.create(icon, color, 34)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(ic)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(v)
	var val := UiTheme.make_label(value, 26, color)
	val.add_theme_font_override("font", UiTheme.number_font)
	v.add_child(val)
	v.add_child(UiTheme.make_label(label, 13, Palette.BONE))
	if progress >= 0.0:
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.max_value = 1.0
		bar.value = progress
		bar.custom_minimum_size = Vector2(90, 5)
		bar.add_theme_stylebox_override("background", UiTheme.panel_style(Palette.CHARCOAL_DEEP, Color(0, 0, 0, 0), 0, 2))
		bar.add_theme_stylebox_override("fill", UiTheme.panel_style(color.darkened(0.15), Color(0, 0, 0, 0), 0, 2))
		v.add_child(bar)
	return tile


func _station(title: String, motif: StringName, accent: Color, desc: String, action: String, cb: Callable) -> Control:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var key: String = STATION_ART.get(title, "")
	var notice := Profile.station_notice(key)
	# com novidade: borda na cor da estação, mais forte
	p.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.CHARCOAL, accent if notice != "" else accent.darkened(0.5), 2 if notice != "" else 1, 8, 12))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	p.add_child(h)
	var art := MotifArt.new()
	art.custom_minimum_size = Vector2(104, 104)
	art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	art.setup(motif, accent, Database.get_art("stations", STATION_ART.get(title, "")))
	h.add_child(art)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	h.add_child(v)
	v.add_child(UiTheme.make_label(title, 21, Palette.BONE_LIGHT, true))
	if notice != "":
		var badge := _notice_badge(notice, accent)
		badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		v.add_child(badge)
	var d := UiTheme.make_label(desc, 14, Palette.PAPER)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(d)
	var b := UiTheme.make_button(action, func():
		Profile.mark_seen(key)
		cb.call())
	if title == "Mesa de Expedição":
		# é o "começar a partida": botão em destaque
		b.theme_type_variation = "PrimaryButton"
	b.custom_minimum_size.y = 38
	v.add_child(b)
	return p


## Selo de novidade: ponto pulsante + texto curto, na cor da estação.
func _notice_badge(text: String, accent: Color) -> Control:
	var pill := PanelContainer.new()
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var st := UiTheme.panel_style(accent.darkened(0.55), accent, 1, 10, 0)
	st.content_margin_left = 8
	st.content_margin_right = 10
	st.content_margin_top = 2
	st.content_margin_bottom = 2
	pill.add_theme_stylebox_override("panel", st)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	pill.add_child(h)
	var dot := IconView.create(&"unknown", accent.lightened(0.25), 10)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(dot)
	h.add_child(UiTheme.make_label(text, 13, Palette.BONE_LIGHT))
	var tw := dot.create_tween().set_loops()
	tw.tween_property(dot, "modulate:a", 0.25, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(dot, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	return pill


func _choose_region() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.02, 0.03, 0.88)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size.x = 720
	center.add_child(box)
	box.add_child(UiTheme.make_label("Escolha a região", 34, Palette.BONE_LIGHT, true))
	if RunState.has_save():
		box.add_child(UiTheme.make_label("Atenção: partir agora descarta a expedição salva.", 15, Palette.BLOOD_BRIGHT))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 500
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	for e in Database.get_sorted_expeditions():
		var unlocked := Profile.is_expedition_unlocked(e)
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.CHARCOAL, e.accent if unlocked else Palette.INK_SOFT, 2 if unlocked else 1, 8, 14))
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 16)
		p.add_child(h)
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(v)
		var cleared := " ✓" if Profile.cleared_expeditions.has(e.id) else ""
		v.add_child(UiTheme.make_label(e.display_name + cleared, 24, Palette.BONE_LIGHT if unlocked else Palette.TEXT_DIM, true))
		var d := UiTheme.make_label(e.description if unlocked else "Bloqueada: conclua %s." % _exp_name(e.unlock_requirement), 15, Palette.PAPER if unlocked else Palette.TEXT_DIM)
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(d)
		if unlocked:
			v.add_child(UiTheme.make_label("%d andares · chefe: %s" % [e.floors, e.boss.display_name if e.boss and Profile.is_monster_known(e.boss.id) else "???"], 13, Palette.TEXT_DIM))
		var b := UiTheme.make_button("Partir", func(): Game.start_expedition(e.id), 140)
		b.disabled = not unlocked
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(b)
		list.add_child(p)
	var cancel := UiTheme.make_button("Cancelar", overlay.queue_free, 200, "GhostButton")
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(cancel)


func _exp_name(id: StringName) -> String:
	var e: ExpeditionData = Database.expeditions.get(id)
	return e.display_name if e else String(id)


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
