extends Control
## Mapa ramificado da expedição.

var _canvas: MapCanvas


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if not RunState.active:
		RunState.start(Database.expeditions.get(Database.DEFAULT_EXPEDITION))
	RunState.save_run()
	var bg := UiTheme.add_background(self, Color("#22262A"), String(RunState.expedition.id) if RunState.expedition else "", 0.45) as BackgroundView
	bg.glow_color = Palette.PETROL
	bg.glow_center = Vector2(0.5, 0.5)

	_canvas = MapCanvas.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.offset_top = 96
	_canvas.offset_bottom = -56
	_canvas.node_chosen.connect(Game.enter_node)
	add_child(_canvas)

	_build_header()
	_build_legend()


func _build_header() -> void:
	# faixa escura no topo para o texto ler bem sobre a paisagem
	var shade := _gradient_rect(Color(0, 0, 0, 0.7), Color(0, 0, 0, 0.0))
	shade.set_anchors_preset(Control.PRESET_TOP_WIDE)
	shade.offset_bottom = 120
	add_child(shade)

	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 28
	top.offset_right = -28
	top.offset_top = 14
	top.add_theme_constant_override("separation", 14)
	add_child(top)

	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 0)
	top.add_child(titles)
	var exp_color := RunState.expedition.accent.lightened(0.35) if RunState.expedition else Palette.BONE_LIGHT
	titles.add_child(UiTheme.make_label(RunState.expedition.display_name, 36, Palette.BONE_LIGHT, true))
	var floors := RunState.map.size()
	var floor_now := clampi(RunState.get_floor() + 1, 1, maxi(1, floors))
	var hint := "Escolha o próximo destino." if not RunState.get_available_nodes().is_empty() else ""
	titles.add_child(UiTheme.make_label("Andar %d de %d   ·   %s" % [floor_now, floors, hint], 16, exp_color))

	# vida
	var hp_box := VBoxContainer.new()
	hp_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hp_box.add_theme_constant_override("separation", 2)
	top.add_child(hp_box)
	hp_box.add_child(UiTheme.make_label("Vida", 13, Palette.TEXT_DIM))
	var bar := HealthBar.new()
	bar.custom_minimum_size = Vector2(190, 22)
	hp_box.add_child(bar)
	bar.set_values(RunState.hp, RunState.max_hp, 0)

	top.add_child(_chip("Partes", str(_count_gathered()), Palette.MOSS_BRIGHT))
	var deck_btn := UiTheme.make_button("Baralho  %d" % RunState.deck.size(),
		func(): CardGridOverlay.open(self, "Baralho da expedição", RunState.get_deck_cards()))
	deck_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(deck_btn)
	var ab := UiTheme.make_button("Abandonar", _confirm_abandon)
	ab.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ab.modulate = Color(1, 1, 1, 0.8)
	top.add_child(ab)


func _build_legend() -> void:
	var shade := _gradient_rect(Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.6))
	shade.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	shade.offset_top = -70
	add_child(shade)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	row.offset_bottom = -14
	row.add_theme_constant_override("separation", 22)
	add_child(row)
	var tips := {
		MapNode.Type.COMBAT: "Uma criatura comum. Disseque o corpo depois da luta.",
		MapNode.Type.ELITE: "Covil: espécime de elite, mais forte, com partes raras.",
		MapNode.Type.EVENT: "Mistério: um encontro com escolhas. Pode ajudar ou ferir.",
		MapNode.Type.REST: "Acampamento: descansar, aprimorar uma carta ou purgar.",
		MapNode.Type.BOSS: "O chefe da região, no fim do caminho.",
	}
	for t in [MapNode.Type.COMBAT, MapNode.Type.ELITE, MapNode.Type.EVENT, MapNode.Type.REST, MapNode.Type.BOSS]:
		var item := HBoxContainer.new()
		item.add_theme_constant_override("separation", 6)
		item.mouse_filter = Control.MOUSE_FILTER_STOP
		item.tooltip_text = tips[t]
		var ic := MapCanvas.NodeIcon.new()
		ic.type = t
		ic.custom_minimum_size = Vector2(28, 28)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(ic)
		var l := UiTheme.make_label(MapNode.TYPE_NAMES[t], 15, Palette.PAPER)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(l)
		row.add_child(item)
	var saved := UiTheme.make_label("Progresso salvo a cada passo", 13, Palette.TEXT_DIM)
	row.add_child(saved)


func _chip(label: String, value: String, color: Color) -> Control:
	var v := VBoxContainer.new()
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.add_theme_constant_override("separation", 0)
	v.add_child(UiTheme.make_label(label, 13, Palette.TEXT_DIM))
	var val := UiTheme.make_label(value, 20, color)
	val.add_theme_font_override("font", UiTheme.number_font)
	v.add_child(val)
	return v


func _gradient_rect(from: Color, to: Color) -> TextureRect:
	var grad := Gradient.new()
	grad.set_color(0, from)
	grad.set_color(1, to)
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_to = Vector2(0, 1)
	tex.width = 4
	tex.height = 64
	var r := TextureRect.new()
	r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


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

	const MAX_WIDTH := 980.0

	var _buttons: Array[Control] = []
	var _reachable: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_PASS
		resized.connect(_rebuild)
		_rebuild()

	func _rebuild() -> void:
		for b in _buttons:
			b.queue_free()
		_buttons.clear()
		var available := RunState.get_available_nodes()
		_compute_reachable(available)
		for row in RunState.map:
			for n: MapNode in row:
				var b := NodeButton.new()
				b.node = n
				b.available = available.has(n)
				b.is_current = n == RunState.current
				b.reachable = _reachable.has(n)
				b.position = _pos(n) - b.size * 0.5
				b.tooltip_text = _tooltip(n)
				b.chosen.connect(func(node): node_chosen.emit(node))
				add_child(b)
				_buttons.append(b)
		queue_redraw()

	## Nós que ainda podem ser alcançados a partir das opções atuais.
	func _compute_reachable(available: Array) -> void:
		_reachable.clear()
		var frontier: Array = available.duplicate()
		for n in frontier:
			_reachable[n] = true
		while not frontier.is_empty():
			var n: MapNode = frontier.pop_back()
			var f := _floor_of(n)
			if f < 0 or f + 1 >= RunState.map.size():
				continue
			for j in n.links:
				var m: MapNode = RunState.map[f + 1][j]
				if not _reachable.has(m):
					_reachable[m] = true
					frontier.append(m)

	func _floor_of(n: MapNode) -> int:
		for f in RunState.map.size():
			if RunState.map[f].has(n):
				return f
		return -1

	func _area() -> Rect2:
		var w := minf(size.x - 120.0, MAX_WIDTH)
		return Rect2(Vector2((size.x - w) * 0.5, 40), Vector2(w, size.y - 80))

	func _pos(n: MapNode) -> Vector2:
		var a := _area()
		return a.position + n.position * a.size

	func _tooltip(n: MapNode) -> String:
		var t := n.get_type_name()
		if n.type == MapNode.Type.BOSS and not n.monsters.is_empty():
			t += ": " + (n.monsters[0].display_name if Profile.is_monster_known(n.monsters[0].id) else "???")
		elif n.is_combat() and not n.monsters.is_empty():
			t += " — rastros de %s" % Family.get_name_of(n.monsters[0].family)
			if n.monsters.size() > 1:
				t += " (grupo de %d)" % n.monsters.size()
		return t

	## Folha de papel onde o mapa é desenhado a tinta.
	func _paper_rect() -> Rect2:
		var a := _area()
		var r := a.grow_individual(80, 40, 80, 40)
		return r.intersection(Rect2(Vector2(0, 2), size - Vector2(0, 4)))

	func _draw() -> void:
		_draw_paper(_paper_rect())
		var available := RunState.get_available_nodes()
		for f in RunState.map.size() - 1:
			for n: MapNode in RunState.map[f]:
				for j in n.links:
					var m: MapNode = RunState.map[f + 1][j]
					_draw_edge(n, m, available)

	func _draw_paper(r: Rect2) -> void:
		# sombra da folha
		for i in 6:
			draw_rect(r.grow(10.0 - i * 1.6).grow_individual(0, 0, 0, 0) , Color(0, 0, 0, 0.07))
		draw_rect(r, Palette.PAPER)
		# manchas de idade
		var rng := RandomNumberGenerator.new()
		rng.seed = 4242
		for i in 14:
			var p := r.position + Vector2(rng.randf(), rng.randf()) * r.size
			draw_circle(p, rng.randf_range(30, 110), Color(Palette.BONE, rng.randf_range(0.04, 0.09)))
		# quadriculado, como nas cartas
		var step := 26.0
		var x := r.position.x + step
		while x < r.end.x:
			draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color(Palette.INK, 0.06), 1.0)
			x += step
		var y := r.position.y + step
		while y < r.end.y:
			draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color(Palette.INK, 0.06), 1.0)
			y += step
		# bordas queimadas pelo tempo
		for i in 10:
			draw_rect(r.grow(-i * 3.0), Color(Palette.INK_SOFT, 0.06 - i * 0.005), false, 3.0)
		# moldura de prancha
		draw_rect(r.grow(-14), Color(Palette.INK, 0.55), false, 2.0)
		draw_rect(r.grow(-19), Color(Palette.INK, 0.3), false, 1.0)
		_draw_compass(Vector2(r.end.x - 70, r.end.y - 70), 40.0)

	## Rosa dos ventos simples no canto da folha.
	func _draw_compass(c: Vector2, s: float) -> void:
		var ink := Color(Palette.INK, 0.5)
		draw_arc(c, s * 0.62, 0, TAU, 40, ink, 1.5, true)
		for k in 4:
			var ang := k * PI * 0.5 - PI * 0.5
			var d := Vector2(cos(ang), sin(ang))
			var side := Vector2(-d.y, d.x)
			var pts := PackedVector2Array([c + d * s, c + side * s * 0.16, c - side * s * 0.16])
			draw_colored_polygon(pts, Color(Palette.BLOOD, 0.75) if k == 0 else ink)
		var font := UiTheme.title_font if UiTheme.title_font != null else ThemeDB.fallback_font
		draw_string(font, c + Vector2(-5, -s - 4), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(Palette.INK, 0.7))

	func _draw_edge(n: MapNode, m: MapNode, available: Array) -> void:
		var p := _pos(n)
		var q := _pos(m)
		if n.visited and m.visited:
			_line(p, q, Color(Palette.BLOOD, 0.85), 3.5, false)
		elif n == RunState.current and available.has(m):
			_line(p, q, Palette.BLOOD, 3.0, true)
		elif _reachable.has(n) and _reachable.has(m) or (n == RunState.current and _reachable.has(m)):
			_line(p, q, Color(Palette.INK, 0.7), 2.0, true)
		else:
			_line(p, q, Color(Palette.INK, 0.2), 1.5, true)

	## Traço de tinta (contínuo ou tracejado).
	func _line(a: Vector2, b: Vector2, col: Color, w: float, dashed: bool) -> void:
		var dist := a.distance_to(b)
		var dir: Vector2 = (b - a) / maxf(1.0, dist)
		var gap := 30.0
		var s := a + dir * gap
		var e := b - dir * gap
		if dist <= gap * 2.0:
			return
		if not dashed:
			draw_line(s, e, col, w, true)
			return
		var d := 0.0
		var total := dist - gap * 2.0
		while d < total:
			draw_line(s + dir * d, s + dir * minf(d + 9.0, total), col, w, true)
			d += 15.0

	class NodeButton:
		extends Control
		signal chosen(node: MapNode)
		var node: MapNode
		var available := false
		var is_current := false
		var reachable := false
		var _t := 0.0
		var _hover := false

		func _init() -> void:
			size = Vector2(110, 110)
			mouse_filter = Control.MOUSE_FILTER_STOP

		func _ready() -> void:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW
			mouse_entered.connect(func(): _hover = true; queue_redraw())
			mouse_exited.connect(func(): _hover = false; queue_redraw())

		func _has_point(p: Vector2) -> bool:
			return p.distance_to(size * 0.5) <= _radius() + 4.0

		func _process(d: float) -> void:
			if available or is_current:
				_t += d
				queue_redraw()

		func _gui_input(e: InputEvent) -> void:
			if available and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				chosen.emit(node)
				accept_event()

		func _radius() -> float:
			var r := 40.0 if node.type == MapNode.Type.BOSS else (26.0 if node.type == MapNode.Type.ELITE else 23.0)
			if available and _hover:
				r *= 1.15
			return r

		## Cor de tinta de cada tipo de nó (sobre papel).
		static func type_color(t: MapNode.Type) -> Color:
			match t:
				MapNode.Type.ELITE: return Palette.BLOOD
				MapNode.Type.EVENT: return Palette.VIOLET
				MapNode.Type.REST: return Palette.MOSS.darkened(0.15)
				MapNode.Type.BOSS: return Palette.VIOLET
			return Palette.INK

		func _draw() -> void:
			var c := size * 0.5
			var r := _radius()
			var col := type_color(node.type)
			# opacidade: opções e caminho possível em destaque; o resto esmaecido, como lápis apagado
			var alpha := 1.0
			if not (available or node.visited or is_current):
				alpha = 0.8 if reachable else 0.35
			# círculos de tinta vermelha pulsando nas opções atuais
			if available:
				var pulse := 0.5 + 0.5 * sin(_t * 3.2)
				draw_arc(c, r + 7.0 + pulse * 3.0, 0, TAU, 48, Color(Palette.BLOOD, 0.55 + pulse * 0.3), 2.5, true)
				draw_arc(c, r + 13.0 + pulse * 4.0, 0, TAU, 48, Color(Palette.BLOOD, 0.2 + pulse * 0.15), 1.5, true)
			# medalhão de papel
			var fill := Palette.PAPER.lightened(0.1)
			if node.visited:
				fill = Palette.PAPER_DARK
			draw_circle(c + Vector2(1.5, 2.5), r, Color(Palette.INK, 0.18 * alpha))
			draw_circle(c, r, Color(fill, alpha))
			if node.type == MapNode.Type.BOSS and _draw_boss_portrait(c, r - 4.0, alpha):
				pass
			else:
				var icon_r := r * 0.62
				NodeIcon.draw_type(self, node.type, Rect2(c - Vector2(icon_r, icon_r), Vector2(icon_r, icon_r) * 2.0),
					alpha * (0.5 if node.visited and not is_current else 1.0))
			# aro de tinta
			var rim_w := 3.0 if available or is_current else 2.0
			var rim := Palette.BLOOD if available else (Palette.INK if node.visited else col)
			draw_arc(c, r, 0, TAU, 48, Color(rim, alpha), rim_w, true)
			if node.type == MapNode.Type.BOSS:
				draw_arc(c, r + 5.0, 0, TAU, 48, Color(col, 0.7 * alpha), 1.5, true)
			# visitado: risco de tinta, como item riscado da lista
			if node.visited and not is_current:
				draw_line(c + Vector2(-r * 0.55, r * 0.55), c + Vector2(r * 0.55, -r * 0.55), Color(Palette.BLOOD, 0.6), 2.5, true)
			# você está aqui
			if is_current:
				var bob := sin(_t * 2.5) * 2.0
				var tip := c + Vector2(0, -r - 6.0 + bob)
				var tri := PackedVector2Array([tip, tip + Vector2(-9, -15), tip + Vector2(9, -15)])
				draw_colored_polygon(tri, Palette.BLOOD)

		## Retrato do chefe recortado em círculo (só se o jogador já conhece o monstro).
		func _draw_boss_portrait(c: Vector2, r: float, alpha: float) -> bool:
			if node.monsters.is_empty():
				return false
			var m: MonsterData = node.monsters[0]
			if m.portrait == null or not Profile.is_monster_known(m.id):
				return false
			var tex := m.portrait
			var ts := tex.get_size()
			var focus := m.region_anchors[0] if m.region_anchors.size() > 0 else Vector2(0.5, 0.4)
			var half := ts.y * 0.32 # recorte quadrado em volta da cabeça
			var center_px := Vector2(clampf(focus.x * ts.x, half, ts.x - half), clampf(focus.y * ts.y, half, ts.y - half))
			var pts := PackedVector2Array()
			var uvs := PackedVector2Array()
			for i in 40:
				var ang := TAU * i / 40.0
				var d := Vector2(cos(ang), sin(ang))
				pts.append(c + d * r)
				uvs.append((center_px + d * half) / ts)
			draw_colored_polygon(pts, Color(1, 1, 1, alpha), uvs, tex)
			return true

	class NodeIcon:
		extends Control
		var type: MapNode.Type = MapNode.Type.COMBAT

		func _draw() -> void:
			var c := size * 0.5
			var col := NodeButton.type_color(type)
			draw_circle(c, size.x * 0.5, Palette.PAPER.lightened(0.1))
			draw_arc(c, size.x * 0.5 - 1.0, 0, TAU, 32, col, 1.5, true)
			draw_type(self, type, Rect2(Vector2(5, 5), size - Vector2(10, 10)), 1.0)

		## Ícone do tipo, em tinta escura (feito para fundo de papel).
		static func draw_type(ci: CanvasItem, t: MapNode.Type, r: Rect2, alpha: float) -> void:
			match t:
				MapNode.Type.COMBAT:
					ProceduralArt.draw_icon(ci, &"attack", r, Color(Palette.INK, alpha))
				MapNode.Type.ELITE:
					ProceduralArt.draw_motif(ci, &"fang", r, Color(Palette.BLOOD, alpha))
				MapNode.Type.REST:
					ProceduralArt.draw_icon(ci, &"energy", r, Color(Palette.MOSS.darkened(0.15), alpha))
				MapNode.Type.BOSS:
					ProceduralArt.draw_motif(ci, &"eye", r, Color(Palette.VIOLET, alpha))
				MapNode.Type.EVENT:
					var font := UiTheme.title_font if UiTheme.title_font != null else ThemeDB.fallback_font
					var fs := int(r.size.y * 1.1)
					var w := font.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
					ci.draw_string(font, r.get_center() + Vector2(-w * 0.5, fs * 0.34), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Palette.VIOLET, alpha))
