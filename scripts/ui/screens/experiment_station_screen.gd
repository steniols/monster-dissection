extends Control
## Estação de Experimentação: combine duas partes de famílias diferentes para descobrir cartas híbridas.
## Combinações sem reação não consomem materiais.

var _slot_a: AnatomyPart
var _slot_b: AnatomyPart
var _shelf: GridContainer
var _slot_views: Array[SlotView] = []
var _result: VBoxContainer
var _notebook: VBoxContainer
var _try_btn: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Color("#1F2422"), "lab", 0.65) as BackgroundView
	bg.glow_color = Palette.MOSS
	bg.glow_center = Vector2(0.5, 0.35)

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
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	titles.add_child(UiTheme.make_label("Estação de Experimentação", 34, Palette.MOSS_BRIGHT, true))
	titles.add_child(UiTheme.make_label("Combine duas partes de espécies diferentes. Sem reação, nada é consumido.", 15, Palette.TEXT_DIM))
	top.add_child(UiTheme.back_button(func(): Game.goto("lab")))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	# Prateleira
	var shelf_panel := PanelContainer.new()
	shelf_panel.custom_minimum_size.x = 330
	body.add_child(shelf_panel)
	var sv := VBoxContainer.new()
	shelf_panel.add_child(sv)
	sv.add_child(UiTheme.make_label("Materiais", 18, Palette.BONE, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sv.add_child(scroll)
	_shelf = GridContainer.new()
	_shelf.columns = 2
	_shelf.add_theme_constant_override("h_separation", 6)
	_shelf.add_theme_constant_override("v_separation", 6)
	scroll.add_child(_shelf)

	# Bancada
	var bench := VBoxContainer.new()
	bench.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bench.alignment = BoxContainer.ALIGNMENT_CENTER
	bench.add_theme_constant_override("separation", 14)
	body.add_child(bench)
	var slots := HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	slots.add_theme_constant_override("separation", 16)
	bench.add_child(slots)
	for i in 2:
		var s := SlotView.new()
		s.custom_minimum_size = Vector2(150, 150)
		var idx := i
		s.clicked.connect(func(): _clear_slot(idx))
		_slot_views.append(s)
		slots.add_child(s)
		if i == 0:
			slots.add_child(UiTheme.make_label("+", 40, Palette.BONE, true))
	_try_btn = UiTheme.make_button("Experimentar", _experiment, 240)
	_try_btn.custom_minimum_size.y = 48
	_try_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bench.add_child(_try_btn)
	_result = VBoxContainer.new()
	_result.alignment = BoxContainer.ALIGNMENT_CENTER
	_result.add_theme_constant_override("separation", 8)
	_result.custom_minimum_size.y = 250
	bench.add_child(_result)

	# Caderno de receitas
	var note_panel := PanelContainer.new()
	note_panel.custom_minimum_size.x = 340
	note_panel.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.PAPER, Palette.INK_SOFT, 1, 4, 12))
	body.add_child(note_panel)
	var nv := VBoxContainer.new()
	note_panel.add_child(nv)
	nv.add_child(UiTheme.make_label("Caderno de receitas", 20, Palette.INK, true))
	var nscroll := ScrollContainer.new()
	nscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	nv.add_child(nscroll)
	_notebook = VBoxContainer.new()
	_notebook.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_notebook.add_theme_constant_override("separation", 8)
	nscroll.add_child(_notebook)
	_refresh()


func _refresh() -> void:
	for c in _shelf.get_children():
		c.queue_free()
	var ids: Array = Profile.materials.keys()
	ids.sort()
	if ids.is_empty():
		var l := UiTheme.make_label("Nenhum material. Disseque criaturas nas expedições.", 14, Palette.TEXT_DIM)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 300
		_shelf.add_child(l)
	for id in ids:
		var part := Database.get_part(id)
		if part == null:
			continue
		var available := Profile.get_material(id) - (1 if _slot_a == part else 0) - (1 if _slot_b == part else 0)
		var b := Button.new()
		b.text = "%s ×%d" % [part.display_name, Profile.get_material(id)]
		b.icon = null
		b.custom_minimum_size = Vector2(150, 40)
		b.add_theme_font_size_override("font_size", 14)
		b.add_theme_color_override("font_color", Family.get_color(part.family))
		b.tooltip_text = "%s (%s)\n%s" % [part.display_name, Family.get_name_of(part.family), part.description]
		b.disabled = available <= 0
		b.pressed.connect(_put.bind(part))
		_shelf.add_child(b)
	_slot_views[0].set_part(_slot_a)
	_slot_views[1].set_part(_slot_b)
	_try_btn.disabled = _slot_a == null or _slot_b == null

	for c in _notebook.get_children():
		c.queue_free()
	var found := 0
	for r: HybridRecipe in Database.recipes.values():
		var known := Profile.discovered_recipes.has(r.id)
		var l: Label
		if known:
			found += 1
			l = UiTheme.make_label("◆ %s + %s\n   → %s" % [r.part_a.display_name, r.part_b.display_name, r.result.display_name], 14, Palette.INK)
		else:
			l = UiTheme.make_label("◇ Pista: " + r.hint, 14, Palette.INK_SOFT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 300
		_notebook.add_child(l)
	_notebook.add_child(UiTheme.make_label("Descobertas: %d / %d" % [found, Database.recipes.size()], 14, Palette.BLOOD))


func _put(part: AnatomyPart) -> void:
	if _slot_a == null:
		_slot_a = part
	elif _slot_b == null:
		_slot_b = part
	else:
		_slot_b = part
	_clear_result()
	_refresh()


func _clear_slot(i: int) -> void:
	if i == 0:
		_slot_a = null
	else:
		_slot_b = null
	_refresh()


func _clear_result() -> void:
	for c in _result.get_children():
		c.queue_free()


func _experiment() -> void:
	_clear_result()
	if _slot_a == null or _slot_b == null:
		return
	if _slot_a.family == _slot_b.family:
		_message("Tecidos da mesma espécie apenas se fundem. Tente famílias diferentes.", Palette.BONE)
		Sfx.play(&"fail")
		return
	var r := Profile.experiment(_slot_a, _slot_b)
	if r == null:
		_message("Nenhuma reação. Os tecidos permanecem inertes (nada foi consumido).", Palette.TEXT_DIM)
		Sfx.play(&"fail")
		return
	Sfx.play(&"unlock")
	Fx.burst(self, _slot_views[0].global_position + Vector2(170, 75), Family.get_color(r.result.family), 30, 260)
	_message("Reação! Carta híbrida catalogada: %s" % r.result.display_name, Palette.MOSS_BRIGHT)
	var cv := CardView.create(r.result)
	cv.interactive = false
	cv.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_result.add_child(cv)
	cv.scale = Vector2(0.6, 0.6)
	cv.create_tween().tween_property(cv, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_slot_a = null
	_slot_b = null
	_refresh()


func _message(text: String, color: Color) -> void:
	var l := UiTheme.make_label(text, 17, color, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result.add_child(l)


class SlotView:
	extends PanelContainer
	signal clicked
	var _art: MotifArt
	var _label: Label

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tooltip_text = "Clique para esvaziar."
		var v := VBoxContainer.new()
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(v)
		_art = MotifArt.new()
		_art.custom_minimum_size = Vector2(120, 110)
		_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(_art)
		_label = UiTheme.make_label("Vazio", 14, Palette.TEXT_DIM)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(_label)

	func set_part(p: AnatomyPart) -> void:
		if p == null:
			_art.setup(&"", Palette.INK_SOFT)
			_label.text = "Vazio"
			_label.add_theme_color_override("font_color", Palette.TEXT_DIM)
		else:
			_art.setup(p.art_motif, Family.get_color(p.family), p.icon)
			_label.text = p.display_name
			_label.add_theme_color_override("font_color", Family.get_color(p.family))

	func _gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
