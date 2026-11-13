extends Control
## Menu inicial: logo no alto, botões em placas dentro de um círculo arcano e objetos de gabinete nos cantos.

const BTN_W := 330
const BTN_H := 50
## Largura de cada objeto de canto, em fração da largura da tela.
const CORNER_W := 0.27

var _ring: TextureRect
var _buttons: VBoxContainer
var _corners: Array[TextureRect] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Palette.CHARCOAL, "menu", 0.2) as BackgroundView
	bg.glow_color = Palette.VIOLET
	bg.glow_center = Vector2(0.5, 0.35)

	# círculo arcano (atrás dos botões, girando devagar) e objetos nos cantos de baixo
	var ring_tex := Database.get_art("ui", &"menu_ring")
	if ring_tex != null:
		_ring = TextureRect.new()
		_ring.texture = ring_tex
		_ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_ring.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ring.modulate = Color(1, 1, 1, 0.6)
		add_child(_ring)
	for id in [&"menu_left", &"menu_right"]:
		var tex := Database.get_art("ui", id)
		if tex == null:
			continue
		var r := TextureRect.new()
		r.texture = tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_SCALE
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.set_meta("left", id == &"menu_left")
		add_child(r)
		_corners.append(r)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_top = 6
	box.offset_bottom = -30
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	add_child(box)

	var logo_tex := Database.get_art("ui", &"logo")
	if logo_tex != null:
		var logo := TextureRect.new()
		logo.texture = logo_tex
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.custom_minimum_size = Vector2(460, 230)
		logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(logo)
	else:
		var t1 := UiTheme.make_label("MONSTER", 64, Palette.PAPER, true)
		var t2 := UiTheme.make_label("DISSECTION", 64, Palette.BLOOD_BRIGHT, true)
		t2.add_theme_constant_override("line_spacing", -10)
		box.add_child(t1)
		box.add_child(t2)
	var sub := UiTheme.make_label("Cada criatura derrotada pode transformar seu baralho —\ne seu próprio corpo.", 17, Palette.BONE)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	var gap := Control.new()
	gap.custom_minimum_size.y = 34
	box.add_child(gap)

	_buttons = VBoxContainer.new()
	_buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_buttons.add_theme_constant_override("separation", 10)
	box.add_child(_buttons)
	if RunState.has_save():
		_buttons.add_child(_btn("Continuar expedição", Game.continue_expedition, "MenuGreen"))
	var enter := _btn("Entrar no laboratório", func(): Game.goto("lab"), "MenuGold")
	_buttons.add_child(enter)
	_buttons.add_child(_btn("Opções", func(): Game.open_options("menu"), "MenuDark"))
	_buttons.add_child(_btn("Apagar progresso", _confirm_reset, "MenuDark"))
	_buttons.add_child(_btn("Sair", func(): get_tree().quit(), "MenuDark"))
	enter.grab_focus()

	var ver := UiTheme.make_label("Protótipo 0.2 · %d expedições · %d vitórias" % [Profile.runs_started, Profile.runs_won], 13, Palette.TEXT_DIM)
	ver.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ver.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.offset_top = -24
	ver.offset_bottom = -4
	add_child(ver)


func _process(d: float) -> void:
	_layout_decor()
	if _ring != null:
		_ring.rotation += d * 0.03


func _btn(text: String, cb: Callable, variant: String) -> Button:
	var b := UiTheme.make_button(text, cb, BTN_W, variant)
	b.custom_minimum_size.y = BTN_H
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return b


## Círculo centrado nos botões; objetos de canto presos embaixo, dimensionados pela largura da tela.
func _layout_decor() -> void:
	if _ring != null and _buttons != null:
		var rect := _buttons.get_global_rect()
		var dia := maxf(rect.size.y + 80.0, rect.size.x + 40.0)
		_ring.size = Vector2(dia, dia)
		_ring.pivot_offset = _ring.size * 0.5
		_ring.global_position = rect.get_center() - _ring.size * 0.5
	for r in _corners:
		var ts := r.texture.get_size()
		var w := size.x * CORNER_W
		var h := w * ts.y / ts.x
		r.size = Vector2(w, h)
		var x := -6.0 if r.get_meta("left") else size.x - w + 6.0
		r.position = Vector2(x, size.y - h + 4.0)


func _confirm_reset() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Apagar progresso"
	d.dialog_text = "Isso apaga cartas desbloqueadas, materiais, mutações e bestiário.\nNão pode ser desfeito."
	d.ok_button_text = "Apagar"
	d.cancel_button_text = "Cancelar"
	UiTheme.style_dialog(d)
	d.confirmed.connect(func():
		Profile.reset()
		RunState.delete_save()
		get_tree().reload_current_scene())
	add_child(d)
	d.popup_centered()
