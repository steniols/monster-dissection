extends CanvasLayer
## Autoload "PauseMenu": engrenagem no canto durante a expedição (mapa, combate, dissecação, eventos,
## descanso). Abre um menu com Continuar, Opções e a volta ao laboratório ou ao menu. Esc também abre.

## Telas da expedição onde a engrenagem aparece.
const RUN_SCREENS := ["map", "rest", "event", "combat", "dissection"]

var _gear: Button
var _overlay: Control
var _content: VBoxContainer
var _root: Control


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	# CanvasLayer não herda o tema da janela: um Control raiz com o tema do jogo
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = get_tree().root.theme if get_tree().root.theme else UiTheme.build()
	add_child(_root)
	_gear = _gear_button()
	_gear.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_gear.offset_left = -56
	_gear.offset_right = -12
	_gear.offset_top = 12
	_gear.offset_bottom = 56
	_root.add_child(_gear)
	_gear.visible = false


## Engrenagem para pôr no cabeçalho de uma tela, alinhada aos outros botões.
## A engrenagem solta do canto some enquanto essa tela estiver aberta.
func make_gear_button() -> Button:
	_gear.visible = false
	var b := _gear_button()
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return b


func _gear_button() -> Button:
	var b := Button.new()
	b.tooltip_text = "Menu (Esc)"
	b.custom_minimum_size = Vector2(46, 44)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(open)
	var icon := GearIcon.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(icon)
	b.mouse_entered.connect(func(): icon.hover = true; icon.queue_redraw())
	b.mouse_exited.connect(func(): icon.hover = false; icon.queue_redraw())
	return b


## Chamado pelo Game a cada troca de tela.
func on_screen(key: String) -> void:
	close()
	_gear.visible = key in RUN_SCREENS


func is_open() -> bool:
	return _overlay != null


func open() -> void:
	if _overlay != null:
		return
	get_tree().paused = true
	_overlay = ColorRect.new()
	(_overlay as ColorRect).color = Color(0.02, 0.02, 0.03, 0.82)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	center.add_child(panel)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 12)
	panel.add_child(_content)
	_show_main()


func close() -> void:
	if _overlay == null:
		return
	Settings.save_settings()
	_overlay.queue_free()
	_overlay = null
	get_tree().paused = false


func _clear() -> void:
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()


func _show_main() -> void:
	_clear()
	panel_width(420)
	_title("Pausa")
	_button("Continuar", close)
	_button("Opções", _show_options)
	_button("Voltar ao laboratório", func(): _confirm_leave("lab"))
	_button("Menu principal", func(): _confirm_leave("menu"))


func _show_options() -> void:
	_clear()
	panel_width(560)
	_title("Opções")
	_content.add_child(OptionsPanel.new())
	_button("Voltar", func():
		Settings.save_settings()
		_show_main())


func _confirm_leave(to: String) -> void:
	_clear()
	panel_width(480)
	_title("Sair da expedição?")
	var msg := "A expedição fica salva no último ponto do mapa. Use \"Continuar expedição\" no laboratório para retomar."
	if Game.current != "map":
		msg += "\nO que está acontecendo nesta tela (combate, dissecação ou evento) será refeito."
	var l := UiTheme.make_label(msg, 15, Palette.PAPER)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(l)
	var go := _button("Sair", func():
		close()
		Game.goto(to))
	go.add_theme_stylebox_override("normal", UiTheme.panel_style(Palette.BLOOD.darkened(0.25), Palette.BLOOD_BRIGHT, 2, 6, 10))
	_button("Cancelar", _show_main)


func panel_width(w: int) -> void:
	(_content.get_parent() as Control).custom_minimum_size.x = w


func _title(text: String) -> void:
	var l := UiTheme.make_label(text, 32, Palette.BONE_LIGHT, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(l)


func _button(text: String, cb: Callable) -> Button:
	var b := UiTheme.make_button(text, cb)
	b.custom_minimum_size.y = 42
	_content.add_child(b)
	return b


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _overlay != null:
		close()
		get_viewport().set_input_as_handled()
	elif Game.current in RUN_SCREENS:
		open()
		get_viewport().set_input_as_handled()


## Engrenagem desenhada em código.
class GearIcon:
	extends Control

	var hover := false

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.3
		var col := Palette.BONE_LIGHT if hover else Palette.BONE
		var teeth := 8
		var pts := PackedVector2Array()
		for i in teeth * 4:
			var a := TAU * float(i) / (teeth * 4) - PI / (teeth * 4)
			var outer := (i % 4) < 2
			pts.append(c + Vector2.from_angle(a) * (r * 1.32 if outer else r))
		draw_colored_polygon(pts, col)
		draw_circle(c, r * 0.42, Palette.CHARCOAL_DEEP)
