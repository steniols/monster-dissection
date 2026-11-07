extends Node
## Autoload "Database": carrega todos os Resources de res://data/ e os indexa por id.

const STARTER_DECK: Array[StringName] = [
	&"scalpel_cut", &"scalpel_cut", &"scalpel_cut", &"scalpel_cut", &"scalpel_cut",
	&"guard", &"guard", &"guard", &"guard",
	&"incision",
]
const DEFAULT_EXPEDITION := &"bone_moor"

var cards: Dictionary = {} # StringName -> CardData
var monsters: Dictionary = {} # StringName -> MonsterData
var parts: Dictionary = {} # StringName -> AnatomyPart
var mutations: Dictionary = {} # StringName -> MutationData
var expeditions: Dictionary = {} # StringName -> ExpeditionData
var _part_owner: Dictionary = {} # part id -> MonsterData


func _ready() -> void:
	_load_dir("res://data/cards", cards)
	_load_dir("res://data/organs", parts)
	_load_dir("res://data/monsters", monsters)
	_load_dir("res://data/mutations", mutations)
	_load_dir("res://data/expeditions", expeditions)
	for m: MonsterData in monsters.values():
		for p in m.parts:
			_part_owner[p.id] = m


func _load_dir(path: String, into: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("Database: pasta não encontrada: " + path)
		return
	for file in dir.get_files():
		file = file.trim_suffix(".remap")
		if not (file.ends_with(".tres") or file.ends_with(".res")):
			continue
		var res := load(path.path_join(file))
		if res != null and "id" in res and res.id != &"":
			into[res.id] = res


func get_card(id: StringName) -> CardData:
	return cards.get(id)


func get_part(id: StringName) -> AnatomyPart:
	return parts.get(id)


func get_monster(id: StringName) -> MonsterData:
	return monsters.get(id)


func get_mutation(id: StringName) -> MutationData:
	return mutations.get(id)


func get_part_owner(part_id: StringName) -> MonsterData:
	return _part_owner.get(part_id)


func cards_from_ids(ids: Array) -> Array[CardData]:
	var result: Array[CardData] = []
	for id in ids:
		var c := get_card(StringName(id))
		if c != null:
			result.append(c)
	return result


func get_sorted_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for c: CardData in cards.values():
		result.append(c)
	result.sort_custom(func(a: CardData, b: CardData) -> bool:
		if a.family != b.family:
			return a.family < b.family
		if a.rarity != b.rarity:
			return a.rarity < b.rarity
		return a.display_name < b.display_name)
	return result


func get_sorted_monsters() -> Array[MonsterData]:
	var result: Array[MonsterData] = []
	for m: MonsterData in monsters.values():
		result.append(m)
	result.sort_custom(func(a: MonsterData, b: MonsterData) -> bool:
		if a.tier != b.tier:
			return a.tier < b.tier
		return a.family < b.family)
	return result
