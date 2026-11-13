extends Node
## Teste de fumaça: regras, conteúdo, simulações de balanceamento, todas as telas e fluxos.
## Uso: Godot_console.exe --headless --path . res://tools/smoke_test.tscn
## Não altera o progresso do jogador (backup/restauração de perfil, expedição e opções).

const SIMS_PER_MONSTER := 12
const BACKUP_FILES := ["user://profile.json", "user://run.json", "user://settings.cfg"]

var _backups: Dictionary = {}
var _failures: PackedStringArray = []


func _ready() -> void:
	# Mantém este nó vivo durante as trocas de cena.
	get_tree().current_scene = null
	for path in BACKUP_FILES:
		_backups[path] = FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else null
	Engine.time_scale = 40.0
	await _run()
	Engine.time_scale = 1.0
	_restore()
	print("\n==== RESULTADO: %s ====" % ("OK" if _failures.is_empty() else "FALHAS:\n- " + "\n- ".join(_failures)))
	get_tree().quit(0 if _failures.is_empty() else 1)


func _restore() -> void:
	for path in BACKUP_FILES:
		if _backups[path] == null:
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			FileAccess.open(path, FileAccess.WRITE).store_string(_backups[path])


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		push_error("FALHA: " + msg)


func _run() -> void:
	Profile.reset()
	_test_data()
	_test_effects()
	_test_upgrades()
	_test_lab_systems()
	_test_run_save()
	_test_ng_plus()
	await _test_balance()
	await _test_screens()
	await _test_event_flow()
	await _test_full_flow()


# --- Dados ------------------------------------------------------------------

func _test_data() -> void:
	print("[dados] cartas=%d partes=%d monstros=%d mutações=%d receitas=%d eventos=%d melhorias=%d regiões=%d" % [
		Database.cards.size(), Database.parts.size(), Database.monsters.size(), Database.mutations.size(),
		Database.recipes.size(), Database.events.size(), Database.lab_upgrades.size(), Database.expeditions.size()])
	for id in Database.STARTER_DECK:
		_check(Database.get_card(id) != null, "carta inicial ausente: %s" % id)
	for p: AnatomyPart in Database.parts.values():
		_check(p.unlocks_card != null, "parte sem carta: %s" % p.id)
		_check(Database.get_part_owner(p.id) != null, "parte sem espécie: %s" % p.id)
	_check(Database.get_part_owner(&"bf_fangs").id == &"bloodfang", "dona de Presas deveria ser Bloodfang, não o filhote")
	_check(Database.get_part_owner(&"vs_ichor").id == &"voidspawn", "dona do Icor deveria ser Voidspawn")
	for m: MutationData in Database.mutations.values():
		for k in m.material_cost:
			_check(Database.get_part(StringName(k)) != null, "mutação %s exige parte inexistente %s" % [m.id, k])
	for r: HybridRecipe in Database.recipes.values():
		_check(r.part_a.family != r.part_b.family, "receita %s com a mesma família" % r.id)
		_check(r.result.is_hybrid(), "resultado de %s não é híbrido" % r.id)
	for c: CardData in Database.cards.values():
		_check(not c.get_description().is_empty(), "carta sem descrição: %s" % c.id)
	for e: ExpeditionData in Database.expeditions.values():
		_check(not e.encounters.is_empty() and e.boss != null and not e.events.is_empty(), "expedição incompleta: %s" % e.id)
		for enc in e.encounters:
			_check(not enc.monsters.is_empty(), "encontro vazio: %s" % enc.id)
	# Toda arte das fases 3 e 4 precisa existir; cartas e partes dos monstros extras ainda usam o desenho provisório.
	var no_art_yet := [&"antler_charge", &"lace_ribs", &"stag_gaze", &"burst_sacs", &"rooted_steps", &"moss_mantle", &"lantern_core", &"drift_tendrils",
		&"sg_antlers", &"sg_ribs", &"sg_eye", &"sc_sacs", &"sc_legs", &"sc_moss", &"sw_core", &"sw_tendrils"]
	for c: CardData in Database.cards.values():
		if c.family in [Family.Id.SPOREMAW, Family.Id.ASHWING] and not no_art_yet.has(c.id):
			_check(c.illustration != null, "carta sem arte: %s" % c.id)
	for p: AnatomyPart in Database.parts.values():
		if p.family in [Family.Id.SPOREMAW, Family.Id.ASHWING] and not no_art_yet.has(p.id):
			_check(p.icon != null, "parte sem arte: %s" % p.id)
	for m: MonsterData in Database.monsters.values():
		_check(m.portrait != null, "monstro sem arte: %s" % m.id)
		_check(m.region_anchors.size() == 4, "monstro sem pontos de dissecação: %s" % m.id)
		_check(not m.parts.is_empty(), "monstro sem partes: %s" % m.id)
	for m: MutationData in Database.mutations.values():
		_check(Database.get_art("mutations", m.id) != null, "mutação sem arte: %s" % m.id)
	for e: EventData in Database.events.values():
		_check(Database.get_art("events", e.id) != null, "evento sem arte: %s" % e.id)
	for id in [&"fungal_grove", &"ash_peaks", &"battle_fungal_hollow", &"battle_ash_ridge"]:
		_check(Database.get_art("backgrounds", id) != null, "fundo ausente: %s" % id)


# --- Efeitos e condição do corpo -------------------------------------------

func _test_effects() -> void:
	var cm := CombatManager.new()
	add_child(cm)
	var p := PlayerCombatant.new("T", 50, 50, 3)
	cm.player = p
	var m := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	cm.monsters.append(m)
	m.add_status(&"vulnerable", 1)
	p.add_status(&"strength", 2)
	_check(cm.calc_attack_damage(p, m, 6) == 12, "cálculo de dano com força/vulnerável")
	var ib := MonsterCombatant.new(Database.get_monster(&"ironback"))
	ib.add_status(&"thorns", 3)
	ib.take_damage(5, p, true)
	_check(p.hp == 47, "espinhos devolvem dano (hp=%d)" % p.hp)
	var bf := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	bf.take_damage(bf.hp + 13, p, true)
	var cond := BodyCondition.from_combatant(bf)
	_check(cond.get_state(AnatomyPart.Region.HEAD) == BodyCondition.State.LOST, "overkill deveria destruir cabeça")
	var bf2 := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	bf2.lose_hp(999, Combatant.DeathCause.STATUS)
	var cond2 := BodyCondition.from_combatant(bf2)
	_check(cond2.chance_for(Database.get_part(&"bf_heart")) > Database.get_part(&"bf_heart").preserve_chance, "morte por status dá bônus")
	# Imortalidade Pútrida
	var ab := MonsterCombatant.new(Database.get_monster(&"stitched_abomination"))
	ab.add_status(&"undying", 1)
	ab.take_damage(999, p, true)
	_check(ab.is_alive() and ab.hp == 1 and ab.get_status(&"undying") == 0, "Imortalidade Pútrida deveria salvar uma vez")
	ab.take_damage(999, p, true)
	_check(not ab.is_alive(), "segundo golpe fatal deveria matar")
	# carta condicional: cura ao matar
	p.hp = 30
	var weak := MonsterCombatant.new(Database.get_monster(&"voidspawn"))
	weak.hp = 3
	cm.monsters = [weak]
	cm.hand.append(CardInstance.new(Database.get_card(&"predatory_pulse")))
	cm.is_player_turn = true
	p.set_energy(3)
	cm.play_card(cm.hand[0], weak)
	_check(p.hp == 36, "Pulso Predatório cura ao matar (hp=%d)" % p.hp)
	# Instinto: híbrida continua a sequência da segunda família
	cm.instinct_family = Family.Id.IRONBACK
	cm.instinct_count = 1
	cm._register_instinct(Database.get_card(&"hb_armored_heart"))
	_check(cm.instinct_family == Family.Id.IRONBACK and cm.instinct_count == 2, "híbrida deveria contar para Ironback")
	# Dano penetrante ignora a Armadura
	var pz := MonsterCombatant.new(Database.get_monster(&"ironback"))
	pz.add_block(50)
	var pz_hp := pz.hp
	pz.take_damage(7, null, true, true)
	_check(pz.hp == pz_hp - 7 and pz.block == 50, "dano penetrante deveria ignorar a Armadura")
	# Detonar consome os Esporos
	var dz := MonsterCombatant.new(Database.get_monster(&"sporemaw"))
	dz.add_status(&"spores", 4)
	var dz_hp := dz.hp
	var dctx := EffectContext.new(cm, p, dz)
	var det := DetonateEffect.new()
	det.multiplier = 2
	det.apply(dctx)
	_check(dz.hp == dz_hp - 8 and dz.get_status(&"spores") == 0, "Detonar deveria tirar 8 e zerar os Esporos")
	# Cópias: cada extração dá uma cópia, até o limite
	var cp_id := &"deep_bite"
	Profile.card_copies.erase(cp_id)
	Profile.unlocked_cards.erase(cp_id)
	Profile.add_card_copy(cp_id)
	_check(Profile.max_copies(Database.get_card(cp_id)) == 1, "primeira extração deveria dar 1 cópia")
	for i in 5:
		Profile.add_card_copy(cp_id)
	_check(Profile.max_copies(Database.get_card(cp_id)) == Profile.MAX_EARNED_COPIES, "cópias deveriam parar no limite")
	# Germinação: perde vida, cresce 1 e explode em 8
	var gz := MonsterCombatant.new(Database.get_monster(&"sporemaw"))
	gz.add_status(&"spores", 3)
	var gz_hp := gz.hp
	cm._tick_statuses(gz)
	_check(gz.hp == gz_hp - 3 and gz.get_status(&"spores") == 4, "Esporos: perde 3 e cresce para 4")
	gz.set_status(&"spores", 7)
	gz_hp = gz.hp
	cm._tick_statuses(gz)
	_check(gz.hp == gz_hp - 7 - CombatManager.SPORE_BURST_DAMAGE and gz.get_status(&"spores") == 0, "Esporos explodem ao chegar a 8")
	# Memória Muscular: +1 de Energia se devolver uma carta que dá Armadura
	cm.monsters = [MonsterCombatant.new(Database.get_monster(&"bloodfang"))]
	cm.hand.clear()
	cm.discard_pile = [CardInstance.new(Database.get_card(&"guard")), CardInstance.new(Database.get_card(&"guard"))]
	cm.hand.append(CardInstance.new(Database.get_card(&"muscle_memory")))
	cm.is_player_turn = true
	cm.is_over = false
	p.set_energy(3)
	cm.play_card(cm.hand[0], null)
	_check(p.energy == 3 and cm.hand.size() == 2, "Memória Muscular devolve 2 e dá 1 de Energia (energia=%d, mão=%d)" % [p.energy, cm.hand.size()])
	# Com a tela ligada, a Memória Muscular pede a escolha; aqui o "jogador" pega a Postura de Guarda
	var asked := {"n": 0}
	var pick := func(count: int, energy: int):
		asked["n"] = count
		var guard_inst: CardInstance = null
		for c in cm.discard_pile:
			if c.data.id == &"guard":
				guard_inst = c
		cm.take_from_discard(guard_inst)
		ReturnFromDiscardEffect.reward(cm, [guard_inst], energy)
	cm.discard_choice_requested.connect(pick)
	cm.hand.clear()
	cm.discard_pile = [CardInstance.new(Database.get_card(&"rend")), CardInstance.new(Database.get_card(&"guard"))]
	cm.hand.append(CardInstance.new(Database.get_card(&"muscle_memory")))
	p.set_energy(3)
	cm.play_card(cm.hand[0], null)
	_check(asked["n"] == 2 and cm.hand.size() == 1 and cm.hand[0].data.id == &"guard" and p.energy == 3,
		"Memória Muscular: escolha do descarte (pedido=%d, mão=%d, energia=%d)" % [asked["n"], cm.hand.size(), p.energy])
	cm.discard_choice_requested.disconnect(pick)
	# Dano que cresce com as pilhas: Bile Necrótica (descarte) e Toque Corruptor (banidas)
	var tgt := MonsterCombatant.new(Database.get_monster(&"iron_colossus"))
	cm.monsters = [tgt]
	p.statuses.clear()
	for card_id in [&"necrotic_bile", &"corrupting_touch"]:
		cm.hand.clear()
		cm.discard_pile.clear()
		cm.exhaust_pile.clear()
		for i in 4:
			cm.discard_pile.append(CardInstance.new(Database.get_card(&"guard")))
		for i in 2:
			cm.exhaust_pile.append(CardInstance.new(Database.get_card(&"guard")))
		tgt.hp = tgt.max_hp
		tgt.clear_block()
		tgt.statuses.clear()
		cm.hand.append(CardInstance.new(Database.get_card(card_id)))
		p.set_energy(3)
		cm.play_card(cm.hand[0], tgt)
		var expected := 3 + 4 if card_id == &"necrotic_bile" else 4 + 3 * 2
		_check(tgt.max_hp - tgt.hp == expected, "%s: dano %d (esperado %d)" % [card_id, tgt.max_hp - tgt.hp, expected])
	# Brasa: cobra a cada golpe, ignora Armadura e diminui
	var em := MonsterCombatant.new(Database.get_monster(&"ashwing"))
	em.add_status(&"ember", 3)
	var em_hp := em.hp
	em.add_block(100)
	em.take_damage(5, p, true)
	_check(em.hp == em_hp - 3 and em.get_status(&"ember") == 2, "Brasa deveria tirar 3 de vida e cair para 2 (hp=%d brasa=%d)" % [em.hp, em.get_status(&"ember")])
	em.lose_hp(1)
	_check(em.get_status(&"ember") == 2, "Brasa só cobra em ataques")
	# Esporos: passam para os outros inimigos quando o portador morre
	var sp1 := MonsterCombatant.new(Database.get_monster(&"sporeling"))
	var sp2 := MonsterCombatant.new(Database.get_monster(&"sporeling"))
	cm.monsters = [sp1, sp2]
	sp1.died.connect(cm._spread_spores.bind(sp1))
	sp1.add_status(&"spores", 4)
	sp1.lose_hp(999, Combatant.DeathCause.STATUS)
	_check(sp2.get_status(&"spores") == 4, "Esporos deveriam passar ao vizinho (%d)" % sp2.get_status(&"spores"))
	# Instintos novos
	var hand_before := cm.hand.size()
	cm.draw_pile.append(CardInstance.new(Database.get_card(&"guard")))
	cm._trigger_instinct(Family.Id.ASHWING)
	_check(sp2.get_status(&"ember") == 3 and cm.hand.size() == hand_before + 1, "Instinto Ashwing")
	p.hp = 20
	cm._trigger_instinct(Family.Id.SPOREMAW)
	_check(sp2.get_status(&"spores") == 7 and p.hp == 23, "Instinto Sporemaw")
	cm.queue_free()
	print("[efeitos] verificados")


func _test_upgrades() -> void:
	var rend := Database.get_card(&"rend")
	var up := Database.get_card(&"rend+")
	_check(up != null and up.upgraded and up.display_name == "Rasgar+", "aprimorar Rasgar")
	_check((up.effects[0] as DamageEffect).amount == (rend.effects[0] as DamageEffect).amount + 1, "Rasgar+ multi-golpe +1")
	_check((rend.effects[0] as DamageEffect).amount == 3, "original não pode mudar ao aprimorar")
	var core := Database.get_card(&"unstable_core+")
	_check((core.effects[0] as LoseHpEffect).amount == 4, "Núcleo Instável+ perde menos vida")
	var pulse := Database.get_card(&"predatory_pulse+")
	var inner := (pulse.effects[1] as ConditionalEffect).effects[0] as HealEffect
	_check(inner.amount == 9, "efeito condicional aprimorado (cura %d)" % inner.amount)
	var chitin := Database.get_card(&"chitin_charge+")
	_check(chitin.cost == 0, "carta sem números aprimora o custo")
	print("[aprimorar] %s → %s" % [rend.get_description(), up.get_description()])


func _test_lab_systems() -> void:
	Profile.reset()
	# híbrida
	_check(Profile.experiment(Database.get_part(&"bf_heart"), Database.get_part(&"ib_carapace")) == null, "sem materiais não deveria funcionar")
	Profile.add_material(&"bf_heart", 1)
	Profile.add_material(&"ib_carapace", 1)
	Profile.add_material(&"bf_claws", 1)
	_check(Profile.experiment(Database.get_part(&"bf_claws"), Database.get_part(&"ib_carapace")) == null, "combinação inválida")
	_check(Profile.get_material(&"bf_claws") == 1, "combinação inválida não consome")
	var r := Profile.experiment(Database.get_part(&"bf_heart"), Database.get_part(&"ib_carapace"))
	_check(r != null and Profile.is_card_unlocked(&"hb_armored_heart"), "receita Coração Blindado")
	_check(Profile.get_material(&"bf_heart") == 0 and Profile.get_material(&"ib_carapace") == 0, "receita consome materiais")
	# melhoria do laboratório
	var obs: LabUpgradeData = Database.lab_upgrades[&"up_obsidian"]
	_check(not Profile.can_buy_upgrade(obs), "sem materiais para a oficina")
	for id in [&"bf_fangs", &"bf_fangs", &"bf_hide"]:
		Profile.add_material(id, 1)
	Profile.add_material(&"ib_mandible", 2)
	_check(Profile.buy_upgrade(obs), "comprar Bisturi de Obsidiana")
	_check(Profile.get_incisions() == Profile.BASE_INCISIONS + 1, "incisão extra")
	_check(Profile.get_family_material(Family.Id.BLOODFANG) == 1, "pagou 3 partes Bloodfang (restou %d)" % Profile.get_family_material(Family.Id.BLOODFANG))
	var twin: LabUpgradeData = Database.lab_upgrades[&"up_twin_blades"]
	_check(Database.lab_upgrades[&"up_obsidian"] != null and twin.requires == &"up_obsidian", "pré-requisito")
	# regiões
	var cat: ExpeditionData = Database.expeditions[&"flooded_catacombs"]
	_check(Profile.UNLOCK_ALL_REGIONS or not Profile.is_expedition_unlocked(cat), "Catacumbas começam bloqueadas")
	Profile.mark_cleared(&"bone_moor")
	_check(Profile.is_expedition_unlocked(cat), "Catacumbas liberadas após a Charneca")
	Profile.reset()
	print("[laboratório] híbridas, oficina e regiões verificadas")


func _test_run_save() -> void:
	RunState.start(Database.expeditions[&"flooded_catacombs"])
	var first: MapNode = RunState.get_available_nodes()[0]
	RunState.current = first
	first.visited = true
	RunState.hp = 17
	RunState.deck.append(&"rend+")
	RunState.gathered[&"rw_flesh"] = 2
	RunState.save_run()
	var deck_before := RunState.deck.duplicate()
	var floors_before := RunState.map.size()
	var types_before: Array = []
	for n: MapNode in RunState.map[3]:
		types_before.append(n.type)
	RunState.active = false
	RunState.map.clear()
	RunState.deck.clear()
	_check(RunState.load_run(), "carregar expedição")
	_check(RunState.expedition.id == &"flooded_catacombs", "região restaurada")
	_check(RunState.hp == 17 and RunState.deck == deck_before, "vida e baralho restaurados")
	_check(RunState.map.size() == floors_before, "mapa restaurado")
	var types_after: Array = []
	for n: MapNode in RunState.map[3]:
		types_after.append(n.type)
	_check(types_after == types_before, "tipos dos nós restaurados")
	_check(RunState.current != null and RunState.current.floor_index == 0 and RunState.current.visited, "posição restaurada")
	_check(int(RunState.gathered.get(&"rw_flesh", 0)) == 2, "materiais da expedição restaurados")
	RunState.end_run(false)
	_check(not RunState.has_save(), "fim da expedição apaga o save")
	Profile.reset()
	print("[save] expedição salva e restaurada")


# --- Balanceamento (IA gulosa simples) --------------------------------------

func _test_balance() -> void:
	var starter := Database.cards_from_ids(Database.STARTER_DECK)
	var mid_ids: Array = Database.STARTER_DECK.duplicate()
	mid_ids.append_array([&"deep_bite", &"rend", &"carapace_plate", &"tough_hide", &"tentacle_grip"])
	var mid := Database.cards_from_ids(mid_ids)
	var late_ids: Array = mid_ids.duplicate()
	late_ids.append_array([&"hb_armored_heart", &"necrotic_bile", &"dry_sinew", &"deep_bite+", &"rend+"])
	var late := Database.cards_from_ids(late_ids)
	var grove_ids: Array = late_ids.duplicate()
	grove_ids.append_array([&"fungal_bite", &"filter_gills", &"spore_cloud", &"take_root", &"fungal_bite+"])
	var grove := Database.cards_from_ids(grove_ids)
	var peaks_ids: Array = grove_ids.duplicate()
	peaks_ids.append_array([&"hooked_strike", &"dive_talons", &"smoke_screen", &"luminous_veil", &"hb_burning_spores"])
	var peaks := Database.cards_from_ids(peaks_ids)
	# [nome, baralho, grupos, região, andar simulado, vida do caçador]
	# A vida cresce com as regiões, como cresce com mutações e melhorias num jogo real.
	var setups := [
		["inicial", starter, [[&"bloodfang"], [&"ironback"], [&"voidspawn"], [&"bloodfang_pup", &"bloodfang_pup"], [&"rotwalker"], [&"ghoul", &"ghoul"]], &"bone_moor", 2, 60],
		["meio", mid, [[&"bloodfang_alpha"], [&"void_matriarch"], [&"voidspawn", &"bloodfang_pup"]], &"bone_moor", 5, 60],
		["catacumbas", late, [[&"rotwalker", &"ghoul"], [&"stitched_abomination"], [&"iron_colossus"]], &"flooded_catacombs", 5, 70],
		["bosque", grove, [[&"sporeling", &"sporeling"], [&"spore_wisp", &"spore_wisp"], [&"sporemaw"], [&"spore_carrier"], [&"sporemaw", &"spore_wisp"], [&"mycostalker"], [&"spore_stag"], [&"mycelium_mother"]], &"fungal_grove", 5, 80],
		["pináculos", peaks, [[&"ash_hatchling", &"ash_hatchling"], [&"ashwing"], [&"ashwing", &"ash_hatchling"], [&"stormtalon"], [&"ember_roc"]], &"ash_peaks", 6, 90],
	]
	for setup in setups:
		var expd: ExpeditionData = Database.expeditions[setup[3]]
		var floor_n: int = setup[4]
		for group in setup[2]:
			var datas: Array[MonsterData] = []
			for id in group:
				datas.append(Database.get_monster(id))
			var is_boss := datas[0].tier == MonsterData.Tier.BOSS
			var hp_bonus := 0 if is_boss else floor_n * expd.hp_per_floor
			var strength := expd.monster_strength / 2 if is_boss else expd.monster_strength
			if not is_boss and expd.strength_floor_step > 0:
				strength += floor_n / expd.strength_floor_step
			var wins := 0
			var turns := 0
			var hp_left := 0
			for i in SIMS_PER_MONSTER:
				var r: Dictionary = await _simulate(datas, setup[1], setup[5], hp_bonus, strength)
				wins += 1 if r["won"] else 0
				turns += r["turns"]
				hp_left += r["hp"]
			print("[balanço · %-10s] %-34s vitórias %2d/%d  turnos %4.1f  vida final %4.1f de %d" % [
				setup[0], " + ".join(group), wins, SIMS_PER_MONSTER, float(turns) / SIMS_PER_MONSTER, float(hp_left) / SIMS_PER_MONSTER, setup[5]])


func _simulate(datas: Array[MonsterData], deck: Array[CardData], hp: int, hp_bonus: int = 0, strength: int = 0) -> Dictionary:
	var cm := CombatManager.new()
	add_child(cm)
	var p := PlayerCombatant.new("Sim", hp, hp, 3)
	var result := {}
	cm.combat_ended.connect(func(v): result["won"] = v)
	cm.start_combat(p, deck, datas, [], hp_bonus, 0, strength)
	var guard := 0
	while not cm.is_over and guard < 60:
		guard += 1
		var played := true
		while played and not cm.is_over:
			played = false
			var incoming := 0
			for m in cm.monsters:
				if m.is_alive():
					var d := cm.preview_intent_damage(m)
					incoming += d.x * d.y
			var best: CardInstance = null
			for c in cm.hand:
				if not cm.can_play(c):
					continue
				var is_def := c.data.card_type == CardData.CardType.DEFENSE
				if best == null or (is_def and incoming > p.block) or (not is_def and incoming <= p.block and best.data.card_type == CardData.CardType.DEFENSE):
					best = c
			if best != null:
				# mira no monstro vivo com menos vida
				var target: Combatant = null
				for m in cm.get_living_monsters():
					if target == null or m.hp < target.hp:
						target = m
				played = cm.play_card(best, target)
		if not cm.is_over:
			await cm.end_player_turn()
			while not cm.is_player_turn and not cm.is_over:
				await get_tree().process_frame
	var out := {"won": result.get("won", false), "turns": cm.turn_number, "hp": p.hp}
	cm.queue_free()
	return out


# --- Telas ------------------------------------------------------------------

func _test_screens() -> void:
	Profile.reset()
	for key in ["menu", "options", "lab", "deck", "mutations", "experiment", "workshop", "archive"]:
		await _open(key)
	RunState.start(Database.expeditions[Database.DEFAULT_EXPEDITION])
	await _open("map")
	await _open("rest")
	RunState.current = RunState.get_available_nodes()[0]
	RunState.current.event = Database.events[&"ev_bone_altar"]
	await _open("event")
	var two: Array[MonsterData] = [Database.get_monster(&"ghoul"), Database.get_monster(&"rotwalker")]
	RunState.current.monsters = two
	await _open("combat")
	var screen := get_tree().current_scene
	_check(screen._monster_views.size() == 2, "combate com 2 monstros deveria mostrar 2 views")
	await _open("dissection")
	RunState.end_run(false)
	await _open("run_end")
	print("[telas] todas abriram")


func _open(key: String) -> void:
	get_tree().change_scene_to_file(Game.SCENES[key])
	for i in 6:
		await get_tree().process_frame
	_check(get_tree().current_scene != null and get_tree().current_scene.scene_file_path == Game.SCENES[key], "tela não abriu: " + key)


func _test_event_flow() -> void:
	Profile.reset()
	RunState.start(Database.expeditions[Database.DEFAULT_EXPEDITION])
	RunState.current = RunState.get_available_nodes()[0]
	RunState.current.event = Database.events[&"ev_hermit"]
	RunState.hp = 20
	await _open("event")
	var screen := get_tree().current_scene
	screen._resolve(screen.event.choices[0]) # tônico: +15 de vida
	_check(RunState.hp == 35, "evento: tônico deveria curar (hp=%d)" % RunState.hp)
	# evento que leva a combate
	RunState.current.event = Database.events[&"ev_ironback_nest"]
	await _open("event")
	screen = get_tree().current_scene
	var c: EventChoice = screen.event.choices[0].duplicate()
	c.success_chance = 0.0 # força a falha → luta
	screen._resolve(c)
	Game.start_event_fight(c.fail_fight)
	await _frames(6)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["combat"], "falha no ninho deveria iniciar combate")
	_check(get_tree().current_scene.combat.monsters[0].data.id == &"ironback", "evento: inimigo correto")
	RunState.end_run(false)
	print("[eventos] cura e combate por evento verificados")


# --- Fluxo completo ---------------------------------------------------------

func _test_full_flow() -> void:
	Profile.reset()
	Game.start_expedition()
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["map"], "expedição deveria abrir o mapa")
	_check(RunState.has_save(), "mapa deveria salvar a expedição")
	var node: MapNode = RunState.get_available_nodes()[0]
	Game.enter_node(node)
	await _frames(4)
	var screen := get_tree().current_scene
	_check(screen.scene_file_path == Game.SCENES["combat"], "nó deveria abrir combate")
	var cm: CombatManager = screen.combat
	var hv: HandView = screen._hand
	_check(hv.views.size() == CombatManager.HAND_SIZE, "mão inicial deveria ter %d cartas" % CombatManager.HAND_SIZE)
	var energy_before := cm.player.energy
	screen._on_card_pressed(hv.views[0])
	await _frames(3)
	_check(cm.player.energy < energy_before or cm.hand.size() < CombatManager.HAND_SIZE, "jogar carta pela UI")
	screen._on_end_turn()
	var guard := 0
	while not cm.is_player_turn and not cm.is_over and guard < 600:
		guard += 1
		await get_tree().process_frame
	_check(cm.turn_number == 2 or cm.is_over, "deveria estar no turno 2")
	for m in cm.monsters:
		m.take_damage(m.hp + m.block + 2, cm.player, true)
	cm._check_end()
	_check(cm.is_over, "combate deveria terminar")
	Game.on_combat_won(cm.monsters, cm.player.hp)
	await _frames(4)
	screen = get_tree().current_scene
	_check(screen.scene_file_path == Game.SCENES["dissection"], "vitória deveria abrir dissecação")
	var sess: DissectionSession = screen.session
	for p in sess.monster.parts:
		if sess.can_attempt(p):
			screen._extract(p)
	_check(sess.incisions_left == 0, "incisões deveriam ser consumidas")
	print("[fluxo] partes extraídas: %d" % sess.collected.size())
	screen._show_summary()
	await _frames(2)
	while not RunState.dissection_queue.is_empty():
		Game.on_dissection_done()
		await _frames(4)
	Game.on_dissection_done()
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["map"], "após dissecação deveria voltar ao mapa")
	# continuar expedição a partir do menu
	await _open("menu")
	_check(Game.continue_expedition(), "continuar expedição")
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["map"] and RunState.current == null or RunState.current.floor_index == 0, "continuar volta ao mapa")
	Game.finish_run(true)
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["run_end"], "fim de expedição")
	_check(Profile.is_expedition_unlocked(Database.expeditions[&"flooded_catacombs"]), "vencer a Charneca libera as Catacumbas")
	await _open("lab")


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


# --- NG+ --------------------------------------------------------------------

func _test_ng_plus() -> void:
	Profile.reset()
	var expd: ExpeditionData = Database.expeditions[Database.DEFAULT_EXPEDITION]
	_check(Profile.get_ng_unlocked(expd.id) == 0, "NG+: região nova começa sem NG+")
	# vencer o normal libera o NG+1; vencer o NG+1 libera o NG+2; nunca passa de MAX_NG
	_check(Profile.clear_ng(expd.id, 0) == 1, "NG+: vencer o normal libera o NG+1")
	_check(Profile.clear_ng(expd.id, 0) == -1, "NG+: vencer o normal de novo não libera nada")
	_check(Profile.clear_ng(expd.id, 1) == 2, "NG+: vencer o NG+1 libera o NG+2")
	for i in 10:
		Profile.clear_ng(expd.id, Profile.MAX_NG)
	_check(Profile.get_ng_unlocked(expd.id) == Profile.MAX_NG, "NG+: limite é NG+%d" % Profile.MAX_NG)
	# dificuldade: vida e força sobem com o nível; o nível volta do save da expedição
	RunState.start(expd, 3)
	var base_s := expd.monster_strength
	_check(is_equal_approx(RunState.get_monster_hp_mult(), 1.36), "NG+3: monstros com +36% de vida")
	_check(RunState.get_monster_strength() >= base_s + 2, "NG+3: monstros com +2 de Força")
	var m := MonsterCombatant.new(Database.get_monster(&"bloodfang"), 0, RunState.get_monster_hp_mult())
	_check(m.max_hp == roundi(Database.get_monster(&"bloodfang").max_hp * 1.36), "NG+3: vida do monstro multiplicada")
	RunState.save_run()
	RunState.ng_level = 0
	RunState.load_run()
	_check(RunState.ng_level == 3, "NG+: nível volta ao carregar a expedição")
	RunState.delete_save()
	RunState.active = false
	Profile.reset()
