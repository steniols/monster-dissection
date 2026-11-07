extends SceneTree
## Gera o conteúdo inicial do protótipo como .tres em res://data/.
##
## Uso (na pasta do projeto):
##   Godot_v4.x_console.exe --headless --path . --script res://tools/seed_data.gd
##
## ATENÇÃO: sobrescreve os arquivos de mesmo nome em data/. Depois da semeadura,
## os .tres são a fonte da verdade — edite-os no Inspector do Godot.

const ATK := CardData.CardType.ATTACK
const DEF := CardData.CardType.DEFENSE
const SKL := CardData.CardType.SKILL
const MUT := CardData.CardType.MUTATION

const STARTER := CardData.Rarity.STARTER
const COMMON := CardData.Rarity.COMMON
const UNCOMMON := CardData.Rarity.UNCOMMON
const RARE := CardData.Rarity.RARE

const NEU := Family.Id.NEUTRAL
const BF := Family.Id.BLOODFANG
const IB := Family.Id.IRONBACK
const VS := Family.Id.VOIDSPAWN

const HEAD := AnatomyPart.Region.HEAD
const TORSO := AnatomyPart.Region.TORSO
const LIMBS := AnatomyPart.Region.LIMBS
const FLUIDS := AnatomyPart.Region.FLUIDS

var cards := {}
var parts := {}
var monsters := {}


func _init() -> void:
	_build_cards()
	_build_parts()
	_build_monsters()
	_build_mutations()
	_build_expedition()
	print("Semeadura concluída: %d cartas, %d partes, %d monstros." % [cards.size(), parts.size(), monsters.size()])
	quit()


# --- Fábricas de efeitos ----------------------------------------------------

func dmg(amount: int, hits: int = 1, all: bool = false, per_card: int = 0) -> DamageEffect:
	var e := DamageEffect.new()
	e.amount = amount
	e.hits = hits
	e.bonus_per_card_played = per_card
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


func reduce(amount: int) -> ReduceCostEffect:
	var e := ReduceCostEffect.new()
	e.amount = amount
	return e


func on_kill(effects: Array) -> ConditionalEffect:
	var e := ConditionalEffect.new()
	e.condition = ConditionalEffect.Condition.TARGET_KILLED
	e.effects.assign(effects)
	return e


func block_dmg() -> BlockAsDamageEffect:
	return BlockAsDamageEffect.new()


func _save(res: Resource, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	res.take_over_path(path)
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("Falha ao salvar %s (%d)" % [path, err])


# --- Cartas -----------------------------------------------------------------

func card(id: StringName, name: String, cost: int, type: CardData.CardType, rarity: CardData.Rarity,
		family: Family.Id, part: String, motif: StringName, effects: Array, flavor: String = "", exhaust: bool = false) -> void:
	var c := CardData.new()
	c.id = id
	c.display_name = name
	c.cost = cost
	c.card_type = type
	c.rarity = rarity
	c.family = family
	c.source_part = part
	c.art_motif = motif
	c.effects.assign(effects)
	c.flavor = flavor
	c.exhaust = exhaust
	cards[id] = c
	_save(c, "res://data/cards/%s.tres" % id)


func _build_cards() -> void:
	# Instrumentos (neutras, desbloqueadas desde o início)
	card(&"scalpel_cut", "Corte de Bisturi", 1, ATK, STARTER, NEU, "", &"scalpel", [dmg(6)],
		"O primeiro corte é sempre o mais limpo.")
	card(&"guard", "Postura de Guarda", 1, DEF, STARTER, NEU, "", &"guard", [blk(5)],
		"Mantenha distância de qualquer coisa com mais dentes que você.")
	card(&"incision", "Incisão Precisa", 1, ATK, STARTER, NEU, "", &"incision", [dmg(4), st(&"bleed", 2)],
		"Corte ao longo das fibras. Deixe a criatura fazer o resto.")
	card(&"field_notes", "Anotações de Campo", 1, SKL, COMMON, NEU, "", &"notes", [draw(2)],
		"Página 41: não confiar em nada que tenha olhos ímpares.")
	card(&"double_scalpel", "Bisturi Duplo", 1, ATK, COMMON, NEU, "", &"double_scalpel", [dmg(4, 2)])

	# Bloodfang — sangramento e agressividade
	card(&"deep_bite", "Mordida Profunda", 1, ATK, COMMON, BF, "Presas", &"fang", [dmg(5), st(&"bleed", 3)],
		"Canais nas presas mantêm a ferida aberta.")
	card(&"rend", "Rasgar", 1, ATK, COMMON, BF, "Garras", &"claw", [dmg(3, 3)])
	card(&"predatory_pulse", "Pulso Predatório", 1, ATK, UNCOMMON, BF, "Coração", &"heart", [dmg(8), on_kill([heal(6)])],
		"O coração acelera quando a presa cai.")
	card(&"tough_hide", "Couro Resistente", 1, DEF, COMMON, BF, "Pele", &"hide", [blk(8)])
	card(&"hunters_sight", "Visão do Caçador", 0, SKL, UNCOMMON, BF, "Olhos", &"eye", [st(&"vulnerable", 2), draw(1)],
		"Enxerga o ponto onde a pele é mais fina.")
	card(&"hematic_fury", "Fúria Hemática", 1, SKL, UNCOMMON, BF, "Sangue Fervente", &"blood", [lose(3), st(&"strength", 2, true)])
	card(&"reflex", "Reflexo Muscular", 0, SKL, COMMON, BF, "Tendões", &"tendon", [reduce(1), draw(1)])
	card(&"pack_lunge", "Investida da Matilha", 2, ATK, RARE, BF, "Garras do Alfa", &"claw", [dmg(6, 1, false, 3)],
		"Quanto mais longa a caçada, mais feroz o bote.")
	card(&"bloodthirst", "Sede de Sangue", 2, MUT, RARE, BF, "Coração do Alfa", &"heart", [st(&"bloodthirst", 1, true)])

	# Ironback — defesa e contra-ataque
	card(&"carapace_plate", "Placa de Carapaça", 1, DEF, COMMON, IB, "Carapaça", &"carapace", [blk(8)])
	card(&"reactive_mandible", "Mandíbula Reativa", 1, SKL, COMMON, IB, "Mandíbula", &"mandible", [blk(4), st(&"thorns", 2, true)],
		"Fecha por reflexo, mesmo depois de separada do corpo.")
	card(&"acid_gland", "Glândula Ácida", 1, ATK, COMMON, IB, "Glândula Ácida", &"gland", [dmg(4), st(&"weak", 2)])
	card(&"chitin_charge", "Investida Quitinosa", 1, ATK, UNCOMMON, IB, "Placas Dorsais", &"plates", [block_dmg()])
	card(&"endoskeleton", "Endoesqueleto", 2, MUT, RARE, IB, "Endoesqueleto", &"ribs", [st(&"endoskeleton", 3, true)])

	# Voidspawn — corrupção e controle
	card(&"tentacle_grip", "Aperto Tentacular", 1, ATK, COMMON, VS, "Tentáculos", &"tentacle", [dmg(6), st(&"weak", 1)])
	card(&"void_eyes", "Olhos do Vazio", 0, SKL, COMMON, VS, "Olhos Múltiplos", &"eye", [st(&"corruption", 2), draw(1)],
		"Um deles está sempre olhando para você.")
	card(&"corrupting_touch", "Toque Corruptor", 1, ATK, UNCOMMON, VS, "Icor Violeta", &"blood", [dmg(4), st(&"corruption", 3)])
	card(&"unstable_core", "Núcleo Instável", 0, SKL, RARE, VS, "Núcleo do Vazio", &"core", [lose(5), energy(2)],
		"Pulsa em um ritmo que não pertence a nenhum coração.")
	card(&"abyssal_gaze", "Contemplar o Abismo", 2, MUT, RARE, VS, "Coroa de Olhos", &"crown", [st(&"abyss", 2, true)])
	card(&"tide_of_void", "Maré do Vazio", 2, ATK, UNCOMMON, VS, "Tentáculos-Mãe", &"tentacle", [dmg(7, 1, true), st(&"corruption", 2, false, true)])


# --- Partes anatômicas ------------------------------------------------------

func part(id: StringName, name: String, family: Family.Id, region: AnatomyPart.Region, rarity: CardData.Rarity,
		chance: float, card_id: StringName, motif: StringName, desc: String) -> void:
	var p := AnatomyPart.new()
	p.id = id
	p.display_name = name
	p.family = family
	p.region = region
	p.rarity = rarity
	p.preserve_chance = chance
	p.unlocks_card = cards[card_id]
	p.art_motif = motif
	p.description = desc
	parts[id] = p
	_save(p, "res://data/organs/%s.tres" % id)


func _build_parts() -> void:
	part(&"bf_fangs", "Presas", BF, HEAD, COMMON, 0.75, &"deep_bite", &"fang", "Presas serrilhadas com canais que mantêm a ferida aberta.")
	part(&"bf_claws", "Garras", BF, LIMBS, COMMON, 0.8, &"rend", &"claw", "Garras curvas, feitas para golpes rápidos e repetidos.")
	part(&"bf_heart", "Coração", BF, TORSO, UNCOMMON, 0.6, &"predatory_pulse", &"heart", "Quatro câmaras e um ritmo que dispara diante da presa.")
	part(&"bf_hide", "Pele", BF, TORSO, COMMON, 0.85, &"tough_hide", &"hide", "Couro curto e cicatrizado, mais resistente do que parece.")
	part(&"bf_eyes", "Olhos", BF, HEAD, UNCOMMON, 0.55, &"hunters_sight", &"eye", "Pupilas verticais que enxergam no escuro e no sangue.")

	part(&"bfa_blood", "Sangue Fervente", BF, FLUIDS, UNCOMMON, 0.7, &"hematic_fury", &"blood", "Ainda quente horas depois da morte.")
	part(&"bfa_tendons", "Tendões", BF, LIMBS, COMMON, 0.75, &"reflex", &"tendon", "Fibras tensas como cordas de arco.")
	part(&"bfa_claws", "Garras do Alfa", BF, LIMBS, RARE, 0.5, &"pack_lunge", &"claw", "Gastas por anos liderando a caçada.")
	part(&"bfa_heart", "Coração do Alfa", BF, TORSO, RARE, 0.45, &"bloodthirst", &"heart", "Maior que o punho de um homem. Nunca para de pedir sangue.")

	part(&"ib_carapace", "Carapaça", IB, TORSO, COMMON, 0.85, &"carapace_plate", &"carapace", "Placas de quitina sobrepostas, duras como ferro fundido.")
	part(&"ib_mandible", "Mandíbula", IB, HEAD, COMMON, 0.7, &"reactive_mandible", &"mandible", "Fecha por reflexo ao menor toque.")
	part(&"ib_gland", "Glândula Ácida", IB, FLUIDS, COMMON, 0.7, &"acid_gland", &"gland", "Bolsa de ácido que corrói tecidos e vontade.")
	part(&"ib_plates", "Placas Dorsais", IB, TORSO, UNCOMMON, 0.6, &"chitin_charge", &"plates", "Placas pesadas, usadas como aríete.")
	part(&"ib_endo", "Endoesqueleto", IB, TORSO, RARE, 0.35, &"endoskeleton", &"ribs", "Uma armação interna que se recompõe sozinha.")

	part(&"vs_tentacles", "Tentáculos", VS, LIMBS, COMMON, 0.8, &"tentacle_grip", &"tentacle", "Ventosas que continuam se contraindo no frasco.")
	part(&"vs_eyes", "Olhos Múltiplos", VS, HEAD, COMMON, 0.7, &"void_eyes", &"eye", "Cada olho foca em um momento diferente.")
	part(&"vs_ichor", "Icor Violeta", VS, FLUIDS, UNCOMMON, 0.65, &"corrupting_touch", &"blood", "Fluido frio que mancha tudo o que toca.")

	part(&"vm_core", "Núcleo do Vazio", VS, TORSO, RARE, 0.6, &"unstable_core", &"core", "Um órgão sem função conhecida. Emite calor e sussurros.")
	part(&"vm_crown", "Coroa de Olhos", VS, HEAD, RARE, 0.55, &"abyssal_gaze", &"crown", "Hastes oculares dispostas como uma coroa.")
	part(&"vm_tentacles", "Tentáculos-Mãe", VS, LIMBS, UNCOMMON, 0.7, &"tide_of_void", &"tentacle", "Grossos como troncos, ainda úmidos.")


# --- Monstros ---------------------------------------------------------------

func intent(name: String, kind: MonsterIntent.Kind, effects: Array, weight: int = 1) -> MonsterIntent:
	var i := MonsterIntent.new()
	i.display_name = name
	i.kind = kind
	i.effects.assign(effects)
	i.weight = weight
	return i


func monster(id: StringName, name: String, family: Family.Id, tier: MonsterData.Tier, hp: int, pattern: MonsterData.Pattern,
		intents: Array, part_ids: Array, visual: StringName, scale: float, lore: String, weakness: String, start_effects: Array = []) -> void:
	var m := MonsterData.new()
	m.id = id
	m.display_name = name
	m.family = family
	m.tier = tier
	m.max_hp = hp
	m.pattern = pattern
	m.intents.assign(intents)
	var ps: Array[AnatomyPart] = []
	for pid in part_ids:
		ps.append(parts[pid])
	m.parts = ps
	m.visual = visual
	m.scale = scale
	m.lore = lore
	m.weakness_note = weakness
	m.combat_start_effects.assign(start_effects)
	monsters[id] = m
	_save(m, "res://data/monsters/%s.tres" % id)


func _build_monsters() -> void:
	var K := MonsterIntent.Kind
	monster(&"bloodfang", "Bloodfang", BF, MonsterData.Tier.NORMAL, 42, MonsterData.Pattern.RANDOM_NO_REPEAT, [
		intent("Mordida", K.ATTACK, [dmg(9)], 2),
		intent("Dilacerar", K.ATTACK_DEBUFF, [dmg(5), st(&"bleed", 2)], 2),
		intent("Rosnar", K.BUFF, [st(&"strength", 2, true)], 1),
	], [&"bf_fangs", &"bf_claws", &"bf_heart", &"bf_hide", &"bf_eyes"], &"bloodfang", 1.0,
		"Predador quadrúpede de ombros altos e mandíbula desproporcional. Caça em silêncio e só ruge quando já provou sangue.",
		"Pele fina: o sangramento o abate sem danificar o coração. Golpes finais exagerados destroem a cabeça.")

	monster(&"ironback", "Ironback", IB, MonsterData.Tier.NORMAL, 46, MonsterData.Pattern.CYCLE, [
		intent("Enrijecer", K.DEFEND, [blk(12)]),
		intent("Investida", K.ATTACK, [dmg(11)]),
		intent("Esguicho Ácido", K.ATTACK_DEBUFF, [dmg(5), st(&"vulnerable", 1)]),
	], [&"ib_carapace", &"ib_mandible", &"ib_gland", &"ib_plates", &"ib_endo"], &"ironback", 1.0,
		"Inseto do tamanho de um javali, coberto de placas sobrepostas. Os espinhos da carapaça punem quem ataca às cegas.",
		"Espinhos devolvem dano a cada golpe: prefira poucos ataques fortes, ou deixe o sangramento trabalhar.",
		[st(&"thorns", 2, true)])

	monster(&"voidspawn", "Voidspawn", VS, MonsterData.Tier.NORMAL, 38, MonsterData.Pattern.RANDOM_NO_REPEAT, [
		intent("Toque do Vazio", K.ATTACK_DEBUFF, [dmg(6), st(&"corruption", 1)], 2),
		intent("Olhar Fixo", K.DEBUFF, [st(&"weak", 2), st(&"vulnerable", 1)], 1),
		intent("Pulsar", K.ATTACK, [dmg(4, 2)], 2),
	], [&"vs_tentacles", &"vs_eyes", &"vs_ichor"], &"voidspawn", 1.0,
		"Aberração assimétrica cujos olhos parecem observar coisas que ainda não aconteceram.",
		"Corrupção acumulada demais degenera os órgãos do tórax.")

	monster(&"bloodfang_alpha", "Bloodfang Alfa", BF, MonsterData.Tier.ELITE, 72, MonsterData.Pattern.CYCLE, [
		intent("Uivo da Matilha", K.BUFF, [st(&"strength", 2, true), blk(6)]),
		intent("Dilacerar", K.ATTACK_DEBUFF, [dmg(7), st(&"bleed", 3)]),
		intent("Golpe Brutal", K.ATTACK, [dmg(15)]),
		intent("Rasgar", K.ATTACK, [dmg(5, 3)]),
	], [&"bfa_blood", &"bfa_tendons", &"bfa_claws", &"bfa_heart"], &"bloodfang_alpha", 1.15,
		"Líder de matilha marcado por dezenas de cicatrizes. A crina de espinhos se eriça antes de cada bote.",
		"Fica mais forte a cada uivo: derrube-o rápido ou aguente o ritmo com armadura.")

	monster(&"void_matriarch", "Matriarca do Vazio", VS, MonsterData.Tier.BOSS, 112, MonsterData.Pattern.CYCLE, [
		intent("Gestação", K.BUFF, [blk(12), st(&"strength", 2, true)]),
		intent("Maré de Tentáculos", K.ATTACK, [dmg(5, 3)]),
		intent("Contemplação", K.DEBUFF, [st(&"corruption", 3), st(&"weak", 2)]),
		intent("Esmagar", K.ATTACK, [dmg(16)]),
	], [&"vm_core", &"vm_crown", &"vm_tentacles", &"vs_ichor"], &"void_matriarch", 1.25,
		"A origem de todos os Voidspawn da charneca. Seu núcleo pulsa em sincronia com algo muito abaixo da terra.",
		"A Contemplação acumula corrupção permanente em você. Termine a luta antes que ela termine com você.")


# --- Mutações ---------------------------------------------------------------

func mutation(id: StringName, name: String, family: Family.Id, desc: String, cost: Dictionary, corruption: int,
		motif: StringName, max_hp: int = 0, energy_bonus: int = 0, draw_bonus: int = 0, start: Array = []) -> void:
	var m := MutationData.new()
	m.id = id
	m.display_name = name
	m.family = family
	m.description = desc
	m.material_cost = cost
	m.corruption = corruption
	m.art_motif = motif
	m.max_hp_bonus = max_hp
	m.energy_bonus = energy_bonus
	m.first_turn_draw_bonus = draw_bonus
	m.combat_start_effects.assign(start)
	_save(m, "res://data/mutations/%s.tres" % id)


func _build_mutations() -> void:
	mutation(&"mut_bf_heart", "Coração de Bloodfang", BF, "+8 de vida máxima.",
		{"bf_heart": 1}, 1, &"heart", 8)
	mutation(&"mut_ib_shell", "Couraça de Ironback", IB, "Comece cada combate com 6 de Armadura.",
		{"ib_carapace": 2}, 1, &"carapace", 0, 0, 0, [blk(6)])
	mutation(&"mut_vs_eyes", "Olhos de Voidspawn", VS, "Compre 2 cartas a mais no primeiro turno de cada combate.",
		{"vs_eyes": 1, "vs_ichor": 1}, 2, &"eye", 0, 0, 2)
	mutation(&"mut_bfa_blood", "Sangue do Alfa", BF, "Comece cada combate com 1 de Força.",
		{"bfa_blood": 1, "bf_claws": 1}, 2, &"blood", 0, 0, 0, [st(&"strength", 1, true)])
	mutation(&"mut_vm_core", "Núcleo Transplantado", VS, "+1 de Energia por turno.",
		{"vm_core": 1, "vs_tentacles": 2}, 3, &"core", 0, 1)


# --- Expedição --------------------------------------------------------------

func _build_expedition() -> void:
	var e := ExpeditionData.new()
	e.id = &"bone_moor"
	e.display_name = "Charneca dos Ossos"
	e.description = "Pântano de turfa e ossadas onde predadores, insetos blindados e aberrações disputam carcaças."
	e.floors = 8
	e.normal_pool.assign([monsters[&"bloodfang"], monsters[&"ironback"], monsters[&"voidspawn"]])
	e.elite_pool.assign([monsters[&"bloodfang_alpha"]])
	e.boss = monsters[&"void_matriarch"]
	e.hp_per_floor = 2
	_save(e, "res://data/expeditions/bone_moor.tres")
