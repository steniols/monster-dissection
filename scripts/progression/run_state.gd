extends Node
## Autoload "RunState": estado da expedição em andamento.
## É salvo em user://run.json sempre que o jogador volta ao mapa.

const SAVE_PATH := "user://run.json"
## Fração dos materiais preservada se o caçador morrer ou abandonar.
const DEFEAT_MATERIAL_KEEP := 0.5

var active: bool = false
var expedition: ExpeditionData
## Nível de NG+ desta expedição (0 = normal). Ver NG_HP e NG_STRENGTH.
var ng_level: int = 0
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
## Incisões que sobram para todos os corpos deste combate (um combate com 2 monstros não dá 4 incisões).
var incisions_left: int = 0
var last_summary: Dictionary = {}
var rng := RandomNumberGenerator.new()


func start(expd: ExpeditionData, ng: int = 0) -> void:
	rng.randomize()
	active = true
	expedition = expd
	ng_level = clampi(ng, 0, Profile.MAX_NG)
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
	save_run()


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


## NG+: vida extra dos monstros (fração) e Força extra, por nível (índice = nível). Valem também para o chefe.
const NG_HP := [0.0, 0.12, 0.24, 0.36, 0.5, 0.65]
const NG_STRENGTH := [0, 1, 1, 2, 2, 3]


## Multiplicador de vida dos monstros pelo NG+.
func get_monster_hp_mult() -> float:
	return 1.0 + float(NG_HP[clampi(ng_level, 0, NG_HP.size() - 1)])


## Texto curto do que o nível de NG+ muda (para a escolha de região e o cabeçalho).
static func ng_summary(ng: int) -> String:
	if ng <= 0:
		return "Normal"
	return "NG+%d: monstros com +%d%% de vida e +%d de Força" % [ng, roundi(float(NG_HP[ng]) * 100.0), NG_STRENGTH[ng]]


## Força inicial dos monstros: base da região + 1 a cada strength_floor_step andares (o chefe recebe metade da base).
func get_monster_strength() -> int:
	if expedition == null:
		return 0
	var ng_s: int = NG_STRENGTH[clampi(ng_level, 0, NG_STRENGTH.size() - 1)]
	if current != null and current.type == MapNode.Type.BOSS:
		return expedition.monster_strength / 2 + ng_s # o chefe já é duro por si
	var s := expedition.monster_strength + ng_s
	if expedition.strength_floor_step > 0:
		s += max(0, get_floor()) / expedition.strength_floor_step
	return s


func get_monster_hp_bonus() -> int:
	if expedition == null or (current != null and current.type == MapNode.Type.BOSS):
		return 0
	return max(0, get_floor()) * expedition.hp_per_floor


func change_hp(amount: int) -> void:
	hp = clampi(hp + amount, 1, max_hp)


func change_max_hp(amount: int) -> void:
	max_hp = max(1, max_hp + amount)
	hp = clampi(hp + max(0, amount), 1, max_hp)


## Substitui uma carta do baralho pela versão aprimorada.
func upgrade_card(id: StringName) -> bool:
	var idx := deck.find(id)
	var card := Database.get_card(id)
	if idx < 0 or card == null or not card.can_upgrade():
		return false
	deck[idx] = StringName(String(id) + CardData.UPGRADE_SUFFIX)
	return true


func get_upgradable_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for c in get_deck_cards():
		if c.can_upgrade():
			result.append(c)
	return result


## Registra uma parte extraída. Retorna true se desbloqueou uma carta nova.
func gather(part: AnatomyPart) -> bool:
	gathered[part.id] = int(gathered.get(part.id, 0)) + 1
	Profile.record_part(part.id)
	var unlocked := false
	if part.unlocks_card != null and Profile.add_card_copy(part.unlocks_card.id):
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
	var newly_unlocked: Array[String] = []
	var ng_new := -1
	if won:
		Profile.runs_won += 1
		ng_new = Profile.clear_ng(expedition.id, ng_level)
		var before := Profile.cleared_expeditions.size()
		Profile.mark_cleared(expedition.id)
		if Profile.cleared_expeditions.size() > before:
			for e in Database.get_sorted_expeditions():
				if e.unlock_requirement == expedition.id:
					newly_unlocked.append(e.display_name)
	Profile.save_profile()
	last_summary = {
		"won": won,
		"kept": kept,
		"lost": lost,
		"new_cards": new_cards.duplicate(),
		"kills": kills,
		"floor": get_floor() + 1,
		"unlocked_regions": newly_unlocked,
		"ng_unlocked": ng_new,
		"expedition": expedition.display_name + (" · NG+%d" % ng_level if ng_level > 0 else ""),
	}
	active = false
	delete_save()
	return last_summary


# --- Persistência da expedição ---------------------------------------------

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func save_run() -> void:
	if not active:
		return
	var floors := []
	for row in map:
		var r := []
		for n: MapNode in row:
			r.append(n.to_dict())
		floors.append(r)
	var g := {}
	for k in gathered:
		g[String(k)] = gathered[k]
	var data := {
		"expedition": String(expedition.id),
		"ng_level": ng_level,
		"map": floors,
		"current": [current.floor_index, current.index] if current != null else [],
		"deck": Profile._to_strings(deck),
		"hp": hp,
		"max_hp": max_hp,
		"gathered": g,
		"new_cards": Profile._to_strings(new_cards),
		"kills": kills,
		"rng_state": str(rng.state),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data))


func load_run() -> bool:
	if not has_save():
		return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		delete_save()
		return false
	var expd: ExpeditionData = Database.expeditions.get(StringName(data.get("expedition", "")))
	if expd == null:
		delete_save()
		return false
	expedition = expd
	ng_level = clampi(int(data.get("ng_level", 0)), 0, Profile.MAX_NG)
	map.clear()
	var floors: Array = data.get("map", [])
	for fi in floors.size():
		var row: Array[MapNode] = []
		var nodes: Array = floors[fi]
		for ni in nodes.size():
			row.append(MapNode.from_dict(nodes[ni], fi, ni))
		map.append(row)
	var cur: Array = data.get("current", [])
	current = map[int(cur[0])][int(cur[1])] if cur.size() == 2 else null
	deck = Profile._to_names(data.get("deck", []))
	deck.assign(deck.filter(func(id): return Database.get_card(id) != null))
	hp = int(data.get("hp", 1))
	max_hp = int(data.get("max_hp", Profile.get_max_hp()))
	gathered.clear()
	var g: Dictionary = data.get("gathered", {})
	for k in g:
		gathered[StringName(k)] = int(g[k])
	new_cards = Profile._to_names(data.get("new_cards", []))
	kills = int(data.get("kills", 0))
	rng.state = int(data.get("rng_state", "0"))
	dissection_queue.clear()
	active = true
	return true
