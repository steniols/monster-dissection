extends Node
## Autoload "Game": aplica o tema e coordena o fluxo entre telas.

const SCENES := {
	"menu": "res://scenes/menus/main_menu.tscn",
	"lab": "res://scenes/laboratory/laboratory.tscn",
	"deck": "res://scenes/laboratory/deck_builder.tscn",
	"mutations": "res://scenes/laboratory/mutation_chamber.tscn",
	"archive": "res://scenes/collection/archive.tscn",
	"map": "res://scenes/map/expedition_map.tscn",
	"rest": "res://scenes/map/rest_site.tscn",
	"combat": "res://scenes/combat/combat.tscn",
	"dissection": "res://scenes/dissection/dissection.tscn",
	"run_end": "res://scenes/menus/run_end.tscn",
}


func _ready() -> void:
	get_tree().root.theme = UiTheme.build()


func goto(key: String) -> void:
	var path: String = SCENES.get(key, "")
	if path.is_empty():
		push_error("Game: cena desconhecida " + key)
		return
	get_tree().change_scene_to_file.call_deferred(path)


# --- Fluxo da expedição -----------------------------------------------------

func start_expedition() -> void:
	var expd: ExpeditionData = Database.expeditions.get(Database.DEFAULT_EXPEDITION)
	if expd == null:
		push_error("Game: expedição padrão não encontrada.")
		return
	RunState.start(expd)
	goto("map")


func enter_node(node: MapNode) -> void:
	RunState.current = node
	node.visited = true
	match node.type:
		MapNode.Type.REST:
			goto("rest")
		_:
			goto("combat")


func on_combat_won(bodies: Array[MonsterCombatant], player_hp: int) -> void:
	RunState.hp = player_hp
	RunState.dissection_queue.clear()
	for m in bodies:
		RunState.kills += 1
		Profile.record_kill(m.data.id)
		RunState.dissection_queue.append({"monster": m.data, "condition": BodyCondition.from_combatant(m)})
	Profile.save_profile()
	goto("dissection")


func on_combat_lost() -> void:
	RunState.hp = 0
	finish_run(false)


func on_dissection_done() -> void:
	if not RunState.dissection_queue.is_empty():
		goto("dissection")
	elif RunState.current != null and RunState.current.type == MapNode.Type.BOSS:
		finish_run(true)
	else:
		goto("map")


func finish_run(won: bool) -> void:
	RunState.end_run(won)
	goto("run_end")
