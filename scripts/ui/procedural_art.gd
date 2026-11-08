class_name ProceduralArt
extends RefCounted
## Arte provisória desenhada em código (silhuetas, órgãos e ícones).
## Todas as funções recebem o CanvasItem que está executando _draw().
## Quando a arte final existir, os Resources usam Texture2D e isto vira só fallback.

# --- Geometria --------------------------------------------------------------

static func fit_box(rect: Rect2, aspect: float) -> Rect2:
	var w := rect.size.x
	var h := rect.size.y
	if h <= 0.0 or w <= 0.0:
		return rect
	if w / h > aspect:
		w = h * aspect
	else:
		h = w / aspect
	return Rect2(rect.position + (rect.size - Vector2(w, h)) * 0.5, Vector2(w, h))


static func _p(box: Rect2, x: float, y: float) -> Vector2:
	return box.position + Vector2(x * box.size.x, y * box.size.y)


static func _poly(box: Rect2, coords: Array) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for c in coords:
		pts.append(_p(box, c[0], c[1]))
	return pts


static func _ellipse(center: Vector2, r: Vector2, n: int = 24, a0: float = 0.0, a1: float = TAU) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var full := is_equal_approx(a1 - a0, TAU)
	var steps := n if full else n + 1
	for i in steps:
		var a := a0 + (a1 - a0) * float(i) / float(n)
		pts.append(center + Vector2(cos(a) * r.x, sin(a) * r.y))
	return pts


static func _blob(center: Vector2, r: Vector2, seed: float, n: int = 28, wobble: float = 0.12) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * float(i) / float(n)
		var k := 1.0 + wobble * sin(3.0 * a + seed) + wobble * 0.6 * sin(5.0 * a + seed * 1.7)
		pts.append(center + Vector2(cos(a) * r.x, sin(a) * r.y) * k)
	return pts


static func _fill(ci: CanvasItem, pts: PackedVector2Array, color: Color) -> void:
	if pts.size() >= 3:
		ci.draw_colored_polygon(pts, color)


static func _outline(ci: CanvasItem, pts: PackedVector2Array, color: Color, width: float = 2.0) -> void:
	if pts.size() < 2:
		return
	var closed := pts.duplicate()
	closed.append(pts[0])
	ci.draw_polyline(closed, color, width, true)


static func _limb(ci: CanvasItem, box: Rect2, coords: Array, color: Color, width_frac: float) -> void:
	var pts := _poly(box, coords)
	var w := box.size.x * width_frac
	ci.draw_polyline(pts, color, w, true)
	for p in pts:
		ci.draw_circle(p, w * 0.5, color)


static func _glow(ci: CanvasItem, center: Vector2, radius: float, color: Color, layers: int = 4) -> void:
	for i in layers:
		var k := 1.0 - float(i) / float(layers)
		ci.draw_circle(center, radius * (0.4 + k * 0.6), Color(color, 0.07 + 0.05 * (1.0 - k)))


# --- Monstros ---------------------------------------------------------------

const MONSTER_ASPECT := 1.3

## Pontos (normalizados na caixa do monstro) de cada região anatômica.
const REGION_ANCHORS := {
	&"bloodfang": [Vector2(0.19, 0.45), Vector2(0.58, 0.50), Vector2(0.33, 0.82), Vector2(0.36, 0.47)],
	&"bloodfang_alpha": [Vector2(0.19, 0.45), Vector2(0.58, 0.50), Vector2(0.33, 0.82), Vector2(0.36, 0.47)],
	&"ironback": [Vector2(0.15, 0.56), Vector2(0.52, 0.44), Vector2(0.44, 0.82), Vector2(0.80, 0.56)],
	&"voidspawn": [Vector2(0.44, 0.40), Vector2(0.52, 0.52), Vector2(0.38, 0.82), Vector2(0.64, 0.64)],
	&"void_matriarch": [Vector2(0.50, 0.17), Vector2(0.50, 0.50), Vector2(0.30, 0.84), Vector2(0.68, 0.62)],
	&"rotwalker": [Vector2(0.37, 0.33), Vector2(0.55, 0.45), Vector2(0.31, 0.72), Vector2(0.50, 0.57)],
	&"ghoul": [Vector2(0.27, 0.62), Vector2(0.57, 0.63), Vector2(0.43, 0.84), Vector2(0.68, 0.68)],
}


static func region_anchor(visual: StringName, region: int, rect: Rect2) -> Vector2:
	var box := fit_box(rect, MONSTER_ASPECT)
	var list: Array = REGION_ANCHORS.get(visual, REGION_ANCHORS[&"bloodfang"])
	var v: Vector2 = list[clampi(region, 0, list.size() - 1)]
	return _p(box, v.x, v.y)


static func draw_monster(ci: CanvasItem, visual: StringName, rect: Rect2, t: float = 0.0) -> void:
	var box := fit_box(rect, MONSTER_ASPECT)
	# sombra no chão
	_fill(ci, _ellipse(_p(box, 0.5, 0.9), Vector2(box.size.x * 0.4, box.size.y * 0.05)), Color(0, 0, 0, 0.35))
	match visual:
		&"bloodfang":
			_bloodfang(ci, box, t, false)
		&"bloodfang_alpha":
			_bloodfang(ci, box, t, true)
		&"ironback":
			_ironback(ci, box, t)
		&"voidspawn":
			_voidspawn(ci, box, t, false)
		&"void_matriarch":
			_voidspawn(ci, box, t, true)
		&"rotwalker":
			_rotwalker(ci, box, t)
		&"ghoul":
			_ghoul(ci, box, t)
		_:
			_fill(ci, _blob(_p(box, 0.5, 0.5), box.size * 0.3, 1.0), Palette.FLESH)


static func _bloodfang(ci: CanvasItem, box: Rect2, t: float, alpha: bool) -> void:
	var body_c := Color("#5B2B2C") if not alpha else Color("#4A2022")
	var dark := Color("#2E1517")
	var bone := Palette.BONE_LIGHT
	var eye := Color("#FF6A5E")
	var br := sin(t * 2.2) * 0.006
	# patas traseiras (fundo)
	_limb(ci, box, [[0.74, 0.58], [0.80, 0.72], [0.77, 0.87]], dark, 0.045)
	_limb(ci, box, [[0.42, 0.60], [0.38, 0.74], [0.41, 0.87]], dark, 0.045)
	# cauda
	ci.draw_polyline(_poly(box, [[0.84, 0.50], [0.92, 0.45], [0.96, 0.37], [0.99, 0.31]]), body_c, box.size.x * 0.02, true)
	# corpo
	var body := _poly(box, [[0.30, 0.38 - br], [0.46, 0.31 - br], [0.62, 0.38], [0.78, 0.43], [0.87, 0.50],
		[0.84, 0.61], [0.66, 0.65], [0.46, 0.67], [0.32, 0.62]])
	_fill(ci, body, body_c)
	_outline(ci, body, dark, 2.0)
	for i in 4:
		ci.draw_line(_p(box, 0.45 + i * 0.065, 0.40), _p(box, 0.43 + i * 0.065, 0.61), Color(dark, 0.8), 2.0)
	ci.draw_polyline(_poly(box, [[0.33, 0.46], [0.45, 0.42], [0.55, 0.47], [0.67, 0.45], [0.78, 0.50]]),
		Color(Palette.BLOOD_BRIGHT, 0.55), 1.5, true)
	if alpha:
		for i in 8:
			var x := 0.30 + i * 0.07
			var y := lerpf(0.37, 0.46, float(i) / 7.0) - br
			_fill(ci, _poly(box, [[x - 0.022, y + 0.01], [x + 0.022, y + 0.01], [x + 0.008, y - 0.09 + (i % 2) * 0.03]]), dark)
		# cicatrizes
		for i in 3:
			ci.draw_line(_p(box, 0.52 + i * 0.06, 0.47), _p(box, 0.56 + i * 0.06, 0.55), Palette.BONE.darkened(0.2), 2.0)
	# patas dianteiras
	_limb(ci, box, [[0.69, 0.58], [0.72, 0.73], [0.70, 0.88]], body_c, 0.05)
	_limb(ci, box, [[0.35, 0.56], [0.31, 0.72], [0.34, 0.88]], body_c, 0.055)
	for foot: Vector2 in [Vector2(0.70, 0.89), Vector2(0.34, 0.89)]:
		for k in 3:
			var fx := foot.x - 0.025 + k * 0.022
			_fill(ci, _poly(box, [[fx, foot.y - 0.01], [fx + 0.012, foot.y - 0.01], [fx - 0.008, foot.y + 0.03]]), bone)
	# orelha
	_fill(ci, _poly(box, [[0.25, 0.33], [0.30, 0.19], [0.33, 0.34]]), dark)
	# cabeça
	var head := _poly(box, [[0.07, 0.40], [0.17, 0.30], [0.31, 0.31], [0.37, 0.42], [0.33, 0.54], [0.20, 0.57], [0.06, 0.50]])
	_fill(ci, head, body_c.lightened(0.06))
	_outline(ci, head, dark, 2.0)
	# mandíbula
	var jaw := _poly(box, [[0.05, 0.52], [0.22, 0.555], [0.30, 0.60], [0.24, 0.67], [0.10, 0.63]])
	_fill(ci, jaw, dark)
	for i in 6:
		var x := 0.07 + i * 0.036
		_fill(ci, _poly(box, [[x, 0.515], [x + 0.02, 0.52], [x + 0.01, 0.565]]), bone)
	# presas externas
	_fill(ci, _poly(box, [[0.105, 0.52], [0.14, 0.52], [0.10, 0.68]]), bone)
	_fill(ci, _poly(box, [[0.20, 0.54], [0.235, 0.55], [0.215, 0.69]]), bone)
	# olho
	var ep := _p(box, 0.20, 0.39)
	_glow(ci, ep, box.size.x * 0.035, eye)
	ci.draw_circle(ep, box.size.x * 0.011, eye)


static func _ironback(ci: CanvasItem, box: Rect2, t: float) -> void:
	var moss := Color("#4F6046")
	var moss_l := Color("#6E8160")
	var grey := Color("#555B57")
	var dark := Color("#262B27")
	var rust := Color("#8A5A3A")
	var br := sin(t * 1.6) * 0.004
	# patas traseiras
	for i in 3:
		var x := 0.32 + i * 0.2
		_limb(ci, box, [[x, 0.60], [x + 0.06, 0.70], [x + 0.03, 0.87]], dark, 0.03)
	# placas (de trás para frente)
	for i in 4:
		var cx := 0.80 - i * 0.15
		var center := _p(box, cx, 0.64)
		var r := Vector2(box.size.x * (0.14 - i * 0.005), box.size.y * (0.30 - abs(i - 1.5) * 0.03 + br * 3.0))
		var arc := _ellipse(center, r, 18, PI, TAU)
		_fill(ci, arc, moss if i % 2 == 0 else grey)
		ci.draw_polyline(arc, rust, 3.0, true)
		ci.draw_polyline(_ellipse(center, r * 0.75, 14, PI * 1.15, PI * 1.85), Color(moss_l, 0.7), 2.0, true)
		# espinho
		var top := center + Vector2(0, -r.y)
		_fill(ci, PackedVector2Array([top + Vector2(-6, 2), top + Vector2(6, 2), top + Vector2(0, -box.size.y * 0.05)]), dark)
	# barriga
	_fill(ci, _poly(box, [[0.25, 0.63], [0.92, 0.63], [0.88, 0.69], [0.30, 0.69]]), dark)
	# patas dianteiras
	for i in 3:
		var x := 0.28 + i * 0.2
		_limb(ci, box, [[x, 0.64], [x - 0.05, 0.74], [x - 0.02, 0.88]], grey.darkened(0.2), 0.035)
	# cabeça
	var hc := _p(box, 0.17, 0.57)
	var head := _ellipse(hc, Vector2(box.size.x * 0.09, box.size.y * 0.11), 20)
	_fill(ci, head, grey.darkened(0.15))
	_outline(ci, head, dark, 2.0)
	# chifres curtos
	_fill(ci, _poly(box, [[0.15, 0.47], [0.19, 0.47], [0.14, 0.38]]), Palette.BONE)
	_fill(ci, _poly(box, [[0.20, 0.48], [0.24, 0.49], [0.23, 0.40]]), Palette.BONE)
	# mandíbulas
	ci.draw_polyline(_poly(box, [[0.11, 0.62], [0.05, 0.66], [0.04, 0.72], [0.08, 0.74]]), rust, box.size.x * 0.018, true)
	ci.draw_polyline(_poly(box, [[0.16, 0.66], [0.13, 0.72], [0.15, 0.78], [0.19, 0.78]]), rust, box.size.x * 0.018, true)
	# olhos
	for e in [Vector2(0.12, 0.54), Vector2(0.17, 0.52)]:
		var p := _p(box, e.x, e.y)
		_glow(ci, p, box.size.x * 0.02, Color("#D7E07A"), 3)
		ci.draw_circle(p, box.size.x * 0.008, Color("#D7E07A"))


static func _voidspawn(ci: CanvasItem, box: Rect2, t: float, matriarch: bool) -> void:
	var violet := Color("#3E2B4E")
	var violet_l := Color("#5D4475")
	var dark := Color("#1D1526")
	var cold := Palette.PETROL_BRIGHT
	var center := _p(box, 0.5, 0.48 if not matriarch else 0.50)
	_glow(ci, center, box.size.x * (0.32 if not matriarch else 0.42), Palette.VIOLET_BRIGHT, 5)
	# tentáculos
	var count := 6 if not matriarch else 9
	for i in count:
		var base_x := lerpf(0.30, 0.70, float(i) / float(count - 1))
		var pts := PackedVector2Array()
		var segs := 12
		for k in segs:
			var f := float(k) / float(segs - 1)
			var sway := sin(t * 1.8 + i * 1.3 + f * 4.0) * 0.035 * f
			var spread := (base_x - 0.5) * f * 0.6
			pts.append(_p(box, base_x + sway + spread, 0.58 + f * (0.32 if not matriarch else 0.34)))
		for k in segs - 1:
			var w := lerpf(box.size.x * 0.03, 2.0, float(k) / float(segs - 1))
			ci.draw_line(pts[k], pts[k + 1], violet if i % 2 == 0 else violet_l, w, true)
	# corpo
	var r := Vector2(box.size.x * 0.22, box.size.y * 0.22)
	if matriarch:
		r = Vector2(box.size.x * 0.28, box.size.y * 0.27)
	var body := _blob(center, r, 2.1 + sin(t) * 0.1, 32, 0.12)
	_fill(ci, body, violet)
	_outline(ci, body, dark, 3.0)
	_fill(ci, _blob(center + Vector2(r.x * 0.15, r.y * 0.2), r * 0.6, 4.0, 24, 0.15), violet_l.darkened(0.25))
	if matriarch:
		# núcleo pulsante
		var pulse := 0.85 + sin(t * 3.0) * 0.15
		_glow(ci, center + Vector2(0, r.y * 0.15), box.size.x * 0.09 * pulse, cold, 5)
		ci.draw_circle(center + Vector2(0, r.y * 0.15), box.size.x * 0.03 * pulse, cold.lightened(0.4))
		# coroa de olhos em hastes
		for i in 7:
			var a := lerpf(PI * 1.15, PI * 1.85, float(i) / 6.0)
			var stalk_base := center + Vector2(cos(a) * r.x * 0.8, sin(a) * r.y * 0.85)
			var tip := center + Vector2(cos(a) * r.x * 1.25, sin(a) * r.y * 1.45) + Vector2(sin(t * 2.0 + i) * 4.0, 0)
			ci.draw_line(stalk_base, tip, violet_l, 4.0, true)
			_eye(ci, tip, box.size.x * (0.022 + (i % 3) * 0.006), t + i)
	# olhos assimétricos
	var eyes := [Vector3(0.43, 0.42, 0.055), Vector3(0.58, 0.37, 0.032), Vector3(0.62, 0.51, 0.042),
		Vector3(0.37, 0.54, 0.028), Vector3(0.52, 0.58, 0.022), Vector3(0.49, 0.31, 0.018)]
	if matriarch:
		eyes = [Vector3(0.42, 0.44, 0.05), Vector3(0.60, 0.42, 0.04), Vector3(0.36, 0.56, 0.03), Vector3(0.64, 0.58, 0.028)]
	for i in eyes.size():
		var e: Vector3 = eyes[i]
		_eye(ci, _p(box, e.x, e.y), box.size.x * e.z, t * 0.7 + i * 1.9)


static func _rotwalker(ci: CanvasItem, box: Rect2, t: float) -> void:
	var skin := Color("#6E7458")
	var skin_l := Color("#8A8F70")
	var dark := Color("#30352A")
	var bone := Palette.BONE_LIGHT
	var sway := sin(t * 1.3) * 0.01
	# perna de trás e braço de trás
	_limb(ci, box, [[0.58, 0.58], [0.64, 0.73], [0.62, 0.88]], dark, 0.035)
	_limb(ci, box, [[0.61, 0.37], [0.70, 0.52 + sway], [0.67, 0.68 + sway]], dark, 0.03)
	# trapos
	for i in 4:
		var x := 0.45 + i * 0.05
		_fill(ci, _poly(box, [[x, 0.58], [x + 0.04, 0.58], [x + 0.02 + sin(t * 2.0 + i) * 0.01, 0.74 + (i % 2) * 0.04]]), Color("#2A2620"))
	# tronco curvado
	var torso := _poly(box, [[0.42, 0.33], [0.57, 0.29], [0.66, 0.42], [0.63, 0.58], [0.48, 0.61], [0.42, 0.49]])
	_fill(ci, torso, skin)
	_outline(ci, torso, dark, 2.0)
	# costelas expostas
	_fill(ci, _poly(box, [[0.50, 0.40], [0.60, 0.39], [0.61, 0.53], [0.51, 0.54]]), Color("#3A2A26"))
	for i in 4:
		var y := 0.41 + i * 0.035
		ci.draw_polyline(_poly(box, [[0.50, y], [0.56, y - 0.01], [0.61, y + 0.005]]), bone, 2.5, true)
	# perna da frente
	_limb(ci, box, [[0.50, 0.58], [0.45, 0.73], [0.48, 0.88]], skin.darkened(0.1), 0.04)
	_fill(ci, _poly(box, [[0.44, 0.88], [0.53, 0.88], [0.53, 0.9], [0.43, 0.9]]), dark)
	# braço longo pendente com garras
	_limb(ci, box, [[0.45, 0.36], [0.36, 0.54 - sway], [0.31, 0.74 - sway]], skin_l.darkened(0.15), 0.032)
	var hand := _p(box, 0.31, 0.75 - sway)
	for k in 3:
		ci.draw_line(hand, hand + Vector2(-6 + k * 6, 14 + k * 2), bone, 2.0, true)
	# cabeça caída para frente
	var hc := _p(box, 0.37, 0.33)
	var head := _ellipse(hc, Vector2(box.size.x * 0.055, box.size.y * 0.075), 18)
	_fill(ci, head, skin_l)
	_outline(ci, head, dark, 2.0)
	# mandíbula pendurada
	_fill(ci, _poly(box, [[0.33, 0.37], [0.40, 0.38], [0.38, 0.45], [0.34, 0.44]]), dark)
	for k in 3:
		var x := 0.34 + k * 0.018
		_fill(ci, _poly(box, [[x, 0.375], [x + 0.01, 0.375], [x + 0.005, 0.395]]), bone)
	var ep := _p(box, 0.355, 0.315)
	_glow(ci, ep, box.size.x * 0.025, Color("#C9D86A"), 3)
	ci.draw_circle(ep, box.size.x * 0.008, Color("#E2EE8A"))
	# moscas
	for i in 5:
		var a := t * (2.0 + i * 0.4) + i * 1.7
		var fp := _p(box, 0.45 + cos(a) * 0.08, 0.25 + sin(a * 1.3) * 0.05)
		ci.draw_circle(fp, 1.6, Color(0.05, 0.05, 0.05, 0.9))


static func _ghoul(ci: CanvasItem, box: Rect2, t: float) -> void:
	var skin := Color("#8A8F7A")
	var dark := Color("#3B3F33")
	var bone := Palette.BONE_LIGHT
	var crawl := sin(t * 3.0) * 0.012
	# membros de trás (fundo)
	_limb(ci, box, [[0.66, 0.66], [0.74, 0.52 + crawl], [0.80, 0.86]], dark, 0.025)
	_limb(ci, box, [[0.42, 0.66], [0.40, 0.50 - crawl], [0.34, 0.86]], dark, 0.025)
	# corpo
	var body := _ellipse(_p(box, 0.56, 0.66), Vector2(box.size.x * 0.2, box.size.y * 0.075), 22)
	_fill(ci, body, skin)
	_outline(ci, body, dark, 2.0)
	for i in 6:
		var p := _p(box, 0.42 + i * 0.05, 0.595 + absf(i - 2.5) * 0.006)
		ci.draw_circle(p, box.size.x * 0.008, skin.darkened(0.3))
	# membros da frente
	_limb(ci, box, [[0.62, 0.68], [0.66, 0.54 - crawl], [0.70, 0.87]], skin.darkened(0.15), 0.028)
	_limb(ci, box, [[0.46, 0.68], [0.48, 0.55 + crawl], [0.44, 0.87]], skin.darkened(0.15), 0.028)
	# cabeça grande
	var hc := _p(box, 0.28, 0.62 + crawl * 0.5)
	var head := _blob(hc, Vector2(box.size.x * 0.085, box.size.y * 0.1), 0.6, 20, 0.06)
	_fill(ci, head, skin.lightened(0.05))
	_outline(ci, head, dark, 2.0)
	# boca larga com dentes
	var m0 := hc + Vector2(-box.size.x * 0.06, box.size.y * 0.03)
	var m1 := hc + Vector2(box.size.x * 0.04, box.size.y * 0.04)
	ci.draw_line(m0, m1, dark, 4.0, true)
	for k in 6:
		var p := m0.lerp(m1, (k + 0.5) / 6.0)
		ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-3, -2), p + Vector2(3, -2), p + Vector2(0, 5)]), bone)
	for e in [Vector2(-0.035, -0.03), Vector2(0.01, -0.035)]:
		var ep: Vector2 = hc + Vector2(box.size.x * e.x, box.size.y * e.y)
		ci.draw_circle(ep, box.size.x * 0.012, Color("#141410"))
		ci.draw_circle(ep, box.size.x * 0.004, Color("#D8E07A"))


static func _eye(ci: CanvasItem, p: Vector2, radius: float, phase: float) -> void:
	var blink := clampf(absf(sin(phase * 0.9)) * 6.0, 0.15, 1.0)
	_fill(ci, _ellipse(p, Vector2(radius, radius * blink), 18), Color("#D8E4E0"))
	ci.draw_circle(p, radius * 0.6 * min(1.0, blink + 0.2), Palette.PETROL_BRIGHT)
	_fill(ci, _ellipse(p, Vector2(radius * 0.18, radius * 0.5 * blink), 10), Color("#0D0A12"))


static func draw_hunter(ci: CanvasItem, rect: Rect2, t: float = 0.0) -> void:
	var box := fit_box(rect, 0.8)
	var cloak := Color("#2C2A2E")
	var cloak_l := Color("#3F3B3D")
	_fill(ci, _ellipse(_p(box, 0.5, 0.95), Vector2(box.size.x * 0.35, box.size.y * 0.03)), Color(0, 0, 0, 0.35))
	# capa
	_fill(ci, _poly(box, [[0.5, 0.25], [0.86, 0.95], [0.14, 0.95]]), cloak)
	_fill(ci, _poly(box, [[0.5, 0.30], [0.66, 0.95], [0.34, 0.95]]), cloak_l)
	# alça e bolsa de instrumentos
	ci.draw_line(_p(box, 0.36, 0.42), _p(box, 0.70, 0.78), Palette.BONE.darkened(0.4), 3.0)
	_fill(ci, _poly(box, [[0.62, 0.70], [0.78, 0.70], [0.76, 0.84], [0.64, 0.84]]), Color("#4A3A2C"))
	# capuz
	var hood := _ellipse(_p(box, 0.5, 0.26), Vector2(box.size.x * 0.17, box.size.y * 0.15), 24)
	_fill(ci, hood, cloak_l)
	_fill(ci, _ellipse(_p(box, 0.5, 0.28), Vector2(box.size.x * 0.11, box.size.y * 0.1), 20), Color("#121114"))
	# lentes
	for x in [0.455, 0.545]:
		var p := _p(box, x, 0.28)
		_glow(ci, p, box.size.x * 0.03, Palette.BONE_LIGHT, 3)
		ci.draw_circle(p, box.size.x * 0.016, Palette.BONE_LIGHT.lightened(0.2))
	# lanterna
	var lp := _p(box, 0.24, 0.66 + sin(t * 1.5) * 0.005)
	ci.draw_line(_p(box, 0.30, 0.55), lp, Palette.INK_SOFT, 2.0)
	_glow(ci, lp, box.size.x * 0.1, Palette.MOSS_BRIGHT, 5)
	ci.draw_rect(Rect2(lp - Vector2(6, 8), Vector2(12, 16)), Palette.MOSS_BRIGHT.lightened(0.2))
	ci.draw_rect(Rect2(lp - Vector2(6, 8), Vector2(12, 16)), Palette.INK, false, 2.0)


# --- Motivos anatômicos (cartas, partes, mutações) --------------------------

static func draw_motif(ci: CanvasItem, motif: StringName, rect: Rect2, accent: Color) -> void:
	var box := fit_box(rect, 1.0)
	var ink := Palette.INK
	var bone := Palette.BONE_LIGHT
	var c := _p(box, 0.5, 0.5)
	var s := box.size.x
	match motif:
		&"scalpel":
			_scalpel(ci, box, Vector2(0.2, 0.8), Vector2(0.82, 0.18), accent)
		&"double_scalpel":
			_scalpel(ci, box, Vector2(0.18, 0.78), Vector2(0.80, 0.22), accent)
			_scalpel(ci, box, Vector2(0.82, 0.78), Vector2(0.20, 0.22), accent.darkened(0.2))
		&"incision":
			_scalpel(ci, box, Vector2(0.18, 0.75), Vector2(0.72, 0.2), accent)
			_drop(ci, _p(box, 0.68, 0.66), s * 0.13, Palette.BLOOD_BRIGHT)
		&"guard":
			var sh := _poly(box, [[0.5, 0.12], [0.82, 0.24], [0.78, 0.58], [0.5, 0.88], [0.22, 0.58], [0.18, 0.24]])
			_fill(ci, sh, accent.darkened(0.3))
			_outline(ci, sh, ink, 3.0)
			ci.draw_line(_p(box, 0.5, 0.18), _p(box, 0.5, 0.80), Color(bone, 0.6), 3.0)
			ci.draw_line(_p(box, 0.26, 0.38), _p(box, 0.74, 0.38), Color(bone, 0.6), 3.0)
		&"notes":
			var l := _poly(box, [[0.12, 0.25], [0.48, 0.30], [0.48, 0.80], [0.12, 0.75]])
			var r := _poly(box, [[0.52, 0.30], [0.88, 0.25], [0.88, 0.75], [0.52, 0.80]])
			_fill(ci, l, bone)
			_fill(ci, r, bone.darkened(0.08))
			_outline(ci, l, ink, 2.0)
			_outline(ci, r, ink, 2.0)
			for i in 5:
				var y := 0.38 + i * 0.07
				ci.draw_line(_p(box, 0.17, y), _p(box, 0.43, y + 0.02), Color(ink, 0.5), 1.5)
			ci.draw_circle(_p(box, 0.70, 0.50), s * 0.1, Color(accent, 0.5))
			_outline(ci, _ellipse(_p(box, 0.70, 0.50), Vector2(s * 0.1, s * 0.1), 18), ink, 1.5)
		&"fang":
			for f in [[0.32, 1.0], [0.62, 0.8]]:
				var x: float = f[0]
				var k: float = f[1]
				var fang := _poly(box, [[x - 0.09 * k, 0.15], [x + 0.09 * k, 0.15], [x + 0.06 * k, 0.45], [x + 0.01, 0.15 + 0.7 * k], [x - 0.05 * k, 0.45]])
				_fill(ci, fang, bone)
				_outline(ci, fang, ink, 2.0)
			_drop(ci, _p(box, 0.33, 0.88), s * 0.06, accent)
		&"claw":
			for i in 3:
				var x := 0.28 + i * 0.2
				var pts := PackedVector2Array()
				for k in 10:
					var f := float(k) / 9.0
					pts.append(_p(box, x + sin(f * 1.6) * 0.12, 0.15 + f * 0.7))
				for k in 9:
					ci.draw_line(pts[k], pts[k + 1], bone, lerpf(s * 0.07, 2.0, float(k) / 9.0), true)
				_outline(ci, pts, Color(ink, 0.0), 1.0)
			ci.draw_line(_p(box, 0.15, 0.6), _p(box, 0.85, 0.35), Color(accent, 0.8), 3.0)
		&"heart":
			var h := _blob(c + Vector2(0, s * 0.05), Vector2(s * 0.26, s * 0.3), 0.8, 28, 0.08)
			_fill(ci, h, accent.darkened(0.15))
			_outline(ci, h, ink, 2.5)
			ci.draw_line(_p(box, 0.42, 0.28), _p(box, 0.36, 0.08), accent.darkened(0.3), s * 0.07)
			ci.draw_line(_p(box, 0.56, 0.26), _p(box, 0.64, 0.06), Palette.PETROL, s * 0.06)
			ci.draw_polyline(_poly(box, [[0.38, 0.45], [0.48, 0.55], [0.44, 0.7], [0.54, 0.78]]), Color(bone, 0.5), 2.0, true)
		&"hide":
			var p := _poly(box, [[0.2, 0.2], [0.4, 0.14], [0.6, 0.16], [0.82, 0.24], [0.86, 0.5], [0.78, 0.82], [0.5, 0.88], [0.22, 0.8], [0.14, 0.5]])
			_fill(ci, p, accent.darkened(0.35))
			_outline(ci, p, ink, 2.5)
			for i in 6:
				var y := 0.28 + i * 0.1
				ci.draw_line(_p(box, 0.48, y), _p(box, 0.54, y + 0.03), bone, 2.0)
		&"blood":
			_drop(ci, c + Vector2(0, s * 0.05), s * 0.3, accent)
		&"eye":
			_fill(ci, _ellipse(c, Vector2(s * 0.38, s * 0.22), 28), bone)
			ci.draw_circle(c, s * 0.15, accent)
			_fill(ci, _ellipse(c, Vector2(s * 0.03, s * 0.12), 12), ink)
			_outline(ci, _ellipse(c, Vector2(s * 0.38, s * 0.22), 28), ink, 2.5)
			for i in 5:
				var a := PI * 1.1 + i * 0.2
				ci.draw_line(c + Vector2(cos(a), sin(a)) * s * 0.3, c + Vector2(cos(a), sin(a)) * s * 0.42, ink, 2.0)
		&"carapace":
			for i in 3:
				var center := _p(box, 0.5, 0.78 - i * 0.16)
				var arc := _ellipse(center, Vector2(s * (0.38 - i * 0.05), s * 0.3), 18, PI, TAU)
				_fill(ci, arc, accent.darkened(0.3 - i * 0.1))
				ci.draw_polyline(arc, ink, 2.5, true)
		&"mandible":
			for sgn in [-1.0, 1.0]:
				var pts := PackedVector2Array()
				for k in 12:
					var f := float(k) / 11.0
					pts.append(c + Vector2(sgn * (s * 0.3 - sin(f * PI * 0.9) * s * 0.22), -s * 0.32 + f * s * 0.64))
				for k in 11:
					ci.draw_line(pts[k], pts[k + 1], accent, lerpf(s * 0.1, 3.0, float(k) / 11.0), true)
		&"gland":
			var g := _blob(c, Vector2(s * 0.25, s * 0.3), 1.4, 24, 0.07)
			_fill(ci, g, Color(accent, 0.85))
			_outline(ci, g, ink, 2.5)
			ci.draw_circle(c + Vector2(-s * 0.08, -s * 0.1), s * 0.06, Color(1, 1, 1, 0.3))
			_drop(ci, _p(box, 0.5, 0.88), s * 0.06, accent.lightened(0.2))
		&"plates":
			for i in 4:
				var r := Rect2(_p(box, 0.18 + i * 0.05, 0.18 + i * 0.16), Vector2(s * 0.55, s * 0.18))
				ci.draw_rect(r, accent.darkened(0.25 - i * 0.05))
				ci.draw_rect(r, ink, false, 2.0)
		&"ribs":
			ci.draw_line(_p(box, 0.5, 0.12), _p(box, 0.5, 0.88), bone, s * 0.05)
			for i in 5:
				var y := 0.22 + i * 0.13
				var w := 0.3 - absf(i - 2) * 0.04
				ci.draw_polyline(_poly(box, [[0.5, y], [0.5 - w, y + 0.06], [0.5 - w * 0.8, y + 0.14]]), bone, 3.5, true)
				ci.draw_polyline(_poly(box, [[0.5, y], [0.5 + w, y + 0.06], [0.5 + w * 0.8, y + 0.14]]), bone, 3.5, true)
			ci.draw_circle(c, s * 0.08, Color(accent, 0.6))
		&"tentacle":
			var pts := PackedVector2Array()
			for k in 26:
				var f := float(k) / 25.0
				var a := f * TAU * 1.1
				var rad := s * (0.36 - f * 0.28)
				pts.append(c + Vector2(cos(a), sin(a)) * rad + Vector2(0, s * 0.02))
			for k in 25:
				ci.draw_line(pts[k], pts[k + 1], accent, lerpf(s * 0.11, 3.0, float(k) / 25.0), true)
			for k in range(2, 20, 4):
				ci.draw_circle(pts[k], s * 0.02, bone)
		&"core":
			_glow(ci, c, s * 0.42, accent, 6)
			for i in 8:
				var a := TAU * i / 8.0
				ci.draw_line(c + Vector2(cos(a), sin(a)) * s * 0.18, c + Vector2(cos(a), sin(a)) * s * 0.4, Color(accent, 0.6), 2.0)
			ci.draw_circle(c, s * 0.15, accent)
			ci.draw_circle(c, s * 0.07, accent.lightened(0.5))
		&"crown":
			ci.draw_arc(c + Vector2(0, s * 0.25), s * 0.36, PI * 1.1, PI * 1.9, 24, accent.darkened(0.3), s * 0.06, true)
			for i in 5:
				var a := lerpf(PI * 1.15, PI * 1.85, i / 4.0)
				var p := c + Vector2(0, s * 0.25) + Vector2(cos(a), sin(a)) * s * 0.36
				_fill(ci, _ellipse(p, Vector2(s * 0.07, s * 0.05), 14), bone)
				ci.draw_circle(p, s * 0.03, accent)
		&"tendon":
			for i in 5:
				var off := (i - 2) * 0.05
				ci.draw_polyline(_poly(box, [[0.2, 0.3 + off], [0.4, 0.45 + off * 0.5], [0.6, 0.5 + off * 0.5], [0.82, 0.68 + off]]),
					accent.lerp(bone, i * 0.15), 3.5, true)
			ci.draw_circle(_p(box, 0.2, 0.3), s * 0.06, bone)
			ci.draw_circle(_p(box, 0.82, 0.68), s * 0.06, bone)
		&"brain":
			var b := _blob(c, Vector2(s * 0.34, s * 0.26), 2.2, 28, 0.06)
			_fill(ci, b, Palette.FLESH.lerp(accent, 0.3))
			_outline(ci, b, ink, 2.5)
			ci.draw_line(c + Vector2(0, -s * 0.24), c + Vector2(0, s * 0.22), Color(ink, 0.6), 2.0)
			for i in 6:
				var a0 := Vector2(-0.28 + (i % 3) * 0.1, -0.12 + (i / 3) * 0.16)
				ci.draw_polyline(PackedVector2Array([c + a0 * s, c + (a0 + Vector2(0.04, 0.04)) * s, c + (a0 + Vector2(0.08, -0.01)) * s]),
					Color(ink, 0.5), 2.0, true)
				ci.draw_polyline(PackedVector2Array([c + Vector2(-a0.x, a0.y) * s, c + Vector2(-a0.x - 0.04, a0.y + 0.04) * s, c + Vector2(-a0.x - 0.08, a0.y - 0.01) * s]),
					Color(ink, 0.5), 2.0, true)
		&"horn":
			var pts := PackedVector2Array()
			for k in 14:
				var f := k / 13.0
				pts.append(c + Vector2(-s * 0.3 + f * s * 0.55, s * 0.3 - sin(f * 2.2) * s * 0.55))
			for k in 13:
				ci.draw_line(pts[k], pts[k + 1], bone.darkened(k * 0.02), lerpf(s * 0.2, 3.0, k / 13.0), true)
			for k in range(1, 9, 2):
				var n := (pts[k + 1] - pts[k]).normalized().orthogonal()
				ci.draw_line(pts[k] - n * s * 0.07, pts[k] + n * s * 0.07, Color(ink, 0.4), 1.5)
			ci.draw_circle(pts[0], s * 0.1, accent.darkened(0.3))
		&"suture":
			ci.draw_polyline(_poly(box, [[0.15, 0.6], [0.35, 0.45], [0.55, 0.55], [0.85, 0.35]]), Palette.FLESH.darkened(0.3), maxf(2.0, s * 0.06), true)
			for i in 7:
				var f := 0.15 + i * 0.1
				var y := 0.55 - i * 0.03
				ci.draw_line(_p(box, f - 0.03, y - 0.06), _p(box, f + 0.03, y + 0.06), ink, 2.0, true)
			_drop(ci, _p(box, 0.72, 0.72), s * 0.06, accent)
		&"flesh":
			var f := _blob(c, Vector2(s * 0.32, s * 0.24), 3.3, 24, 0.12)
			_fill(ci, f, Palette.FLESH)
			_outline(ci, f, ink, 2.5)
			ci.draw_polyline(_poly(box, [[0.3, 0.5], [0.45, 0.45], [0.6, 0.55], [0.72, 0.48]]), accent, 2.5, true)
		_:
			ci.draw_circle(c, s * 0.25, accent)


static func _scalpel(ci: CanvasItem, box: Rect2, from: Vector2, to: Vector2, accent: Color) -> void:
	var a := _p(box, from.x, from.y)
	var b := _p(box, to.x, to.y)
	var dir := (b - a).normalized()
	var n := Vector2(-dir.y, dir.x)
	var mid := a.lerp(b, 0.55)
	ci.draw_line(a, mid, Palette.INK_SOFT, box.size.x * 0.06, true)
	var blade := PackedVector2Array([mid + n * 5.0, mid - n * 3.0, b, mid + n * 9.0 + dir * box.size.x * 0.2])
	_fill(ci, blade, Color("#C8CCC9"))
	_outline(ci, blade, Palette.INK, 1.5)
	ci.draw_line(mid + n * 4.0, b - n * 1.0, accent, 1.5, true)


static func _drop(ci: CanvasItem, center: Vector2, radius: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 21:
		var a := lerpf(-0.25 * PI, 1.25 * PI, i / 20.0)
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	pts.append(center + Vector2(0, -radius * 2.0))
	_fill(ci, pts, color)
	_outline(ci, pts, Palette.INK, 1.5)
	ci.draw_circle(center + Vector2(-radius * 0.35, -radius * 0.2), radius * 0.2, Color(1, 1, 1, 0.35))


# --- Ícones de interface ----------------------------------------------------

static func draw_icon(ci: CanvasItem, icon: StringName, rect: Rect2, color: Color) -> void:
	var box := fit_box(rect, 1.0)
	var c := box.get_center()
	var s := box.size.x
	match icon:
		&"heart":
			var pts := PackedVector2Array()
			for i in 32:
				var tt := TAU * i / 32.0
				var x := 16.0 * pow(sin(tt), 3)
				var y := -(13.0 * cos(tt) - 5.0 * cos(2 * tt) - 2.0 * cos(3 * tt) - cos(4 * tt))
				pts.append(c + Vector2(x, y) * s / 36.0)
			_fill(ci, pts, color)
		&"shield":
			var sh := PackedVector2Array([c + Vector2(0, -s * 0.45), c + Vector2(s * 0.4, -s * 0.3), c + Vector2(s * 0.35, s * 0.1),
				c + Vector2(0, s * 0.47), c + Vector2(-s * 0.35, s * 0.1), c + Vector2(-s * 0.4, -s * 0.3)])
			_fill(ci, sh, color)
			_outline(ci, sh, Palette.CHARCOAL_DEEP, 1.5)
		&"energy":
			_glow(ci, c, s * 0.5, color, 3)
			ci.draw_circle(c, s * 0.36, color)
			ci.draw_circle(c, s * 0.2, color.lightened(0.4))
		&"attack":
			for i in 3:
				var x := -0.25 + i * 0.25
				var pts := PackedVector2Array()
				for k in 8:
					var f := k / 7.0
					pts.append(c + Vector2((x + sin(f * 1.4) * 0.15) * s, (-0.4 + f * 0.8) * s))
				for k in 7:
					ci.draw_line(pts[k], pts[k + 1], color, lerpf(s * 0.14, 2.0, k / 7.0), true)
		&"buff":
			var arrow := PackedVector2Array([c + Vector2(0, -s * 0.45), c + Vector2(s * 0.38, 0), c + Vector2(s * 0.15, 0),
				c + Vector2(s * 0.15, s * 0.45), c + Vector2(-s * 0.15, s * 0.45), c + Vector2(-s * 0.15, 0), c + Vector2(-s * 0.38, 0)])
			_fill(ci, arrow, color)
		&"debuff":
			var pts := PackedVector2Array()
			for k in 30:
				var f := k / 29.0
				var a := f * TAU * 1.6
				pts.append(c + Vector2(cos(a), sin(a)) * s * 0.45 * (1.0 - f * 0.85))
			ci.draw_polyline(pts, color, s * 0.1, true)
		&"defend":
			draw_icon(ci, &"shield", rect, color)
		&"card":
			var back := Rect2(c + Vector2(-s * 0.22, -s * 0.44), Vector2(s * 0.5, s * 0.7))
			ci.draw_set_transform(c, 0.25, Vector2.ONE)
			ci.draw_rect(Rect2(back.position - c, back.size), color.darkened(0.45))
			ci.draw_set_transform(c, -0.12, Vector2.ONE)
			var front := Rect2(Vector2(-s * 0.3, -s * 0.38), Vector2(s * 0.5, s * 0.72))
			ci.draw_rect(front, color)
			ci.draw_rect(front.grow(-s * 0.07), Palette.CHARCOAL_DEEP, false, maxf(1.0, s * 0.04))
			ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		&"vial":
			var neck := Rect2(c + Vector2(-s * 0.09, -s * 0.46), Vector2(s * 0.18, s * 0.3))
			ci.draw_rect(neck, color.darkened(0.3))
			ci.draw_rect(Rect2(c + Vector2(-s * 0.13, -s * 0.5), Vector2(s * 0.26, s * 0.09)), Palette.BONE)
			ci.draw_circle(c + Vector2(0, s * 0.14), s * 0.32, color.darkened(0.3))
			ci.draw_circle(c + Vector2(0, s * 0.18), s * 0.25, color)
			ci.draw_circle(c + Vector2(-s * 0.09, s * 0.08), s * 0.06, color.lightened(0.5))
		&"unknown":
			ci.draw_circle(c, s * 0.4, color)
		_:
			ci.draw_circle(c, s * 0.3, color)
