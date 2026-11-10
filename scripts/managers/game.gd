extends Node
## Autoload "Game": aplica o tema e coordena o fluxo entre telas.

const SCENES := {
	"menu": "res://scenes/menus/main_menu.tscn",
	"options": "res://scenes/menus/options.tscn",
	"lab": "res://scenes/laboratory/laboratory.tscn",
	"deck": "res://scenes/laboratory/deck_builder.tscn",
	"mutations": "res://scenes/laboratory/mutation_chamber.tscn",
	"experiment": "res://scenes/laboratory/experiment_station.tscn",
	"workshop": "res://scenes/laboratory/workshop.tscn",
	"archive": "res://scenes/collection/archive.tscn",
	"map": "res://scenes/map/expedition_map.tscn",
	"rest": "res://scenes/map/rest_site.tscn",
	"event": "res://scenes/map/event.tscn",
	"combat": "res://scenes/combat/combat.tscn",
	"dissection": "res://scenes/dissection/dissection.tscn",
	"run_end": "res://scenes/menus/run_end.tscn",
}

## Tela para onde "Voltar" leva a partir das opções.
var options_return: String = "menu"
## Chave da tela atual (ver SCENES).
var current: String = "menu"


func _ready() -> void:
	get_tree().root.theme = UiTheme.build()
	get_tree().node_added.connect(_on_node_added)


## Som de clique em qualquer botão do jogo, e cursor de mãozinha em tudo que é clicável.
func _on_node_added(n: Node) -> void:
	if n is BaseButton:
		n.pressed.connect(func(): Sfx.play(&"click"))
		var b := n as BaseButton
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		# desativado: seta normal
		b.mouse_entered.connect(func(): b.mouse_default_cursor_shape = Control.CURSOR_ARROW if b.disabled else Control.CURSOR_POINTING_HAND)
	elif n is Slider:
		n.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if n is Control and not n is ScrollContainer and not n is ScrollBar:
		_let_scroll_through.call_deferred(n)


## Dentro de listas com rolagem, o toque precisa chegar até a lista: senão, arrastar o dedo em cima
## de uma carta ou painel não rola. Os botões continuam funcionando (o clique é cancelado se a lista rolar).
func _let_scroll_through(c: Control) -> void:
	if not is_instance_valid(c) or c.mouse_filter != Control.MOUSE_FILTER_STOP:
		return
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer:
			c.mouse_filter = Control.MOUSE_FILTER_PASS
			return
		p = p.get_parent()


func goto(key: String) -> void:
	var path: String = SCENES.get(key, "")
	if path.is_empty():
		push_error("Game: cena desconhecida " + key)
		return
	current = key
	PauseMenu.on_screen(key)
	get_tree().change_scene_to_file.call_deferred(path)


func open_options(from: String) -> void:
	options_return = from
	goto("options")


# --- Fluxo da expedição -----------------------------------------------------

func start_expedition(id: StringName = Database.DEFAULT_EXPEDITION) -> void:
	var expd: ExpeditionData = Database.expeditions.get(id)
	if expd == null:
		push_error("Game: expedição não encontrada: %s" % id)
		return
	RunState.start(expd)
	goto("map")


func continue_expedition() -> bool:
	if RunState.load_run():
		goto("map")
		return true
	return false


func enter_node(node: MapNode) -> void:
	RunState.current = node
	node.visited = true
	match node.type:
		MapNode.Type.REST:
			goto("rest")
		MapNode.Type.EVENT:
			goto("event")
		_:
			goto("combat")


## Usado por eventos que levam a um combate.
func start_event_fight(monsters: Array[MonsterData]) -> void:
	RunState.current.monsters = monsters
	goto("combat")


func on_combat_won(bodies: Array[MonsterCombatant], player_hp: int) -> void:
	RunState.hp = player_hp
	RunState.dissection_queue.clear()
	RunState.incisions_left = Profile.get_incisions()
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
	if RunState.incisions_left <= 0:
		RunState.dissection_queue.clear()
	if not RunState.dissection_queue.is_empty():
		goto("dissection")
	elif RunState.current != null and RunState.current.type == MapNode.Type.BOSS:
		finish_run(true)
	else:
		goto("map")


func finish_run(won: bool) -> void:
	RunState.end_run(won)
	goto("run_end")
