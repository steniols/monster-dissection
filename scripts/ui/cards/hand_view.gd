class_name HandView
extends Control
## Mão de cartas em leque, com elevação ao passar o mouse.

signal card_pressed(view: CardView)

const HOVER_RAISE := 70.0
const HOVER_SCALE := 1.15

var views: Array[CardView] = []
var _hovered: CardView
var _selected: CardView


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	resized.connect(_layout)


func set_cards(cards: Array[CardInstance], playable_check: Callable) -> void:
	var keep: Array[CardView] = []
	for v in views:
		if cards.has(v.instance):
			keep.append(v)
		else:
			v.queue_free()
	views.clear()
	for inst in cards:
		var found: CardView = null
		for v in keep:
			if v.instance == inst:
				found = v
				break
		if found == null:
			found = CardView.create(inst.data, inst)
			found.position = Vector2(size.x * 0.5 - CardView.CARD_SIZE.x * 0.5, size.y + 40)
			found.pressed.connect(func(view: CardView): card_pressed.emit(view))
			found.hover_changed.connect(_on_hover)
			add_child(found)
		views.append(found)
	for v in views:
		v.playable = playable_check.call(v.instance)
		v.refresh()
	if _hovered != null and not views.has(_hovered):
		_hovered = null
	if _selected != null and not views.has(_selected):
		_selected = null
	_layout()


func refresh_playable(playable_check: Callable) -> void:
	for v in views:
		v.playable = playable_check.call(v.instance)
		v.refresh()


func set_selected(view: CardView) -> void:
	if _selected != null and is_instance_valid(_selected):
		_selected.selected = false
	_selected = view
	if view != null:
		view.selected = true
	_layout()


func get_view_for(inst: CardInstance) -> CardView:
	for v in views:
		if v.instance == inst:
			return v
	return null


func _on_hover(view: CardView, hovering: bool) -> void:
	if hovering:
		_hovered = view
	elif _hovered == view:
		_hovered = null
	_layout()


func _layout() -> void:
	var n := views.size()
	if n == 0:
		return
	var w := CardView.CARD_SIZE.x
	var spacing: float = min(w + 6.0, (size.x - w) / max(1, n - 1))
	var total := spacing * (n - 1) + w
	var start_x := (size.x - total) * 0.5
	var base_y := size.y - CardView.CARD_SIZE.y - 20.0
	for i in n:
		var v := views[i]
		var t := 0.0 if n == 1 else (float(i) / (n - 1)) * 2.0 - 1.0
		var target_pos := Vector2(start_x + i * spacing, base_y + absf(t) * absf(t) * 18.0)
		var target_rot: float = t * 0.06 * minf(1.0, n / 5.0)
		var target_scale := Vector2.ONE
		v.z_index = i
		if v == _hovered or v == _selected:
			target_pos.y = base_y - (HOVER_RAISE if v == _hovered else HOVER_RAISE * 0.6)
			target_rot = 0.0
			target_scale = Vector2.ONE * HOVER_SCALE
			v.z_index = 100
		var tw := v.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(v, "position", target_pos, 0.18)
		tw.tween_property(v, "rotation", target_rot, 0.18)
		tw.tween_property(v, "scale", target_scale, 0.12)
