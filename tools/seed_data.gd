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
const RW := Family.Id.ROTWALKER

const HEAD := AnatomyPart.Region.HEAD
const TORSO := AnatomyPart.Region.TORSO
const LIMBS := AnatomyPart.Region.LIMBS
const FLUIDS := AnatomyPart.Region.FLUIDS

var cards := {}
var parts := {}
var monsters := {}


func _init() -> void:
	_build_cards()
	_build_cards_m2()
	_build_parts()
	_build_parts_m2()
	_build_monsters()
	_build_monsters_m2()
	_build_mutations()
	_build_mutations_m2()
	_build_recipes()
	_build_upgrades()
	_build_events()
	_build_expeditions()
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
		intents: Array, part_ids: Array, visual: StringName, scale: float, lore: String, weakness: String, start_effects: Array = [], tint: Color = Color.WHITE) -> void:
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
	m.tint = tint
	monsters[id] = m
	_save(m, "res://data/monsters/%s.tres" % id)


func _build_monsters() -> void:
	var K := MonsterIntent.Kind
	monster(&"bloodfang", "Bloodfang", BF, MonsterData.Tier.NORMAL, 46, MonsterData.Pattern.RANDOM_NO_REPEAT, [
		intent("Mordida", K.ATTACK, [dmg(10)], 2),
		intent("Dilacerar", K.ATTACK_DEBUFF, [dmg(5), st(&"bleed", 2)], 2),
		intent("Rosnar", K.BUFF, [st(&"strength", 2, true)], 1),
	], [&"bf_fangs", &"bf_claws", &"bf_heart", &"bf_hide", &"bf_eyes"], &"bloodfang", 1.0,
		"Predador quadrúpede de ombros altos e mandíbula desproporcional. Caça em silêncio e só ruge quando já provou sangue.",
		"Pele fina: o sangramento o abate sem danificar o coração. Golpes finais exagerados destroem a cabeça.")

	monster(&"ironback", "Ironback", IB, MonsterData.Tier.NORMAL, 50, MonsterData.Pattern.CYCLE, [
		intent("Enrijecer", K.DEFEND, [blk(12)]),
		intent("Investida", K.ATTACK, [dmg(11)]),
		intent("Esguicho Ácido", K.ATTACK_DEBUFF, [dmg(5), st(&"vulnerable", 1)]),
	], [&"ib_carapace", &"ib_mandible", &"ib_gland", &"ib_plates", &"ib_endo"], &"ironback", 1.0,
		"Inseto do tamanho de um javali, coberto de placas sobrepostas. Os espinhos da carapaça punem quem ataca às cegas.",
		"Espinhos devolvem dano a cada golpe: prefira poucos ataques fortes, ou deixe o sangramento trabalhar.",
		[st(&"thorns", 2, true)])

	monster(&"voidspawn", "Voidspawn", VS, MonsterData.Tier.NORMAL, 42, MonsterData.Pattern.RANDOM_NO_REPEAT, [
		intent("Toque do Vazio", K.ATTACK_DEBUFF, [dmg(6), st(&"corruption", 1)], 2),
		intent("Olhar Fixo", K.DEBUFF, [st(&"weak", 2), st(&"vulnerable", 1)], 1),
		intent("Pulsar", K.ATTACK, [dmg(5, 2)], 2),
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



# =============================================================================
# Marco 2: Rotwalker, 2ª região, híbridas, eventos, melhorias de laboratório
# =============================================================================

func ret(count: int) -> ReturnFromDiscardEffect:
	var e := ReturnFromDiscardEffect.new()
	e.count = count
	return e


func hybrid(id: StringName, name: String, cost: int, type: CardData.CardType, rarity: CardData.Rarity,
		fam_a: Family.Id, fam_b: Family.Id, motif: StringName, effects: Array, flavor: String = "", exhaust: bool = false) -> void:
	card(id, name, cost, type, rarity, fam_a, "Experimento", motif, effects, flavor, exhaust)
	var c: CardData = cards[id]
	c.secondary_family = fam_b
	c.category = CardData.Category.HYBRID
	_save(c, "res://data/cards/%s.tres" % id)


func _build_cards_m2() -> void:
	# Rotwalker — regeneração e persistência
	card(&"regenerative_flesh", "Carne Regenerativa", 1, SKL, COMMON, RW, "Carne", &"flesh", [st(&"regen", 4, true)],
		"Continua se recompondo dentro do frasco.")
	card(&"marrow_spark", "Medula Energética", 0, SKL, UNCOMMON, RW, "Medula", &"ribs", [energy(1), draw(1)], "", true)
	card(&"muscle_memory", "Memória Muscular", 1, SKL, UNCOMMON, RW, "Cérebro", &"brain", [ret(2)],
		"O corpo lembra o que a mente esqueceu.")
	card(&"necrotic_bile", "Bile Necrótica", 1, ATK, COMMON, RW, "Bile", &"gland", [dmg(5), st(&"weak", 1), st(&"vulnerable", 1)])
	card(&"infected_bite", "Mordida Infecta", 1, ATK, COMMON, RW, "Dentes Podres", &"fang", [dmg(5), heal(2)])
	card(&"dry_sinew", "Tendões Secos", 1, DEF, COMMON, RW, "Tendões Secos", &"tendon", [blk(6), st(&"regen", 2, true)])
	card(&"field_suture", "Sutura de Campo", 1, SKL, UNCOMMON, RW, "Suturas", &"suture", [heal(5), blk(4)], "", true)
	card(&"rot_pulse", "Pulso Pútrido", 2, MUT, RARE, RW, "Coração Costurado", &"heart", [st(&"rot_pulse", 3, true)],
		"Bate devagar. Nunca para.")
	# Colosso Ironback
	card(&"iron_bastion", "Bastião de Ferro", 2, DEF, RARE, IB, "Núcleo de Ferro", &"carapace", [blk(18)])
	card(&"colossal_horn", "Chifrada Colossal", 2, ATK, RARE, IB, "Chifre Colossal", &"horn", [dmg(14), st(&"vulnerable", 2)])

	# Híbridas (desbloqueadas na Estação de Experimentação)
	hybrid(&"hb_armored_heart", "Coração Blindado", 1, DEF, UNCOMMON, BF, IB, &"heart", [blk(7), st(&"regen", 3, true)],
		"Um coração que bate atrás de placas de quitina.")
	hybrid(&"hb_void_claws", "Garras do Vazio", 1, ATK, UNCOMMON, BF, VS, &"claw", [dmg(3, 3), st(&"corruption", 2)])
	hybrid(&"hb_necro_oracle", "Oráculo Necrótico", 1, SKL, RARE, VS, RW, &"brain", [draw(2), ret(1)],
		"Vê o que virá e lembra o que passou.")
	hybrid(&"hb_living_shell", "Casca Viva", 1, DEF, UNCOMMON, IB, RW, &"carapace", [blk(9), st(&"regen", 3, true)])
	hybrid(&"hb_corrosive_fang", "Presa Corrosiva", 1, ATK, UNCOMMON, BF, IB, &"fang", [dmg(5), st(&"bleed", 2), st(&"weak", 2)])
	hybrid(&"hb_void_marrow", "Medula do Vazio", 0, SKL, RARE, VS, RW, &"core", [energy(1), st(&"corruption", 2, false, true)], "", true)
	hybrid(&"hb_hematic_tide", "Maré Hemática", 2, ATK, RARE, BF, VS, &"tentacle", [dmg(6, 1, true), st(&"bleed", 3, false, true)])
	hybrid(&"hb_chitin_maw", "Bocarra Quitinosa", 2, ATK, UNCOMMON, IB, BF, &"mandible", [dmg(10), st(&"thorns", 3, true)])


func _build_parts_m2() -> void:
	part(&"rw_flesh", "Carne", RW, TORSO, COMMON, 0.85, &"regenerative_flesh", &"flesh", "Tecido que se fecha sozinho alguns minutos após o corte.")
	part(&"rw_marrow", "Medula", RW, TORSO, UNCOMMON, 0.55, &"marrow_spark", &"ribs", "Medula escura que ainda gera calor.")
	part(&"rw_brain", "Cérebro", RW, HEAD, UNCOMMON, 0.6, &"muscle_memory", &"brain", "Encolhido, mas os reflexos persistem.")
	part(&"rw_bile", "Bile", RW, FLUIDS, COMMON, 0.75, &"necrotic_bile", &"gland", "Fluido amarelado que enfraquece qualquer tecido vivo.")
	part(&"gh_teeth", "Dentes Podres", RW, HEAD, COMMON, 0.8, &"infected_bite", &"fang", "Dentes que transmitem febre e fome.")
	part(&"gh_sinew", "Tendões Secos", RW, LIMBS, COMMON, 0.8, &"dry_sinew", &"tendon", "Fibras ressecadas, mas impossíveis de romper.")
	part(&"ab_stitches", "Suturas", RW, LIMBS, UNCOMMON, 0.7, &"field_suture", &"suture", "Pontos feitos por mãos que ninguém viu.")
	part(&"ab_heart", "Coração Costurado", RW, TORSO, RARE, 0.45, &"rot_pulse", &"heart", "Três corações costurados em um só.")
	part(&"co_core", "Núcleo de Ferro", IB, TORSO, RARE, 0.5, &"iron_bastion", &"carapace", "O centro maciço de uma carapaça de toneladas.")
	part(&"co_horn", "Chifre Colossal", IB, HEAD, RARE, 0.55, &"colossal_horn", &"horn", "Um chifre que já derrubou muralhas.")


func _build_monsters_m2() -> void:
	var K := MonsterIntent.Kind
	monster(&"bloodfang_pup", "Filhote de Bloodfang", BF, MonsterData.Tier.NORMAL, 20, MonsterData.Pattern.RANDOM_NO_REPEAT, [
		intent("Mordiscar", K.ATTACK, [dmg(5)], 2),
		intent("Arranhar", K.ATTACK_DEBUFF, [dmg(3), st(&"bleed", 2)], 1),
	], [&"bf_fangs", &"bf_hide"], &"bloodfang", 0.7,
		"Filhotes caçam em dupla e aprendem rápido o gosto do sangue.",
		"Frágeis: um golpe forte resolve, mas danifica a cabeça.")

	monster(&"rotwalker", "Rotwalker", RW, MonsterData.Tier.NORMAL, 48, MonsterData.Pattern.CYCLE, [
		intent("Golpe Arrastado", K.ATTACK, [dmg(12)]),
		intent("Recompor", K.BUFF, [st(&"regen", 3, true), blk(4)]),
		intent("Vômito Pútrido", K.ATTACK_DEBUFF, [dmg(7), st(&"weak", 2)]),
	], [&"rw_flesh", &"rw_marrow", &"rw_brain", &"rw_bile"], &"rotwalker", 1.0,
		"Um cadáver que se recusa a parar. A carne se fecha sobre as próprias feridas.",
		"Regenera rápido: sangramento e corrupção vencem a regeneração ao longo do tempo.")

	monster(&"ghoul", "Carniçal", RW, MonsterData.Tier.NORMAL, 25, MonsterData.Pattern.RANDOM_NO_REPEAT, [
		intent("Mordida Infecta", K.ATTACK, [dmg(8)], 2),
		intent("Roer", K.ATTACK, [dmg(5), heal(4)], 1),
	], [&"gh_teeth", &"gh_sinew"], &"ghoul", 0.8,
		"Rastejam em bandos pelas catacumbas, roendo o que encontram.",
		"Sempre em grupo: golpes em área resolvem o problema.")

	monster(&"stitched_abomination", "Abominação Costurada", RW, MonsterData.Tier.ELITE, 100, MonsterData.Pattern.CYCLE, [
		intent("Golpe Costurado", K.ATTACK, [dmg(15)]),
		intent("Recosturar", K.BUFF, [st(&"regen", 5, true), blk(8)]),
		intent("Esmagar e Arrastar", K.ATTACK_DEBUFF, [dmg(8, 2), st(&"weak", 1)]),
	], [&"ab_stitches", &"ab_heart", &"rw_flesh"], &"rotwalker", 1.2,
		"Vários corpos unidos por suturas grosseiras. Já morreu uma vez — e não aceitou.",
		"Sobrevive ao primeiro golpe fatal. Guarde força para derrubá-la duas vezes.",
		[st(&"undying", 1, true)], Color("#C9A5A0"))

	monster(&"iron_colossus", "Colosso Ironback", IB, MonsterData.Tier.BOSS, 125, MonsterData.Pattern.CYCLE, [
		intent("Couraça Total", K.DEFEND, [blk(16)]),
		intent("Avalanche de Placas", K.ATTACK, [dmg(6, 3)]),
		intent("Chifrada", K.ATTACK, [dmg(18)]),
		intent("Ácido Corrosivo", K.ATTACK_DEBUFF, [dmg(8), st(&"vulnerable", 2)]),
	], [&"co_core", &"co_horn", &"ib_carapace", &"ib_endo"], &"ironback", 1.35,
		"O mais antigo dos Ironback. Sua carapaça carrega a lama de séculos.",
		"Espinhos em todo o corpo: prefira sangramento, corrupção e golpes únicos e fortes.",
		[st(&"thorns", 3, true)], Color("#D7A07A"))


func _build_mutations_m2() -> void:
	mutation(&"mut_rw_blood", "Sangue de Rotwalker", RW, "Uma vez por combate, sobreviva a um golpe fatal com 1 de vida.",
		{"rw_flesh": 1, "rw_bile": 1}, 2, &"blood", 0, 0, 0, [st(&"undying", 1, true)])
	mutation(&"mut_co_plates", "Placas de Colosso", IB, "+12 de vida máxima. Comece cada combate com 2 de Espinhos.",
		{"co_core": 1}, 3, &"carapace", 12, 0, 0, [st(&"thorns", 2, true)])


# --- Receitas híbridas ------------------------------------------------------

func recipe(id: StringName, a: StringName, b: StringName, result: StringName, hint: String) -> void:
	var r := HybridRecipe.new()
	r.id = id
	r.part_a = parts[a]
	r.part_b = parts[b]
	r.result = cards[result]
	r.hint = hint
	_save(r, "res://data/recipes/%s.tres" % id)


func _build_recipes() -> void:
	recipe(&"rc_armored_heart", &"bf_heart", &"ib_carapace", &"hb_armored_heart", "Algo que pulsa, protegido por algo que não se rompe.")
	recipe(&"rc_void_claws", &"bf_claws", &"vs_ichor", &"hb_void_claws", "Lâminas naturais mergulhadas em um fluido frio e violeta.")
	recipe(&"rc_necro_oracle", &"vs_eyes", &"rw_brain", &"hb_necro_oracle", "Olhos que veem demais, ligados a uma mente que não esquece.")
	recipe(&"rc_living_shell", &"ib_carapace", &"rw_flesh", &"hb_living_shell", "Uma couraça que cicatriza sozinha.")
	recipe(&"rc_corrosive_fang", &"bf_fangs", &"ib_gland", &"hb_corrosive_fang", "Dentes serrilhados banhados em ácido.")
	recipe(&"rc_void_marrow", &"vs_tentacles", &"rw_marrow", &"hb_void_marrow", "Calor de medula conduzido por membros que não são deste mundo.")
	recipe(&"rc_hematic_tide", &"bfa_blood", &"vs_tentacles", &"hb_hematic_tide", "Sangue fervente espalhado por tentáculos.")
	recipe(&"rc_chitin_maw", &"ib_mandible", &"bf_fangs", &"hb_chitin_maw", "Uma boca de inseto com dentes de predador.")


# --- Melhorias do laboratório -----------------------------------------------

func upgrade(id: StringName, name: String, desc: String, cost: Dictionary, motif: StringName,
		incisions: int = 0, preserve: float = 0.0, damaged_mult: float = 0.0, hp: int = 0, requires: StringName = &"") -> void:
	var u := LabUpgradeData.new()
	u.id = id
	u.display_name = name
	u.description = desc
	u.family_cost = cost
	u.art_motif = motif
	u.incisions_bonus = incisions
	u.preserve_bonus = preserve
	u.damaged_multiplier = damaged_mult
	u.max_hp_bonus = hp
	u.requires = requires
	_save(u, "res://data/lab_upgrades/%s.tres" % id)


func _build_upgrades() -> void:
	upgrade(&"up_obsidian", "Bisturi de Obsidiana", "+1 incisão em cada dissecação.", {BF: 3, IB: 2}, &"scalpel", 1)
	upgrade(&"up_twin_blades", "Lâminas Gêmeas", "+1 incisão em cada dissecação.", {VS: 3, RW: 3}, &"double_scalpel", 1, 0.0, 0.0, 0, &"up_obsidian")
	upgrade(&"up_jars", "Frascos de Conservação", "+10% de chance de extrair qualquer parte.", {VS: 2, BF: 2}, &"gland", 0, 0.1)
	upgrade(&"up_table", "Mesa de Contenção", "Partes danificadas mantêm 75% da chance (em vez de 50%).", {IB: 4}, &"plates", 0, 0.0, 0.75)
	upgrade(&"up_field_kit", "Kit de Sobrevivência", "+6 de vida máxima.", {RW: 3}, &"suture", 0, 0.0, 0.0, 6)


# --- Eventos ----------------------------------------------------------------

func choice(label: String, result: String, opts: Dictionary = {}) -> EventChoice:
	var c := EventChoice.new()
	c.label = label
	c.result_text = result
	c.description = opts.get("desc", "")
	c.success_chance = opts.get("chance", 1.0)
	c.hp_change = opts.get("hp", 0)
	c.max_hp_change = opts.get("max_hp", 0)
	var gp: Array[AnatomyPart] = []
	for pid in opts.get("parts", []):
		gp.append(parts[pid])
	c.gain_parts = gp
	var ac: Array[CardData] = []
	for cid in opts.get("cards", []):
		ac.append(cards[cid])
	c.add_cards = ac
	c.remove_card = opts.get("remove", false)
	c.upgrade_card = opts.get("upgrade", false)
	var f: Array[MonsterData] = []
	for mid in opts.get("fight", []):
		f.append(monsters[mid])
	c.fight = f
	c.fail_text = opts.get("fail_text", "")
	c.fail_hp_change = opts.get("fail_hp", 0)
	var ff: Array[MonsterData] = []
	for mid in opts.get("fail_fight", []):
		ff.append(monsters[mid])
	c.fail_fight = ff
	return c


func event(id: StringName, title: String, text: String, motif: StringName, accent: Color, choices: Array) -> void:
	var e := EventData.new()
	e.id = id
	e.title = title
	e.text = text
	e.art_motif = motif
	e.accent = accent
	e.choices.assign(choices)
	_save(e, "res://data/events/%s.tres" % id)


func _build_events() -> void:
	event(&"ev_old_carcass", "Carcaça Antiga",
		"Sob a turfa, o corpo de um Bloodfang morto há dias. A carne já escurece, mas a pele parece intacta.",
		&"hide", Palette.BLOOD_BRIGHT, [
		choice("Dissecar às pressas", "Você salva um pedaço de couro antes que apodreça.",
			{"desc": "70%: ganhe Pele de Bloodfang. Falha: perca 6 de vida.", "chance": 0.7, "parts": [&"bf_hide"],
			"fail_text": "O bisturi escorrega no tecido podre. O corte infecciona.", "fail_hp": -6}),
		choice("Arrancar as presas", "As presas cedem — e cortam seus dedos no caminho.",
			{"desc": "Perca 3 de vida. Ganhe Presas.", "hp": -3, "parts": [&"bf_fangs"]}),
		choice("Seguir em frente", "Nem tudo que está morto vale o risco."),
	])
	event(&"ev_wounded_researcher", "Pesquisador Ferido",
		"Um colega do laboratório, encostado em uma árvore, segura um caderno manchado de sangue. Ele não vai durar muito.",
		&"notes", Palette.BONE, [
		choice("Tratar os ferimentos", "Antes de partir, ele lhe ensina uma técnica de corte.",
			{"desc": "Perca 7 de vida. Aprimore uma carta.", "hp": -7, "upgrade": true}),
		choice("Aceitar as anotações", "Páginas e páginas de observações. Algumas são úteis.",
			{"desc": "Adicione Anotações de Campo ao baralho.", "cards": [&"field_notes"]}),
		choice("Deixá-lo", "Você segue. O silêncio pesa mais que a mochila."),
	])
	event(&"ev_violet_pool", "Poça Violeta",
		"Um líquido frio e luminoso escorre de uma fenda na rocha. Ele parece se mover contra a gravidade.",
		&"blood", Palette.VIOLET_BRIGHT, [
		choice("Beber", "Seu sangue esfria. Algo em você se adapta.",
			{"desc": "+5 de vida máxima, perca 6 de vida.", "max_hp": 5, "hp": -6}),
		choice("Coletar amostra", "O frasco se enche de icor violeta.",
			{"desc": "60%: ganhe Icor Violeta. Falha: algo emerge da poça.", "chance": 0.6, "parts": [&"vs_ichor"],
			"fail_text": "A superfície se rompe — um Voidspawn emerge!", "fail_fight": [&"voidspawn"]}),
		choice("Afastar-se", "Você não confia em nada que brilha no escuro."),
	])
	event(&"ev_ironback_nest", "Ninho de Ironback",
		"Ovos de casca metálica, ainda mornos, aninhados entre ossos roídos.",
		&"carapace", Palette.MOSS_BRIGHT, [
		choice("Recolher cascas", "Fragmentos de carapaça, perfeitos para estudo.",
			{"desc": "60%: ganhe Carapaça. Falha: a mãe estava por perto.", "chance": 0.6, "parts": [&"ib_carapace"],
			"fail_text": "Um estalo de quitina atrás de você. A mãe voltou.", "fail_fight": [&"ironback"]}),
		choice("Esmagar os ovos", "Menos Ironback no mundo. Você sente uma satisfação estranha.",
			{"desc": "Recupere 5 de vida.", "hp": 5}),
		choice("Afastar-se", "Você anota a localização para outra ocasião."),
	])
	event(&"ev_bone_altar", "Altar de Ossos",
		"Um altar de costelas empilhadas. Oferendas antigas apodrecem aos pés dele.",
		&"ribs", Palette.SICK_GREEN, [
		choice("Oferecer uma carta", "O altar aceita a oferenda. Você se sente mais leve.",
			{"desc": "Remova uma carta do baralho e recupere 8 de vida.", "remove": true, "hp": 8}),
		choice("Rezar", "Nada responde. Ainda assim, você descansa um pouco.", {"desc": "Recupere 6 de vida.", "hp": 6}),
		choice("Profanar", "Entre os ossos, uma medula ainda morna.",
			{"desc": "50%: ganhe Medula de Rotwalker. Falha: perca 10 de vida.", "chance": 0.5, "parts": [&"rw_marrow"],
			"fail_text": "Os ossos desabam sobre você.", "fail_hp": -10}),
	])
	event(&"ev_hermit", "Eremita Alquimista",
		"Um velho mistura frascos fervendo sobre uma fogueira azul. \"Traga-me algo vivo e eu lhe darei algo melhor.\"",
		&"gland", Palette.PETROL_BRIGHT, [
		choice("Pedir um tônico", "Amargo como fel, mas funciona.", {"desc": "Recupere 15 de vida.", "hp": 15}),
		choice("Pedir uma técnica", "Ele corrige sua postura com uma bengala.",
			{"desc": "Perca 4 de vida. Aprimore uma carta.", "hp": -4, "upgrade": true}),
		choice("Recusar", "Ele dá de ombros e volta aos frascos."),
	])


# --- Expedições -------------------------------------------------------------

func encounter(id: StringName, ids: Array, min_floor: int = 0, weight: int = 1) -> EncounterData:
	var e := EncounterData.new()
	e.id = id
	var ms: Array[MonsterData] = []
	for mid in ids:
		ms.append(monsters[mid])
	e.monsters = ms
	e.min_floor = min_floor
	e.weight = weight
	return e


func _all_events() -> Array[EventData]:
	var list: Array[EventData] = []
	for id in [&"ev_old_carcass", &"ev_wounded_researcher", &"ev_violet_pool", &"ev_ironback_nest", &"ev_bone_altar", &"ev_hermit"]:
		list.append(load("res://data/events/%s.tres" % id))
	return list


func _build_expeditions() -> void:
	var e := ExpeditionData.new()
	e.id = &"bone_moor"
	e.display_name = "Charneca dos Ossos"
	e.description = "Pântano de turfa e ossadas onde predadores, insetos blindados e aberrações disputam carcaças."
	e.order = 0
	e.floors = 8
	e.encounters.assign([
		encounter(&"bm_bloodfang", [&"bloodfang"], 0, 2),
		encounter(&"bm_ironback", [&"ironback"], 0, 2),
		encounter(&"bm_voidspawn", [&"voidspawn"], 0, 2),
		encounter(&"bm_pups", [&"bloodfang_pup", &"bloodfang_pup"], 1, 2),
		encounter(&"bm_void_pup", [&"voidspawn", &"bloodfang_pup"], 3, 1),
	])
	e.elite_pool.assign([monsters[&"bloodfang_alpha"]])
	e.boss = monsters[&"void_matriarch"]
	e.events = _all_events()
	e.hp_per_floor = 2
	e.accent = Palette.BLOOD
	_save(e, "res://data/expeditions/bone_moor.tres")

	var c := ExpeditionData.new()
	c.id = &"flooded_catacombs"
	c.display_name = "Catacumbas Alagadas"
	c.description = "Túneis funerários inundados onde os mortos não descansam e algo enorme raspa as paredes."
	c.order = 1
	c.unlock_requirement = &"bone_moor"
	c.floors = 9
	c.encounters.assign([
		encounter(&"fc_rotwalker", [&"rotwalker"], 0, 2),
		encounter(&"fc_ghouls", [&"ghoul", &"ghoul"], 0, 2),
		encounter(&"fc_ironback", [&"ironback"], 1, 1),
		encounter(&"fc_void_ghoul", [&"voidspawn", &"ghoul"], 2, 1),
		encounter(&"fc_rot_pack", [&"rotwalker", &"ghoul"], 4, 1),
	])
	c.elite_pool.assign([monsters[&"stitched_abomination"], monsters[&"bloodfang_alpha"]])
	c.boss = monsters[&"iron_colossus"]
	c.events = _all_events()
	c.hp_per_floor = 3
	c.accent = Palette.SICK_GREEN
	_save(c, "res://data/expeditions/flooded_catacombs.tres")
