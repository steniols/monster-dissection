class_name BackgroundView
extends Control
## Fundo de tela: gradiente escuro, grão de papel e vinheta.

@export var base_color: Color = Palette.CHARCOAL
@export var grain: bool = true
@export var glow_color: Color = Color(0, 0, 0, 0)
@export var glow_center: Vector2 = Vector2(0.5, 0.4)

var _grain_points: PackedVector2Array = []


func _ready() -> void:
	resized.connect(_regen)
	_regen()


func _regen() -> void:
	_grain_points.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	for i in 900:
		_grain_points.append(Vector2(rng.randf() * size.x, rng.randf() * size.y))
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var top := base_color.lightened(0.04)
	var bottom := base_color.darkened(0.45)
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, 0), r.end, Vector2(0, r.end.y)]),
		PackedColorArray([top, top, bottom, bottom]))
	if glow_color.a > 0.0:
		var c := Vector2(size.x * glow_center.x, size.y * glow_center.y)
		var layers := 28
		for i in layers:
			var f := float(i) / layers
			draw_circle(c, size.y * (0.75 - f * 0.7), Color(glow_color, glow_color.a * 0.035))
	if grain:
		for i in _grain_points.size():
			draw_rect(Rect2(_grain_points[i], Vector2(1.5, 1.5)), Color(Palette.PAPER, 0.025 if i % 3 else 0.045))
	# vinheta nas bordas
	var edge := Color(0, 0, 0, 0.55)
	var clear := Color(0, 0, 0, 0)
	var w := size.x * 0.18
	var h := size.y * 0.22
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w, size.y), Vector2(0, size.y)]),
		PackedColorArray([edge, clear, clear, edge]))
	draw_polygon(PackedVector2Array([Vector2(size.x - w, 0), Vector2(size.x, 0), size, Vector2(size.x - w, size.y)]),
		PackedColorArray([clear, edge, edge, clear]))
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, h), Vector2(0, h)]),
		PackedColorArray([edge, edge, clear, clear]))
	draw_polygon(PackedVector2Array([Vector2(0, size.y - h), Vector2(size.x, size.y - h), size, Vector2(0, size.y)]),
		PackedColorArray([clear, clear, edge, edge]))
