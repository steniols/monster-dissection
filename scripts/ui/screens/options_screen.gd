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

	_slider(box, "Volume geral", Settings.master_volume, func(v): Settings.master_volume = v)
	_slider(box, "Efeitos sonoros", Settings.sfx_volume, func(v):
		Settings.sfx_volume = v
		Sfx.play(&"click"))
	_slider(box, "Ambiente", Settings.music_volume, func(v): Settings.music_volume = v)
	_check(box, "Tela cheia", Settings.fullscreen, func(v): Settings.fullscreen = v)
	_check(box, "Efeitos de impacto (pausa no golpe, tremor, partículas)", Settings.impact_fx, func(v): Settings.impact_fx = v)

	var back := UiTheme.make_button("Voltar", _back, 200)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(back)


func _slider(parent: Control, label: String, value: float, setter: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var l := UiTheme.make_label(label, 17, Palette.PAPER)
	l.custom_minimum_size.x = 180
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var pct := UiTheme.make_label("%d%%" % roundi(value * 100), 16, Palette.BONE_LIGHT)
	pct.custom_minimum_size.x = 50
	s.value_changed.connect(func(v: float):
		setter.call(v)
		pct.text = "%d%%" % roundi(v * 100)
		Settings.apply())
	row.add_child(s)
	row.add_child(pct)


func _check(parent: Control, label: String, value: bool, setter: Callable) -> void:
	var c := CheckBox.new()
	c.text = label
	c.button_pressed = value
	c.add_theme_font_size_override("font_size", 17)
	c.toggled.connect(func(v: bool):
		setter.call(v)
		Settings.apply())
	parent.add_child(c)


func _back() -> void:
	Settings.save_settings()
	Game.goto(Game.options_return)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
