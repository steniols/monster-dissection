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
	## Trilha horizontal: o caminho anda da esquerda (início) para a direita (chefe).
	## As próximas escolhas aparecem como cartões grandes; o que está longe fica pequeno e enevoado.
	signal node_chosen(node: MapNode)

	enum Tier { CARD, MEDIUM, SMALL }

	var _buttons: Array[Control] = []
	var _reachable: Dictionary = {}
	var _col_x: PackedFloat32Array = []
	var _t := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_PASS
		resized.connect(_rebuild)
		_rebuild()

	func _process(d: float) -> void:
		_t += d
		queue_redraw()

	func _rebuild() -> void:
		for b in _buttons:
			b.queue_free()
		_buttons.clear()
		var available := RunState.get_available_nodes()
		_compute_reachable(available)
		_compute_columns()
		for row in RunState.map:
			for n: MapNode in row:
				var b := NodeButton.new()
				b.node = n
				b.available = available.has(n)
				b.is_current = n == RunState.current
				b.reachable = _reachable.has(n)
				b.tier = _tier(n, b.available)
				b.setup_size()
				b.position = _pos(n) - b.size * 0.5
				b.tooltip_text = _tooltip(n)
				b.chosen.connect(func(node): node_chosen.emit(node))
				add_child(b)
				_buttons.append(b)
		queue_redraw()

	func _tier(n: MapNode, is_available: bool) -> int:
		if is_available:
			return Tier.CARD
		var d := n.floor_index - RunState.get_floor()
		if n == RunState.current or n.type == MapNode.Type.BOSS or (d >= 1 and d <= 2 and _reachable.has(n)):
			return Tier.MEDIUM
		return Tier.SMALL

	## Largura de cada andar: as próximas escolhas ganham muito espaço; o passado e o futuro distante, pouco.
	func _compute_columns() -> void:
		var floors := RunState.map.size()
		var cur := RunState.get_floor()
		var weights: Array[float] = []
		var total := 0.0
		for f in floors:
			var d := f - cur
			var w := 0.5
			if d < 0:
				w = 0.45
			elif d == 0:
				w = 0.7
			elif d == 1:
				w = 2.1
			elif d == 2:
				w = 1.0
			if f == floors - 1:
				w = maxf(w, 1.0)
			weights.append(w)
			total += w
		_col_x.resize(floors)
		var margin := 40.0
		var usable := size.x - margin * 2.0
		var acc := 0.0
		for f in floors:
			_col_x[f] = margin + (acc + weights[f] * 0.5) / total * usable
			acc += weights[f]

	func _pos(n: MapNode) -> Vector2:
		var top := 70.0
		var h := size.y - 140.0
		var x: float = _col_x[n.floor_index] if n.floor_index < _col_x.size() else size.x * 0.5
		# a posição lateral sorteada pelo gerador vira a altura na trilha (espalhamento natural, sem grade)
		var y := top + h * clampf((n.position.x - 0.12) / 0.76, 0.0, 1.0)
		return Vector2(x, y)

	## Nós que ainda podem ser alcançados a partir das opções atuais.
	func _compute_reachable(available: Array) -> void:
		_reachable.clear()
		var frontier: Array = available.duplicate()
		for n in frontier:
			_reachable[n] = true
		while not frontier.is_empty():
			var n: MapNode = frontier.pop_back()
			var f := n.floor_index
			if f + 1 >= RunState.map.size():
				continue
			for j in n.links:
				var m: MapNode = RunState.map[f + 1][j]
				if not _reachable.has(m):
					_reachable[m] = true
					frontier.append(m)

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
		var cur := RunState.get_floor()
		# névoa sobre o futuro distante
		if cur + 3 < _col_x.size():
			var x0: float = (_col_x[cur + 2] + _col_x[cur + 3]) * 0.5 if cur + 2 >= 0 else 0.0
			var steps := 12
			for i in steps:
				var f := float(i) / steps
				var x := lerpf(x0, size.x, f)
				draw_rect(Rect2(x, 0, size.x - x, size.y), Color(Palette.CHARCOAL_DEEP, 0.045))
			for i in 7:
				var p := Vector2(lerpf(x0, size.x, fmod(i * 0.37 + _t * 0.01, 1.0)), size.y * (0.15 + 0.12 * i))
				draw_circle(p, 70.0 + 20.0 * sin(_t * 0.4 + i), Color(Palette.PAPER, 0.025))
		var available := RunState.get_available_nodes()
		for f in RunState.map.size() - 1:
			for n: MapNode in RunState.map[f]:
				for j in n.links:
					_draw_edge(n, RunState.map[f + 1][j], available)
		# trilha começando antes do primeiro andar
		if RunState.current == null:
			for n in available:
				_trail(Vector2(0, _pos(n).y), _pos(n), Color(Palette.BONE_LIGHT, 0.9), 3.0, false)

	func _draw_edge(n: MapNode, m: MapNode, available: Array) -> void:
		var p := _pos(n)
		var q := _pos(m)
		if n.visited and m.visited:
			_trail(p, q, Color(Palette.BONE, 0.85), 3.5, false)
		elif n == RunState.current and available.has(m):
			_trail(p, q, Palette.BONE_LIGHT, 3.5, false)
		elif _reachable.has(n) and _reachable.has(m):
			var far := m.floor_index - RunState.get_floor()
			_trail(p, q, Color(Palette.PAPER, 0.5 if far <= 2 else 0.22), 2.0, true)
		else:
			_trail(p, q, Color(Palette.PAPER, 0.08), 1.5, true)

	## Trilha curva (como um caminho de terra), com sombra por baixo.
	func _trail(a: Vector2, b: Vector2, col: Color, w: float, dashed: bool) -> void:
		var pts := PackedVector2Array()
		var steps := 24
		var c1 := Vector2(lerpf(a.x, b.x, 0.5), a.y)
		var c2 := Vector2(lerpf(a.x, b.x, 0.5), b.y)
		for i in steps + 1:
			var t := float(i) / steps
			var u := 1.0 - t
			pts.append(a * u * u * u + c1 * 3.0 * u * u * t + c2 * 3.0 * u * t * t + b * t * t * t)
		if not dashed:
			draw_polyline(pts, Color(0, 0, 0, col.a * 0.55), w + 4.0, true)
			draw_polyline(pts, col, w, true)
			return
		for i in range(0, steps, 2):
			draw_line(pts[i], pts[i + 1], Color(0, 0, 0, col.a * 0.5), w + 3.0, true)
			draw_line(pts[i], pts[i + 1], col, w, true)

	class NodeButton:
		extends Control
		signal chosen(node: MapNode)
		const CARD_SIZE := Vector2(250, 112)
		var node: MapNode
		var available := false
		var is_current := false
		var reachable := false
		var tier: int = 0
		var _t := 0.0
		var _hover := false

		func setup_size() -> void:
			if tier == 0:
				size = CARD_SIZE + Vector2(24, 24)
			elif tier == 1:
				size = Vector2(90, 90) if node.type == MapNode.Type.BOSS else Vector2(64, 64)
			else:
				size = Vector2(40, 40)
			mouse_filter = Control.MOUSE_FILTER_STOP

		func _ready() -> void:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW
			mouse_entered.connect(func(): _hover = true; queue_redraw())
			mouse_exited.connect(func(): _hover = false; queue_redraw())

		func _has_point(p: Vector2) -> bool:
			if tier == 0:
				return Rect2(Vector2(12, 12), CARD_SIZE).has_point(p)
			return p.distance_to(size * 0.5) <= size.x * 0.5

		func _process(d: float) -> void:
			if available or is_current:
				_t += d
				queue_redraw()

		func _gui_input(e: InputEvent) -> void:
			if available and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				chosen.emit(node)
				accept_event()

		static func type_color(t: MapNode.Type) -> Color:
			match t:
				MapNode.Type.ELITE:
					return Palette.BLOOD_BRIGHT
				MapNode.Type.EVENT:
					return Palette.VIOLET_BRIGHT
				MapNode.Type.REST:
					return Palette.MOSS_BRIGHT
				MapNode.Type.BOSS:
					return Palette.VIOLET_BRIGHT
			return Palette.BONE_LIGHT

		func _subtitle() -> String:
			match node.type:
				MapNode.Type.COMBAT:
					if node.monsters.size() > 1:
						return "Grupo de %d criaturas" % node.monsters.size()
					if node.monsters.is_empty():
						return "Uma criatura"
					return "Rastros de %s" % Family.get_name_of(node.monsters[0].family)
				MapNode.Type.ELITE:
					return "Elite com partes raras"
				MapNode.Type.EVENT:
					return "Pode ajudar ou ferir"
				MapNode.Type.REST:
					return "Descansar ou aprimorar"
				MapNode.Type.BOSS:
					if not node.monsters.is_empty() and Profile.is_monster_known(node.monsters[0].id):
						return node.monsters[0].display_name
					return "Desconhecido"
			return ""

		func _draw() -> void:
			if tier == 0:
				_draw_card()
			else:
				_draw_medallion()

		func _draw_card() -> void:
			var col := type_color(node.type)
			var lift := -6.0 if _hover else 0.0
			var r := Rect2(Vector2(12, 12 + lift), CARD_SIZE)
			var pulse := 0.5 + 0.5 * sin(_t * 3.0)
			for i in 3:
				_rounded(r.grow(4.0 + i * 4.0 + pulse * 2.0), 12.0 + i * 3.0, Color(col, (0.12 - i * 0.03) * (1.4 if _hover else 1.0)))
			_rounded(Rect2(r.position + Vector2(0, 5), r.size), 10.0, Color(0, 0, 0, 0.45))
			_rounded(r, 10.0, Palette.PAPER)
			# faixa do tipo à esquerda
			var band_col := Palette.CHARCOAL_DEEP.lerp(col, 0.18)
			var band := Rect2(r.position, Vector2(64, r.size.y))
			_rounded(band, 10.0, band_col)
			draw_rect(Rect2(band.position + Vector2(band.size.x - 10, 0), Vector2(10, band.size.y)), band_col)
			if not (node.type == MapNode.Type.BOSS and _boss_portrait(band.get_center(), 26.0, 1.0)):
				NodeIcon.draw_type(self, node.type, Rect2(band.get_center() - Vector2(20, 20), Vector2(40, 40)), 1.0)
			# texto
			var tf := UiTheme.title_font if UiTheme.title_font != null else ThemeDB.fallback_font
			var bf := UiTheme.body_font if UiTheme.body_font != null else ThemeDB.fallback_font
			var tx := r.position.x + 76
			var tw := r.size.x - 84
			draw_string(tf, Vector2(tx, r.position.y + 42), node.get_type_name(), HORIZONTAL_ALIGNMENT_LEFT, tw, 22, Palette.INK)
			draw_line(Vector2(tx, r.position.y + 52), Vector2(r.end.x - 10, r.position.y + 52), Color(col.darkened(0.3), 0.7), 1.5)
			draw_string(bf, Vector2(tx, r.position.y + 76), _subtitle(), HORIZONTAL_ALIGNMENT_LEFT, tw, 14, Palette.INK_SOFT)
			var hint_a := 0.55 + pulse * 0.45 if _hover else 0.55
			draw_string(bf, Vector2(tx, r.position.y + 100), "Clique para seguir", HORIZONTAL_ALIGNMENT_LEFT, tw, 12, Color(Palette.INK_SOFT, hint_a))
			_rounded_outline(r, 10.0, col.darkened(0.15), 3 if _hover else 2)

		func _draw_medallion() -> void:
			var c := size * 0.5
			var r := size.x * 0.5 - 3.0
			var col := type_color(node.type)
			var alpha := 1.0
			if node.visited and not is_current:
				alpha = 0.55
			elif not is_current:
				if node.type == MapNode.Type.BOSS:
					alpha = 0.95
				elif tier == 1:
					alpha = 0.85
				else:
					alpha = 0.55 if reachable else 0.2
			draw_circle(c + Vector2(0, 3), r + 1.0, Color(0, 0, 0, 0.5 * alpha))
			draw_circle(c, r, Color(Palette.CHARCOAL_DEEP.lerp(col, 0.15), alpha))
			if not (node.type == MapNode.Type.BOSS and _boss_portrait(c, r - 3.0, alpha)):
				var ir := r * 0.6
				NodeIcon.draw_type(self, node.type, Rect2(c - Vector2(ir, ir), Vector2(ir, ir) * 2.0), alpha)
			var rim := Palette.BONE_LIGHT if is_current else (Palette.BONE if node.visited else col)
			draw_arc(c, r, 0, TAU, 40, Color(rim, alpha), 3.0 if is_current else 2.0, true)
			if is_current:
				var bf := UiTheme.body_font if UiTheme.body_font != null else ThemeDB.fallback_font
				var w := bf.get_string_size("Você", HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
				draw_string(bf, Vector2(c.x - w * 0.5, size.y + 12), "Você", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.BONE_LIGHT)

		## Retrato do chefe recortado em círculo (só se o jogador já conhece o monstro).
		func _boss_portrait(c: Vector2, r: float, alpha: float) -> bool:
			if node.monsters.is_empty():
				return false
			var m: MonsterData = node.monsters[0]
			if m.portrait == null or not Profile.is_monster_known(m.id):
				return false
			var tex := m.portrait
			var ts := tex.get_size()
			var focus := m.region_anchors[0] if m.region_anchors.size() > 0 else Vector2(0.5, 0.4)
			var half := ts.y * 0.32
			var center_px := Vector2(clampf(focus.x * ts.x, half, ts.x - half), clampf(focus.y * ts.y, half, ts.y - half))
			var pts := PackedVector2Array()
			var uvs := PackedVector2Array()
			for i in 40:
				var d := Vector2(cos(TAU * i / 40.0), sin(TAU * i / 40.0))
				pts.append(c + d * r)
				uvs.append((center_px + d * half) / ts)
			draw_colored_polygon(pts, Color(1, 1, 1, alpha), uvs, tex)
			return true

		func _rounded(r: Rect2, rad: float, col: Color) -> void:
			var sb := StyleBoxFlat.new()
			sb.bg_color = col
			sb.set_corner_radius_all(int(rad))
			sb.anti_aliasing = true
			draw_style_box(sb, r)

		func _rounded_outline(r: Rect2, rad: float, col: Color, w: int) -> void:
			var sb := StyleBoxFlat.new()
			sb.draw_center = false
			sb.border_color = col
			sb.set_border_width_all(w)
			sb.set_corner_radius_all(int(rad))
			sb.anti_aliasing = true
			draw_style_box(sb, r)

	class NodeIcon:
		extends Control
		var type: MapNode.Type = MapNode.Type.COMBAT

		func _draw() -> void:
			var c := size * 0.5
			var col := NodeButton.type_color(type)
			draw_circle(c, size.x * 0.5, Palette.CHARCOAL_DEEP.lerp(col, 0.15))
			draw_arc(c, size.x * 0.5 - 1.0, 0, TAU, 32, col, 1.5, true)
			draw_type(self, type, Rect2(Vector2(5, 5), size - Vector2(10, 10)), 1.0)

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
					var font := UiTheme.title_font if UiTheme.title_font != null else ThemeDB.fallback_font
					var fs := int(r.size.y * 1.1)
					var w := font.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
					ci.draw_string(font, r.get_center() + Vector2(-w * 0.5, fs * 0.34), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Palette.VIOLET_BRIGHT.lightened(0.3), alpha))
