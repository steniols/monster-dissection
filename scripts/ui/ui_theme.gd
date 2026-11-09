class_name UiTheme
extends RefCounted
## Tema global (painéis escuros, papel envelhecido, tipografia legível) e utilitários de UI.

static var title_font: Font
static var body_font: Font


const TITLE_FONT_PATH := "res://assets/fonts/CormorantGaramond-Variable.ttf"
const BODY_FONT_PATH := "res://assets/fonts/SourceSans3-Variable.ttf"

static var bold_font: Font
## Fonte para números (custo, energia, vida, intenção): algarismos alinhados e legíveis.
static var number_font: Font
static var button_font: Font


static func build() -> Theme:
	title_font = _font_file(TITLE_FONT_PATH, 700, ["Georgia", "Palatino Linotype", "Times New Roman", "serif"])
	body_font = _font_file(BODY_FONT_PATH, 420, ["Segoe UI", "Helvetica Neue", "Arial", "sans-serif"])
	bold_font = _font_file(BODY_FONT_PATH, 700, ["Segoe UI", "Arial", "sans-serif"])
	number_font = bold_font
	button_font = _font_file(BODY_FONT_PATH, 600, ["Segoe UI", "Arial", "sans-serif"])

	var t := Theme.new()
	t.default_font = body_font
	t.default_font_size = 16

	t.set_color("font_color", "Label", Palette.TEXT)

	# Botões
	# Botões em placa de latão (ver PlateStyle). Variantes: PrimaryButton, MossButton, GoldButton, GhostButton.
	for kind in ["normal", "primary", "moss", "gold", "ghost"]:
		var type: String = {"normal": "Button", "primary": "PrimaryButton", "moss": "MossButton", "gold": "GoldButton", "ghost": "GhostButton"}[kind]
		if type != "Button":
			t.set_type_variation(type, "Button")
		var st := PlateStyle.states(kind)
		for state in st:
			t.set_stylebox(state, type, st[state])
		t.set_stylebox("focus", type, StyleBoxEmpty.new())
	t.set_color("font_color", "PrimaryButton", Palette.BONE_LIGHT)
	t.set_color("font_color", "MossButton", Palette.BONE_LIGHT)
	# texto escuro sobre a placa dourada
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(key, "GoldButton", Palette.INK)
	t.set_color("font_color", "GhostButton", Palette.TEXT_DIM)
	t.set_color("font_color", "Button", Palette.PAPER)
	t.set_color("font_hover_color", "Button", Palette.BONE_LIGHT)
	t.set_color("font_pressed_color", "Button", Palette.BONE_LIGHT)
	t.set_color("font_disabled_color", "Button", Palette.TEXT_DIM.darkened(0.2))
	t.set_font("font", "Button", button_font)
	t.set_font_size("font_size", "Button", 16)

	# Caixas de seleção: respiro entre o quadrado e o texto, realce leve no hover
	t.set_constant("h_separation", "CheckBox", 12)
	t.set_stylebox("normal", "CheckBox", panel_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 1, 4, 8))
	t.set_stylebox("pressed", "CheckBox", panel_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 1, 4, 8))
	t.set_stylebox("hover", "CheckBox", panel_style(Palette.PANEL_LIGHT, Palette.BONE.darkened(0.35), 1, 4, 8))
	t.set_stylebox("hover_pressed", "CheckBox", panel_style(Palette.PANEL_LIGHT, Palette.BONE.darkened(0.35), 1, 4, 8))
	t.set_stylebox("focus", "CheckBox", StyleBoxEmpty.new())
	t.set_color("font_color", "CheckBox", Palette.PAPER)
	t.set_color("font_hover_color", "CheckBox", Palette.BONE_LIGHT)
	t.set_color("font_pressed_color", "CheckBox", Palette.PAPER)
	t.set_color("font_hover_pressed_color", "CheckBox", Palette.BONE_LIGHT)

	# Painéis
	t.set_stylebox("panel", "Panel", panel_style(Palette.CHARCOAL, Palette.INK_SOFT, 1, 6))
	t.set_stylebox("panel", "PanelContainer", panel_style(Palette.CHARCOAL, Palette.INK_SOFT, 1, 6, 12))

	# Tooltip
	t.set_stylebox("panel", "TooltipPanel", panel_style(Palette.CHARCOAL_DEEP, Palette.BONE, 1, 4, 8))
	t.set_color("font_color", "TooltipLabel", Palette.PAPER)

	# Rich text
	t.set_color("default_color", "RichTextLabel", Palette.TEXT)
	t.set_font("normal_font", "RichTextLabel", body_font)
	t.set_font("bold_font", "RichTextLabel", bold_font)

	# Scroll
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
	var grabber := panel_style(Palette.BONE.darkened(0.3), Color(0, 0, 0, 0), 0, 4)
	t.set_stylebox("grabber", "VScrollBar", grabber)
	t.set_stylebox("grabber_highlight", "VScrollBar", panel_style(Palette.BONE, Color(0, 0, 0, 0), 0, 4))
	t.set_stylebox("grabber_pressed", "VScrollBar", panel_style(Palette.BONE_LIGHT, Color(0, 0, 0, 0), 0, 4))
	t.set_stylebox("scroll", "VScrollBar", panel_style(Palette.CHARCOAL_DEEP, Color(0, 0, 0, 0), 0, 4))

	# Abas
	t.set_stylebox("tab_selected", "TabBar", panel_style(Palette.PANEL_LIGHT, Palette.BONE, 1, 4, 8))
	t.set_stylebox("tab_unselected", "TabBar", panel_style(Palette.CHARCOAL, Palette.INK_SOFT, 1, 4, 8))
	t.set_stylebox("tab_hovered", "TabBar", panel_style(Palette.PANEL, Palette.BONE.darkened(0.2), 1, 4, 8))
	t.set_color("font_selected_color", "TabBar", Palette.BONE_LIGHT)
	t.set_color("font_unselected_color", "TabBar", Palette.TEXT_DIM)
	return t


## Fonte do projeto (variável, com peso escolhido); usa fonte do sistema se o arquivo faltar.
static func _font_file(path: String, weight: int, fallback: PackedStringArray) -> Font:
	if not ResourceLoader.exists(path):
		return _system_font(fallback, weight)
	var base := load(path) as FontFile
	if base == null:
		return _system_font(fallback, weight)
	var v := FontVariation.new()
	v.base_font = base
	v.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	v.fallbacks = [_system_font(fallback, weight)]
	return v


static func _system_font(names: PackedStringArray, weight: int) -> SystemFont:
	var f := SystemFont.new()
	f.font_names = names
	f.font_weight = weight
	f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	return f


static func panel_style(bg: Color, border: Color, border_width: int = 1, radius: int = 6, padding: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	if padding > 0:
		s.set_content_margin_all(padding)
	s.anti_aliasing = true
	return s


static func make_label(text: String, size: int = 16, color: Color = Palette.TEXT, title: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title and title_font != null:
		l.add_theme_font_override("font", title_font)
	return l


static func make_rich(bbcode: String, size: int = 15, color: Color = Palette.TEXT) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.text = bbcode
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_color_override("default_color", color)
	return r


static func make_button(text: String, callback: Callable, min_width: int = 0, variant: String = "") -> Button:
	var b := Button.new()
	b.theme_type_variation = variant
	b.text = text
	if min_width > 0:
		b.custom_minimum_size.x = min_width
	b.pressed.connect(callback)
	return b


## Coloca um ícone pintado (assets/art/ui/<id>.png) à esquerda do texto do botão. Sem o arquivo, fica só o texto.
static func with_icon(b: Button, id: StringName, px: int = 26) -> Button:
	var tex := Database.get_art("ui", id)
	if tex != null:
		# fica por cima do botão, sem empurrar o texto: botões com e sem ícone mantêm o texto centralizado
		var r := TextureRect.new()
		r.texture = tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		r.offset_left = 12
		r.offset_right = 12 + px
		r.offset_top = -px * 0.5
		r.offset_bottom = px * 0.5
		b.add_child(r)
		# a placa sobe no hover e afunda ao clicar: o ícone acompanha
		b.draw.connect(func():
			var dy := button_lift(b)
			r.offset_top = -px * 0.5 + dy
			r.offset_bottom = px * 0.5 + dy)
	return b


## Deslocamento vertical da placa do botão no estado atual (ver PlateStyle.lift).
static func button_lift(b: Button) -> float:
	var key := "normal"
	match b.get_draw_mode():
		BaseButton.DRAW_HOVER:
			key = "hover"
		BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED:
			key = "pressed"
		BaseButton.DRAW_DISABLED:
			key = "disabled"
	var sb := b.get_theme_stylebox(key)
	return (sb as PlateStyle).lift if sb is PlateStyle else 0.0


## Envolve um controle numa margem (para o selo de custo das cartas não ser cortado dentro de rolagens).
static func padded(child: Control, px: int = 6) -> MarginContainer:
	var m := MarginContainer.new()
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "top", "right", "bottom"]:
		m.add_theme_constant_override("margin_" + side, px)
	m.add_child(child)
	return m


## Cria a camada de fundo padrão das telas (carvão com vinheta).
## art: nome da imagem em assets/art/backgrounds (ex.: "lab"); sem imagem, usa o gradiente.
static func add_background(parent: Control, tint: Color = Palette.CHARCOAL, art: String = "", dim: float = 0.35) -> Control:
	var bg := BackgroundView.new()
	bg.base_color = tint
	if not art.is_empty():
		bg.texture = Database.get_art("backgrounds", StringName(art))
		bg.dim = dim
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg


## Texto flutuante (dano, cura, etc.).
static func float_text(parent: Node, text: String, at: Vector2, color: Color, size: int = 30) -> void:
	var l := make_label(text, size, color, true)
	if number_font != null and (text.begins_with("-") or text.begins_with("+")):
		l.add_theme_font_override("font", number_font)
	l.add_theme_color_override("font_outline_color", Palette.CHARCOAL_DEEP)
	l.add_theme_constant_override("outline_size", 6)
	l.position = at - Vector2(20, 20)
	l.z_index = 50
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 60, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tw.tween_callback(l.queue_free)
