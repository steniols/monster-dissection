extends Control
## Câmara de mutação: instalar/remover alterações biológicas usando materiais.

const LabScreen := preload("res://scripts/ui/screens/laboratory_screen.gd")

var _list: VBoxContainer
var _header: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Color("#221E26"), "lab", 0.65) as BackgroundView
	bg.glow_color = Palette.VIOLET
	bg.glow_center = Vector2(0.5, 0.2)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 32
	root.offset_right = -32
	root.offset_top = 18
	root.offset_bottom = -18
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	titles.add_child(UiTheme.make_label("Câmara de Mutação", 32, Palette.VIOLET_BRIGHT, true))
	_header = UiTheme.make_label("", 15, Palette.TEXT_DIM)
	_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_header)
	top.add_child(UiTheme.make_button("Voltar ao laboratório", func(): Game.goto("lab")))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)
	_refresh()


func _refresh() -> void:
	_header.text = "Mutações instaladas: %d / %d   ·   Pontos de corrupção: %d   ·   Remover descarta o tecido.\nCada mutação soma pontos de corrupção. A cada %d pontos, você inicia a batalha com 1 de Corrupção (atual: %d)." % [
		Profile.mutations.size(), Profile.MAX_MUTATIONS, Profile.get_corruption(), Profile.CORRUPTION_STEP, Profile.get_starting_corruption_stacks()]
	for c in _list.get_children():
		c.queue_free()
	var all: Array[MutationData] = []
	for m: MutationData in Database.mutations.values():
		all.append(m)
	all.sort_custom(func(a: MutationData, b: MutationData) -> bool: return a.family < b.family)
	for m in all:
		_list.add_child(_row(m))


func _row(m: MutationData) -> Control:
	var installed := Profile.mutations.has(m.id)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.PANEL if installed else Palette.CHARCOAL,
		Family.get_color(m.family) if installed else Family.get_dark_color(m.family), 2 if installed else 1, 8, 12))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	p.add_child(h)
	var art := MotifArt.new()
	art.custom_minimum_size = Vector2(90, 90)
	art.setup(m.art_motif, Family.get_color(m.family), Database.get_art("mutations", m.id))
	h.add_child(art)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	v.add_child(UiTheme.make_label("%s%s" % [m.display_name, "  — instalada" if installed else ""], 20, Family.get_color(m.family), true))
	var d := UiTheme.make_label(m.description, 15, Palette.PAPER)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(d)
	var cost := HFlowContainer.new()
	cost.add_theme_constant_override("h_separation", 8)
	v.add_child(cost)
	cost.add_child(UiTheme.make_label("Custo:", 14, Palette.TEXT_DIM))
	for k in m.material_cost:
		var part := Database.get_part(StringName(k))
		if part != null:
			var known := Profile.is_part_known(part.id) or Profile.get_material(part.id) > 0
			if known:
				cost.add_child(LabScreen.material_chip(part, Profile.get_material(part.id), int(m.material_cost[k])))
			else:
				cost.add_child(UiTheme.make_label("??? (parte desconhecida) ×%d" % int(m.material_cost[k]), 14, Palette.BLOOD_BRIGHT))
	cost.add_child(UiTheme.make_label("  +%d %s de corrupção" % [m.corruption, "ponto" if m.corruption == 1 else "pontos"], 14, Palette.VIOLET_BRIGHT))
	var b := Button.new()
	b.custom_minimum_size = Vector2(150, 44)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if installed:
		b.text = "Remover"
		b.pressed.connect(func():
			Profile.remove_mutation(m.id)
			_refresh())
	else:
		b.text = "Instalar"
		b.disabled = not Profile.can_install(m)
		if Profile.mutations.size() >= Profile.MAX_MUTATIONS:
			b.tooltip_text = "Sem espaço para novas mutações."
		b.pressed.connect(func():
			Profile.install_mutation(m)
			_refresh())
	h.add_child(b)
	return p
