extends SceneTree
## Balanceamento 1: curva de custo das cartas, cartas repetidas redesenhadas, escudo em mais monstros
## e dificuldade crescente por região. Edita os .tres em data/ (são a fonte da verdade).
##
## Uso: Godot_console.exe --headless --path . --script res://tools/balance_v1.gd
## Pode rodar de novo: cada valor é definido por completo, não somado.
## ATENÇÃO: rodar tools/seed_data.gd ou tools/seed_phases34.gd depois desfaz estas mudanças.

const SM := Family.Id.SPOREMAW
const K := MonsterIntent.Kind


func _init() -> void:
	_cards()
	_monsters()
	_regions()
	_ashwing_dive()
	print("Balanceamento 1 aplicado.")
	quit()


# --- Fábricas ---------------------------------------------------------------

func dmg(amount: int, hits: int = 1, all: bool = false, pierce: bool = false) -> DamageEffect:
	var e := DamageEffect.new()
	e.amount = amount
	e.hits = hits
	e.pierce = pierce
	if all:
		e.target = CardEffect.Target.ALL_OPPONENTS
	return e


func blk(amount: int) -> BlockEffect:
	var e := BlockEffect.new()
	e.amount = amount
	return e


func st(id: StringName, stacks: int, self_target: bool = false, all: bool = false) -> ApplyStatusEffect:
	var e := ApplyStatusEffect.new()
	e.status_id = id
	e.stacks = stacks
	if self_target:
		e.target = CardEffect.Target.SELF
	elif all:
		e.target = CardEffect.Target.ALL_OPPONENTS
	return e


func heal(amount: int) -> HealEffect:
	var e := HealEffect.new()
	e.amount = amount
	return e


func draw(count: int) -> DrawEffect:
	var e := DrawEffect.new()
	e.count = count
	return e


func energy(amount: int) -> GainEnergyEffect:
	var e := GainEnergyEffect.new()
	e.amount = amount
	return e


func lose(amount: int) -> LoseHpEffect:
	var e := LoseHpEffect.new()
	e.amount = amount
	return e


func shatter() -> RemoveBlockEffect:
	return RemoveBlockEffect.new()


func detonate(id: StringName, mult: int, all: bool = false) -> DetonateEffect:
	var e := DetonateEffect.new()
	e.status_id = id
	e.multiplier = mult
	if all:
		e.target = CardEffect.Target.ALL_OPPONENTS
	return e


func double(id: StringName, self_target: bool = false) -> MultiplyStatusEffect:
	var e := MultiplyStatusEffect.new()
	e.status_id = id
	e.factor = 2
	if self_target:
		e.target = CardEffect.Target.SELF
	return e


func cleanse() -> CleanseEffect:
	return CleanseEffect.new()


func intent(name: String, kind: MonsterIntent.Kind, effects: Array, weight: int = 1) -> MonsterIntent:
	var i := MonsterIntent.new()
	i.display_name = name
	i.kind = kind
	i.effects.assign(effects)
	i.weight = weight
	return i


func _save(res: Resource) -> void:
	var err := ResourceSaver.save(res, res.resource_path)
	if err != OK:
		push_error("Falha ao salvar %s (%d)" % [res.resource_path, err])


# --- Cartas -----------------------------------------------------------------

func card(id: StringName, cost: int, effects: Array, exhaust: bool = false) -> void:
	var c: CardData = load("res://data/cards/%s.tres" % id)
	c.cost = cost
	c.effects.assign(effects)
	c.exhaust = exhaust
	_save(c)


func _cards() -> void:
	# Custo 0: só o que é fraco ou se bane sozinho
	card(&"hunters_sight", 1, [st(&"vulnerable", 2), draw(1)])
	card(&"unstable_core", 0, [lose(6), energy(2)], true)
	card(&"lantern_core", 0, [lose(2), energy(1)], true)
	card(&"void_eyes", 1, [st(&"corruption", 3), draw(1)])

	# Custo 2: precisa valer mais que duas cartas de custo 1
	card(&"antler_charge", 2, [dmg(12, 1, false, true), st(&"spores", 3)])
	card(&"hb_chitin_maw", 2, [dmg(12), st(&"thorns", 3, true)])
	card(&"iron_bastion", 2, [blk(20)])
	card(&"shelf_scythe", 2, [dmg(9, 1, true), st(&"spores", 2, false, true)])
	card(&"tide_of_void", 2, [dmg(8, 1, true), st(&"corruption", 2, false, true)])
	card(&"rooted_steps", 2, [blk(12), st(&"thorns", 2, true)])

	# Custo 3: as cartas de chefe e de elite mais fortes
	card(&"colossal_horn", 3, [dmg(20, 1, false, true), st(&"vulnerable", 2)])
	card(&"matrix_pulse", 3, [heal(12), st(&"spores", 5, false, true)], true)
	card(&"molten_wing", 3, [dmg(12, 1, true), st(&"ember", 3, false, true)])
	card(&"hb_hematic_tide", 3, [dmg(9, 1, true), st(&"bleed", 4, false, true)])

	# Cartas que eram quase iguais a outras ganham mecânicas próprias
	card(&"tough_hide", 1, [blk(5), st(&"strength", 1, true)]) ## era igual à Placa de Carapaça
	card(&"filter_gills", 1, [blk(5), cleanse()]) ## era igual aos Tendões Secos
	card(&"moss_mantle", 1, [st(&"regen", 2, true), double(&"regen", true)]) ## era quase o Coração Blindado
	card(&"hb_kiln_shell", 1, [blk(8), st(&"ember", 2, false, true)]) ## era quase o Enraizar
	card(&"mycelial_web", 1, [detonate(&"spores", 2, true)]) ## era quase a Nuvem de Esporos
	card(&"fire_lash", 1, [dmg(2, 4, false, true)]) ## era quase o Rasgar
	card(&"ash_gaze", 1, [double(&"ember"), st(&"vulnerable", 1)]) ## era igual ao Olhar Bioluminescente
	card(&"acid_gland", 1, [shatter(), dmg(6), st(&"weak", 1)]) ## ácido que derrete o escudo


# --- Monstros ---------------------------------------------------------------

func add_intent(monster_id: StringName, it: MonsterIntent) -> void:
	var m: MonsterData = load("res://data/monsters/%s.tres" % monster_id)
	var list: Array[MonsterIntent] = []
	for old in m.intents:
		if old.display_name != it.display_name:
			list.append(old)
	list.append(it)
	m.intents = list
	_save(m)


func _monsters() -> void:
	# Mais monstros se defendem às vezes; o dano penetrante e o ácido passam a ter alvo
	add_intent(&"bloodfang", intent("Eriçar o Pelo", K.ATTACK_DEFEND, [dmg(6), blk(8)], 1))
	add_intent(&"voidspawn", intent("Membrana", K.DEFEND, [blk(10), st(&"corruption", 1)], 1))
	add_intent(&"ghoul", intent("Encolher", K.ATTACK_DEFEND, [dmg(4), blk(6)], 1))
	add_intent(&"sporeling", intent("Fechar o Chapéu", K.DEFEND, [blk(7)], 1))
	add_intent(&"spore_wisp", intent("Névoa", K.DEFEND, [blk(6), st(&"spores", 1)], 1))
	add_intent(&"ash_hatchling", intent("Penas Eriçadas", K.DEFEND, [blk(7)], 1))
	var ms: MonsterData = load("res://data/monsters/mycostalker.tres")
	for it in ms.intents:
		if it.display_name == "Afiar Foices":
			it.kind = K.BUFF
			it.effects.assign([st(&"strength", 2, true), blk(10)])
	_save(ms)


# --- Regiões ----------------------------------------------------------------

func region(id: StringName, hp_per_floor: int, strength: int, step: int) -> void:
	var e: ExpeditionData = load("res://data/expeditions/%s.tres" % id)
	e.hp_per_floor = hp_per_floor
	e.monster_strength = strength
	e.strength_floor_step = step
	_save(e)


func _regions() -> void:
	region(&"bone_moor", 2, 0, 0)
	region(&"flooded_catacombs", 4, 1, 4)
	region(&"fungal_grove", 5, 1, 4)
	region(&"ash_peaks", 6, 2, 5)


func _ashwing_dive() -> void:
	var m: MonsterData = load("res://data/monsters/ashwing.tres")
	for it in m.intents:
		if it.display_name == "Mergulho":
			it.effects.assign([dmg(5, 3)])
	_save(m)
	# Stormtalon: com a Força da região, as garras triplas pesavam demais
	var s: MonsterData = load("res://data/monsters/stormtalon.tres")
	for it in s.intents:
		if it.display_name == "Garras":
			it.effects.assign([dmg(5, 3)])
		elif it.display_name == "Eriçar":
			it.effects.assign([blk(8), st(&"strength", 2, true)])
	_save(s)
