extends Node
## Autoload "RunState": estado da expedição em andamento (não persiste entre sessões).

## Fração dos materiais preservada se o caçador morrer.
const DEFEAT_MATERIAL_KEEP := 0.5

var active: bool = false
var expedition: ExpeditionData
var map: Array = [] # Array de Array[MapNode]
var current: MapNode = null
var deck: Array[StringName] = []
var hp: int = 0
var max_hp: int = 0
var gathered: Dictionary = {} # part id -> quantidade
var new_cards: Array[StringName] = []
var kills: int = 0
## Fila de corpos a dissecar: [{ "monster": MonsterData, "condition": BodyCondition }]
var dissection_queue: Array = []
var last_summary: Dictionary = {}
var rng := RandomNumberGenerator.new()


func start(expd: ExpeditionData) -> void:
	rng.randomize()
	active = true
	expedition = expd
	map = MapGenerator.generate(expd, rng)
	current = null
	deck = Profile.starting_deck.duplicate()
	max_hp = Profile.get_max_hp()
	hp = max_hp
	gathered.clear()
	new_cards.clear()
	kills = 0
	dissection_queue.clear()
	last_summary = {}
	Profile.runs_started += 1
	Profile.save_profile()


func get_floor() -> int:
	return -1 if current == null else current.floor_index


func get_available_nodes() -> Array[MapNode]:
	var result: Array[MapNode] = []
	if map.is_empty():
		return result
	if current == null:
		for n: MapNode in map[0]:
			result.append(n)
		return result
	var next_floor := current.floor_index + 1
	if next_floor >= map.size():
		return result
	for i in current.links:
		result.append(map[next_floor][i])
	return result


func get_deck_cards() -> Array[CardData]:
	return Database.cards_from_ids(deck)


## Vida extra dos monstros conforme o andar (o chefe tem vida fixa).
func get_monster_hp_bonus() -> int:
	if expedition == null or (current != null and current.type == MapNode.Type.BOSS):
		return 0
	return max(0, get_floor()) * expedition.hp_per_floor


## Registra uma parte extraída. Retorna true se desbloqueou uma carta nova.
func gather(part: AnatomyPart) -> bool:
	gathered[part.id] = int(gathered.get(part.id, 0)) + 1
	Profile.record_part(part.id)
	var unlocked := false
	if part.unlocks_card != null and Profile.unlock_card(part.unlocks_card.id):
		new_cards.append(part.unlocks_card.id)
		unlocked = true
	Profile.save_profile()
	return unlocked


func end_run(won: bool) -> Dictionary:
	var kept := {}
	var lost := {}
	for id in gathered:
		var amount: int = gathered[id]
		var keep := amount if won else int(ceil(amount * DEFEAT_MATERIAL_KEEP))
		if keep > 0:
			kept[id] = keep
			Profile.add_material(id, keep)
		if amount - keep > 0:
			lost[id] = amount - keep
	if won:
		Profile.runs_won += 1
	Profile.save_profile()
	last_summary = {
		"won": won,
		"kept": kept,
		"lost": lost,
		"new_cards": new_cards.duplicate(),
		"kills": kills,
		"floor": get_floor() + 1,
	}
	active = false
	return last_summary
