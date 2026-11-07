class_name MonsterArt
extends Control
## Mostra o retrato do monstro (Texture2D se houver; senão, desenho procedural animado).
## Retratos ganham contorno escuro e um brilho na cor da família (shader sprite_outline).

const OUTLINE_SHADER := preload("res://scripts/ui/shaders/sprite_outline.gdshader")
## Espessura do contorno e alcance do brilho, em pixels de tela.
const OUTLINE_SCREEN_PX := 2.5
const GLOW_SCREEN_PX := 9.0

@export var animate: bool = true

var visual: StringName = &"bloodfang"
var portrait: Texture2D
var data: MonsterData
## 0 = brilho discreto; 1 = destacado (alvo, foco).
var highlight: float = 0.0:
	set(v):
		highlight = v
		_update_material()
var _t: float = 0.0
var _mat: ShaderMaterial


func setup(data_: MonsterData) -> void:
	data = data_
	visual = data_.visual
	portrait = data_.portrait
	# O tingimento só cria variações do desenho provisório; a arte final já vem com as cores certas.
	self_modulate = data_.tint if portrait == null else Color.WHITE
	if portrait != null:
		_mat = ShaderMaterial.new()
		_mat.shader = OUTLINE_SHADER
		material = _mat
	else:
		material = null
		_mat = null
	_update_material()
	queue_redraw()


func _process(delta: float) -> void:
	if animate and portrait == null and is_visible_in_tree():
		_t += delta
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if portrait != null:
		var box := _portrait_box()
		# sombra no chão
		var c := Vector2(box.get_center().x, box.end.y - box.size.y * 0.06)
		draw_set_transform(c, 0.0, Vector2(1.0, 0.16))
		draw_circle(Vector2.ZERO, box.size.x * 0.27, Color(0, 0, 0, 0.3))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_texture_rect(portrait, box, false)
	else:
		ProceduralArt.draw_monster(self, visual, r, _t)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_material()


func _update_material() -> void:
	if _mat == null or portrait == null:
		return
	var box := _portrait_box()
	var tex_per_screen := portrait.get_width() / maxf(1.0, box.size.x)
	_mat.set_shader_parameter("outline_px", OUTLINE_SCREEN_PX * tex_per_screen)
	_mat.set_shader_parameter("glow_px", GLOW_SCREEN_PX * (1.0 + highlight * 0.6) * tex_per_screen)
	var fam := Family.get_color(data.family) if data != null else Palette.BONE
	_mat.set_shader_parameter("glow_color", Color(fam.lightened(0.25), lerpf(0.65, 1.0, highlight)))


func _portrait_box() -> Rect2:
	return ProceduralArt.fit_box(Rect2(Vector2.ZERO, size), portrait.get_width() / float(max(1, portrait.get_height())))


func region_point(region: int) -> Vector2:
	if portrait != null and data != null and data.region_anchors.size() > region:
		var box := _portrait_box()
		return box.position + box.size * data.region_anchors[region]
	return ProceduralArt.region_anchor(visual, region, Rect2(Vector2.ZERO, size))
