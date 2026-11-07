class_name MonsterArt
extends Control
## Mostra o retrato do monstro (Texture2D se houver; senão, desenho procedural animado).

@export var animate: bool = true

var visual: StringName = &"bloodfang"
var portrait: Texture2D
var _t: float = 0.0


func setup(data: MonsterData) -> void:
	visual = data.visual
	portrait = data.portrait
	self_modulate = data.tint
	queue_redraw()


func _process(delta: float) -> void:
	if animate and portrait == null and is_visible_in_tree():
		_t += delta
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if portrait != null:
		var box := ProceduralArt.fit_box(r, portrait.get_width() / float(max(1, portrait.get_height())))
		draw_texture_rect(portrait, box, false)
	else:
		ProceduralArt.draw_monster(self, visual, r, _t)


func region_point(region: int) -> Vector2:
	return ProceduralArt.region_anchor(visual, region, Rect2(Vector2.ZERO, size))
