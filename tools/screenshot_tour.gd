extends Node
## Abre cada tela e salva uma captura. Uso (precisa de janela, não headless):
##   Godot.exe --path . res://tools/screenshot_tour.tscn -- <pasta_de_saida>
## Faz backup e restaura o perfil e a expedição salva do jogador.

var _out := "user://screenshots"
var _backup := ""
var _run_backup := ""


func _ready() -> void:
	get_tree().current_scene = null
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	if FileAccess.file_exists(Profile.SAVE_PATH):
		_backup = FileAccess.get_file_as_string(Profile.SAVE_PATH)
	if FileAccess.file_exists(RunState.SAVE_PATH):
		_run_backup = FileAccess.get_file_as_string(RunState.SAVE_PATH)
	await _tour()
	if _backup.is_empty():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Profile.SAVE_PATH))
	else:
		FileAccess.open(Profile.SAVE_PATH, FileAccess.WRITE).store_string(_backup)
	# a expedição salva também volta como estava
	if _run_backup.is_empty():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RunState.SAVE_PATH))
	else:
		FileAccess.open(RunState.SAVE_PATH, FileAccess.WRITE).store_string(_run_backup)
	get_tree().quit()


func _tour() -> void:
	get_viewport().warp_mouse(Vector2(1275, 715))
	# Perfil de demonstração com algum progresso.
	Profile.reset()
	for id in [&"deep_bite", &"rend", &"carapace_plate", &"tentacle_grip", &"predatory_pulse"]:
		Profile.unlock_card(id)
	for id in [&"bf_fangs", &"bf_claws", &"bf_heart", &"ib_carapace", &"tentacle_grip"]:
		Profile.record_part(id)
	Profile.record_kill(&"bloodfang")
	Profile.record_kill(&"ironback")
	Profile.add_material(&"bf_heart", 1)
	Profile.add_material(&"ib_carapace", 3)
	Profile.add_material(&"bf_claws", 2)

	await _shot("menu", "01_menu")
	await _shot("lab", "02_laboratorio")
	await _shot("deck", "03_baralho")
	await _shot("mutations", "04_mutacoes")
	await _shot("archive", "05_arquivo")
	RunState.start(Database.expeditions[Database.DEFAULT_EXPEDITION])
	RunState.deck.append_array([&"deep_bite", &"rend", &"tentacle_grip"])
	await _shot("map", "06_mapa")
	var conf: Control = UiTheme.confirm(get_tree().current_scene, "Abandonar expedição", "Retornar agora ao laboratório?\nVocê perde metade dos materiais desta expedição.", "Abandonar", "Continuar explorando", func(): pass)
	await _wait(0.3)
	await _capture("06b_abandonar")
	conf.queue_free()
	RunState.current = RunState.get_available_nodes()[0]
	RunState.current.monsters = [Database.get_monster(&"bloodfang")]
	await _shot("combat", "07_combate", 1.2)
	# pose de conjurar (no meio do gesto)
	for pp in get_tree().current_scene.find_children("*", "PlayerPanel", true, false):
		pp.cast(Database.get_card(&"rend"))
	await _wait(0.12)
	await _capture("07c_conjurar")
	# reação ao dano (golpe forte, no meio do recuo)
	await _wait(0.8)
	for pp in get_tree().current_scene.find_children("*", "PlayerPanel", true, false):
		pp._art.hurt(2.0)
	await _wait(0.08)
	await _capture("07d_dano")
	PauseMenu.open()
	await _wait(0.3)
	await _capture("07b_pausa")
	PauseMenu.close()
	# passa o mouse numa carta
	var screen := get_tree().current_scene
	var hv: HandView = screen._hand
	if hv.views.size() > 2:
		hv._on_hover(hv.views[2], true)
		screen.combat.monsters[0].add_status(&"bleed", 3)
		screen.combat.player.add_block(5)
		await _wait(0.4)
		await _capture("08_combate_hover")
	RunState.current.monsters = [Database.get_monster(&"void_matriarch")]
	await _shot("combat", "09_chefe", 1.2)
	var m := MonsterCombatant.new(Database.get_monster(&"bloodfang"))
	m.attack_hits_taken = 11
	m.take_damage(m.hp + 8, null, true)
	RunState.dissection_queue = [{"monster": m.data, "condition": BodyCondition.from_combatant(m)}]
	await _shot("dissection", "10_dissecacao")
	RunState.dissection_queue = [{"monster": Database.get_monster(&"ironback"), "condition": BodyCondition.from_combatant(_dead(&"ironback"))}]
	await _shot("dissection", "11_dissecacao_ironback")
	await _shot("rest", "12_acampamento")
	get_tree().current_scene._study()
	await _wait(0.3)
	await _capture("12b_estudar")

	# --- Marco 2 ---
	Profile.add_material(&"rw_flesh", 2)
	Profile.add_material(&"vs_eyes", 1)
	Profile.unlock_card(&"hb_armored_heart")
	Profile.discovered_recipes.append(&"rc_armored_heart")
	Profile.mark_cleared(&"bone_moor")
	await _shot("experiment", "13_experimentacao")
	await _shot("workshop", "14_oficina")
	await _shot("options", "15_opcoes")
	RunState.current.event = Database.events[&"ev_violet_pool"]
	await _shot("event", "16_evento")
	var group: Array[MonsterData] = [Database.get_monster(&"rotwalker"), Database.get_monster(&"ghoul")]
	RunState.current.monsters = group
	RunState.deck.append_array([&"hb_armored_heart", &"rend+", &"hb_void_claws"])
	await _shot("combat", "17_rotwalker_carnical", 1.2)
	var boss: Array[MonsterData] = [Database.get_monster(&"iron_colossus")]
	RunState.current.monsters = boss
	await _shot("combat", "18_colosso", 1.2)
	await _shot("lab", "19_laboratorio_v2")
	get_tree().current_scene._choose_region()
	await _wait(0.3)
	await _capture("20_regioes")
	var ab := MonsterCombatant.new(Database.get_monster(&"stitched_abomination"))
	ab.lose_hp(999, Combatant.DeathCause.STATUS)
	RunState.dissection_queue = [{"monster": ab.data, "condition": BodyCondition.from_combatant(ab)}]
	await _shot("dissection", "21_dissecacao_abominacao")
	# Fases 3 e 4
	RunState.start(Database.expeditions[&"fungal_grove"])
	await _shot("map", "22_mapa_bosque")
	RunState.current = RunState.get_available_nodes()[0]
	var grove: Array[MonsterData] = [Database.get_monster(&"sporemaw"), Database.get_monster(&"spore_wisp")]
	RunState.current.monsters = grove
	RunState.deck.append_array([&"fungal_bite", &"spore_cloud", &"hooked_strike", &"hb_burning_spores"])
	await _shot("combat", "23_combate_bosque", 1.2)
	var sc := get_tree().current_scene
	sc.combat.monsters[0].add_status(&"spores", 4)
	sc.combat.player.add_status(&"ember", 2)
	await _wait(0.3)
	await _capture("23b_status_novos")
	RunState.current.event = Database.events[&"ev_spore_cocoon"]
	await _shot("event", "24_evento_bosque")
	RunState.start(Database.expeditions[&"ash_peaks"])
	await _shot("map", "25_mapa_pinaculos")
	RunState.current = RunState.get_available_nodes()[0]
	var peaks: Array[MonsterData] = [Database.get_monster(&"ash_hatchling"), Database.get_monster(&"ash_hatchling")]
	RunState.current.monsters = peaks
	RunState.deck.append_array([&"molten_heart", &"dive_talons"])
	await _shot("combat", "26_combate_pinaculos", 1.2)
	var roc: Array[MonsterData] = [Database.get_monster(&"ember_roc")]
	RunState.current.monsters = roc
	await _shot("combat", "27_chefe_pinaculos", 1.2)
	RunState.current.event = Database.events[&"ev_abandoned_gear"]
	await _shot("event", "28_evento_pinaculos")
	Profile.mark_cleared(&"flooded_catacombs")
	Profile.mark_cleared(&"fungal_grove")
	Profile.ng_levels[&"bone_moor"] = 3
	Profile.ng_levels[&"flooded_catacombs"] = 1
	await _shot("lab", "29_laboratorio_fases")
	get_tree().current_scene._choose_region()
	await _wait(0.3)
	await _capture("30_regioes_4")
	await _shot("mutations", "31_mutacoes")
	await _shot("workshop", "32_oficina")
	var new_ids := [&"sporeling", &"sporemaw", &"spore_carrier", &"spore_wisp", &"mycostalker", &"spore_stag", &"mycelium_mother", &"ash_hatchling", &"ashwing", &"stormtalon", &"ember_roc"]
	for id in new_ids:
		var nm := MonsterCombatant.new(Database.get_monster(id))
		nm.take_damage(nm.hp, null, true)
		RunState.dissection_queue = [{"monster": nm.data, "condition": BodyCondition.from_combatant(nm)}]
		await _shot("dissection", "d_" + String(id))
	# Ícones de todos os tipos de ponto do mapa
	RunState.start(Database.expeditions[&"bone_moor"])
	var nodes := RunState.get_available_nodes()
	var types := [MapNode.Type.ELITE, MapNode.Type.REST, MapNode.Type.EVENT]
	for i in mini(nodes.size(), 3):
		nodes[i].type = types[i]
		if types[i] == MapNode.Type.EVENT:
			nodes[i].event = Database.events[&"ev_hermit"]
		if types[i] == MapNode.Type.ELITE:
			nodes[i].monsters = [Database.get_monster(&"bloodfang_alpha")]
	await _shot("map", "33_mapa_icones")
	get_tree().current_scene._open_full_map()
	await _wait(0.4)
	await _capture("34_mapa_completo")
	# Hover: a engrenagem e o ícone do "Ver mapa completo" acompanham a placa
	await _shot("map", "36_mapa_hover_base")
	for b in get_tree().current_scene.find_children("*", "Button", true, false):
		if b.tooltip_text == "Menu (Esc)" or b.text == "Ver mapa completo":
			get_viewport().warp_mouse(b.get_global_rect().get_center())
			await _wait(0.3)
			await _capture("37_hover_" + ("engrenagem" if b.text.is_empty() else "mapa"))
	await _shot("menu", "38_menu_dourado")
	for b in get_tree().current_scene.find_children("*", "Button", true, false):
		if b.text == "Entrar no laboratório":
			get_viewport().warp_mouse(b.get_global_rect().get_center())
			await _wait(0.3)
			await _capture("39_menu_dourado_hover")
	await _shot("lab", "40_laboratorio_ordem")
	# Explicação ao segurar uma carta e ao tocar num status
	InfoPopup.open_card(get_tree().current_scene, Database.get_card(&"clotting_lick"))
	await _wait(0.3)
	await _capture("42_info_carta")
	for n in get_tree().current_scene.get_children():
		if n is InfoPopup:
			n.queue_free()
	InfoPopup.open_status(get_tree().current_scene, &"spores", 4)
	await _wait(0.3)
	await _capture("43_info_status")


func _dead(id: StringName) -> MonsterCombatant:
	var m := MonsterCombatant.new(Database.get_monster(id))
	m.lose_hp(999, Combatant.DeathCause.STATUS)
	return m


func _shot(key: String, name: String, delay: float = 0.5) -> void:
	Game.current = key
	PauseMenu.on_screen(key)
	get_tree().change_scene_to_file(Game.SCENES[key])
	await _wait(delay)
	await _capture(name)


func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(_out.path_join(name + ".png"))
	print("captura: ", name)
