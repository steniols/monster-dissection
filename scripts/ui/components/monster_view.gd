class_name MonsterView
extends VBoxContainer
## Monstro em combate: intenção, retrato, nome, vida e status.

signal pressed(view: MonsterView)

var monster: MonsterCombatant
var combat: CombatManager
var targetable: bool = false:
	set(v):
		targetable = v
		# mãozinha só quando dá para escolher este monstro como alvo
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if v else Control.CURSOR_ARROW
		_update_target_highlight()

var _intent_icon: IconView
var _intent_label: Label
var _intent_panel: PanelContainer
var _art: MonsterArt
var _name: Label
var _bar: HealthBar
var _statuses: StatusRow
var _target_marker: Label


func setup(m: MonsterCombatant, c: CombatManager) -> void:
	monster = m
	combat = c
	alignment = BoxContainer.ALIGNMENT_END
	add_theme_constant_override("separation", 4)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	_intent_panel = PanelContainer.new()
	_intent_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_intent_panel.add_theme_stylebox_override("panel", UiTheme.panel_style(Color(Palette.CHARCOAL_DEEP, 0.85), Palette.INK_SOFT, 1, 12, 6))
	_intent_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_intent_panel.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and not e.pressed and e.button_index == MOUSE_BUTTON_LEFT and monster != null and monster.current_intent != null:
			var txt := monster.current_intent.describe()
			var terms := InfoPopup.explain(txt)
			InfoPopup.open(_intent_panel, "Intenção: %s" % monster.current_intent.display_name, txt + ("

" + terms if not terms.is_empty() else ""))
			_intent_panel.accept_event())
	var ib := HBoxContainer.new()
	ib.add_theme_constant_override("separation", 6)
	ib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intent_icon = IconView.create(&"attack", Palette.BLOOD_BRIGHT, 26)
	_intent_label = UiTheme.make_label("", 18, Palette.PAPER, true)
	_intent_label.add_theme_font_override("font", UiTheme.number_font)
	_intent_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ib.add_child(_intent_icon)
	ib.add_child(_intent_label)
	_intent_panel.add_child(ib)
	add_child(_intent_panel)

	_art = MonsterArt.new()
	_art.custom_minimum_size = Vector2(300, 220) * m.data.scale
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.pivot_offset = _art.custom_minimum_size * Vector2(0.5, 1.0)
	_art.setup(m.data)
	add_child(_art)

	_target_marker = UiTheme.make_label("▼ alvo", 13, Palette.BONE_LIGHT)
	_target_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_target_marker.modulate.a = 0.0
	_target_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_name = UiTheme.make_label(m.display_name, 18, Family.get_color(m.data.family), true)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name)

	_bar = HealthBar.new()
	_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bar.custom_minimum_size = Vector2(200, 20)
	add_child(_bar)

	_statuses = StatusRow.new()
	_statuses.alignment = FlowContainer.ALIGNMENT_CENTER
	_statuses.custom_minimum_size = Vector2(220, 22)
	_statuses.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(_statuses)
	add_child(_target_marker)

	m.hp_changed.connect(func(_a, _b): _refresh())
	m.block_changed.connect(func(_b): _refresh())
	m.statuses_changed.connect(_refresh)
	m.intent_changed.connect(refresh_intent)
	m.damaged.connect(_on_damaged)
	m.healed.connect(func(a): UiTheme.float_text(_float_parent(), "+%d" % a, _float_pos(), Palette.MOSS_BRIGHT))
	m.died.connect(_on_died)
	m.cheated_death.connect(func():
		Sfx.play(&"instinct")
		Fx.burst(_float_parent(), _float_pos(), Palette.SICK_GREEN, 30, 260)
		UiTheme.float_text(_float_parent(), "Recusa-se a morrer!", _float_pos() + Vector2(-60, -30), Palette.SICK_GREEN, 24))
	_refresh()
	refresh_intent()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(self)
		accept_event()


func _refresh() -> void:
	_bar.set_values(monster.hp, monster.max_hp, monster.block, monster.get_status(&"bleed") + monster.get_status(&"corruption"))
	_statuses.refresh(monster.statuses)


func refresh_intent() -> void:
	if not monster.is_alive() or monster.current_intent == null:
		_intent_panel.modulate.a = 0.0
		return
	_intent_panel.modulate.a = 1.0
	var intent := monster.current_intent
	var icon := &"buff"
	var color := Palette.BONE_LIGHT
	var text := ""
	match intent.kind:
		MonsterIntent.Kind.ATTACK, MonsterIntent.Kind.ATTACK_DEBUFF, MonsterIntent.Kind.ATTACK_DEFEND:
			icon = &"attack"
			color = Palette.BLOOD_BRIGHT
		MonsterIntent.Kind.DEFEND:
			icon = &"shield"
			color = Palette.PETROL_BRIGHT
		MonsterIntent.Kind.BUFF:
			icon = &"buff"
			color = Palette.BONE_LIGHT
		MonsterIntent.Kind.DEBUFF:
			icon = &"debuff"
			color = Palette.VIOLET_BRIGHT
	if intent.is_attack() and combat != null:
		var dmg := combat.preview_intent_damage(monster)
		text = str(dmg.x) if dmg.y <= 1 else "%d×%d" % [dmg.x, dmg.y]
		if intent.kind == MonsterIntent.Kind.ATTACK_DEBUFF:
			text += " +"
		elif intent.kind == MonsterIntent.Kind.ATTACK_DEFEND:
			text += " ⛨"
	_intent_icon.set_icon(icon, color)
	_intent_label.text = text
	_intent_label.visible = not text.is_empty()
	_intent_panel.tooltip_text = "Intenção: %s\n%s" % [intent.display_name, CardView._strip_bbcode(intent.describe())]


func _on_damaged(amount: int, blocked: int) -> void:
	if blocked > 0:
		Sfx.play(&"block", -4.0)
		Fx.burst(_float_parent(), _float_pos(), Palette.PETROL_BRIGHT, 10, 180)
	if amount > 0:
		var big := amount >= 10
		Sfx.play(&"hit_big" if big else &"hit")
		Fx.burst(_float_parent(), _float_pos(), Palette.BLOOD_BRIGHT, 26 if big else 14, 300 if big else 220)
		if big:
			Fx.hit_stop(0.08)
		UiTheme.float_text(_float_parent(), "-%d" % amount, _float_pos(), Palette.BLOOD_BRIGHT, 38 if big else 30)
		var tw := _art.create_tween()
		_art.modulate = Color(1.8, 0.7, 0.7)
		tw.tween_property(_art, "modulate", Color.WHITE, 0.25)
		var base := _art.position
		var sh := _art.create_tween()
		for i in 4:
			sh.tween_property(_art, "position", base + Vector2(randf_range(-8, 8), randf_range(-3, 3)), 0.03)
		sh.tween_property(_art, "position", base, 0.03)
	elif blocked > 0:
		UiTheme.float_text(_float_parent(), "Bloqueado", _float_pos(), Palette.PETROL_BRIGHT, 20)


func _on_died() -> void:
	Sfx.play(&"death")
	_intent_panel.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_art, "modulate", Color(0.35, 0.33, 0.33, 0.7), 0.6)
	tw.tween_property(_art, "rotation", 0.08, 0.6)
	_name.text = "%s (abatido)" % monster.display_name
	mouse_default_cursor_shape = Control.CURSOR_ARROW


func play_attack_lunge() -> void:
	var tw := _art.create_tween()
	var base := _art.position
	tw.tween_property(_art, "position", base + Vector2(0, -10), 0.1)
	tw.tween_property(_art, "position", base + Vector2(0, 30), 0.08)
	tw.tween_property(_art, "position", base, 0.15)


func _update_target_highlight() -> void:
	if _target_marker != null:
		_target_marker.modulate.a = 1.0 if targetable and monster.is_alive() else 0.0
	if _art != null:
		var on := targetable and monster.is_alive()
		_art.highlight = (1.0 if _hovered else 0.55) if on else 0.0


var _hovered := false


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER or what == NOTIFICATION_MOUSE_EXIT:
		_hovered = what == NOTIFICATION_MOUSE_ENTER
		_update_target_highlight()


func _float_parent() -> Node:
	return get_tree().current_scene if get_tree() != null else self


func _float_pos() -> Vector2:
	return _art.global_position + Vector2(_art.size.x * 0.5, _art.size.y * 0.35)
