class_name MonsterArt
extends Control
## Mostra o retrato do monstro (Texture2D se houver; senão, desenho procedural animado).

@export var animate: bool = true

var visual: StringName = &"bloodfang"
var portrait: Texture2D
var data: MonsterData
var _t: float = 0.0


func setup(data_: MonsterData) -> void:
	data = data_
	visual = data_.visual
	portrait = data_.portrait
	# O tingimento só cria variações do desenho provisório; a arte final já vem com as cores certas.
	self_modulate = data_.tint if portrait == null else Color.WHITE
	queue_redraw()


func _process(delta: float) -> void:
	if animate and portrait == null and is_visible_in_tree():
		_t += delta
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if portrait != null:
		draw_texture_rect(portrait, _portrait_box(), false)
	else:
		ProceduralArt.draw_monster(self, visual, r, _t)


func _portrait_box() -> Rect2:
	return ProceduralArt.fit_box(Rect2(Vector2.ZERO, size), portrait.get_width() / float(max(1, portrait.get_height())))


func region_point(region: int) -> Vector2:
	if portrait != null and data != null and data.region_anchors.size() > region:
		var box := _portrait_box()
		return box.position + box.size * data.region_anchors[region]
	return ProceduralArt.region_anchor(visual, region, Rect2(Vector2.ZERO, size))
