class_name HealthBar
extends Control
## Barra de vida com armadura e prévia de sangramento/corrupção.

var hp: int = 1
var max_hp: int = 1
var block: int = 0
var pending_loss: int = 0 ## dano previsto por status no próximo turno
var _shown_ratio: float = 1.0


func _init() -> void:
	custom_minimum_size = Vector2(180, 22)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_values(hp_: int, max_hp_: int, block_: int, pending: int = 0) -> void:
	hp = hp_
	max_hp = max(1, max_hp_)
	block = block_
	pending_loss = pending
	var tw := create_tween()
	tw.tween_property(self, "_shown_ratio", float(hp) / max_hp, 0.25)
	tw.parallel().tween_callback(queue_redraw).set_delay(0.0)
	queue_redraw()


func _process(_d: float) -> void:
	if not is_equal_approx(_shown_ratio, float(hp) / max_hp):
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var border := Palette.PETROL_BRIGHT if block > 0 else Palette.INK_SOFT
	draw_rect(r, Palette.CHARCOAL_DEEP)
	var ratio := float(hp) / max_hp
	# trilha "fantasma" do dano recente
	draw_rect(Rect2(r.position, Vector2(r.size.x * _shown_ratio, r.size.y)), Palette.BONE.darkened(0.2))
	draw_rect(Rect2(r.position, Vector2(r.size.x * ratio, r.size.y)), Palette.BLOOD)
	if pending_loss > 0:
		var p: float = min(pending_loss, hp) / float(max_hp)
		draw_rect(Rect2(Vector2(r.size.x * (ratio - p), 0), Vector2(r.size.x * p, r.size.y)), Color(Palette.VIOLET_BRIGHT, 0.6))
	draw_rect(Rect2(r.position, Vector2(r.size.x * ratio, r.size.y * 0.3)), Color(1, 1, 1, 0.08))
	draw_rect(r, border, false, 2.0 if block > 0 else 1.0)
	var font := get_theme_default_font()
	var text := "%d / %d" % [hp, max_hp]
	var fs := 14
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var pos := Vector2((size.x - tw) * 0.5, size.y * 0.5 + fs * 0.35)
	draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Palette.CHARCOAL_DEEP)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Palette.PAPER)
	if block > 0:
		var shield_rect := Rect2(Vector2(-14, -4), Vector2(30, 30))
		ProceduralArt.draw_icon(self, &"shield", shield_rect, Palette.PETROL)
		var bt := str(block)
		var bw := font.get_string_size(bt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		draw_string(font, shield_rect.get_center() + Vector2(-bw * 0.5, 5), bt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.PAPER)
