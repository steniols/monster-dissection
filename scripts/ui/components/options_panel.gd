class_name OptionsPanel
extends VBoxContainer
## Controles de opções (volumes, tela cheia, efeitos). Usado na tela de Opções e no menu de pausa.


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	_slider("Volume geral", Settings.master_volume, func(v): Settings.master_volume = v)
	_slider("Efeitos sonoros", Settings.sfx_volume, func(v):
		Settings.sfx_volume = v
		Sfx.play(&"click"))
	_slider("Música", Settings.music_volume, func(v): Settings.music_volume = v)
	_check("Tela cheia", Settings.fullscreen, func(v): Settings.fullscreen = v)
	_check("Efeitos de impacto (pausa no golpe, tremor, partículas)", Settings.impact_fx, func(v): Settings.impact_fx = v)


func _slider(label: String, value: float, setter: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)
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


func _check(label: String, value: bool, setter: Callable) -> void:
	var c := CheckBox.new()
	c.text = label
	c.button_pressed = value
	c.add_theme_font_size_override("font_size", 17)
	c.toggled.connect(func(v: bool):
		setter.call(v)
		Settings.apply())
	add_child(c)
