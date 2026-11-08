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
var recipes: Dictionary = {} # StringName -> HybridRecipe
var lab_upgrades: Dictionary = {} # StringName -> LabUpgradeData
var events: Dictionary = {} # StringName -> EventData
var _part_owner: Dictionary = {} # part id -> MonsterData (espécie de origem principal)
var _upgraded_cache: Dictionary = {}


func _ready() -> void:
	_load_dir("res://data/cards", cards)
	_load_dir("res://data/organs", parts)
	_load_dir("res://data/monsters", monsters)
	_load_dir("res://data/mutations", mutations)
	_load_dir("res://data/expeditions", expeditions)
	_load_dir("res://data/recipes", recipes)
	_load_dir("res://data/lab_upgrades", lab_upgrades)
	_load_dir("res://data/events", events)
	# Partes podem ser compartilhadas (filhotes, chefes). A espécie "dona" é a de menor tier;
	# no empate, a que tem mais partes (a espécie principal, não o filhote).
	for m: MonsterData in monsters.values():
		for p in m.parts:
			var cur: MonsterData = _part_owner.get(p.id)
			if cur == null or m.tier < cur.tier or (m.tier == cur.tier and m.parts.size() > cur.parts.size()):
				_part_owner[p.id] = m
	_attach_art()


## Arte final: um arquivo com o id do recurso é ligado automaticamente
## (ex.: assets/art/cards/rend.png -> CardData.illustration).
const ART_DIR := "res://assets/art"


func _attach_art() -> void:
	for c: CardData in cards.values():
		if c.illustration == null:
			c.illustration = get_art("cards", c.id)
	for p: AnatomyPart in parts.values():
		if p.icon == null:
			p.icon = get_art("parts", p.id)
	for m: MonsterData in monsters.values():
		if m.portrait == null:
			m.portrait = get_art("monsters", m.id)


## Ícones de interface ficam guardados: quem os desenha em _draw() não mantém referência à textura,
## e sem isso ela seria liberada antes de ir para a tela (aparece um quadrado branco).
var _ui_art: Dictionary = {}


## Textura em assets/art/<kind>/<id>.png (ou .jpg/.webp), ou null.
func get_art(kind: String, id: StringName) -> Texture2D:
	if kind == "ui" and _ui_art.has(id):
		return _ui_art[id]
	for ext in ["png", "jpg", "webp"]:
		var path := "%s/%s/%s.%s" % [ART_DIR, kind, id, ext]
		if ResourceLoader.exists(path):
			var tex := load(path) as Texture2D
			if kind == "ui":
				_ui_art[id] = tex
			return tex
	return null


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


## Aceita ids aprimorados ("rend+"): a versão é gerada e guardada em cache.
func get_card(id: StringName) -> CardData:
	if cards.has(id):
		return cards[id]
	if _upgraded_cache.has(id):
		return _upgraded_cache[id]
	var s := String(id)
	if s.ends_with(CardData.UPGRADE_SUFFIX):
		var base: CardData = cards.get(StringName(s.trim_suffix(CardData.UPGRADE_SUFFIX)))
		if base != null:
			var up := base.make_upgraded()
			_upgraded_cache[id] = up
			return up
	return null


func get_part(id: StringName) -> AnatomyPart:
	return parts.get(id)


func get_monster(id: StringName) -> MonsterData:
	return monsters.get(id)


func get_mutation(id: StringName) -> MutationData:
	return mutations.get(id)


func get_part_owner(part_id: StringName) -> MonsterData:
	return _part_owner.get(part_id)


func find_recipe(a: AnatomyPart, b: AnatomyPart) -> HybridRecipe:
	for r: HybridRecipe in recipes.values():
		if r.matches(a, b):
			return r
	return null


## Receita que gera a carta (para mostrar a origem de híbridas na coleção).
func recipe_for_card(card_id: StringName) -> HybridRecipe:
	for r: HybridRecipe in recipes.values():
		if r.result != null and r.result.id == card_id:
			return r
	return null


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
		if a.is_hybrid() != b.is_hybrid():
			return b.is_hybrid()
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
		if a.family != b.family:
			return a.family < b.family
		return a.max_hp < b.max_hp)
	return result


func get_sorted_expeditions() -> Array[ExpeditionData]:
	var result: Array[ExpeditionData] = []
	for e: ExpeditionData in expeditions.values():
		result.append(e)
	result.sort_custom(func(a: ExpeditionData, b: ExpeditionData) -> bool: return a.order < b.order)
	return result


func get_sorted_upgrades() -> Array[LabUpgradeData]:
	var result: Array[LabUpgradeData] = []
	for u: LabUpgradeData in lab_upgrades.values():
		result.append(u)
	result.sort_custom(func(a: LabUpgradeData, b: LabUpgradeData) -> bool:
		if a.requires.is_empty() != b.requires.is_empty():
			return a.requires.is_empty()
		return a.display_name < b.display_name)
	return result
