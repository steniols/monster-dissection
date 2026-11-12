extends Node
## Cena inicial: abertura com a logo sobre fundo preto (~3 s) e depois o menu.
## Um toque ou tecla pula a abertura.

const FADE_IN := 0.6
const HOLD := 1.8
const FADE_OUT := 0.6

var _done := false


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bg)

	var logo := TextureRect.new()
	logo.texture = load("res://assets/art/ui/logo.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.set_anchors_preset(Control.PRESET_FULL_RECT)
	# a logo ocupa ~60% da largura, centralizada
	logo.anchor_left = 0.2
	logo.anchor_right = 0.8
	logo.anchor_top = 0.2
	logo.anchor_bottom = 0.8
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.modulate.a = 0.0
	layer.add_child(logo)

	var tw := create_tween()
	tw.tween_property(logo, "modulate:a", 1.0, FADE_IN)
	tw.tween_interval(HOLD)
	tw.tween_property(logo, "modulate:a", 0.0, FADE_OUT)
	tw.finished.connect(_finish)


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey) and event.is_pressed():
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	Game.goto("menu")
