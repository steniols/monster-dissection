class_name PlayerPanel
extends HBoxContainer
## Retrato do caçador, vida, armadura, status e orbe de energia.

var player: PlayerCombatant

var _art: HunterArt
var _bar: HealthBar
var _statuses: StatusRow
var _energy: EnergyOrb


func setup(p: PlayerCombatant) -> void:
	player = p
	add_theme_constant_override("separation", 10)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_energy = EnergyOrb.new()
	_energy.custom_minimum_size = Vector2(76, 76)
	_energy.size_flags_vertical = Control.SIZE_SHRINK_END
	add_child(_energy)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_END
	col.add_theme_constant_override("separation", 4)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)

	_art = HunterArt.new()
	_art.custom_minimum_size = Vector2(150, 150)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_art)

	var title := UiTheme.make_label("O Pesquisador", 16, Palette.BONE_LIGHT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	_bar = HealthBar.new()
	_bar.custom_minimum_size = Vector2(180, 20)
	col.add_child(_bar)

	_statuses = StatusRow.new()
	_statuses.custom_minimum_size = Vector2(180, 22)
	col.add_child(_statuses)

	p.hp_changed.connect(func(_a, _b): _refresh())
	p.block_changed.connect(func(_b): _refresh())
	p.statuses_changed.connect(_refresh)
	p.energy_changed.connect(func(e, m): _energy.set_energy(e, m))
	p.damaged.connect(_on_damaged)
	p.healed.connect(func(a): UiTheme.float_text(get_tree().current_scene, "+%d" % a, _float_pos(), Palette.MOSS_BRIGHT))
	_refresh()
	_energy.set_energy(p.energy, p.max_energy)


func _refresh() -> void:
	_bar.set_values(player.hp, player.max_hp, player.block, player.get_status(&"bleed") + player.get_status(&"corruption"))
	_statuses.refresh(player.statuses)


func _on_damaged(amount: int, blocked: int) -> void:
	if amount > 0:
		UiTheme.float_text(get_tree().current_scene, "-%d" % amount, _float_pos(), Palette.BLOOD_BRIGHT)
		_art.modulate = Color(1.8, 0.6, 0.6)
		_art.create_tween().tween_property(_art, "modulate", Color.WHITE, 0.3)
	elif blocked > 0:
		UiTheme.float_text(get_tree().current_scene, "Bloqueado", _float_pos(), Palette.PETROL_BRIGHT, 20)


func _float_pos() -> Vector2:
	return _art.global_position + Vector2(_art.size.x * 0.5, 20)


func get_energy_orb() -> Control:
	return _energy


class HunterArt:
	extends Control
	var _t := 0.0

	func _process(d: float) -> void:
		_t += d
		queue_redraw()

	func _draw() -> void:
		ProceduralArt.draw_hunter(self, Rect2(Vector2.ZERO, size), _t)


class EnergyOrb:
	extends Control
	var energy := 3
	var max_energy := 3

	func set_energy(e: int, m: int) -> void:
		energy = e
		max_energy = m
		tooltip_text = "Energia: %d de %d.\nCartas custam energia para serem jogadas." % [e, m]
		queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r: float = min(size.x, size.y) * 0.45
		var col := Palette.PETROL_BRIGHT if energy > 0 else Palette.INK_SOFT
		for i in 5:
			draw_circle(c, r * (1.25 - i * 0.06), Color(col, 0.05))
		draw_circle(c, r, Palette.CHARCOAL_DEEP)
		draw_circle(c, r * 0.82, Color(col, 0.35))
		draw_arc(c, r, 0, TAU, 40, col, 3.0, true)
		var font := UiTheme.title_font if UiTheme.title_font != null else get_theme_default_font()
		var txt := "%d/%d" % [energy, max_energy]
		var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		draw_string_outline(font, c + Vector2(-w * 0.5, 9), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 4, Palette.CHARCOAL_DEEP)
		draw_string(font, c + Vector2(-w * 0.5, 9), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.PAPER)
