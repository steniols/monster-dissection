extends Control
## Tela de combate. Só apresenta e encaminha input; regras ficam em CombatManager.

var combat: CombatManager
var player: PlayerCombatant

var _monster_row: HBoxContainer
var _monster_views: Array[MonsterView] = []
var _player_panel: PlayerPanel
var _hand: HandView
var _end_turn: Button
var _draw_btn: Button
var _discard_btn: Button
var _exhaust_btn: Button
var _instinct_label: RichTextLabel
var _message: Label
var _banner: Label
var _pending: CardView


func _ready() -> void:
	if not RunState.active or RunState.current == null:
		_debug_setup()
	_build_ui()
	_start_combat()


## Permite rodar esta cena isolada (F6) para testes.
func _debug_setup() -> void:
	RunState.start(Database.expeditions.get(Database.DEFAULT_EXPEDITION))
	var nodes := RunState.get_available_nodes()
	RunState.current = nodes[0]


## Fundo de batalha por família de criatura (assets/art/backgrounds).
const BATTLE_BACKGROUNDS := {
	Family.Id.BLOODFANG: "battle_red_wasteland",
	Family.Id.IRONBACK: "battle_marsh",
	Family.Id.VOIDSPAWN: "battle_violet_cavern",
	Family.Id.ROTWALKER: "battle_ruins",
	Family.Id.SPOREMAW: "battle_fungal_hollow",
	Family.Id.ASHWING: "battle_ash_ridge",
}


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fam := RunState.current.monsters[0].family if not RunState.current.monsters.is_empty() else Family.Id.NEUTRAL
	# fundo de batalha neutro, escolhido pela família da criatura (cai no fundo da região se faltar)
	var battle_art: String = BATTLE_BACKGROUNDS.get(fam, "")
	if Database.get_art("backgrounds", StringName(battle_art)) == null:
		battle_art = String(RunState.expedition.id) if RunState.expedition else ""
	var bg := UiTheme.add_background(self, Palette.CHARCOAL, battle_art, 0.12) as BackgroundView
	bg.glow_color = Family.get_dark_color(fam)
	bg.glow_center = Vector2(0.5, 0.35)

	# chão: escurece em degradê a partir da linha onde os monstros pisam (sem corte reto na paisagem)
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.0))
	grad.set_color(1, Color(0, 0, 0, 0.45 if bg.texture != null else 0.3))
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill_from = Vector2(0, 0)
	gtex.fill_to = Vector2(0, 1)
	gtex.width = 4
	gtex.height = 128
	var floor_rect := TextureRect.new()
	floor_rect.texture = gtex
	floor_rect.stretch_mode = TextureRect.STRETCH_SCALE
	floor_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	floor_rect.anchor_top = 0.40
	floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_rect)

	# barra superior
	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 16
	top.offset_right = -16
	top.offset_top = 8
	top.custom_minimum_size.y = 36
	top.add_theme_constant_override("separation", 16)
	add_child(top)
	var where := "%s · Andar %d · %s" % [RunState.expedition.display_name, RunState.get_floor() + 1, RunState.current.get_type_name()]
	top.add_child(UiTheme.make_label(where, 16, Palette.TEXT_DIM, true))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	_instinct_label = UiTheme.make_rich("", 16)
	_instinct_label.custom_minimum_size = Vector2(360, 24)
	_instinct_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_instinct_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_instinct_label.tooltip_text = "Instinto: jogue %d cartas seguidas da mesma família para ativar seu efeito de conjunto.\nCartas de Instrumento não quebram a sequência.\n\n" % CombatManager.INSTINCT_THRESHOLD
	for f in Family.INSTINCT_NAMES:
		_instinct_label.tooltip_text += "%s — %s: %s\n" % [Family.get_name_of(f), Family.INSTINCT_NAMES[f], Family.INSTINCT_DESCRIPTIONS[f]]
	top.add_child(_instinct_label)
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer2)
	top.add_child(UiTheme.make_button("Baralho (%d)" % RunState.deck.size(), _show_run_deck))
	top.add_child(PauseMenu.make_gear_button())

	# monstros
	_monster_row = HBoxContainer.new()
	_monster_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_monster_row.add_theme_constant_override("separation", 48)
	_monster_row.set_anchors_preset(Control.PRESET_FULL_RECT)
	_monster_row.anchor_left = 0.22
	_monster_row.anchor_right = 0.86
	_monster_row.anchor_top = 0.07
	_monster_row.anchor_bottom = 0.64
	add_child(_monster_row)

	# mão
	_hand = HandView.new()
	_hand.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hand.anchor_left = 0.2
	_hand.anchor_right = 0.82
	_hand.offset_top = -250
	_hand.offset_bottom = 0
	_hand.card_pressed.connect(_on_card_pressed)
	add_child(_hand)

	# painel do jogador
	_player_panel = PlayerPanel.new()
	_player_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_player_panel.offset_left = 14
	_player_panel.offset_bottom = -14
	_player_panel.offset_top = -280
	_player_panel.offset_right = 290
	_player_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(_player_panel)

	# controles à direita
	var right := VBoxContainer.new()
	right.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	right.offset_left = -200
	right.offset_right = -16
	right.offset_top = -220
	right.offset_bottom = -16
	right.alignment = BoxContainer.ALIGNMENT_END
	right.add_theme_constant_override("separation", 6)
	add_child(right)
	_end_turn = UiTheme.make_button("Encerrar turno", _on_end_turn)
	_end_turn.custom_minimum_size = Vector2(184, 52)
	_end_turn.tooltip_text = "Atalho: E"
	_end_turn.theme_type_variation = "PrimaryButton"
	right.add_child(_end_turn)
	_draw_btn = UiTheme.make_button("", func(): _show_pile("Pilha de compra (ordem oculta)", combat.draw_pile, true))
	_discard_btn = UiTheme.make_button("", func(): _show_pile("Descarte", combat.discard_pile, false))
	_exhaust_btn = UiTheme.make_button("", func(): _show_pile("Cartas banidas", combat.exhaust_pile, false))
	for b in [_draw_btn, _discard_btn, _exhaust_btn]:
		b.add_theme_font_size_override("font_size", 14)
		right.add_child(b)

	# mensagens
	_message = UiTheme.make_label("", 17, Palette.BONE_LIGHT, true)
	_message.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_message.anchor_top = 0.6
	_message.anchor_left = 0.2
	_message.anchor_right = 0.8
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_color_override("font_outline_color", Palette.CHARCOAL_DEEP)
	_message.add_theme_constant_override("outline_size", 6)
	_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_message)

	_banner = UiTheme.make_label("", 44, Palette.PAPER, true)
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.anchor_left = 0.0
	_banner.anchor_right = 1.0
	_banner.anchor_top = 0.38
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.add_theme_color_override("font_outline_color", Palette.CHARCOAL_DEEP)
	_banner.add_theme_constant_override("outline_size", 10)
	_banner.modulate.a = 0.0
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.z_index = 80
	add_child(_banner)


func _start_combat() -> void:
	combat = CombatManager.new()
	add_child(combat)
	player = PlayerCombatant.new("Pesquisador", RunState.hp, RunState.max_hp, Profile.get_max_energy())
	_player_panel.setup(player)

	combat.hand_changed.connect(_on_hand_changed)
	combat.piles_changed.connect(_update_piles)
	combat.turn_started.connect(_on_turn_started)
	combat.monster_acting.connect(_on_monster_acting)
	combat.combat_ended.connect(_on_combat_ended)
	combat.instinct_changed.connect(_on_instinct_changed)
	combat.instinct_triggered.connect(_on_instinct_triggered)
	combat.message.connect(show_message)
	combat.card_played.connect(func(c: CardInstance):
		Sfx.play(&"card")
		_player_panel.cast(c.data)
		_refresh_intents())
	player.energy_changed.connect(func(_e, _m): _hand.refresh_playable(combat.can_play))
	player.statuses_changed.connect(_refresh_intents)

	# Instancia as views depois de criar os monstros (start_combat cria os combatentes).
	combat.start_combat(player, RunState.get_deck_cards(), RunState.current.monsters,
		Profile.get_installed_mutations(), RunState.get_monster_hp_bonus(), Profile.get_starting_corruption_stacks(), RunState.get_monster_strength())
	for m in combat.monsters:
		var mv := MonsterView.new()
		mv.setup(m, combat)
		mv.pressed.connect(_on_monster_pressed)
		m.statuses_changed.connect(_refresh_intents)
		_monster_row.add_child(mv)
		_monster_views.append(mv)
	_on_instinct_changed(Family.Id.NEUTRAL, 0)
	_update_piles()
	_on_hand_changed()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_on_end_turn()
	elif event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
		# Esc sem carta selecionada fica para o menu de pausa
		if _pending != null or not event.is_action_pressed("ui_cancel"):
			_cancel_pending()
			get_viewport().set_input_as_handled()


# --- Cartas -----------------------------------------------------------------

func _on_card_pressed(view: CardView) -> void:
	if combat.is_over or not combat.is_player_turn:
		return
	if not combat.can_play(view.instance):
		show_message("Energia insuficiente.")
		_shake(view)
		return
	var living := combat.get_living_monsters()
	if view.data.needs_target() and living.size() > 1:
		if _pending == view:
			_cancel_pending()
			return
		_pending = view
		_hand.set_selected(view)
		for mv in _monster_views:
			mv.targetable = true
		show_message("Escolha um alvo.")
	else:
		_play(view, living[0] if not living.is_empty() else null)


func _on_monster_pressed(mv: MonsterView) -> void:
	if _pending != null and mv.monster.is_alive():
		_play(_pending, mv.monster)


func _play(view: CardView, target: Combatant) -> void:
	var ghost := CardView.create(view.data, view.instance)
	ghost.interactive = false
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.z_index = 150
	add_child(ghost)
	ghost.global_position = view.global_position
	ghost.scale = view.scale
	_cancel_pending()
	if combat.play_card(view.instance, target):
		var tw := ghost.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(ghost, "position", Vector2(size.x * 0.5 - 78, size.y * 0.3), 0.25)
		tw.tween_property(ghost, "scale", Vector2(0.8, 0.8), 0.3)
		tw.tween_property(ghost, "modulate:a", 0.0, 0.25).set_delay(0.2)
		tw.chain().tween_callback(ghost.queue_free)
	else:
		ghost.queue_free()


func _cancel_pending() -> void:
	_pending = null
	if _hand != null:
		_hand.set_selected(null)
	for mv in _monster_views:
		mv.targetable = false


func _on_hand_changed() -> void:
	_hand.set_cards(combat.hand, combat.can_play)


func _update_piles() -> void:
	_draw_btn.text = "Compra: %d" % combat.draw_pile.size()
	_discard_btn.text = "Descarte: %d" % combat.discard_pile.size()
	_exhaust_btn.text = "Banidas: %d" % combat.exhaust_pile.size()


func _show_pile(title: String, pile: Array[CardInstance], hide_order: bool) -> void:
	var cards: Array[CardData] = []
	for c in pile:
		cards.append(c.data)
	if hide_order:
		cards.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name < b.display_name)
	CardGridOverlay.open(self, title, cards)


func _show_run_deck() -> void:
	CardGridOverlay.open(self, "Baralho da expedição", RunState.get_deck_cards())


# --- Turnos -----------------------------------------------------------------

func _on_end_turn() -> void:
	if combat.is_player_turn and not combat.is_over:
		_cancel_pending()
		combat.end_player_turn()


func _on_turn_started(is_player: bool) -> void:
	Sfx.play(&"turn", -6.0 if is_player else -10.0)
	_end_turn.disabled = not is_player
	_end_turn.text = "Encerrar turno" if is_player else "Turno inimigo…"
	_show_banner("Seu turno" if is_player else "Turno das criaturas", Palette.PAPER if is_player else Palette.BLOOD_BRIGHT)
	_refresh_intents()
	_hand.refresh_playable(combat.can_play)


func _on_monster_acting(m: MonsterCombatant) -> void:
	for mv in _monster_views:
		if mv.monster == m and m.current_intent != null and m.current_intent.is_attack():
			mv.play_attack_lunge()


func _refresh_intents() -> void:
	for mv in _monster_views:
		mv.refresh_intent()


func _on_instinct_changed(family: Family.Id, count: int) -> void:
	var dots := ""
	for i in CombatManager.INSTINCT_THRESHOLD:
		dots += "●" if i < count else "○"
	if family == Family.Id.NEUTRAL or count == 0:
		_instinct_label.text = "[center][color=#8E877A]Instinto  %s[/color][/center]" % dots
	else:
		var col := Family.get_color(family).to_html(false)
		_instinct_label.text = "[center]Instinto [color=#%s]%s %s[/color]  [color=#8E877A]→ %s[/color][/center]" % [
			col, Family.get_name_of(family), dots, Family.INSTINCT_NAMES.get(family, "")]


func _on_instinct_triggered(family: Family.Id) -> void:
	Sfx.play(&"instinct")
	Fx.burst(self, _player_panel.global_position + Vector2(160, 60), Family.get_color(family), 34, 320)
	_show_banner(Family.INSTINCT_NAMES.get(family, "Instinto") + "!", Family.get_color(family))


func _on_combat_ended(victory: bool) -> void:
	_cancel_pending()
	_end_turn.disabled = true
	await get_tree().create_timer(0.9).timeout
	_show_end_overlay(victory)


func _show_end_overlay(victory: bool) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.02, 0.03, 0.8)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 190
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	if victory:
		var t := UiTheme.make_label("Espécime abatido", 46, Palette.BONE_LIGHT, true)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(t)
		var s := UiTheme.make_label("O corpo ainda está fresco. Leve-o à mesa de dissecação.", 18, Palette.TEXT_DIM)
		s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(s)
		var b := UiTheme.make_button("Iniciar dissecação", func(): Game.on_combat_won(combat.monsters, player.hp), 260)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(b)
		b.grab_focus()
	else:
		var t := UiTheme.make_label("Você sucumbiu", 46, Palette.BLOOD_BRIGHT, true)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(t)
		var s := UiTheme.make_label("Parte do material coletado se perde no caminho de volta ao laboratório.", 18, Palette.TEXT_DIM)
		s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(s)
		var b := UiTheme.make_button("Retornar", Game.on_combat_lost, 220)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(b)


# --- Feedback ---------------------------------------------------------------

func show_message(text: String) -> void:
	_message.text = text
	_message.modulate.a = 1.0
	var tw := _message.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(_message, "modulate:a", 0.0, 0.5)


func _show_banner(text: String, color: Color) -> void:
	_banner.text = text
	_banner.add_theme_color_override("font_color", color)
	var tw := _banner.create_tween()
	_banner.modulate.a = 0.0
	tw.tween_property(_banner, "modulate:a", 1.0, 0.15)
	tw.tween_interval(0.6)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.35)


func _shake(c: Control) -> void:
	var base := c.position
	var tw := c.create_tween()
	for i in 3:
		tw.tween_property(c, "position:x", base.x + 6, 0.04)
		tw.tween_property(c, "position:x", base.x - 6, 0.04)
	tw.tween_property(c, "position:x", base.x, 0.04)
