extends Control
## Mesa de dissecação: regiões selecionáveis, condição do corpo, extração com chance visível,
## e escolha de carta para o baralho da expedição.

const STATE_COLORS := {
	BodyCondition.State.INTACT: Palette.MOSS_BRIGHT,
	BodyCondition.State.DAMAGED: Palette.BONE,
	BodyCondition.State.LOST: Palette.BLOOD_BRIGHT,
}

var session: DissectionSession
var _selected: AnatomyPart

var _art: MonsterArt
var _markers: Control
var _incisions_label: Label
var _part_list: VBoxContainer
var _detail: VBoxContainer
var _finish_btn: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var entry: Dictionary
	if RunState.dissection_queue.is_empty():
		entry = _debug_entry()
	else:
		entry = RunState.dissection_queue.pop_front()
	session = DissectionSession.new(entry["monster"], entry["condition"], Profile.get_incisions())
	_build_ui()
	if not session.monster.parts.is_empty():
		_select(session.monster.parts[0])
	_refresh()


func _debug_entry() -> Dictionary:
	if not RunState.active:
		RunState.start(Database.expeditions.get(Database.DEFAULT_EXPEDITION))
	var data: MonsterData = Database.get_monster(&"bloodfang")
	var m := MonsterCombatant.new(data)
	m.take_damage(m.hp + 7, null, true)
	return {"monster": data, "condition": BodyCondition.from_combatant(m)}


func _build_ui() -> void:
	var bg := UiTheme.add_background(self, Color("#262420"), "dissection", 0.4) as BackgroundView
	bg.glow_color = Palette.MOSS
	bg.glow_center = Vector2(0.32, 0.45)

	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_right = -24
	root.offset_top = 16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 20)
	add_child(root)

	# --- Esquerda: mesa -----------------------------------------------------
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.4
	left.add_theme_constant_override("separation", 8)
	root.add_child(left)

	var title := UiTheme.make_label("Mesa de Dissecação", 30, Palette.BONE_LIGHT, true)
	left.add_child(title)
	var sub := UiTheme.make_label("Espécime: %s — %s (%s)" % [session.monster.display_name, Family.get_name_of(session.monster.family),
		Family.EPITHETS.get(session.monster.family, "")], 16, Family.get_color(session.monster.family))
	left.add_child(sub)

	var table := PanelContainer.new()
	table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	table.add_theme_stylebox_override("panel", UiTheme.panel_style(Color("#3B3328"), Palette.BONE.darkened(0.4), 2, 8, 10))
	left.add_child(table)
	var stage := Control.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	table.add_child(stage)
	var sheet := MotifArt.new()
	sheet.motif = &""
	sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
	sheet.modulate = Color(1, 1, 1, 0.18)
	sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(sheet)
	_art = MonsterArt.new()
	_art.animate = false
	_art.setup(session.monster)
	_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	_art.offset_left = 20
	_art.offset_right = -20
	_art.offset_top = 10
	_art.offset_bottom = -10
	_art.modulate = Color(0.85, 0.8, 0.78)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(_art)
	_markers = Control.new()
	_markers.set_anchors_preset(Control.PRESET_FULL_RECT)
	_markers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.add_child(_markers)
	_art.resized.connect(_rebuild_markers)

	var notes_panel := PanelContainer.new()
	notes_panel.add_theme_stylebox_override("panel", UiTheme.panel_style(Color(Palette.CHARCOAL_DEEP, 0.9), Palette.INK_SOFT, 1, 6, 10))
	left.add_child(notes_panel)
	var notes := VBoxContainer.new()
	notes_panel.add_child(notes)
	notes.add_child(UiTheme.make_label("Condição do corpo", 15, Palette.BONE, true))
	for n in session.condition.notes:
		var l := UiTheme.make_label("• " + n, 14, Palette.PAPER)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notes.add_child(l)

	# --- Direita: partes ----------------------------------------------------
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	root.add_child(right)

	_incisions_label = UiTheme.make_label("", 18, Palette.BONE_LIGHT, true)
	_incisions_label.add_theme_font_override("font", UiTheme.number_font)
	right.add_child(_incisions_label)
	var hint := UiTheme.make_label("Cada incisão tenta extrair uma parte. Partes danificadas mantêm %d%% da chance." % roundi(session.condition.damaged_multiplier * 100), 13, Palette.TEXT_DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(hint)

	_part_list = VBoxContainer.new()
	_part_list.add_theme_constant_override("separation", 4)
	right.add_child(_part_list)

	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(detail_panel)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 6)
	detail_panel.add_child(_detail)

	_finish_btn = UiTheme.make_button("Concluir dissecação", _show_summary)
	_finish_btn.custom_minimum_size.y = 46
	right.add_child(_finish_btn)


func _rebuild_markers() -> void:
	for c in _markers.get_children():
		c.queue_free()
	var by_region := {}
	for p in session.monster.parts:
		if not by_region.has(p.region):
			by_region[p.region] = []
		by_region[p.region].append(p)
	for region in by_region:
		var parts: Array = by_region[region]
		var state := session.condition.get_state(region)
		var pos := _art.region_point(region)
		var m := RegionMarker.new()
		m.color = STATE_COLORS[state]
		m.lost = state == BodyCondition.State.LOST
		m.label = AnatomyPart.region_name(region)
		m.position = pos - Vector2(18, 18)
		m.tooltip_text = "%s — %s\n%s" % [AnatomyPart.region_name(region), BodyCondition.state_name(state), session.condition.get_reason(region)]
		m.clicked.connect(func(): _cycle_region(parts))
		m.active = _selected != null and _selected.region == region
		_markers.add_child(m)


func _cycle_region(parts: Array) -> void:
	var idx := parts.find(_selected)
	_select(parts[(idx + 1) % parts.size()])


func _select(p: AnatomyPart) -> void:
	_selected = p
	_refresh()


func _refresh() -> void:
	_incisions_label.text = "Incisões restantes: %d de %d" % [session.incisions_left, Profile.get_incisions()]

	for c in _part_list.get_children():
		c.queue_free()
	for p in session.monster.parts:
		_part_list.add_child(_make_part_row(p))
	_rebuild_detail()
	_rebuild_markers()
	_finish_btn.text = "Ver resultado" if session.is_finished() else "Concluir dissecação"


func _make_part_row(p: AnatomyPart) -> Button:
	var state := session.condition.get_state(p.region)
	var chance := session.condition.chance_for(p)
	var b := Button.new()
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 15)
	var result := ""
	if session.results.has(p.id):
		result = "  ✓ extraída" if session.results[p.id] else "  ✗ rompida"
	var chance_txt := "—" if state == BodyCondition.State.LOST else "%d%%" % roundi(chance * 100)
	b.text = "%s  ·  %s  ·  %s  ·  %s%s" % [p.display_name, AnatomyPart.region_name(p.region), BodyCondition.state_name(state), chance_txt, result]
	b.add_theme_color_override("font_color", STATE_COLORS[state] if not session.results.has(p.id) else Palette.TEXT_DIM)
	if p == _selected:
		var sel: PlateStyle = PlateStyle.states("normal")["hover"]
		sel.top = Color("#6E5D45")
		sel.bottom = Color("#4C4033")
		sel.brass = Palette.BONE_LIGHT
		b.add_theme_stylebox_override("normal", sel)
		b.add_theme_stylebox_override("hover", sel)
	b.pressed.connect(_select.bind(p))
	return b


func _rebuild_detail() -> void:
	for c in _detail.get_children():
		c.queue_free()
	if _selected == null:
		return
	var p := _selected
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	_detail.add_child(head)
	var icon := MotifArt.new()
	icon.custom_minimum_size = Vector2(84, 84)
	icon.setup(p.art_motif, Family.get_color(p.family), p.icon)
	head.add_child(icon)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(info)
	info.add_child(UiTheme.make_label(p.display_name, 22, Palette.BONE_LIGHT, true))
	info.add_child(UiTheme.make_label("Raridade: %s · Chance base %d%%" % [CardData.RARITY_NAMES[p.rarity], roundi(p.preserve_chance * 100)], 13, Palette.TEXT_DIM))
	var desc := UiTheme.make_label(p.description, 14, Palette.PAPER)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	_detail.add_child(body)
	if p.unlocks_card != null:
		var cv := CardView.create(p.unlocks_card)
		cv.interactive = false
		body.add_child(cv)
	var actions := VBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation", 8)
	body.add_child(actions)
	if p.unlocks_card != null:
		var known := Profile.is_card_unlocked(p.unlocks_card.id)
		var copies := Profile.get_card_copies(p.unlocks_card.id)
		var msg := "Extrair desbloqueia esta carta permanentemente."
		if known and copies >= Profile.MAX_EARNED_COPIES:
			msg = "Carta catalogada, com todas as %d cópias." % Profile.MAX_EARNED_COPIES
		elif known:
			msg = "Extrair dá mais uma cópia para o baralho inicial (%d/%d)." % [copies, Profile.MAX_EARNED_COPIES]
		var l := UiTheme.make_label(msg, 14, Palette.TEXT_DIM if known and copies >= Profile.MAX_EARNED_COPIES else Palette.MOSS_BRIGHT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		actions.add_child(l)
	var state := session.condition.get_state(p.region)
	var reason := session.condition.get_reason(p.region)
	if not reason.is_empty():
		var r := UiTheme.make_label(reason, 14, STATE_COLORS[state])
		r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		actions.add_child(r)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 48)
	if session.results.has(p.id):
		btn.text = "Já processada"
		btn.disabled = true
	elif state == BodyCondition.State.LOST:
		btn.text = "Parte perdida"
		btn.disabled = true
	elif session.incisions_left <= 0:
		btn.text = "Sem incisões"
		btn.disabled = true
	else:
		btn.text = "Extrair (%d%%)" % roundi(session.condition.chance_for(p) * 100)
		btn.theme_type_variation = "PrimaryButton"
		btn.pressed.connect(_extract.bind(p))
	actions.add_child(btn)


func _extract(p: AnatomyPart) -> void:
	var ok := session.attempt(p)
	var pos := _art.global_position + _art.region_point(p.region)
	if ok:
		var new_card := RunState.gather(p)
		Sfx.play(&"cut")
		Fx.burst(self, pos, Family.get_color(p.family), 20, 200)
		UiTheme.float_text(self, "Extraída!", pos, Palette.MOSS_BRIGHT, 28)
		if new_card:
			Sfx.play(&"unlock", -2.0)
			UiTheme.float_text(self, "Nova carta: %s" % p.unlocks_card.display_name, pos + Vector2(-40, 40), Palette.BONE_LIGHT, 20)
		elif p.unlocks_card != null:
			UiTheme.float_text(self, "+1 cópia: %s (%d/%d)" % [p.unlocks_card.display_name, Profile.get_card_copies(p.unlocks_card.id), Profile.MAX_EARNED_COPIES], pos + Vector2(-40, 40), Palette.BONE_LIGHT, 20)
	else:
		Sfx.play(&"fail")
		UiTheme.float_text(self, "Tecido rompido", pos, Palette.BLOOD_BRIGHT, 28)
	_refresh()


# --- Resumo -----------------------------------------------------------------

func _show_summary() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.02, 0.03, 0.9)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	var title := UiTheme.make_label("Registro da dissecação", 34, Palette.BONE_LIGHT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	if session.collected.is_empty():
		var l := UiTheme.make_label("Nenhuma parte foi preservada desta vez.", 18, Palette.TEXT_DIM)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
		var b := UiTheme.make_button("Continuar", Game.on_dissection_done, 220)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(b)
		return

	var names: PackedStringArray = []
	for p in session.collected:
		names.append(p.display_name)
	var got := UiTheme.make_label("Materiais coletados: " + ", ".join(names), 17, Palette.MOSS_BRIGHT)
	got.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(got)
	var ask := UiTheme.make_label("Escolha uma carta para adicionar ao baralho desta expedição:", 17, Palette.PAPER)
	ask.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ask)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	box.add_child(row)
	var offered := {}
	for p in session.collected:
		if p.unlocks_card == null or offered.has(p.unlocks_card.id):
			continue
		offered[p.unlocks_card.id] = true
		var cv := CardView.create(p.unlocks_card)
		var card := p.unlocks_card
		cv.pressed.connect(func(_v):
			RunState.deck.append(card.id)
			Game.on_dissection_done())
		row.add_child(cv)

	var skip := UiTheme.make_button("Não adicionar (guardar apenas o material)", Game.on_dissection_done)
	skip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(skip)


class RegionMarker:
	extends Control
	signal clicked
	var color := Palette.MOSS_BRIGHT
	var lost := false
	var active := false
	var label := ""
	var _t := 0.0

	func _init() -> void:
		size = Vector2(36, 36)
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _process(d: float) -> void:
		_t += d
		queue_redraw()

	func _gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
			accept_event()

	func _draw() -> void:
		var c := size * 0.5
		var pulse := 1.0 + sin(_t * 3.0) * 0.12
		draw_circle(c, 16 * pulse, Color(color, 0.18))
		draw_arc(c, 11, 0, TAU, 24, color, 2.5 if not active else 4.0, true)
		if lost:
			draw_line(c + Vector2(-6, -6), c + Vector2(6, 6), color, 3.0)
			draw_line(c + Vector2(6, -6), c + Vector2(-6, 6), color, 3.0)
		else:
			draw_circle(c, 4, color)
		if active:
			var font := get_theme_default_font()
			draw_string_outline(font, Vector2(c.x + 18, c.y + 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Palette.CHARCOAL_DEEP)
			draw_string(font, Vector2(c.x + 18, c.y + 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.PAPER)
