class_name PlayerPanel
extends VBoxContainer
## Personagem em cima; embaixo, numa faixa só, o orbe de energia e a vida (com os status abaixo dela).

var player: PlayerCombatant

var _art: HunterArt
var _bar: HealthBar
var _statuses: StatusRow
var _energy: EnergyOrb


func setup(p: PlayerCombatant) -> void:
	player = p
	alignment = BoxContainer.ALIGNMENT_END
	add_theme_constant_override("separation", 4)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_art = HunterArt.new()
	_art.custom_minimum_size = Vector2(230, 150)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_art)

	# energia no canto superior esquerdo, ao lado da cabeça
	_energy = EnergyOrb.new()
	_energy.size = Vector2(70, 70)
	_energy.position = Vector2(0, 0)
	_art.add_child(_energy)

	# vida centralizada logo abaixo do personagem, status embaixo dela
	_bar = HealthBar.new()
	_bar.custom_minimum_size = Vector2(170, 22)
	_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(_bar)

	_statuses = StatusRow.new()
	_statuses.custom_minimum_size = Vector2(170, 22)
	_statuses.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_statuses.alignment = FlowContainer.ALIGNMENT_CENTER
	add_child(_statuses)

	p.hp_changed.connect(func(_a, _b): _refresh())
	p.block_changed.connect(func(_b): _refresh())
	p.statuses_changed.connect(_refresh)
	p.energy_changed.connect(func(e, m): _energy.set_energy(e, m))
	p.damaged.connect(_on_damaged)
	p.healed.connect(func(a):
		Sfx.play(&"heal", -6.0)
		UiTheme.float_text(get_tree().current_scene, "+%d" % a, _float_pos(), Palette.MOSS_BRIGHT))
	p.cheated_death.connect(func():
		Sfx.play(&"instinct")
		Fx.burst(get_tree().current_scene, _float_pos(), Palette.SICK_GREEN, 30, 260)
		UiTheme.float_text(get_tree().current_scene, "Imortalidade Pútrida!", _float_pos() + Vector2(-60, -30), Palette.SICK_GREEN, 24))
	_refresh()
	_energy.set_energy(p.energy, p.max_energy)


func _refresh() -> void:
	_bar.set_values(player.hp, player.max_hp, player.block, player.get_status(&"bleed") + player.get_status(&"corruption"))
	_statuses.refresh(player.statuses)


func _on_damaged(amount: int, blocked: int) -> void:
	if blocked > 0:
		Sfx.play(&"block", -4.0)
		Fx.burst(get_tree().current_scene, _float_pos() + Vector2(0, 40), Palette.PETROL_BRIGHT, 10, 180)
	if amount > 0:
		var big := amount >= 10
		Sfx.play(&"hit_big" if big else &"hit")
		Fx.shake(get_tree().current_scene, 12.0 if big else 6.0, 0.25)
		Fx.burst(get_tree().current_scene, _float_pos() + Vector2(0, 40), Palette.BLOOD_BRIGHT, 16, 220)
		if big:
			Fx.hit_stop(0.06)
		UiTheme.float_text(get_tree().current_scene, "-%d" % amount, _float_pos(), Palette.BLOOD_BRIGHT)
		_art.modulate = Color(1.8, 0.6, 0.6)
		_art.create_tween().tween_property(_art, "modulate", Color.WHITE, 0.3)
	elif blocked > 0:
		UiTheme.float_text(get_tree().current_scene, "Bloqueado", _float_pos(), Palette.PETROL_BRIGHT, 20)


func _float_pos() -> Vector2:
	return _art.global_position + Vector2(_art.size.x * 0.5, 20)


## Chamado quando uma carta é jogada.
func cast(card: CardData) -> void:
	var col: Color = Family.get_color(card.family) if card.family != Family.Id.NEUTRAL else CardView.TYPE_COLORS.get(card.card_type, Palette.PETROL_BRIGHT)
	_art.cast(col)


func get_energy_orb() -> Control:
	return _energy


class HunterArt:
	extends Control
	## Com `assets/art/ui/player.png`, mostra o retrato (respirando e conjurando); sem ele, o vulto desenhado.
	## Com `assets/art/ui/player_cast.png`, troca para essa pose por um instante ao jogar uma carta.
	## Pontos em fração da imagem: mãos (de onde sai o brilho) e centro do corpo (fica no meio do espaço).
	const HANDS := Vector2(0.79, 0.265)
	const BODY_X := 0.4
	const HANDS_CAST := Vector2(0.85, 0.3)
	const BODY_X_CAST := 0.4
	## Quanto tempo a pose de conjurar fica (segundos), contando a volta.
	const CAST_TIME := 0.7
	var _t := 0.0
	var _cast := 0.0
	var _cast_color := Palette.PETROL_BRIGHT
	var _tex: Texture2D
	var _tex_cast: Texture2D

	func _ready() -> void:
		_tex = Database.get_art("ui", &"player")
		_tex_cast = Database.get_art("ui", &"player_cast")
		if _tex != null:
			custom_minimum_size = Vector2(230, 280)

	## Gesto de conjurar ao jogar uma carta: troca de pose (ou avança) e acende as mãos na cor da carta.
	func cast(color: Color) -> void:
		_cast = 1.0
		_cast_color = color

	func _process(d: float) -> void:
		_t += d
		_cast = maxf(0.0, _cast - d / CAST_TIME)
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		if _tex == null:
			ProceduralArt.draw_hunter(self, r, _t)
			return
		var breathe := 1.0 + 0.012 * sin(_t * 2.0)
		if _tex_cast == null:
			var dst := _place(_tex, BODY_X, breathe, 8.0 * _cast)
			draw_texture_rect(_tex, dst, false)
			_draw_glow(dst.position + dst.size * HANDS, _cast)
			return
		# troca rápida para a pose de conjurar, segura e volta devagar
		var k := clampf(_cast / 0.6, 0.0, 1.0)
		var base := _place(_tex, BODY_X, breathe, 0.0)
		var pose := _place(_tex_cast, BODY_X_CAST, breathe, 0.0)
		if k < 1.0:
			draw_texture_rect(_tex, base, false, Color(1, 1, 1, 1.0 - k))
		if k > 0.0:
			draw_texture_rect(_tex_cast, pose, false, Color(1, 1, 1, k))
		var hands := (base.position + base.size * HANDS).lerp(pose.position + pose.size * HANDS_CAST, k)
		_draw_glow(hands, _cast)

	## Retângulo da imagem: pela altura (os braços podem passar da largura, na direção das cartas).
	func _place(tex: Texture2D, body_x: float, breathe: float, push: float) -> Rect2:
		var ts := tex.get_size()
		var s := size.y / ts.y
		var w := ts.x * s
		var h := ts.y * s * breathe
		return Rect2(size.x * 0.5 - w * body_x + push, size.y - h, w, h)

	func _draw_glow(at: Vector2, power: float) -> void:
		var glow := 0.35 + 0.15 * sin(_t * 3.0) + power * 0.9
		for i in 6:
			draw_circle(at, 6.0 + i * 5.0 + power * 14.0, Color(_cast_color, glow * 0.09))


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
		var font: Font = UiTheme.number_font if UiTheme.number_font != null else get_theme_default_font()
		var txt := "%d/%d" % [energy, max_energy]
		var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
		draw_string_outline(font, c + Vector2(-w * 0.5, 9), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 4, Palette.CHARCOAL_DEEP)
		draw_string(font, c + Vector2(-w * 0.5, 9), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Palette.PAPER)
