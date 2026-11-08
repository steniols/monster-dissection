class_name CardGridOverlay
extends Control
## Sobreposição modal com uma grade de cartas (ver pilhas, escolher carta para remover, etc.).

signal card_chosen(card: CardData, index: int)
signal closed

var _grid: GridContainer


static func open(parent: Node, title: String, cards: Array[CardData], selectable: bool = false, subtitle: String = "") -> CardGridOverlay:
	var o := CardGridOverlay.new()
	parent.add_child(o)
	o._build(title, cards, selectable, subtitle)
	return o


func _build(title: String, cards: Array[CardData], selectable: bool, subtitle: String) -> void:
	# já está na árvore: ajusta âncoras E margens, senão o tamanho zero de antes é mantido
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 200
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.03, 0.04, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 40
	root.offset_right = -40
	root.offset_top = 24
	root.offset_bottom = -20
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var t := UiTheme.make_label(title, 28, Palette.BONE_LIGHT, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(t)
	if not subtitle.is_empty():
		var s := UiTheme.make_label(subtitle, 15, Palette.TEXT_DIM)
		s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		root.add_child(s)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(UiTheme.padded(center))
	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	center.add_child(_grid)
	resized.connect(_update_columns)
	_update_columns()

	if cards.is_empty():
		var e := UiTheme.make_label("Nenhuma carta.", 18, Palette.TEXT_DIM)
		_grid.add_child(e)
	for i in cards.size():
		var v := CardView.create(cards[i])
		v.interactive = selectable
		if not selectable:
			v.mouse_default_cursor_shape = Control.CURSOR_ARROW
		var idx := i
		v.pressed.connect(func(_view): card_chosen.emit(cards[idx], idx))
		_grid.add_child(v)

	var close := UiTheme.make_button("Fechar" if not selectable else "Cancelar", close_overlay, 180)
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(close)


func _update_columns() -> void:
	if _grid != null:
		_grid.columns = max(1, int((size.x - 80) / (CardView.CARD_SIZE.x + 14)))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_overlay()
		get_viewport().set_input_as_handled()


func close_overlay() -> void:
	closed.emit()
	queue_free()
