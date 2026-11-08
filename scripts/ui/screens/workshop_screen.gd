extends Control
## Oficina: melhorias permanentes do laboratório, pagas com partes de uma família.

var _list: VBoxContainer
var _header: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Color("#25221E"), "lab", 0.65) as BackgroundView
	bg.glow_color = Palette.BONE
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
	titles.add_child(UiTheme.make_label("Oficina do Laboratório", 34, Palette.BONE_LIGHT, true))
	_header = UiTheme.make_label("", 15, Palette.TEXT_DIM)
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
	var stock: PackedStringArray = []
	for f in [Family.Id.BLOODFANG, Family.Id.IRONBACK, Family.Id.VOIDSPAWN, Family.Id.ROTWALKER]:
		stock.append("%s %d" % [Family.get_name_of(f), Profile.get_family_material(f)])
	_header.text = "Pague com quaisquer partes da família indicada (as mais abundantes são usadas primeiro).   Estoque: " + "  ·  ".join(stock)
	for c in _list.get_children():
		c.queue_free()
	for u in Database.get_sorted_upgrades():
		_list.add_child(_row(u))


func _row(u: LabUpgradeData) -> Control:
	var owned := Profile.lab_upgrades.has(u.id)
	var locked := not u.requires.is_empty() and not Profile.lab_upgrades.has(u.requires)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.PANEL if owned else Palette.CHARCOAL,
		Palette.BONE if owned else Palette.INK_SOFT, 2 if owned else 1, 8, 12))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	p.add_child(h)
	var art := MotifArt.new()
	art.custom_minimum_size = Vector2(80, 80)
	art.setup(u.art_motif, Palette.BONE, Database.get_art("upgrades", u.id))
	h.add_child(art)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	v.add_child(UiTheme.make_label(u.display_name + ("  — instalada" if owned else ""), 20, Palette.BONE_LIGHT, true))
	v.add_child(UiTheme.make_label(u.description, 15, Palette.PAPER))
	var cost := HFlowContainer.new()
	cost.add_theme_constant_override("h_separation", 12)
	v.add_child(cost)
	if locked:
		var req: LabUpgradeData = Database.lab_upgrades.get(u.requires)
		cost.add_child(UiTheme.make_label("Requer: %s" % (req.display_name if req else String(u.requires)), 14, Palette.BLOOD_BRIGHT))
	for f in u.family_cost:
		var have := Profile.get_family_material(int(f))
		var need := int(u.family_cost[f])
		cost.add_child(UiTheme.make_label("%s %d/%d" % [Family.get_name_of(int(f)), have, need], 15,
			Family.get_color(int(f)) if have >= need else Palette.BLOOD_BRIGHT))
	var b := Button.new()
	b.custom_minimum_size = Vector2(150, 44)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.text = "Instalada" if owned else "Construir"
	b.disabled = owned or not Profile.can_buy_upgrade(u)
	b.pressed.connect(func():
		if Profile.buy_upgrade(u):
			Sfx.play(&"unlock")
			_refresh())
	h.add_child(b)
	return p
