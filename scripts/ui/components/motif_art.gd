class_name MotifArt
extends Control
## Ilustração de órgão/parte em estilo de prancha anatômica (fundo de papel com grade).

var motif: StringName = &"heart"
var accent: Color = Palette.BLOOD
var texture: Texture2D
var paper: bool = true
## Espaço entre as linhas da grade do papel.
var grid_step: float = 12.0


func setup(motif_: StringName, accent_: Color, texture_: Texture2D = null) -> void:
	motif = motif_
	accent = accent_
	texture = texture_
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if paper:
		draw_rect(r, Palette.PAPER.darkened(0.12))
		var step := grid_step
		var x := step
		while x < size.x:
			draw_line(Vector2(x, 0), Vector2(x, size.y), Color(Palette.INK, 0.06), 1.0)
			x += step
		var y := step
		while y < size.y:
			draw_line(Vector2(0, y), Vector2(size.x, y), Color(Palette.INK, 0.06), 1.0)
			y += step
		# mancha de idade
		draw_circle(Vector2(size.x * 0.82, size.y * 0.2), size.x * 0.12, Color(Palette.BONE, 0.12))
	if texture != null:
		draw_texture_rect(texture, ProceduralArt.fit_box(r.grow(-4), texture.get_width() / float(max(1, texture.get_height()))), false)
	elif motif != &"":
		ProceduralArt.draw_motif(self, motif, r.grow(-size.y * 0.1), accent)
