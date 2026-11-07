extends Control
## Mapa ramificado da expedição.

var _canvas: MapCanvas


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if not RunState.active:
		RunState.start(Database.expeditions.get(Database.DEFAULT_EXPEDITION))
	RunState.save_run()
	var bg := UiTheme.add_background(self, Color("#22262A")) as BackgroundView
	bg.glow_color = Palette.PETROL
	bg.glow_center = Vector2(0.5, 0.5)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_right = -24
	root.offset_top = 14
	root.offset_bottom = -14
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 18)
	root.add_child(top)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	titles.add_child(UiTheme.make_label(RunState.expedition.display_name, 30, Palette.BONE_LIGHT, true))
	var hint := "Escolha o próximo destino." if not RunState.get_available_nodes().is_empty() else ""
	titles.add_child(UiTheme.make_label(hint, 15, Palette.TEXT_DIM))
	var stats := UiTheme.make_label("Vida %d/%d   ·   Baralho %d   ·   Partes coletadas %d" % [RunState.hp, RunState.max_hp, RunState.deck.size(), _count_gathered()], 16, Palette.PAPER)
	top.add_child(stats)
	top.add_child(UiTheme.make_button("Baralho", func(): CardGridOverlay.open(self, "Baralho da expedição", RunState.get_deck_cards())))
	top.add_child(UiTheme.make_button("Abandonar", _confirm_abandon))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	_canvas = MapCanvas.new()
	_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.node_chosen.connect(Game.enter_node)
	body.add_child(_canvas)

	var legend := PanelContainer.new()
	legend.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	legend.custom_minimum_size.x = 220
	body.add_child(legend)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 8)
	legend.add_child(lv)
	lv.add_child(UiTheme.make_label("Legenda", 17, Palette.BONE, true))
	for t in [MapNode.Type.COMBAT, MapNode.Type.ELITE, MapNode.Type.EVENT, MapNode.Type.REST, MapNode.Type.BOSS]:
		var row := HBoxContainer.new()
		var ic := MapCanvas.NodeIcon.new()
		ic.type = t
		ic.custom_minimum_size = Vector2(30, 30)
		row.add_child(ic)
		row.add_child(UiTheme.make_label(MapNode.TYPE_NAMES[t], 15, Palette.PAPER))
		lv.add_child(row)
	var desc := UiTheme.make_label("Covis abrigam espécimes de elite com partes raras. Mistérios podem ajudar ou ferir. Acampamentos permitem descansar, aprimorar ou purgar. O progresso é salvo a cada passo.", 13, Palette.TEXT_DIM)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(desc)


func _count_gathered() -> int:
	var n := 0
	for k in RunState.gathered:
		n += int(RunState.gathered[k])
	return n


func _confirm_abandon() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Abandonar expedição"
	d.dialog_text = "Retornar agora ao laboratório?\nVocê perde metade dos materiais desta expedição."
	d.ok_button_text = "Abandonar"
	d.cancel_button_text = "Continuar explorando"
	d.confirmed.connect(func(): Game.finish_run(false))
	add_child(d)
	d.popup_centered()


class MapCanvas:
	extends Control
	signal node_chosen(node: MapNode)

	var _buttons: Array[Control] = []

	func _ready() -> void:
		resized.connect(_rebuild)
		_rebuild()

	func _rebuild() -> void:
		for b in _buttons:
			b.queue_free()
		_buttons.clear()
		var available := RunState.get_available_nodes()
		for row in RunState.map:
			for n: MapNode in row:
				var b := NodeButton.new()
				b.node = n
				b.available = available.has(n)
				b.is_current = n == RunState.current
				b.position = _pos(n) - b.size * 0.5
				b.tooltip_text = _tooltip(n)
				b.chosen.connect(func(node): node_chosen.emit(node))
				add_child(b)
				_buttons.append(b)
		queue_redraw()

	func _pos(n: MapNode) -> Vector2:
		var margin := Vector2(40, 30)
		return margin + n.position * (size - margin * 2.0)

	func _tooltip(n: MapNode) -> String:
		var t := n.get_type_name()
		if n.type == MapNode.Type.BOSS and not n.monsters.is_empty():
			t += ": " + (n.monsters[0].display_name if Profile.is_monster_known(n.monsters[0].id) else "???")
		elif n.is_combat() and not n.monsters.is_empty():
			t += " — rastros de %s" % Family.get_name_of(n.monsters[0].family)
			if n.monsters.size() > 1:
				t += " (grupo de %d)" % n.monsters.size()
		return t

	func _draw() -> void:
		for f in RunState.map.size() - 1:
			for n: MapNode in RunState.map[f]:
				for j in n.links:
					var m: MapNode = RunState.map[f + 1][j]
					var walked := n.visited and m.visited
					var col := Palette.BONE if walked else Color(Palette.PAPER, 0.18)
					_dashed(_pos(n), _pos(m), col, 3.0 if walked else 2.0)

	func _dashed(a: Vector2, b: Vector2, col: Color, w: float) -> void:
		var dist := a.distance_to(b)
		var dir: Vector2 = (b - a) / maxf(1.0, dist)
		var d := 22.0
		while d < dist - 22.0:
			draw_line(a + dir * d, a + dir * min(d + 7.0, dist - 22.0), col, w, true)
			d += 13.0

	class NodeButton:
		extends Control
		signal chosen(node: MapNode)
		var node: MapNode
		var available := false
		var is_current := false
		var _t := 0.0

		func _init() -> void:
			size = Vector2(44, 44)
			mouse_filter = Control.MOUSE_FILTER_STOP

		func _ready() -> void:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW

		func _process(d: float) -> void:
			if available:
				_t += d
				queue_redraw()

		func _gui_input(e: InputEvent) -> void:
			if available and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				chosen.emit(node)
				accept_event()

		func _draw() -> void:
			var c := size * 0.5
			var r := 20.0 if node.type != MapNode.Type.BOSS else 22.0
			var bg := Palette.CHARCOAL_DEEP
			if node.visited:
				bg = Palette.PANEL_LIGHT
			if available:
				var pulse := 0.5 + 0.5 * sin(_t * 3.5)
				draw_circle(c, r + 6 + pulse * 3, Color(Palette.BONE_LIGHT, 0.12 + pulse * 0.1))
			draw_circle(c, r, bg)
			var rim := Palette.BONE_LIGHT if available else (Palette.BONE if node.visited else Palette.INK_SOFT)
			draw_arc(c, r, 0, TAU, 32, rim, 3.0 if is_current or available else 1.5, true)
			NodeIcon.draw_type(self, node.type, Rect2(c - Vector2(12, 12), Vector2(24, 24)), 1.0 if available or node.visited else 0.45)

	class NodeIcon:
		extends Control
		var type: MapNode.Type = MapNode.Type.COMBAT

		func _draw() -> void:
			draw_circle(size * 0.5, size.x * 0.5, Palette.CHARCOAL_DEEP)
			draw_type(self, type, Rect2(Vector2(4, 4), size - Vector2(8, 8)), 1.0)

		static func draw_type(ci: CanvasItem, t: MapNode.Type, r: Rect2, alpha: float) -> void:
			match t:
				MapNode.Type.COMBAT:
					ProceduralArt.draw_icon(ci, &"attack", r, Color(Palette.PAPER, alpha))
				MapNode.Type.ELITE:
					ProceduralArt.draw_motif(ci, &"fang", r, Color(Palette.BLOOD_BRIGHT, alpha))
				MapNode.Type.REST:
					ProceduralArt.draw_icon(ci, &"energy", r, Color(Palette.MOSS_BRIGHT, alpha))
				MapNode.Type.BOSS:
					ProceduralArt.draw_motif(ci, &"eye", r, Color(Palette.VIOLET_BRIGHT, alpha))
				MapNode.Type.EVENT:
					var font := ThemeDB.fallback_font
					var fs := int(r.size.y * 1.05)
					var w := font.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
					ci.draw_string(font, r.get_center() + Vector2(-w * 0.5, fs * 0.36), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Palette.BONE_LIGHT, alpha))
