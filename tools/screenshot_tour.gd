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
	RunState.current = RunState.get_available_nodes()[0]
	RunState.current.monsters = [Database.get_monster(&"bloodfang")]
	await _shot("combat", "07_combate", 1.2)
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


func _dead(id: StringName) -> MonsterCombatant:
	var m := MonsterCombatant.new(Database.get_monster(id))
	m.lose_hp(999, Combatant.DeathCause.STATUS)
	return m


func _shot(key: String, name: String, delay: float = 0.5) -> void:
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
