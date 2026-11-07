extends Node
## Autoload "Profile": progressão permanente (laboratório), salva em user://profile.json.

signal changed

const SAVE_PATH := "user://profile.json"
const SAVE_VERSION := 1
const BASE_MAX_HP := 60
const BASE_ENERGY := 3
const BASE_INCISIONS := 2
const MAX_MUTATIONS := 3
const DECK_MIN := 8
const DECK_MAX := 20
const MAX_COPIES := 2
const MAX_COPIES_STARTER := 5
## A cada X pontos de corrupção, o caçador começa o combate com 1 de Corrupção.
const CORRUPTION_STEP := 4

var unlocked_cards: Array[StringName] = []
var materials: Dictionary = {} # StringName -> int
var mutations: Array[StringName] = []
var starting_deck: Array[StringName] = []
var bestiary: Dictionary = {} # monster id (StringName) -> {"kills": int, "parts": Array[StringName]}
var runs_started: int = 0
var runs_won: int = 0


func _ready() -> void:
	load_profile()


# --- Persistência -----------------------------------------------------------

func reset() -> void:
	unlocked_cards.clear()
	for c: CardData in Database.cards.values():
		if c.family == Family.Id.NEUTRAL:
			unlocked_cards.append(c.id)
	materials.clear()
	mutations.clear()
	starting_deck = Database.STARTER_DECK.duplicate()
	bestiary.clear()
	runs_started = 0
	runs_won = 0
	save_profile()
	changed.emit()


func load_profile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		reset()
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Profile: save corrompido, criando novo perfil.")
		reset()
		return
	unlocked_cards = _to_names(data.get("unlocked_cards", []))
	mutations = _to_names(data.get("mutations", []))
	starting_deck = _to_names(data.get("starting_deck", []))
	materials.clear()
	for k in data.get("materials", {}):
		materials[StringName(k)] = int(data["materials"][k])
	bestiary.clear()
	for k in data.get("bestiary", {}):
		var e: Dictionary = data["bestiary"][k]
		bestiary[StringName(k)] = {"kills": int(e.get("kills", 0)), "parts": _to_names(e.get("parts", []))}
	runs_started = int(data.get("runs_started", 0))
	runs_won = int(data.get("runs_won", 0))
	# Garante integridade caso o conteúdo do jogo mude entre versões.
	for c: CardData in Database.cards.values():
		if c.family == Family.Id.NEUTRAL and not unlocked_cards.has(c.id):
			unlocked_cards.append(c.id)
	starting_deck.assign(starting_deck.filter(func(id): return Database.get_card(id) != null))
	if starting_deck.size() < DECK_MIN:
		starting_deck = Database.STARTER_DECK.duplicate()
	changed.emit()


func save_profile() -> void:
	var mats := {}
	for k in materials:
		mats[String(k)] = materials[k]
	var best := {}
	for k in bestiary:
		best[String(k)] = {"kills": bestiary[k]["kills"], "parts": _to_strings(bestiary[k]["parts"])}
	var data := {
		"version": SAVE_VERSION,
		"unlocked_cards": _to_strings(unlocked_cards),
		"materials": mats,
		"mutations": _to_strings(mutations),
		"starting_deck": _to_strings(starting_deck),
		"bestiary": best,
		"runs_started": runs_started,
		"runs_won": runs_won,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Profile: não foi possível salvar em " + SAVE_PATH)
		return
	f.store_string(JSON.stringify(data, "\t"))


static func _to_names(arr: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for v in arr:
		result.append(StringName(v))
	return result


static func _to_strings(arr: Array) -> Array[String]:
	var result: Array[String] = []
	for v in arr:
		result.append(String(v))
	return result


# --- Cartas e bestiário -----------------------------------------------------

func is_card_unlocked(id: StringName) -> bool:
	return unlocked_cards.has(id)


## Retorna true se a carta era nova.
func unlock_card(id: StringName) -> bool:
	if id == &"" or unlocked_cards.has(id):
		return false
	unlocked_cards.append(id)
	changed.emit()
	return true


func record_kill(monster_id: StringName) -> void:
	var e: Dictionary = bestiary.get(monster_id, {"kills": 0, "parts": []})
	e["kills"] += 1
	bestiary[monster_id] = e


func record_part(part_id: StringName) -> void:
	var owner := Database.get_part_owner(part_id)
	if owner == null:
		return
	var e: Dictionary = bestiary.get(owner.id, {"kills": 0, "parts": []})
	if not e["parts"].has(part_id):
		e["parts"].append(part_id)
	bestiary[owner.id] = e


func is_monster_known(id: StringName) -> bool:
	return bestiary.has(id)


func is_part_known(part_id: StringName) -> bool:
	var owner := Database.get_part_owner(part_id)
	return owner != null and bestiary.has(owner.id) and bestiary[owner.id]["parts"].has(part_id)


# --- Materiais --------------------------------------------------------------

func add_material(id: StringName, amount: int = 1) -> void:
	materials[id] = int(materials.get(id, 0)) + amount
	changed.emit()


func get_material(id: StringName) -> int:
	return int(materials.get(id, 0))


func has_materials(cost: Dictionary) -> bool:
	for k in cost:
		if get_material(StringName(k)) < int(cost[k]):
			return false
	return true


func spend_materials(cost: Dictionary) -> bool:
	if not has_materials(cost):
		return false
	for k in cost:
		materials[StringName(k)] = get_material(StringName(k)) - int(cost[k])
		if materials[StringName(k)] <= 0:
			materials.erase(StringName(k))
	changed.emit()
	return true


# --- Mutações ---------------------------------------------------------------

func get_installed_mutations() -> Array[MutationData]:
	var result: Array[MutationData] = []
	for id in mutations:
		var m := Database.get_mutation(id)
		if m != null:
			result.append(m)
	return result


func can_install(m: MutationData) -> bool:
	return not mutations.has(m.id) and mutations.size() < MAX_MUTATIONS and has_materials(m.material_cost)


func install_mutation(m: MutationData) -> bool:
	if not can_install(m):
		return false
	spend_materials(m.material_cost)
	mutations.append(m.id)
	save_profile()
	changed.emit()
	return true


## Remover não devolve materiais (o tecido é descartado).
func remove_mutation(id: StringName) -> void:
	mutations.erase(id)
	save_profile()
	changed.emit()


func get_corruption() -> int:
	var total := 0
	for m in get_installed_mutations():
		total += m.corruption
	return total


func get_starting_corruption_stacks() -> int:
	return get_corruption() / CORRUPTION_STEP


func get_max_hp() -> int:
	var hp := BASE_MAX_HP
	for m in get_installed_mutations():
		hp += m.max_hp_bonus
	return hp


func get_max_energy() -> int:
	var e := BASE_ENERGY
	for m in get_installed_mutations():
		e += m.energy_bonus
	return e


func get_incisions() -> int:
	return BASE_INCISIONS


# --- Baralho inicial --------------------------------------------------------

func max_copies(card: CardData) -> int:
	return MAX_COPIES_STARTER if card.rarity == CardData.Rarity.STARTER else MAX_COPIES


func can_add_to_deck(id: StringName) -> bool:
	var card := Database.get_card(id)
	if card == null or not is_card_unlocked(id) or starting_deck.size() >= DECK_MAX:
		return false
	return starting_deck.count(id) < max_copies(card)


func add_to_deck(id: StringName) -> bool:
	if not can_add_to_deck(id):
		return false
	starting_deck.append(id)
	changed.emit()
	return true


func remove_from_deck(id: StringName) -> bool:
	if starting_deck.size() <= DECK_MIN or not starting_deck.has(id):
		return false
	starting_deck.erase(id)
	changed.emit()
	return true
