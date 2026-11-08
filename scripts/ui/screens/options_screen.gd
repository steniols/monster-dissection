extends Control
## Opções: volumes, tela cheia e efeitos de impacto.


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UiTheme.add_background(self, Palette.CHARCOAL, "menu", 0.7)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	box.add_child(UiTheme.make_label("Opções", 36, Palette.BONE_LIGHT, true))
	box.add_child(OptionsPanel.new())

	var back := UiTheme.make_button("Voltar", _back, 200)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(back)


func _back() -> void:
	Settings.save_settings()
	Game.goto(Game.options_return)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
