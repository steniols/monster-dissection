class_name CombatManager
extends Node
## Regras do combate por turnos. Não conhece a UI: comunica-se apenas por sinais.

signal hand_changed
signal piles_changed
signal card_played(card: CardInstance)
signal turn_started(is_player_turn: bool)
signal monster_acting(monster: MonsterCombatant)
signal combat_ended(victory: bool)
signal instinct_changed(family: Family.Id, count: int)
signal instinct_triggered(family: Family.Id)
signal message(text: String)

const HAND_SIZE := 5
const MAX_HAND := 10
const INSTINCT_THRESHOLD := 3

var rng := RandomNumberGenerator.new()
var player: PlayerCombatant
var monsters: Array[MonsterCombatant] = []
var draw_pile: Array[CardInstance] = []
var hand: Array[CardInstance] = []
var discard_pile: Array[CardInstance] = []
var exhaust_pile: Array[CardInstance] = []

var turn_number: int = 0
var cards_played_this_turn: int = 0
var is_player_turn: bool = false
var is_over: bool = false
var instinct_family: Family.Id = Family.Id.NEUTRAL
var instinct_count: int = 0

var _first_turn_draw_bonus: int = 0


func start_combat(p: PlayerCombatant, deck: Array[CardData], monster_list: Array[MonsterData],
		mutations: Array[MutationData] = [], monster_hp_bonus: int = 0, starting_corruption: int = 0, monster_strength: int = 0) -> void:
	rng.randomize()
	player = p
	for data in monster_list:
		var spawned := MonsterCombatant.new(data, monster_hp_bonus)
		if monster_strength > 0:
			spawned.add_status(&"strength", monster_strength)
		spawned.died.connect(_spread_spores.bind(spawned))
		monsters.append(spawned)
	for card_data in deck:
		draw_pile.append(CardInstance.new(card_data))
	_shuffle(draw_pile)

	for m in monsters:
		_resolve_effects(m.data.combat_start_effects, m, player)
		m.roll_intent(rng)
	for mut in mutations:
		_first_turn_draw_bonus += mut.first_turn_draw_bonus
		var first: Combatant = monsters[0] if not monsters.is_empty() else null
		_resolve_effects(mut.combat_start_effects, player, first)
	if starting_corruption > 0:
		player.add_status(&"corruption", starting_corruption)
		message.emit("A corrupção das suas mutações cobra seu preço.")
	_start_player_turn()


# --- Turno do jogador -------------------------------------------------------

func _start_player_turn() -> void:
	turn_number += 1
	cards_played_this_turn = 0
	player.clear_block()
	_tick_statuses(player)
	if _check_end():
		return
	player.set_energy(player.max_energy)
	is_player_turn = true
	draw_cards(HAND_SIZE + (_first_turn_draw_bonus if turn_number == 1 else 0))
	turn_started.emit(true)


func can_play(card: CardInstance) -> bool:
	return is_player_turn and not is_over and hand.has(card) and card.get_cost() <= player.energy


func play_card(card: CardInstance, target: Combatant = null) -> bool:
	if not can_play(card):
		return false
	player.set_energy(player.energy - card.get_cost())
	hand.erase(card)
	var ctx := EffectContext.new(self, player, target, card)
	for effect in card.data.effects:
		effect.apply(ctx)
		if not player.is_alive():
			break
	cards_played_this_turn += 1
	card.turn_cost_modifier = 0
	if card.data.exhaust or card.data.card_type == CardData.CardType.MUTATION:
		exhaust_pile.append(card)
	else:
		discard_pile.append(card)
	card_played.emit(card)
	_register_instinct(card.data)
	hand_changed.emit()
	piles_changed.emit()
	_check_end()
	return true


func end_player_turn() -> void:
	if not is_player_turn or is_over:
		return
	is_player_turn = false
	for c in hand:
		c.turn_cost_modifier = 0
		discard_pile.append(c)
	hand.clear()
	_decay_statuses(player, "turn_end")
	hand_changed.emit()
	piles_changed.emit()
	turn_started.emit(false)
	await _run_monster_turns()


func draw_cards(count: int) -> void:
	for i in count:
		if hand.size() >= MAX_HAND:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			_shuffle(draw_pile)
			message.emit("Descarte embaralhado de volta ao baralho.")
		hand.append(draw_pile.pop_back())
	hand_changed.emit()
	piles_changed.emit()


func return_from_discard(count: int) -> void:
	for i in count:
		if discard_pile.is_empty() or hand.size() >= MAX_HAND:
			break
		var idx := rng.randi_range(0, discard_pile.size() - 1)
		hand.append(discard_pile[idx])
		discard_pile.remove_at(idx)
	hand_changed.emit()
	piles_changed.emit()


# --- Instinto ---------------------------------------------------------------

func _register_instinct(card: CardData) -> void:
	var family := card.family
	if family == Family.Id.NEUTRAL:
		return # instrumentos não quebram a sequência
	# Híbridas continuam a sequência de qualquer uma das suas duas famílias.
	if card.is_hybrid() and card.belongs_to(instinct_family):
		family = instinct_family
	if family == instinct_family:
		instinct_count += 1
	else:
		instinct_family = family
		instinct_count = 1
	if instinct_count >= INSTINCT_THRESHOLD:
		_trigger_instinct(family)
		instinct_count = 0
	instinct_changed.emit(instinct_family, instinct_count)


func _trigger_instinct(family: Family.Id) -> void:
	match family:
		Family.Id.BLOODFANG:
			player.add_status(&"strength", 2)
		Family.Id.IRONBACK:
			player.add_block(8)
			player.add_status(&"thorns", 2)
		Family.Id.VOIDSPAWN:
			for m in get_living_monsters():
				m.add_status(&"corruption", 3)
		Family.Id.ROTWALKER:
			player.heal(5)
		Family.Id.SPOREMAW:
			for m in get_living_monsters():
				m.add_status(&"spores", 3)
			player.heal(3)
		Family.Id.ASHWING:
			for m in get_living_monsters():
				m.add_status(&"ember", 3)
			draw_cards(1)
	instinct_triggered.emit(family)
	message.emit("Instinto: %s! %s" % [Family.INSTINCT_NAMES.get(family, ""), Family.INSTINCT_DESCRIPTIONS.get(family, "")])


## Quem morre com Esporos os passa para os outros inimigos.
func _spread_spores(dead: MonsterCombatant) -> void:
	var stacks := dead.get_status(&"spores")
	if stacks <= 0:
		return
	for m in get_living_monsters():
		m.add_status(&"spores", stacks)


# --- Turno dos monstros -----------------------------------------------------

func _run_monster_turns() -> void:
	await _wait(0.35)
	for m in monsters:
		if is_over:
			return
		if not m.is_alive():
			continue
		m.clear_block()
		_tick_statuses(m)
		if _check_end():
			return
		if not m.is_alive():
			continue
		monster_acting.emit(m)
		await _wait(0.3)
		if is_over:
			return
		if m.current_intent != null:
			message.emit("%s usa %s." % [m.display_name, m.current_intent.display_name])
			_resolve_effects(m.current_intent.effects, m, player)
		if _check_end():
			return
		_decay_statuses(m, "turn_end")
		m.roll_intent(rng)
		await _wait(0.45)
	if is_over:
		return
	_start_player_turn()


func _wait(seconds: float) -> void:
	if is_inside_tree():
		await get_tree().create_timer(seconds).timeout


# --- Status -----------------------------------------------------------------

func _tick_statuses(c: Combatant) -> void:
	for id in c.statuses.keys():
		if not c.is_alive():
			return
		var def := StatusLibrary.get_def(id)
		var stacks := c.get_status(id)
		if def.has("tick"):
			var tick: Dictionary = def["tick"]
			match tick["kind"]:
				"lose_hp":
					c.lose_hp(stacks, Combatant.DeathCause.STATUS)
				"heal":
					c.heal(stacks)
				"block":
					c.add_block(stacks)
				"apply_self":
					c.add_status(tick["status"], stacks)
				"apply_opponents":
					for o in get_living_opponents(c):
						o.add_status(tick["status"], stacks)
		if def.get("decay_on", "") == "turn_start":
			c.set_status(id, c.get_status(id) - int(def.get("decay", 0)))


func _decay_statuses(c: Combatant, timing: String) -> void:
	for id in c.statuses.keys():
		var def := StatusLibrary.get_def(id)
		if def.get("decay_on", "") == timing and int(def.get("decay", 0)) > 0:
			c.set_status(id, c.get_status(id) - int(def["decay"]))


# --- Utilidades -------------------------------------------------------------

func calc_attack_damage(source: Combatant, target: Combatant, base: int) -> int:
	var dmg := float(base + source.get_status(&"strength"))
	if source.get_status(&"weak") > 0:
		dmg *= 0.75
	if target != null and target.get_status(&"vulnerable") > 0:
		dmg *= 1.5
	return max(0, floori(dmg))


## Retorna [dano por golpe, golpes] somados de todos os DamageEffect da intenção.
func preview_intent_damage(m: MonsterCombatant) -> Vector2i:
	if m.current_intent == null:
		return Vector2i.ZERO
	var per_hit := 0
	var hits := 0
	for e in m.current_intent.effects:
		if e is DamageEffect:
			per_hit = calc_attack_damage(m, player, e.amount)
			hits += e.hits
	return Vector2i(per_hit, hits)


func get_living_monsters() -> Array[Combatant]:
	var result: Array[Combatant] = []
	for m in monsters:
		if m.is_alive():
			result.append(m)
	return result


func get_living_opponents(c: Combatant) -> Array[Combatant]:
	if c.is_player:
		return get_living_monsters()
	var result: Array[Combatant] = []
	if player.is_alive():
		result.append(player)
	return result


func _resolve_effects(effects: Array[CardEffect], source: Combatant, target: Combatant) -> void:
	var ctx := EffectContext.new(self, source, target)
	for e in effects:
		e.apply(ctx)


func _check_end() -> bool:
	if is_over:
		return true
	if not player.is_alive():
		is_over = true
		is_player_turn = false
		combat_ended.emit(false)
		return true
	if get_living_monsters().is_empty():
		is_over = true
		is_player_turn = false
		combat_ended.emit(true)
		return true
	return false


func _shuffle(pile: Array[CardInstance]) -> void:
	for i in range(pile.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := pile[i]
		pile[i] = pile[j]
		pile[j] = tmp
