extends Node
## Teste de fumaça: simula combates, percorre todas as telas e o fluxo de uma expedição.
## Uso: Godot_console.exe --headless --path . res://tools/smoke_test.tscn
## Não altera o perfil do jogador (faz backup e restaura user://profile.json).

const SIMS_PER_MONSTER := 12

var _backup: String = ""
var _failures: PackedStringArray = []


func _ready() -> void:
	# Mantém este nó vivo durante as trocas de cena.
	get_tree().current_scene = null
	if FileAccess.file_exists(Profile.SAVE_PATH):
		_backup = FileAccess.get_file_as_string(Profile.SAVE_PATH)
	Engine.time_scale = 40.0
	await _run()
	_restore()
	print("\n==== RESULTADO: %s ====" % ("OK" if _failures.is_empty() else "FALHAS:\n- " + "\n- ".join(_failures)))
	get_tree().quit(0 if _failures.is_empty() else 1)


func _restore() -> void:
	if _backup.is_empty():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Profile.SAVE_PATH))
	else:
		var f := FileAccess.open(Profile.SAVE_PATH, FileAccess.WRITE)
		f.store_string(_backup)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		push_error("FALHA: " + msg)


func _run() -> void:
	Profile.reset()
	_test_data()
	_test_effects()
	await _test_balance()
	await _test_screens()
	await _test_full_flow()


# --- Dados ------------------------------------------------------------------

func _test_data() -> void:
	print("[dados] cartas=%d partes=%d monstros=%d mutações=%d" % [Database.cards.size(), Database.parts.size(), Database.monsters.size(), Database.mutations.size()])
	_check(Database.cards.size() >= 20, "poucas cartas")
	for id in Database.STARTER_DECK:
		_check(Database.get_card(id) != null, "carta inicial ausente: %s" % id)
	for p: AnatomyPart in Database.parts.values():
		_check(p.unlocks_card != null, "parte sem carta: %s" % p.id)
	for m: MutationData in Database.mutations.values():
		for k in m.material_cost:
			_check(Database.get_part(StringName(k)) != null, "mutação %s exige parte inexistente %s" % [m.id, k])
	for c: CardData in Database.cards.values():
		_check(not c.get_description().is_empty(), "carta sem descrição: %s" % c.id)
	print("[dados] exemplo: %s → %s" % [Database.get_card(&"predatory_pulse").display_name, Database.get_card(&"predatory_pulse").get_description()])


# --- Efeitos e condição do corpo -------------------------------------------

func _test_effects() -> void:
	var cm := CombatManager.new()
	add_child(cm)
	var p := PlayerCombatant.new("T", 50, 50, 3)
	cm.player = p
	var m := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	cm.monsters.append(m)
	# vulnerável + força
	m.add_status(&"vulnerable", 1)
	p.add_status(&"strength", 2)
	_check(cm.calc_attack_damage(p, m, 6) == 12, "cálculo de dano com força/vulnerável")
	# espinhos
	var ib := MonsterCombatant.new(Database.get_monster(&"ironback"))
	ib.add_status(&"thorns", 3)
	ib.take_damage(5, p, true)
	_check(p.hp == 47, "espinhos devolvem dano (hp=%d)" % p.hp)
	# overkill destrói cabeça
	var bf := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	bf.take_damage(bf.hp + 13, p, true)
	var cond := BodyCondition.from_combatant(bf)
	_check(cond.get_state(AnatomyPart.Region.HEAD) == BodyCondition.State.LOST, "overkill deveria destruir cabeça")
	_check(cond.chance_for(Database.get_part(&"bf_eyes")) == 0.0, "olhos perdidos têm chance 0")
	# morte por status preserva sólidos
	var bf2 := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	bf2.lose_hp(999, Combatant.DeathCause.STATUS)
	var cond2 := BodyCondition.from_combatant(bf2)
	_check(cond2.chance_for(Database.get_part(&"bf_heart")) > Database.get_part(&"bf_heart").preserve_chance, "morte por status dá bônus")
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
	cm.queue_free()
	print("[efeitos] verificados")


# --- Balanceamento (IA gulosa simples) --------------------------------------

func _test_balance() -> void:
	var starter := Database.cards_from_ids(Database.STARTER_DECK)
	var mid_ids: Array = Database.STARTER_DECK.duplicate()
	mid_ids.append_array([&"deep_bite", &"rend", &"carapace_plate", &"tough_hide", &"tentacle_grip"])
	var mid := Database.cards_from_ids(mid_ids)
	for setup in [["inicial", starter, [&"bloodfang", &"ironback", &"voidspawn"]],
			["meio de expedição", mid, [&"bloodfang_alpha", &"void_matriarch"]]]:
		for id in setup[2]:
			var wins := 0
			var turns := 0
			var hp_left := 0
			for i in SIMS_PER_MONSTER:
				var r: Dictionary = await _simulate(Database.get_monster(id), setup[1], 60)
				wins += 1 if r["won"] else 0
				turns += r["turns"]
				hp_left += r["hp"]
			print("[balanço · %s] %-16s vitórias %2d/%d  turnos médios %.1f  vida final média %.1f" % [
				setup[0], id, wins, SIMS_PER_MONSTER, float(turns) / SIMS_PER_MONSTER, float(hp_left) / SIMS_PER_MONSTER])


func _simulate(data: MonsterData, deck: Array[CardData], hp: int) -> Dictionary:
	var cm := CombatManager.new()
	add_child(cm)
	var p := PlayerCombatant.new("Sim", hp, hp, 3)
	var list: Array[MonsterData] = [data]
	var result := {}
	cm.combat_ended.connect(func(v): result["won"] = v)
	cm.start_combat(p, deck, list)
	var guard := 0
	while not cm.is_over and guard < 60:
		guard += 1
		var played := true
		while played and not cm.is_over:
			played = false
			# prioriza ataques se o monstro não vai atacar, defesa se vai
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
				var target: Combatant = cm.get_living_monsters()[0] if not cm.get_living_monsters().is_empty() else null
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
	for key in ["menu", "lab", "deck", "mutations", "archive"]:
		await _open(key)
	RunState.start(Database.expeditions[Database.DEFAULT_EXPEDITION])
	await _open("map")
	await _open("rest")
	RunState.current = RunState.get_available_nodes()[0]
	await _open("combat")
	await _open("dissection")
	RunState.end_run(false)
	await _open("run_end")
	print("[telas] todas abriram")


func _open(key: String) -> void:
	get_tree().change_scene_to_file(Game.SCENES[key])
	for i in 6:
		await get_tree().process_frame
	_check(get_tree().current_scene != null and get_tree().current_scene.scene_file_path == Game.SCENES[key], "tela não abriu: " + key)


# --- Fluxo completo ---------------------------------------------------------

func _test_full_flow() -> void:
	Profile.reset()
	Game.start_expedition()
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["map"], "expedição deveria abrir o mapa")
	var node: MapNode = RunState.get_available_nodes()[0]
	Game.enter_node(node)
	await _frames(4)
	var screen := get_tree().current_scene
	_check(screen.scene_file_path == Game.SCENES["combat"], "nó deveria abrir combate")
	var cm: CombatManager = screen.combat
	# joga uma carta e encerra o turno pelo caminho da UI
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
	_check(cm.is_player_turn or cm.is_over, "turno do monstro deveria terminar")
	_check(cm.turn_number == 2 or cm.is_over, "deveria estar no turno 2")
	# vence o combate "na marra" para testar a transição
	for m in cm.monsters:
		m.take_damage(m.hp + 2, cm.player, true)
	cm._check_end()
	_check(cm.is_over, "combate deveria terminar")
	Game.on_combat_won(cm.monsters, cm.player.hp)
	await _frames(4)
	screen = get_tree().current_scene
	_check(screen.scene_file_path == Game.SCENES["dissection"], "vitória deveria abrir dissecação")
	var sess: DissectionSession = screen.session
	var before := Profile.unlocked_cards.size()
	for p in sess.monster.parts:
		if sess.can_attempt(p):
			screen._extract(p)
	_check(sess.incisions_left == 0, "incisões deveriam ser consumidas")
	print("[fluxo] partes extraídas: %d, cartas novas: %d" % [sess.collected.size(), Profile.unlocked_cards.size() - before])
	screen._show_summary()
	await _frames(2)
	Game.on_dissection_done()
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["map"], "após dissecação deveria voltar ao mapa")
	Game.finish_run(true)
	await _frames(4)
	_check(get_tree().current_scene.scene_file_path == Game.SCENES["run_end"], "fim de expedição")
	print("[fluxo] materiais no laboratório: %s" % str(Profile.materials))
	await _open("lab")
	await _open("mutations")


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
