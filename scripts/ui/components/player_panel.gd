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
	_energy.size = Vector2(84, 84)
	_energy.position = Vector2(-6, -6)
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
		_art.hurt(2.0 if big else 1.0)
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


## Relógio comum do brilho da mão e do orbe de energia, para pulsarem juntos.
static func glow_time() -> float:
	return Time.get_ticks_msec() / 1000.0


class HunterArt:
	extends Control
	## Com `assets/art/ui/player.png`, mostra o retrato (respirando e conjurando); sem ele, o vulto desenhado.
	## Com `assets/art/ui/player_cast.png`, troca para essa pose por um instante ao jogar uma carta.
	## Com `assets/art/ui/player_hurt.png`, troca para essa pose ao tomar dano (sem ela, só o recuo).
	## Pontos em fração da imagem: mãos (de onde sai o brilho) e centro do corpo (fica no meio do espaço).
	const HANDS := Vector2(0.81, 0.27)
	const BODY_X := 0.38
	const HANDS_CAST := Vector2(0.865, 0.085)
	const BODY_X_CAST := 0.38
	const BODY_X_HURT := 0.38
	## Quanto tempo a pose de conjurar fica (segundos), contando a volta.
	const CAST_TIME := 0.7
	## Quanto tempo dura a reação ao dano (segundos).
	const HURT_TIME := 0.55
	var _t := 0.0
	var _cast := 0.0
	var _hurt := 0.0
	var _hurt_power := 1.0
	var _cast_color := Palette.PETROL_BRIGHT
	var _tex: Texture2D
	var _tex_cast: Texture2D
	var _tex_hurt: Texture2D

	func _ready() -> void:
		_tex = Database.get_art("ui", &"player")
		_tex_cast = Database.get_art("ui", &"player_cast")
		_tex_hurt = Database.get_art("ui", &"player_hurt")
		if _tex != null:
			custom_minimum_size = Vector2(230, 258)

	## Gesto de conjurar ao jogar uma carta: troca de pose (ou avança) e acende as mãos na cor da carta.
	func cast(color: Color) -> void:
		_cast = 1.0
		_cast_color = color

	## Reação ao dano: recua para trás (longe do monstro), inclina, pisca em vermelho e treme. power 1 = golpe normal, 2 = forte.
	func hurt(power: float) -> void:
		_hurt = 1.0
		_hurt_power = power
		_cast = 0.0

	func _process(d: float) -> void:
		_t += d
		_cast = maxf(0.0, _cast - d / CAST_TIME)
		_hurt = maxf(0.0, _hurt - d / HURT_TIME)
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		if _tex == null:
			ProceduralArt.draw_hunter(self, r, _t)
			return
		var breathe := 1.0 + 0.012 * sin(_t * 2.0)
		# recuo: sai rápido e volta com uma leve sobra (curva de mola), inclinando para trás a partir dos pés
		var e := _hurt * _hurt
		var recoil := -22.0 * _hurt_power * e
		var shake := sin(_t * 70.0) * 3.0 * _hurt_power * e
		var tilt := -0.07 * _hurt_power * e
		var feet := Vector2(size.x * 0.5, size.y)
		draw_set_transform(feet + Vector2(recoil + shake, 0), tilt, Vector2.ONE)
		var off := -feet
		var tint := Color(1, 1, 1).lerp(Color(1.6, 0.75, 0.72), clampf(_hurt * 1.4, 0.0, 1.0))
		if _hurt > 0.0 and _tex_hurt != null:
			var hp := _place(_tex_hurt, BODY_X_HURT, 1.0, 0.0)
			hp.position += off
			draw_texture_rect(_tex_hurt, hp, false, tint)
			draw_set_transform(Vector2.ZERO)
			return
		if _tex_cast == null:
			var dst := _place(_tex, BODY_X, breathe, 8.0 * _cast)
			dst.position += off
			draw_texture_rect(_tex, dst, false, tint)
			_draw_glow(dst.position + dst.size * HANDS, _cast)
			draw_set_transform(Vector2.ZERO)
			return
		# troca rápida para a pose de conjurar, segura e volta devagar
		var k := clampf(_cast / 0.6, 0.0, 1.0)
		var base := _place(_tex, BODY_X, breathe, 0.0)
		var pose := _place(_tex_cast, BODY_X_CAST, breathe, 0.0)
		base.position += off
		pose.position += off
		if k < 1.0:
			draw_texture_rect(_tex, base, false, Color(tint, 1.0 - k))
		if k > 0.0:
			draw_texture_rect(_tex_cast, pose, false, Color(tint, k))
		var hands := (base.position + base.size * HANDS).lerp(pose.position + pose.size * HANDS_CAST, k)
		_draw_glow(hands, _cast)
		draw_set_transform(Vector2.ZERO)

	## Retângulo da imagem: pela altura (os braços podem passar da largura, na direção das cartas).
	func _place(tex: Texture2D, body_x: float, breathe: float, push: float) -> Rect2:
		var ts := tex.get_size()
		var s := size.y / ts.y
		var w := ts.x * s
		var h := ts.y * s * breathe
		return Rect2(size.x * 0.5 - w * body_x + push, size.y - h, w, h)

	func _draw_glow(at: Vector2, power: float) -> void:
		var glow := 0.35 + 0.15 * sin(PlayerPanel.glow_time() * 3.0) + power * 0.9
		for i in 6:
			draw_circle(at, 6.0 + i * 5.0 + power * 14.0, Color(_cast_color, glow * 0.09))
		if power <= 0.0:
			return
		# ao conjurar: halo maior, núcleo claro e faíscas girando em volta da mão
		for i in 5:
			draw_circle(at, 18.0 + i * 9.0 + power * 26.0, Color(_cast_color, power * 0.08))
		draw_circle(at, 4.0 + power * 9.0, Color(_cast_color.lightened(0.55), power * 0.85))
		draw_circle(at, 2.0 + power * 4.0, Color(1, 1, 1, power * 0.9))
		var spin := PlayerPanel.glow_time() * 4.0
		for i in 6:
			var ang := spin + i * TAU / 6.0
			var dist := 14.0 + (1.0 - power) * 26.0
			draw_circle(at + Vector2(cos(ang), sin(ang)) * dist, 2.5 * power + 1.0, Color(_cast_color.lightened(0.4), power))


class EnergyOrb:
	extends Control
	## Com `assets/art/ui/orb_frame.png` e `orb_disc.png`: disco arcano pulsando (na cor e no ritmo do brilho
	## da mão do personagem) dentro da moldura de latão; sem os arquivos, o orbe desenhado em código.
	## Raio do disco em fração da largura da moldura (o furo da moldura tem ~0,34).
	const DISC_R := 0.35
	const GLOW := Palette.PETROL_BRIGHT
	var energy := 3
	var max_energy := 3
	var _frame: Texture2D
	var _disc: Texture2D

	func _ready() -> void:
		_frame = Database.get_art("ui", &"orb_frame")
		_disc = Database.get_art("ui", &"orb_disc")

	func set_energy(e: int, m: int) -> void:
		energy = e
		max_energy = m
		tooltip_text = "Energia: %d de %d.\nCartas custam energia para serem jogadas." % [e, m]
		queue_redraw()

	func _process(_d: float) -> void:
		if _disc != null:
			queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		if _frame != null and _disc != null:
			_draw_painted(c)
		else:
			_draw_plain(c)
		var font: Font = UiTheme.number_font if UiTheme.number_font != null else get_theme_default_font()
		var txt := "%d/%d" % [energy, max_energy]
		var fs := int(size.x * 0.27)
		var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var at := c + Vector2(-w * 0.5, fs * 0.36)
		draw_string_outline(font, at, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Palette.CHARCOAL_DEEP)
		draw_string(font, at, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Palette.PAPER)

	func _draw_painted(c: Vector2) -> void:
		var fs := _frame.get_size()
		var k := minf(size.x / fs.x, size.y / fs.y)
		var fw := fs.x * k
		# pulso no mesmo ritmo do brilho da mão (relógio compartilhado)
		var pulse := 0.5 + 0.5 * sin(PlayerPanel.glow_time() * 3.0)
		var tint: Color
		if energy > 0:
			tint = Color(0.55, 0.62, 0.62).lerp(Color(GLOW.r * 1.5, GLOW.g * 1.5, GLOW.b * 1.5), 0.45 + 0.35 * pulse)
		else:
			tint = Color(0.35, 0.36, 0.38)
		var r := fw * DISC_R
		# halo suave atrás do disco quando há energia
		if energy > 0:
			for i in 4:
				draw_circle(c, r * (1.08 + i * 0.07), Color(GLOW, (0.05 + 0.05 * pulse) * (1.0 - i * 0.2)))
		draw_texture_rect(_disc, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false, tint)
		draw_texture_rect(_frame, Rect2(c - fs * k * 0.5, fs * k), false)

	func _draw_plain(c: Vector2) -> void:
		var r: float = min(size.x, size.y) * 0.45
		var col := Palette.PETROL_BRIGHT if energy > 0 else Palette.INK_SOFT
		for i in 5:
			draw_circle(c, r * (1.25 - i * 0.06), Color(col, 0.05))
		draw_circle(c, r, Palette.CHARCOAL_DEEP)
		draw_circle(c, r * 0.82, Color(col, 0.35))
		draw_arc(c, r, 0, TAU, 40, col, 3.0, true)
