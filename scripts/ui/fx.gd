class_name Fx
extends RefCounted
## Efeitos de impacto: partículas, hit-stop e tremor. Respeitam Settings.impact_fx.

static var _hit_stop_active := false


static func enabled() -> bool:
	var s: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("/root/Settings")
	return s == null or s.impact_fx


## Explosão curta de partículas (ex.: sangue, fragmentos de armadura).
static func burst(parent: Node, global_pos: Vector2, color: Color, amount: int = 18, speed: float = 240.0) -> void:
	if not enabled() or parent == null:
		return
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 0.92
	p.amount = amount
	p.lifetime = 0.6
	p.direction = Vector2(0, -1)
	p.spread = 140.0
	p.gravity = Vector2(0, 520)
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.scale_amount_min = 2.0
	p.scale_amount_max = 5.0
	p.color = color
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0.0))
	p.color_ramp = ramp
	p.z_index = 60
	parent.add_child(p)
	p.global_position = global_pos
	p.emitting = true
	p.finished.connect(p.queue_free)


## Congela o jogo por um instante para dar peso ao golpe.
static func hit_stop(duration: float = 0.07) -> void:
	if not enabled() or _hit_stop_active:
		return
	_hit_stop_active = true
	var tree := Engine.get_main_loop() as SceneTree
	var prev := Engine.time_scale
	Engine.time_scale = prev * 0.05
	await tree.create_timer(duration, true, false, true).timeout
	Engine.time_scale = prev
	_hit_stop_active = false


## Tremor rápido de um Control (posição retorna à original).
static func shake(node: CanvasItem, strength: float = 8.0, duration: float = 0.25) -> void:
	if not enabled() or node == null:
		return
	var base: Vector2 = node.position
	var tw := node.create_tween()
	var steps := int(duration / 0.03)
	for i in steps:
		var k := 1.0 - float(i) / steps
		tw.tween_property(node, "position", base + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * k, 0.03)
	tw.tween_property(node, "position", base, 0.03)
