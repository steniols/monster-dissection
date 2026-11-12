class_name StatusRow
extends HFlowContainer
## Fileira de "selos" de status com quantidade e tooltip.


func _init() -> void:
	add_theme_constant_override("h_separation", 4)
	add_theme_constant_override("v_separation", 4)
	mouse_filter = Control.MOUSE_FILTER_PASS


func refresh(statuses: Dictionary) -> void:
	for c in get_children():
		c.queue_free()
	for id: StringName in statuses:
		add_child(_make_chip(id, statuses[id]))


func _make_chip(id: StringName, stacks: int) -> Control:
	var chip := PanelContainer.new()
	var color := StatusLibrary.get_color(id)
	var style := UiTheme.panel_style(Palette.CHARCOAL_DEEP, color, 1, 10, 0)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", style)
	chip.tooltip_text = StatusLibrary.describe(id, stacks)
	chip.mouse_filter = Control.MOUSE_FILTER_STOP
	chip.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and not e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			InfoPopup.open_status(chip, id, stacks)
			chip.accept_event())
	chip.mouse_default_cursor_shape = Control.CURSOR_HELP
	var sname := StatusLibrary.get_display_name(id)
	var l := UiTheme.make_label("%s %d" % [sname, stacks], 12, color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(l)
	return chip
