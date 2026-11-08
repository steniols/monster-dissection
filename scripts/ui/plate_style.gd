@tool
class_name PlateStyle
extends StyleBox
## Botão em "placa de latão": chapa com cantos chanfrados e leve degradê, borda escura,
## filete de latão por dentro, rebites nos cantos e sombra. Desenhado em vetor (nítido em qualquer escala).

## Cor da chapa em cima e embaixo (degradê vertical).
var top := Color("#3A332B")
var bottom := Color("#26211C")
## Borda externa escura.
var edge := Color("#0F0D0B")
## Filete interno e rebites.
var brass := Color("#AE8B52")
## Deslocamento vertical da chapa (negativo = levantada, positivo = afundada).
var lift := 0.0
## Altura da sombra sob a chapa (0 = sem sombra).
var shadow := 3.0
## Tamanho do chanfro dos cantos.
var chamfer := 4.0
var rivets := true
## Só texto: não desenha a chapa (estilo discreto).
var ghost := false
## Linha sob o texto no estilo discreto.
var underline := Color(0, 0, 0, 0)


func _init() -> void:
	content_margin_left = 16
	content_margin_right = 16
	content_margin_top = 9
	content_margin_bottom = 9


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	var rs := RenderingServer
	if ghost:
		if underline.a > 0.0:
			var y := rect.end.y - 6.0
			rs.canvas_item_add_line(to_canvas_item, Vector2(rect.position.x + 14, y), Vector2(rect.end.x - 14, y), underline, 1.5, true)
		return
	var r := Rect2(rect.position + Vector2(0, lift), rect.size)
	if shadow > 0.0:
		var sh := _chamfered(Rect2(r.position + Vector2(0, shadow), r.size), chamfer)
		rs.canvas_item_add_polygon(to_canvas_item, sh, PackedColorArray([Color(0, 0, 0, 0.38)]))
	# chapa com degradê vertical
	var pts := _chamfered(r, chamfer)
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bottom, clampf((p.y - r.position.y) / maxf(1.0, r.size.y), 0.0, 1.0)))
	rs.canvas_item_add_polygon(to_canvas_item, pts, cols)
	# brilho no topo
	rs.canvas_item_add_line(to_canvas_item, r.position + Vector2(chamfer + 1, 1.5), Vector2(r.end.x - chamfer - 1, r.position.y + 1.5),
		Color(1, 1, 1, 0.07), 1.0, true)
	# borda externa
	var outline := pts.duplicate()
	outline.append(pts[0])
	rs.canvas_item_add_polyline(to_canvas_item, outline, PackedColorArray([edge]), 1.5, true)
	# filete de latão
	var inner := _chamfered(r.grow(-3.5), maxf(1.0, chamfer - 2.0))
	inner.append(inner[0])
	rs.canvas_item_add_polyline(to_canvas_item, inner, PackedColorArray([Color(brass, brass.a * 0.75)]), 1.0, true)
	# rebites
	if rivets and r.size.x > 60 and r.size.y > 26:
		var k := 7.0
		for c in [r.position + Vector2(k, k), Vector2(r.end.x - k, r.position.y + k),
				Vector2(r.position.x + k, r.end.y - k), r.end - Vector2(k, k)]:
			rs.canvas_item_add_circle(to_canvas_item, c + Vector2(0, 0.5), 1.8, Color(0, 0, 0, 0.5))
			rs.canvas_item_add_circle(to_canvas_item, c, 1.5, brass)
			rs.canvas_item_add_circle(to_canvas_item, c - Vector2(0.4, 0.4), 0.6, brass.lightened(0.45))


static func _chamfered(r: Rect2, c: float) -> PackedVector2Array:
	var p := r.position
	var e := r.end
	return PackedVector2Array([
		Vector2(p.x + c, p.y), Vector2(e.x - c, p.y), Vector2(e.x, p.y + c), Vector2(e.x, e.y - c),
		Vector2(e.x - c, e.y), Vector2(p.x + c, e.y), Vector2(p.x, e.y - c), Vector2(p.x, p.y + c)])


## Gera os 4 estados (normal, hover, pressed, disabled) de uma variante.
## kind: "normal", "primary" (vermelho-sangue), "moss" (verde) ou "ghost" (só texto).
static func states(kind: String) -> Dictionary:
	var out := {}
	for state in ["normal", "hover", "pressed", "disabled"]:
		var s := PlateStyle.new()
		match kind:
			"primary":
				s.top = Color("#7E2E33")
				s.bottom = Color("#521D21")
				s.brass = Color("#D9B57A")
			"moss":
				s.top = Color("#3F5236")
				s.bottom = Color("#2A3825")
				s.brass = Color("#B9C98F")
			"ghost":
				s.ghost = true
		match state:
			"hover":
				s.top = s.top.lightened(0.12)
				s.bottom = s.bottom.lightened(0.08)
				s.brass = s.brass.lightened(0.3)
				s.lift = -1.5
				s.shadow = 4.5
				s.underline = Palette.BONE
			"pressed":
				s.top = s.bottom.darkened(0.15)
				s.bottom = s.bottom.darkened(0.05)
				s.lift = 1.0
				s.shadow = 0.0
				s.underline = Palette.BONE_LIGHT
			"disabled":
				s.top = Color("#2A2724")
				s.bottom = Color("#201E1C")
				s.brass = Color(Palette.INK_SOFT, 0.7)
				s.shadow = 1.5
				s.rivets = false
		# o texto acompanha a chapa
		s.content_margin_top += s.lift
		s.content_margin_bottom -= s.lift
		out[state] = s
	return out
