class_name CardView
extends Control
## Carta como ficha de estudo anatômico: nome e custo no topo, prancha central,
## efeito em placa escura legível, origem e raridade no rodapé.

signal pressed(view: CardView)
signal hover_changed(view: CardView, hovering: bool)

const CARD_SIZE := Vector2(156, 224)

const TYPE_COLORS := {
	CardData.CardType.ATTACK: Palette.BLOOD,
	CardData.CardType.DEFENSE: Palette.MOSS,
	CardData.CardType.SKILL: Palette.PETROL,
	CardData.CardType.MUTATION: Palette.VIOLET,
}
const RARITY_COLORS := {
	CardData.Rarity.STARTER: Palette.INK_SOFT,
	CardData.Rarity.COMMON: Color("#8B6F42"),
	CardData.Rarity.UNCOMMON: Palette.PETROL_BRIGHT,
	CardData.Rarity.RARE: Palette.VIOLET_BRIGHT,
}

var data: CardData
var instance: CardInstance
var playable: bool = true:
	set(v):
		playable = v
		modulate = Color.WHITE if v else Color(0.62, 0.6, 0.58)
		queue_redraw()
var selected: bool = false:
	set(v):
		selected = v
		queue_redraw()
var dimmed_note: String = "" ## ex.: "x2" ou "Bloqueada"
var interactive: bool = true

var _name_label: Label
var _art: MotifArt
var _type_label: Label
var _desc: RichTextLabel
var _origin: Label
var _note: Label


static func create(card: CardData, inst: CardInstance = null) -> CardView:
	var v := CardView.new()
	v.data = card
	v.instance = inst
	return v


func _init() -> void:
	custom_minimum_size = CARD_SIZE
	size = CARD_SIZE
	pivot_offset = CARD_SIZE * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _ready() -> void:
	_build()
	refresh()
	mouse_entered.connect(func(): if interactive: hover_changed.emit(self, true))
	mouse_exited.connect(func(): if interactive: hover_changed.emit(self, false))


func _gui_input(event: InputEvent) -> void:
	if not interactive:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(self)
		accept_event()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	margin.add_theme_constant_override("margin_top", 6)
	add_child(margin)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 3)
	margin.add_child(box)

	_name_label = UiTheme.make_label("", 15, Palette.INK, true)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name_label.clip_text = true
	_name_label.custom_minimum_size = Vector2(0, 22)
	var name_margin := MarginContainer.new()
	name_margin.add_theme_constant_override("margin_left", 22)
	name_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_margin.add_child(_name_label)
	box.add_child(name_margin)

	_art = MotifArt.new()
	_art.custom_minimum_size = Vector2(0, 80)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_art)

	_type_label = UiTheme.make_label("", 11, Palette.INK_SOFT)
	_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_type_label)

	var plate := PanelContainer.new()
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var ps := UiTheme.panel_style(Color(Palette.CHARCOAL_DEEP, 0.92), Palette.INK, 1, 4, 0)
	ps.set_content_margin_all(5)
	plate.add_theme_stylebox_override("panel", ps)
	_desc = UiTheme.make_rich("", 12, Palette.PAPER)
	_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plate.add_child(_desc)
	box.add_child(plate)

	_origin = UiTheme.make_label("", 10, Palette.INK_SOFT)
	_origin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_origin.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_origin.clip_text = true
	box.add_child(_origin)

	_note = UiTheme.make_label("", 16, Palette.BONE_LIGHT, true)
	_note.add_theme_color_override("font_outline_color", Palette.CHARCOAL_DEEP)
	_note.add_theme_constant_override("outline_size", 6)
	_note.position = Vector2(CARD_SIZE.x - 40, 26)
	_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_note)


func refresh() -> void:
	if data == null or _name_label == null:
		return
	_name_label.text = data.display_name
	_name_label.add_theme_color_override("font_color", Color("#3F6B2E") if data.upgraded else Palette.INK)
	_fit_name()
	_art.setup(data.art_motif, Family.get_color(data.family) if data.family != Family.Id.NEUTRAL else TYPE_COLORS[data.card_type], data.illustration)
	_type_label.text = "%s · %s" % [data.get_type_name().to_upper(), data.get_rarity_name()]
	_desc.text = "[center]%s[/center]" % data.get_description()
	_origin.text = data.get_origin_label()
	_note.text = dimmed_note
	var tip := "%s (%s)\n%s" % [data.display_name, data.get_origin_label(), _strip_bbcode(data.get_description())]
	if not data.flavor.is_empty():
		tip += "\n\n\"%s\"" % data.flavor
	tooltip_text = tip
	queue_redraw()


## Reduz a fonte do nome até caber (em vez de truncar).
func _fit_name() -> void:
	var font: Font = UiTheme.title_font if UiTheme.title_font != null else get_theme_default_font()
	var avail := CARD_SIZE.x - 16.0 - 24.0
	var fs := 15
	while fs > 10 and font.get_string_size(data.display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > avail:
		fs -= 1
	_name_label.add_theme_font_size_override("font_size", fs)


func set_note(text: String) -> void:
	dimmed_note = text
	if _note != null:
		_note.text = text


func get_display_cost() -> int:
	return instance.get_cost() if instance != null else data.cost


func _draw() -> void:
	if data == null:
		return
	var r := Rect2(Vector2.ZERO, size)
	var fam_dark := Family.get_dark_color(data.family)
	# sombra
	draw_style_box(UiTheme.panel_style(Color(0, 0, 0, 0.45), Color(0, 0, 0, 0), 0, 8), Rect2(r.position + Vector2(3, 5), r.size))
	# papel
	var paper := UiTheme.panel_style(Palette.PAPER, fam_dark, 3, 7)
	draw_style_box(paper, r)
	# híbrida: metade inferior da moldura na cor da segunda família
	if data.is_hybrid():
		var sec := Family.get_dark_color(data.secondary_family)
		draw_rect(Rect2(1.5, size.y * 0.5, 3, size.y * 0.5 - 8), sec)
		draw_rect(Rect2(size.x - 4.5, size.y * 0.5, 3, size.y * 0.5 - 8), sec)
		draw_rect(Rect2(8, size.y - 4.5, size.x - 16, 3), sec)
	# faixa de tipo abaixo do nome
	draw_rect(Rect2(8, 30, size.x - 16, 3), TYPE_COLORS.get(data.card_type, Palette.INK))
	# moldura interna (ficha catalogada)
	draw_rect(r.grow(-5), Color(Palette.INK, 0.25), false, 1.0)
	# selo de raridade
	var rc: Color = RARITY_COLORS.get(data.rarity, Palette.INK_SOFT)
	var d := Vector2(size.x - 14, size.y - 12)
	draw_colored_polygon(PackedVector2Array([d + Vector2(0, -6), d + Vector2(5, 0), d + Vector2(0, 6), d + Vector2(-5, 0)]), rc)
	# custo
	var cc := Vector2(14, 15)
	var cost := get_display_cost()
	draw_circle(cc, 17, Palette.CHARCOAL_DEEP)
	draw_arc(cc, 17, 0, TAU, 32, Palette.PETROL_BRIGHT, 2.0, true)
	var font: Font = UiTheme.number_font if UiTheme.number_font != null else get_theme_default_font()
	var txt := str(cost)
	var col := Palette.PAPER
	if instance != null and cost < data.cost:
		col = Palette.MOSS_BRIGHT
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(font, cc + Vector2(-tw * 0.5, 7), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, col)
	if selected:
		draw_style_box(UiTheme.panel_style(Color(0, 0, 0, 0), Palette.BONE_LIGHT, 3, 9), r.grow(4))


static func _strip_bbcode(text: String) -> String:
	var re := RegEx.new()
	re.compile("\\[[^\\]]*\\]")
	return re.sub(text, "", true)
