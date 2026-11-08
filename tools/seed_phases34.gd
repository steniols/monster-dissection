extends SceneTree
## Gera o conteúdo das fases 3 e 4 (famílias Sporemaw e Ashwing) como .tres em res://data/.
## Só cria os arquivos destas fases: não toca no conteúdo antigo.
##
## Uso: Godot_console.exe --headless --path . --script res://tools/seed_phases34.gd
##
## ATENÇÃO: sobrescreve os arquivos de mesmo nome. Depois de ajustar um .tres à mão, não rode de novo.

const ATK := CardData.CardType.ATTACK
const DEF := CardData.CardType.DEFENSE
const SKL := CardData.CardType.SKILL
const MUT := CardData.CardType.MUTATION

const COMMON := CardData.Rarity.COMMON
const UNCOMMON := CardData.Rarity.UNCOMMON
const RARE := CardData.Rarity.RARE

const BF := Family.Id.BLOODFANG
const IB := Family.Id.IRONBACK
const VS := Family.Id.VOIDSPAWN
const RW := Family.Id.ROTWALKER
const SM := Family.Id.SPOREMAW
const AW := Family.Id.ASHWING

const HEAD := AnatomyPart.Region.HEAD
const TORSO := AnatomyPart.Region.TORSO
const LIMBS := AnatomyPart.Region.LIMBS
const FLUIDS := AnatomyPart.Region.FLUIDS

const NORMAL := MonsterData.Tier.NORMAL
const ELITE := MonsterData.Tier.ELITE
const BOSS := MonsterData.Tier.BOSS
const CYCLE := MonsterData.Pattern.CYCLE
const RANDOM := MonsterData.Pattern.RANDOM_NO_REPEAT

const K_ATK := MonsterIntent.Kind.ATTACK
const K_DEF := MonsterIntent.Kind.DEFEND
const K_BUFF := MonsterIntent.Kind.BUFF
const K_DEB := MonsterIntent.Kind.DEBUFF
const K_AD := MonsterIntent.Kind.ATTACK_DEBUFF

var cards := {}
var parts := {}
var monsters := {}


func _init() -> void:
	_build_cards()
	_build_parts()
	_build_monsters()
	_build_mutations()
	_build_recipes()
	_build_upgrades()
	_build_events()
	_build_expeditions()
	print("Fases 3 e 4: %d cartas, %d partes, %d monstros." % [cards.size(), parts.size(), monsters.size()])
	quit()


# --- Fábricas ---------------------------------------------------------------

func dmg(amount: int, hits: int = 1, all: bool = false) -> DamageEffect:
	var e := DamageEffect.new()
	e.amount = amount
	e.hits = hits
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


func _save(res: Resource, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	res.take_over_path(path)
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("Falha ao salvar %s (%d)" % [path, err])


func old_part(id: StringName) -> AnatomyPart:
	return load("res://data/organs/%s.tres" % id)


func old_monster(id: StringName) -> MonsterData:
	return load("res://data/monsters/%s.tres" % id)


func get_part(id: StringName) -> AnatomyPart:
	return parts[id] if parts.has(id) else old_part(id)


func get_monster(id: StringName) -> MonsterData:
	return monsters[id] if monsters.has(id) else old_monster(id)


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


func hybrid(id: StringName, name: String, cost: int, type: CardData.CardType, rarity: CardData.Rarity,
		fam_a: Family.Id, fam_b: Family.Id, motif: StringName, effects: Array, flavor: String = "") -> void:
	card(id, name, cost, type, rarity, fam_a, "Experimento", motif, effects, flavor)
	var c: CardData = cards[id]
	c.secondary_family = fam_b
	c.category = CardData.Category.HYBRID
	_save(c, "res://data/cards/%s.tres" % id)


func _build_cards() -> void:
	# Sporemaw: Esporos que passam de corpo em corpo, e resistência
	card(&"cap_glow", "Brilho do Chapéu", 1, SKL, COMMON, SM, "Chapéu Luminoso", &"eye", [st(&"spores", 3), st(&"weak", 1)],
		"A luz atrai. O resto vem depois.")
	card(&"spore_cloud", "Nuvem de Esporos", 1, SKL, COMMON, SM, "Saco de Esporos", &"blood", [st(&"spores", 3, false, true)],
		"Um sopro basta. Respire pelo nariz, dizem os manuais.")
	card(&"filter_gills", "Lamelas Filtrantes", 1, DEF, COMMON, SM, "Lamelas", &"plates", [blk(6), st(&"regen", 2, true)])
	card(&"fungal_bite", "Bocada Fúngica", 1, ATK, COMMON, SM, "Mandíbula Fúngica", &"fang", [dmg(6), st(&"spores", 2)],
		"Os dentes são fibras. A mordida é só o começo.")
	card(&"take_root", "Enraizar", 1, DEF, COMMON, SM, "Raízes-Pernas", &"tendon", [blk(8), st(&"thorns", 1, true)])
	card(&"mycelial_web", "Rede Micélica", 1, SKL, UNCOMMON, SM, "Rede de Micélio", &"tentacle", [st(&"spores", 2, false, true), st(&"weak", 1, false, true)])
	card(&"shelf_scythe", "Ceifa Fúngica", 2, ATK, UNCOMMON, SM, "Foice de Orelha-de-pau", &"claw", [dmg(8, 1, true), st(&"spores", 1, false, true)])
	card(&"spring_stalk", "Haste Elástica", 0, SKL, COMMON, SM, "Haste Fibrosa", &"tendon", [blk(3), draw(1)])
	card(&"glow_gaze", "Olhar Bioluminescente", 0, SKL, UNCOMMON, SM, "Olhos-Bufa", &"eye", [st(&"vulnerable", 1), st(&"spores", 2)],
		"Nenhum dos olhos pisca. Nenhum deles é um olho.")
	card(&"matrix_pulse", "Pulso da Matriz", 2, SKL, RARE, SM, "Núcleo Pulsante", &"core", [heal(8), st(&"spores", 4, false, true)], "", true)
	card(&"luminous_veil", "Véu Luminoso", 2, DEF, RARE, SM, "Véu Luminoso", &"hide", [blk(14), st(&"regen", 3, true)])
	card(&"cap_crown", "Coroa Micélica", 2, MUT, RARE, SM, "Coroa de Chapéus", &"crown", [st(&"spore_crown", 2, true)],
		"Ela não pesa. Você é que deixa de notar o resto.")
	# Monstros extras do Bosque
	card(&"antler_charge", "Investida da Galhada", 2, ATK, UNCOMMON, SM, "Galhada Fúngica", &"horn", [dmg(12), st(&"spores", 3)])
	card(&"lace_ribs", "Costelas Rendadas", 1, DEF, UNCOMMON, SM, "Costelas Rendadas", &"ribs", [blk(7), st(&"thorns", 2, true)])
	card(&"stag_gaze", "Olhar do Cervo", 1, SKL, RARE, SM, "Olho Verde-Água", &"eye", [draw(2), st(&"spores", 2)])
	card(&"burst_sacs", "Bolsas Estouradas", 1, ATK, UNCOMMON, SM, "Bolsas Cheias", &"gland", [dmg(3, 1, true), st(&"spores", 2, false, true)])
	card(&"rooted_steps", "Passos de Raiz", 1, SKL, COMMON, SM, "Pernas de Raiz", &"tendon", [blk(5), draw(1)])
	card(&"moss_mantle", "Manto de Musgo", 1, DEF, COMMON, SM, "Manto de Musgo", &"hide", [blk(5), st(&"regen", 3, true)])
	card(&"lantern_core", "Coração-Lanterna", 0, SKL, UNCOMMON, SM, "Coração-Lanterna", &"core", [lose(2), energy(1)])
	card(&"drift_tendrils", "Filamentos à Deriva", 1, ATK, COMMON, SM, "Filamentos", &"tentacle", [dmg(3, 2), st(&"spores", 1)])

	# Ashwing: Brasa que cobra a cada golpe, e ataques múltiplos
	card(&"smoldering_down", "Penugem Fumegante", 1, SKL, COMMON, AW, "Pluma de Cinzas", &"hide", [st(&"ember", 4)],
		"Cai devagar. Queima o que encontra.")
	card(&"smoke_screen", "Cortina de Fumaça", 1, DEF, COMMON, AW, "Véu de Fumaça", &"hide", [blk(7), st(&"weak", 1, false, true)])
	card(&"wing_gust", "Rajada de Asas", 1, ATK, COMMON, AW, "Membrana Alada", &"hide", [dmg(4, 1, true), st(&"ember", 1, false, true)])
	card(&"hooked_strike", "Golpe de Bico", 1, ATK, COMMON, AW, "Bico Serrilhado", &"fang", [dmg(7), st(&"ember", 2)])
	card(&"dive_talons", "Mergulho", 1, ATK, COMMON, AW, "Garra Incandescente", &"claw", [dmg(3, 3), st(&"ember", 1)],
		"Você só ouve o vento depois.")
	card(&"ember_burst", "Explosão de Brasa", 1, ATK, UNCOMMON, AW, "Núcleo de Brasa", &"core", [dmg(5), st(&"ember", 4)])
	card(&"bristling_crest", "Crista Eriçada", 1, SKL, UNCOMMON, AW, "Crista Flamejante", &"crown", [st(&"strength", 1, true), draw(1)])
	card(&"ash_gaze", "Olhar de Cinza", 0, SKL, UNCOMMON, AW, "Olho de Cinza", &"eye", [st(&"vulnerable", 1), st(&"ember", 2)],
		"A pupila é uma fenda. O calor vem dela.")
	card(&"fire_lash", "Chicote de Fogo", 1, ATK, UNCOMMON, AW, "Cauda de Fogo", &"tentacle", [dmg(2, 4)])
	card(&"molten_heart", "Coração Fundido", 2, MUT, RARE, AW, "Coração de Brasa", &"heart", [st(&"molten_heart", 2, true)],
		"Bate fora de hora, e cada batida esquenta o ar.")
	card(&"molten_wing", "Asa em Chamas", 2, ATK, RARE, AW, "Asa Carbonizada", &"hide", [dmg(8, 1, true), st(&"ember", 3, false, true)])
	card(&"ash_crown", "Coroa de Cinzas", 1, SKL, RARE, AW, "Coroa de Cinzas", &"crown", [st(&"strength", 3, true)], "", true)

	# Híbridas
	hybrid(&"hb_rot_bloom", "Flor da Podridão", 1, SKL, UNCOMMON, SM, RW, &"flesh", [st(&"regen", 4, true), st(&"spores", 2)],
		"Floresce onde algo deveria ter morrido.")
	hybrid(&"hb_void_spores", "Esporos do Vazio", 1, SKL, RARE, SM, VS, &"core", [st(&"spores", 2, false, true), st(&"corruption", 2, false, true)])
	hybrid(&"hb_moss_plate", "Placa Micélica", 1, DEF, UNCOMMON, SM, IB, &"carapace", [blk(8), st(&"spores", 2)])
	hybrid(&"hb_blood_mold", "Mofo Sanguíneo", 1, ATK, UNCOMMON, SM, BF, &"fang", [dmg(5), st(&"bleed", 2), st(&"spores", 2)])
	hybrid(&"hb_ember_fang", "Presa de Brasa", 1, ATK, UNCOMMON, AW, BF, &"fang", [dmg(5), st(&"ember", 2), st(&"bleed", 2)])
	hybrid(&"hb_kiln_shell", "Casco de Forno", 1, DEF, UNCOMMON, AW, IB, &"carapace", [blk(8), st(&"thorns", 2, true)])
	hybrid(&"hb_void_feather", "Pena do Vazio", 1, ATK, UNCOMMON, AW, VS, &"hide", [dmg(3, 2), st(&"corruption", 2), st(&"ember", 2)])
	hybrid(&"hb_burning_spores", "Esporos Ardentes", 2, ATK, RARE, AW, SM, &"blood", [dmg(6, 1, true), st(&"ember", 2, false, true), st(&"spores", 2, false, true)],
		"O fungo não devia sobreviver ao fogo. Sobrevive, e aprende.")


# --- Partes -----------------------------------------------------------------

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
	part(&"sl_cap", "Chapéu Luminoso", SM, HEAD, COMMON, 0.8, &"cap_glow", &"eye", "Um chapéu de cogumelo que continua aceso depois de colhido.")
	part(&"sl_spores", "Saco de Esporos", SM, FLUIDS, COMMON, 0.7, &"spore_cloud", &"blood", "Membrana fina, cheia até a borda. Manuseie sem pressa.")
	part(&"sm_gills", "Lamelas", SM, TORSO, COMMON, 0.8, &"filter_gills", &"plates", "Filtram o ar e, ao que parece, também o sangue.")
	part(&"sm_maw", "Mandíbula Fúngica", SM, HEAD, COMMON, 0.75, &"fungal_bite", &"fang", "Dentes de fibra que voltam a crescer dentro do frasco.")
	part(&"sm_roots", "Raízes-Pernas", SM, LIMBS, COMMON, 0.85, &"take_root", &"tendon", "Andam e se fixam com a mesma facilidade.")
	part(&"sm_mycelium", "Rede de Micélio", SM, FLUIDS, UNCOMMON, 0.6, &"mycelial_web", &"tentacle", "Fios brancos que ligam tudo o que tocam.")
	part(&"ms_scythe", "Foice de Orelha-de-pau", SM, LIMBS, UNCOMMON, 0.65, &"shelf_scythe", &"claw", "Fungo endurecido até ganhar fio de lâmina.")
	part(&"ms_stalk", "Haste Fibrosa", SM, TORSO, COMMON, 0.8, &"spring_stalk", &"tendon", "Comprime e salta como uma mola.")
	part(&"ms_eyes", "Olhos-Bufa", SM, HEAD, UNCOMMON, 0.6, &"glow_gaze", &"eye", "Bolas de esporos que acompanham o movimento.")
	part(&"mm_core", "Núcleo Pulsante", SM, TORSO, RARE, 0.5, &"matrix_pulse", &"core", "O centro da colônia. Pulsa em ritmo com todo o bosque.")
	part(&"mm_veil", "Véu Luminoso", SM, LIMBS, RARE, 0.55, &"luminous_veil", &"hide", "Renda viva que escorre e se refaz.")
	part(&"mm_crown", "Coroa de Chapéus", SM, HEAD, RARE, 0.5, &"cap_crown", &"crown", "Dezenas de chapéus crescidos em círculo perfeito.")
	part(&"sg_antlers", "Galhada Fúngica", SM, HEAD, UNCOMMON, 0.6, &"antler_charge", &"horn", "Osso tomado por cogumelos, pesado como um tronco.")
	part(&"sg_ribs", "Costelas Rendadas", SM, TORSO, UNCOMMON, 0.65, &"lace_ribs", &"ribs", "O fungo comeu o osso e manteve a forma.")
	part(&"sg_eye", "Olho Verde-Água", SM, HEAD, RARE, 0.5, &"stag_gaze", &"eye", "A única parte do cervo que ainda parece estar viva.")
	part(&"sc_sacs", "Bolsas Cheias", SM, FLUIDS, UNCOMMON, 0.6, &"burst_sacs", &"gland", "Sacos enormes, prontos para estourar ao menor corte.")
	part(&"sc_legs", "Pernas de Raiz", SM, LIMBS, COMMON, 0.8, &"rooted_steps", &"tendon", "Grossas, lentas e impossíveis de derrubar.")
	part(&"sc_moss", "Manto de Musgo", SM, TORSO, COMMON, 0.85, &"moss_mantle", &"hide", "Uma camada viva que fecha sozinha os cortes.")
	part(&"sw_core", "Coração-Lanterna", SM, TORSO, UNCOMMON, 0.65, &"lantern_core", &"core", "Brilha sem calor. Faz o sangue correr mais rápido.")
	part(&"sw_tendrils", "Filamentos", SM, LIMBS, COMMON, 0.8, &"drift_tendrils", &"tentacle", "Fios que flutuam mesmo sem vento.")

	part(&"ah_down", "Pluma de Cinzas", AW, TORSO, COMMON, 0.8, &"smoldering_down", &"hide", "Cinza por fora, quente por dentro. Não apaga.")
	part(&"ah_smoke", "Véu de Fumaça", AW, FLUIDS, COMMON, 0.75, &"smoke_screen", &"blood", "Fumaça densa, guardada em frasco, que ainda se move.")
	part(&"aw_wing", "Membrana Alada", AW, LIMBS, COMMON, 0.8, &"wing_gust", &"hide", "Couro fino com veios de brasa.")
	part(&"aw_beak", "Bico Serrilhado", AW, HEAD, COMMON, 0.75, &"hooked_strike", &"fang", "Osso curvo com dentes que os pássaros não deveriam ter.")
	part(&"aw_talons", "Garra Incandescente", AW, LIMBS, COMMON, 0.8, &"dive_talons", &"claw", "Continua quente horas depois da morte.")
	part(&"aw_gland", "Núcleo de Brasa", AW, FLUIDS, UNCOMMON, 0.6, &"ember_burst", &"core", "Um carvão vivo dentro de uma crosta rachada.")
	part(&"st_crest", "Crista Flamejante", AW, HEAD, UNCOMMON, 0.65, &"bristling_crest", &"crown", "Eriça antes do ataque, como um aviso honesto.")
	part(&"st_eye", "Olho de Cinza", AW, HEAD, UNCOMMON, 0.55, &"ash_gaze", &"eye", "Pupila em fenda, cercada de escamas chamuscadas.")
	part(&"st_tail", "Cauda de Fogo", AW, LIMBS, UNCOMMON, 0.65, &"fire_lash", &"tentacle", "Longa e flexível, com a ponta sempre em brasa.")
	part(&"er_heart", "Coração de Brasa", AW, TORSO, RARE, 0.45, &"molten_heart", &"heart", "Lava sob uma crosta negra. Ainda bate.")
	part(&"er_wing", "Asa Carbonizada", AW, LIMBS, RARE, 0.55, &"molten_wing", &"hide", "Penas de carvão que soltam fagulhas ao toque.")
	part(&"er_crown", "Coroa de Cinzas", AW, HEAD, RARE, 0.5, &"ash_crown", &"crown", "Espinhos de osso queimado, formados ao redor do crânio.")


# --- Monstros ---------------------------------------------------------------

func intent(name: String, kind: MonsterIntent.Kind, effects: Array, weight: int = 1) -> MonsterIntent:
	var i := MonsterIntent.new()
	i.display_name = name
	i.kind = kind
	i.effects.assign(effects)
	i.weight = weight
	return i


func monster(id: StringName, name: String, family: Family.Id, tier: MonsterData.Tier, hp: int, pattern: MonsterData.Pattern,
		intents: Array, part_ids: Array, scale: float, anchors: Array, lore: String, weakness: String, start_effects: Array = []) -> void:
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
	m.visual = &"voidspawn" if family == SM else &"bloodfang"
	m.scale = scale
	m.region_anchors.assign(anchors)
	m.lore = lore
	m.weakness_note = weakness
	m.combat_start_effects.assign(start_effects)
	monsters[id] = m
	_save(m, "res://data/monsters/%s.tres" % id)


func _build_monsters() -> void:
	var V := func(x: float, y: float) -> Vector2: return Vector2(x, y)
	# Sporemaw
	monster(&"sporeling", "Sporeling", SM, NORMAL, 24, RANDOM, [
		intent("Mordiscar", K_ATK, [dmg(5)], 2),
		intent("Soltar Esporos", K_DEB, [st(&"spores", 3)], 1),
	], [&"sl_cap", &"sl_spores"], 0.75, [V.call(0.26, 0.57), V.call(0.50, 0.55), V.call(0.55, 0.85), V.call(0.38, 0.45)],
		"Do tamanho de um gato, anda em grupo e deixa um rastro de pó verde-água.",
		"Frágil, mas os esporos de um passam para o outro quando ele morre. Vale o cuidado de quem aplica, também.")
	monster(&"spore_wisp", "Fogo-Fátuo de Esporos", SM, NORMAL, 22, RANDOM, [
		intent("Filamentos", K_ATK, [dmg(4, 2)], 2),
		intent("Pairar", K_DEB, [st(&"spores", 1), st(&"weak", 1)], 1),
	], [&"sw_core", &"sw_tendrils"], 0.75, [V.call(0.31, 0.18), V.call(0.47, 0.37), V.call(0.36, 0.69), V.call(0.61, 0.33)],
		"Um chapéu que flutua arrastando filamentos. Ninguém sabe o que o mantém no ar.",
		"Pouca vida e muitos golpes pequenos: Armadura resolve quase tudo.")
	monster(&"sporemaw", "Sporemaw", SM, NORMAL, 68, CYCLE, [
		intent("Bocada", K_ATK, [dmg(16)]),
		intent("Exalar", K_DEF, [blk(6), st(&"spores", 3)]),
		intent("Mandíbula", K_AD, [dmg(9), st(&"spores", 2)]),
	], [&"sm_gills", &"sm_maw", &"sm_roots", &"sm_mycelium"], 1.0, [V.call(0.17, 0.54), V.call(0.50, 0.45), V.call(0.60, 0.77), V.call(0.47, 0.25)],
		"Um chapéu enorme sobre uma boca de fibras. Caça parado, deixando a presa respirar.",
		"Esporos somem aos poucos, mas se acumulam rápido. Não prolongue a luta sem Armadura.")
	monster(&"spore_carrier", "Carregador de Esporos", SM, NORMAL, 72, CYCLE, [
		intent("Inchar", K_DEF, [blk(8), st(&"regen", 4, true)]),
		intent("Estourar Bolsa", K_AD, [dmg(8), st(&"spores", 3)]),
		intent("Pisada", K_ATK, [dmg(15)]),
	], [&"sc_sacs", &"sc_legs", &"sc_moss"], 1.05, [V.call(0.23, 0.53), V.call(0.63, 0.34), V.call(0.50, 0.82), V.call(0.77, 0.45)],
		"Carrega bolsas do tamanho de um barril nas costas. Parece lento até uma delas estourar.",
		"Regenera bastante: ataque logo depois de ele inchar, antes que a vida volte.")
	monster(&"mycostalker", "Mycostalker", SM, ELITE, 96, CYCLE, [
		intent("Afiar Foices", K_BUFF, [st(&"strength", 2, true)]),
		intent("Ceifa Dupla", K_ATK, [dmg(8, 2)]),
		intent("Olhar Fixo", K_DEB, [st(&"vulnerable", 2), st(&"spores", 2)]),
		intent("Golpe de Foice", K_ATK, [dmg(17)]),
	], [&"ms_scythe", &"ms_stalk", &"ms_eyes"], 1.15, [V.call(0.31, 0.20), V.call(0.59, 0.49), V.call(0.49, 0.81), V.call(0.69, 0.31)],
		"Um caçador alto e fino, com foices de fungo endurecido. Não faz barulho nenhum.",
		"Fica mais forte a cada ciclo: a Fraqueza e a Armadura seguram as foices.")
	monster(&"spore_stag", "Cervo de Esporos", SM, ELITE, 110, CYCLE, [
		intent("Bramido", K_DEF, [blk(12), st(&"strength", 1, true)]),
		intent("Investida", K_ATK, [dmg(18)]),
		intent("Chuva de Esporos", K_DEB, [st(&"spores", 4), st(&"weak", 1)]),
	], [&"sg_antlers", &"sg_ribs", &"sg_eye"], 1.2, [V.call(0.21, 0.36), V.call(0.54, 0.54), V.call(0.41, 0.85), V.call(0.60, 0.36)],
		"Já foi um cervo. O fungo manteve a forma, comeu o resto e aprendeu a andar.",
		"Avisa a Investida com um turno de antecedência: guarde Armadura para ela.")
	monster(&"mycelium_mother", "Matriz Micélica", SM, BOSS, 160, CYCLE, [
		intent("Germinar", K_DEF, [blk(14), st(&"regen", 5, true)]),
		intent("Raízes", K_ATK, [dmg(7, 3)]),
		intent("Nuvem", K_DEB, [st(&"spores", 5), st(&"weak", 2)]),
		intent("Esmagar", K_ATK, [dmg(22)]),
	], [&"mm_core", &"mm_veil", &"mm_crown", &"sm_gills"], 1.3, [V.call(0.44, 0.21), V.call(0.49, 0.43), V.call(0.23, 0.80), V.call(0.29, 0.43)],
		"A colônia inteira ligada em um só corpo. Cada cogumelo do bosque responde a ela.",
		"Regenera sem parar: Corrupção e Sangramento vencem a cura com o tempo, e a Nuvem pune lutas longas.")

	# Ashwing
	monster(&"ash_hatchling", "Filhote de Ashwing", AW, NORMAL, 28, RANDOM, [
		intent("Bicada", K_ATK, [dmg(8)], 2),
		intent("Cuspir Brasa", K_AD, [dmg(3), st(&"ember", 2)], 1),
	], [&"ah_down", &"ah_smoke"], 0.75, [V.call(0.23, 0.38), V.call(0.48, 0.57), V.call(0.47, 0.83), V.call(0.36, 0.59)],
		"Nasce já com fome e com as penas fumegando. Vem sempre em dupla.",
		"Pouca vida. A Brasa só cobra quando você é atingido: mate um deles antes que se acumule.")
	monster(&"ashwing", "Ashwing", AW, NORMAL, 74, RANDOM, [
		intent("Mergulho", K_ATK, [dmg(6, 3)], 2),
		intent("Asa em Brasa", K_AD, [dmg(11), st(&"ember", 2)], 2),
		intent("Alçar Voo", K_DEF, [blk(10), st(&"strength", 1, true)], 1),
	], [&"aw_wing", &"aw_beak", &"aw_talons", &"aw_gland"], 1.05, [V.call(0.14, 0.31), V.call(0.38, 0.57), V.call(0.57, 0.88), V.call(0.77, 0.34)],
		"Ave de rapina com asas de morcego. O calor do corpo mantém a cinza no ar ao redor.",
		"O Mergulho são três golpes, e cada golpe cobra a Brasa: nunca o receba com Brasa alta.")
	monster(&"stormtalon", "Stormtalon", AW, ELITE, 110, CYCLE, [
		intent("Eriçar", K_DEF, [blk(8), st(&"strength", 3, true)]),
		intent("Garras", K_ATK, [dmg(6, 3)]),
		intent("Olhar Fixo", K_DEB, [st(&"vulnerable", 2), st(&"ember", 3)]),
		intent("Açoite de Fogo", K_ATK, [dmg(18)]),
	], [&"st_crest", &"st_eye", &"st_tail"], 1.2, [V.call(0.27, 0.41), V.call(0.47, 0.54), V.call(0.34, 0.87), V.call(0.77, 0.39)],
		"Só desce das nuvens para caçar o que já está cansado.",
		"O Olhar Fixo prepara o Açoite: guarde sua maior defesa para o turno seguinte.")
	monster(&"ember_roc", "Roca de Brasa", AW, BOSS, 180, CYCLE, [
		intent("Aquecer", K_DEF, [blk(12), st(&"strength", 2, true)]),
		intent("Rajada de Penas", K_ATK, [dmg(6, 3)]),
		intent("Chuva de Brasas", K_DEB, [st(&"ember", 3), st(&"weak", 2)]),
		intent("Bico Blindado", K_ATK, [dmg(22)]),
	], [&"er_heart", &"er_wing", &"er_crown", &"aw_gland"], 1.35, [V.call(0.18, 0.28), V.call(0.44, 0.59), V.call(0.56, 0.91), V.call(0.74, 0.48)],
		"Dizem que o vulcão acordou quando ela fez o ninho. Ninguém voltou para confirmar.",
		"A Força se acumula e a Chuva de Brasas prepara o golpe seguinte. Termine a luta cedo.")


# --- Mutações ---------------------------------------------------------------

func mutation(id: StringName, name: String, family: Family.Id, desc: String, cost: Dictionary, corruption: int,
		motif: StringName, max_hp: int = 0, start: Array = []) -> void:
	var m := MutationData.new()
	m.id = id
	m.display_name = name
	m.family = family
	m.description = desc
	m.material_cost = cost
	m.corruption = corruption
	m.art_motif = motif
	m.max_hp_bonus = max_hp
	m.combat_start_effects.assign(start)
	_save(m, "res://data/mutations/%s.tres" % id)


func _build_mutations() -> void:
	mutation(&"mut_sm_gills", "Lamelas Implantadas", SM, "Comece cada combate com 4 de Regeneração.",
		{"sm_gills": 1, "sl_cap": 1}, 1, &"plates", 0, [st(&"regen", 4, true)])
	mutation(&"mut_mm_core", "Núcleo Micélico", SM, "No início de cada turno, aplique 1 de Esporos a todos os inimigos.",
		{"mm_core": 1, "sm_mycelium": 1}, 3, &"core", 0, [st(&"spore_crown", 1, true)])
	mutation(&"mut_aw_gland", "Glândula Ardente", AW, "No início de cada combate, aplique 4 de Brasa a todos os inimigos.",
		{"aw_gland": 1, "ah_down": 1}, 2, &"gland", 0, [st(&"ember", 4, false, true)])
	mutation(&"mut_er_heart", "Coração da Roca", AW, "+10 de vida máxima. Comece cada combate com 1 de Força.",
		{"er_heart": 1}, 3, &"heart", 10, [st(&"strength", 1, true)])


# --- Receitas ---------------------------------------------------------------

func recipe(id: StringName, a: StringName, b: StringName, result: StringName, hint: String) -> void:
	var r := HybridRecipe.new()
	r.id = id
	r.part_a = get_part(a)
	r.part_b = get_part(b)
	r.result = cards[result]
	r.hint = hint
	_save(r, "res://data/recipes/%s.tres" % id)


func _build_recipes() -> void:
	recipe(&"rc_rot_bloom", &"sl_cap", &"rw_flesh", &"hb_rot_bloom", "Um chapéu aceso sobre carne que não para de se fechar.")
	recipe(&"rc_void_spores", &"sl_spores", &"vs_ichor", &"hb_void_spores", "Esporos embebidos em um fluido frio e violeta.")
	recipe(&"rc_moss_plate", &"sm_mycelium", &"ib_carapace", &"hb_moss_plate", "Fios brancos crescendo sobre placas de quitina.")
	recipe(&"rc_blood_mold", &"sm_maw", &"bf_fangs", &"hb_blood_mold", "Dentes de fibra junto a presas serrilhadas.")
	recipe(&"rc_ember_fang", &"aw_gland", &"bf_fangs", &"hb_ember_fang", "Presas aquecidas em um carvão vivo.")
	recipe(&"rc_kiln_shell", &"aw_gland", &"ib_plates", &"hb_kiln_shell", "Placas pesadas, cozidas até trincar.")
	recipe(&"rc_void_feather", &"ah_down", &"vs_ichor", &"hb_void_feather", "Uma pluma de cinzas mergulhada em um fluido violeta.")
	recipe(&"rc_burning_spores", &"ah_smoke", &"sl_spores", &"hb_burning_spores", "Fumaça e esporos no mesmo frasco. Abra longe do rosto.")


# --- Melhorias --------------------------------------------------------------

func _build_upgrades() -> void:
	var a := LabUpgradeData.new()
	a.id = &"up_spore_filter"
	a.display_name = "Máscara Filtrante"
	a.description = "+8 de vida máxima."
	a.family_cost = {SM: 3}
	a.art_motif = &"plates"
	a.max_hp_bonus = 8
	_save(a, "res://data/lab_upgrades/up_spore_filter.tres")
	var b := LabUpgradeData.new()
	b.id = &"up_ember_tongs"
	b.display_name = "Pinças Refratárias"
	b.description = "+10% de chance de extrair qualquer parte."
	b.family_cost = {AW: 3, SM: 2}
	b.art_motif = &"tendon"
	b.preserve_bonus = 0.1
	_save(b, "res://data/lab_upgrades/up_ember_tongs.tres")


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
		gp.append(get_part(pid))
	c.gain_parts = gp
	c.remove_card = opts.get("remove", false)
	c.upgrade_card = opts.get("upgrade", false)
	c.fail_text = opts.get("fail_text", "")
	c.fail_hp_change = opts.get("fail_hp", 0)
	var ff: Array[MonsterData] = []
	for mid in opts.get("fail_fight", []):
		ff.append(get_monster(mid))
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
	var teal := Family.get_color(SM)
	var ember := Family.get_color(AW)
	event(&"ev_fairy_ring", "Círculo de Cogumelos",
		"Um anel perfeito de cogumelos em uma clareira. Dentro dele, o ar para de se mover e os esporos ficam suspensos.",
		&"crown", teal, [
		choice("Entrar no círculo", "Você respira fundo lá dentro. Algo em você se ajusta.",
			{"desc": "60%: +6 de vida máxima. Falha: o círculo acorda.", "chance": 0.6, "max_hp": 6,
			"fail_text": "Os cogumelos da borda se levantam sobre pernas de raiz.", "fail_fight": [&"sporeling", &"sporeling"]}),
		choice("Colher um chapéu", "O chapéu sai inteiro e continua aceso na sua mão.",
			{"desc": "Perca 3 de vida. Ganhe Chapéu Luminoso.", "hp": -3, "parts": [&"sl_cap"]}),
		choice("Contornar a clareira", "Você dá a volta sem pisar no musgo."),
	])
	event(&"ev_spore_cocoon", "Casulo Fúngico",
		"Um casulo de micélio pende de um cogumelo gigante. A forma lá dentro lembra uma criatura, e a luz verde-água pulsa devagar.",
		&"core", teal, [
		choice("Cortar a rede", "Os fios cedem sem resistência e ficam presos no seu bisturi.",
			{"desc": "50%: ganhe Rede de Micélio. Falha: o casulo se abre.", "chance": 0.5, "parts": [&"sm_mycelium"],
			"fail_text": "A rede se rasga de dentro para fora.", "fail_fight": [&"sporemaw"]}),
		choice("Furar uma bolsa lateral", "Você enche um frasco com o pó verde-água, e tosse por um bom tempo.",
			{"desc": "Perca 5 de vida. Ganhe Saco de Esporos.", "hp": -5, "parts": [&"sl_spores"]}),
		choice("Deixar como está", "Algumas coisas ainda não estão prontas para sair."),
	])
	event(&"ev_overgrown_cart", "Carroça Tomada",
		"Uma carroça de suprimentos afundada no musgo, coberta de cogumelos. O saco e o caixote ainda estão no lugar.",
		&"notes", Palette.BONE, [
		choice("Abrir o saco", "Provisões secas, por milagre ainda boas.", {"desc": "Recupere 12 de vida.", "hp": 12}),
		choice("Forçar o caixote", "Ferramentas bem conservadas. Você afia as suas com elas.",
			{"desc": "60%: aprimore uma carta. Falha: perca 6 de vida.", "chance": 0.6, "upgrade": true,
			"fail_text": "A tampa estoura e uma nuvem de esporos sobe no seu rosto.", "fail_hp": -6}),
		choice("Limpar a mochila", "Você deixa para trás o que não serve mais.", {"desc": "Remova uma carta do baralho.", "remove": true}),
	])
	event(&"ev_cliff_nest", "Ninho no Penhasco",
		"Um ninho de galhos na beira de um penhasco, com três ovos manchados. O dono não está à vista, mas as penas ainda fumegam.",
		&"hide", ember, [
		choice("Recolher as penas", "Você guarda uma pluma ainda quente em um frasco.",
			{"desc": "70%: ganhe Pluma de Cinzas. Falha: os filhotes acordam.", "chance": 0.7, "parts": [&"ah_down"],
			"fail_text": "Um dos ovos já estava aberto.", "fail_fight": [&"ash_hatchling", &"ash_hatchling"]}),
		choice("Comer um ovo", "Quente, forte e estranhamente doce.", {"desc": "Recupere 14 de vida.", "hp": 14}),
		choice("Recuar", "Você desce pelo mesmo caminho, sem olhar para cima."),
	])
	event(&"ev_storm_shrine", "Santuário da Tempestade",
		"Pedras marcadas com o desenho de uma ave cercam uma bacia em chamas. Os raios caem perto demais para ser acaso.",
		&"crown", ember, [
		choice("Oferecer uma carta", "As chamas sobem por um instante. Você se sente mais leve.",
			{"desc": "Remova uma carta do baralho.", "remove": true}),
		choice("Tocar a pedra", "O choque atravessa o braço, e sua mão fica mais firme.",
			{"desc": "Perca 8 de vida. Aprimore uma carta.", "hp": -8, "upgrade": true}),
		choice("Pegar o que há na bacia", "Entre as cinzas, um carvão que não esfria.",
			{"desc": "60%: ganhe Núcleo de Brasa. Falha: perca 10 de vida.", "chance": 0.6, "parts": [&"aw_gland"],
			"fail_text": "O raio não erra desta vez.", "fail_hp": -10}),
	])
	event(&"ev_abandoned_gear", "Mina Abandonada",
		"Engrenagens enferrujadas, um guincho parado e um carrinho de minério sobre os trilhos. A galeria ainda respira calor.",
		&"plates", Palette.BONE, [
		choice("Vasculhar o carrinho", "Sob o minério, algo que não é pedra.",
			{"desc": "60%: ganhe Garra Incandescente. Falha: algo fez ninho aqui.", "chance": 0.6, "parts": [&"aw_talons"],
			"fail_text": "Asas se abrem no fundo da galeria.", "fail_fight": [&"ashwing"]}),
		choice("Usar as ferramentas", "A bigorna ainda serve, e seus instrumentos ficam melhores.",
			{"desc": "Perca 3 de vida. Aprimore uma carta.", "hp": -3, "upgrade": true}),
		choice("Descansar na galeria", "O calor das paredes é quase agradável.", {"desc": "Recupere 10 de vida.", "hp": 10}),
	])


# --- Expedições -------------------------------------------------------------

func encounter(id: StringName, ids: Array, min_floor: int = 0, weight: int = 1) -> EncounterData:
	var e := EncounterData.new()
	e.id = id
	var ms: Array[MonsterData] = []
	for mid in ids:
		ms.append(get_monster(mid))
	e.monsters = ms
	e.min_floor = min_floor
	e.weight = weight
	return e


func _events(ids: Array) -> Array[EventData]:
	var list: Array[EventData] = []
	for id in ids:
		list.append(load("res://data/events/%s.tres" % id))
	return list


func _build_expeditions() -> void:
	var g := ExpeditionData.new()
	g.id = &"fungal_grove"
	g.display_name = "Bosque dos Esporos"
	g.description = "Floresta de cogumelos gigantes onde o ar é denso e tudo o que morre volta a andar coberto de fungo."
	g.order = 2
	g.unlock_requirement = &"flooded_catacombs"
	g.floors = 10
	g.encounters.assign([
		encounter(&"fg_sporelings", [&"sporeling", &"sporeling"], 0, 2),
		encounter(&"fg_wisps", [&"spore_wisp", &"spore_wisp"], 0, 2),
		encounter(&"fg_sporemaw", [&"sporemaw"], 1, 2),
		encounter(&"fg_carrier", [&"spore_carrier"], 2, 2),
		encounter(&"fg_void_sporeling", [&"voidspawn", &"sporeling"], 3, 1),
		encounter(&"fg_maw_wisp", [&"sporemaw", &"spore_wisp"], 4, 1),
		encounter(&"fg_rot_carrier", [&"rotwalker", &"sporeling"], 5, 1),
	])
	g.elite_pool.assign([get_monster(&"mycostalker"), get_monster(&"spore_stag")])
	g.boss = get_monster(&"mycelium_mother")
	g.events = _events([&"ev_fairy_ring", &"ev_spore_cocoon", &"ev_overgrown_cart", &"ev_hermit", &"ev_bone_altar", &"ev_violet_pool"])
	g.hp_per_floor = 3
	g.accent = Family.get_dark_color(SM)
	_save(g, "res://data/expeditions/fungal_grove.tres")

	var p := ExpeditionData.new()
	p.id = &"ash_peaks"
	p.display_name = "Pináculos de Cinza"
	p.description = "Picos vulcânicos sob uma tempestade de cinza. Quem caça aqui vem do alto, e sempre com o corpo em brasa."
	p.order = 3
	p.unlock_requirement = &"fungal_grove"
	p.floors = 11
	p.encounters.assign([
		encounter(&"ap_hatchlings", [&"ash_hatchling", &"ash_hatchling"], 0, 2),
		encounter(&"ap_ironback", [&"ironback"], 0, 1),
		encounter(&"ap_ashwing", [&"ashwing"], 1, 3),
		encounter(&"ap_iron_hatchling", [&"ironback", &"ash_hatchling"], 2, 1),
		encounter(&"ap_wing_hatchling", [&"ashwing", &"ash_hatchling"], 4, 2),
		encounter(&"ap_rot_hatchling", [&"rotwalker", &"ash_hatchling"], 3, 1),
		encounter(&"ap_alpha_hatchling", [&"bloodfang", &"ash_hatchling"], 5, 1),
	])
	p.elite_pool.assign([get_monster(&"stormtalon"), get_monster(&"stitched_abomination"), get_monster(&"mycostalker")])
	p.boss = get_monster(&"ember_roc")
	p.events = _events([&"ev_cliff_nest", &"ev_storm_shrine", &"ev_abandoned_gear", &"ev_hermit", &"ev_wounded_researcher", &"ev_old_carcass"])
	p.hp_per_floor = 4
	p.accent = Family.get_dark_color(AW)
	_save(p, "res://data/expeditions/ash_peaks.tres")
