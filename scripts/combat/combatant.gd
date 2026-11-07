class_name Combatant
extends RefCounted
## Entidade com vida, armadura e status. Base para jogador e monstros.

signal hp_changed(hp: int, max_hp: int)
signal block_changed(block: int)
signal statuses_changed
signal damaged(amount: int, blocked: int)
signal healed(amount: int)
signal died

enum DeathCause { NONE, ATTACK, STATUS, OTHER }

var display_name: String = ""
var max_hp: int = 1
var hp: int = 1
var block: int = 0
var statuses: Dictionary = {} # StringName -> int
var is_player: bool = false

# Registro forense usado pela dissecação.
var attack_hits_taken: int = 0
var death_cause: DeathCause = DeathCause.NONE
var death_overkill: int = 0


func is_alive() -> bool:
	return hp > 0


## Aplica dano (já calculado). Retorna a vida efetivamente perdida.
func take_damage(amount: int, source: Combatant = null, is_attack: bool = false) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var blocked: int = min(block, amount)
	if blocked > 0:
		block -= blocked
		block_changed.emit(block)
	var through := amount - blocked
	if is_attack:
		attack_hits_taken += 1
	var lost := _reduce_hp(through, DeathCause.ATTACK if is_attack else DeathCause.OTHER)
	damaged.emit(through, blocked)
	if is_attack and source != null and source.is_alive() and get_status(&"thorns") > 0:
		source.take_damage(get_status(&"thorns"), self, false)
	return lost


## Perda de vida direta (ignora armadura), ex.: sangramento ou custo de carta.
func lose_hp(amount: int, cause: DeathCause = DeathCause.OTHER) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var lost := _reduce_hp(amount, cause)
	damaged.emit(amount, 0)
	return lost


func _reduce_hp(amount: int, cause: DeathCause) -> int:
	if amount <= 0:
		return 0
	var before := hp
	hp = max(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		death_cause = cause
		death_overkill = amount - before
		died.emit()
	return before - hp


func heal(amount: int) -> int:
	if not is_alive() or amount <= 0:
		return 0
	var before := hp
	hp = min(max_hp, hp + amount)
	if hp != before:
		hp_changed.emit(hp, max_hp)
		healed.emit(hp - before)
	return hp - before


func add_block(amount: int) -> void:
	if amount <= 0 or not is_alive():
		return
	block += amount
	block_changed.emit(block)


func clear_block() -> void:
	if block != 0:
		block = 0
		block_changed.emit(block)


func get_status(id: StringName) -> int:
	return statuses.get(id, 0)


func add_status(id: StringName, stacks: int) -> void:
	if stacks == 0 or not is_alive():
		return
	set_status(id, get_status(id) + stacks)


func set_status(id: StringName, stacks: int) -> void:
	if stacks <= 0:
		statuses.erase(id)
	else:
		statuses[id] = stacks
	statuses_changed.emit()
