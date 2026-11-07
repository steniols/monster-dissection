class_name IconView
extends Control
## Ícone vetorial simples de interface.

var icon: StringName = &"heart"
var color: Color = Palette.BLOOD_BRIGHT


static func create(icon_: StringName, color_: Color, px: int = 22) -> IconView:
	var v := IconView.new()
	v.icon = icon_
	v.color = color_
	v.custom_minimum_size = Vector2(px, px)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return v


func set_icon(icon_: StringName, color_: Color) -> void:
	icon = icon_
	color = color_
	queue_redraw()


func _draw() -> void:
	ProceduralArt.draw_icon(self, icon, Rect2(Vector2.ZERO, size), color)
