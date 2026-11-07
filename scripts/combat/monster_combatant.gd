class_name MonsterCombatant
extends Combatant
## Instância de um monstro em combate: guarda dados, padrão de intenções e intenção atual.

signal intent_changed

var data: MonsterData
var current_intent: MonsterIntent
var _intent_index: int = -1
var _last_intent: MonsterIntent


func _init(monster_data: MonsterData, hp_bonus: int = 0) -> void:
	data = monster_data
	display_name = data.display_name
	max_hp = data.max_hp + hp_bonus
	hp = max_hp


func roll_intent(rng: RandomNumberGenerator) -> void:
	if data.intents.is_empty():
		current_intent = null
		return
	match data.pattern:
		MonsterData.Pattern.CYCLE:
			_intent_index = (_intent_index + 1) % data.intents.size()
			current_intent = data.intents[_intent_index]
		MonsterData.Pattern.RANDOM_NO_REPEAT:
			current_intent = _pick_weighted(rng)
	_last_intent = current_intent
	intent_changed.emit()


func _pick_weighted(rng: RandomNumberGenerator) -> MonsterIntent:
	var pool: Array[MonsterIntent] = []
	for intent in data.intents:
		if intent != _last_intent or data.intents.size() == 1:
			pool.append(intent)
	var total := 0
	for intent in pool:
		total += max(1, intent.weight)
	var roll := rng.randi_range(1, total)
	for intent in pool:
		roll -= max(1, intent.weight)
		if roll <= 0:
			return intent
	return pool.back()
