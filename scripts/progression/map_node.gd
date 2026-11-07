class_name MapNode
extends RefCounted
## Um ponto no mapa da expedição.

enum Type { COMBAT, ELITE, REST, BOSS, EVENT }

const TYPE_NAMES := {
	Type.COMBAT: "Encontro",
	Type.ELITE: "Covil",
	Type.REST: "Acampamento",
	Type.BOSS: "Chefe",
	Type.EVENT: "Mistério",
}

var floor_index: int = 0
var index: int = 0
var type: Type = Type.COMBAT
var links: Array[int] = [] ## índices dos nós no andar seguinte
var position: Vector2 = Vector2.ZERO ## normalizado 0..1
var visited: bool = false
var monsters: Array[MonsterData] = []
var event: EventData


func get_type_name() -> String:
	return TYPE_NAMES.get(type, "?")


func is_combat() -> bool:
	return type in [Type.COMBAT, Type.ELITE, Type.BOSS]


func to_dict() -> Dictionary:
	var ids: Array[String] = []
	for m in monsters:
		ids.append(String(m.id))
	return {
		"type": type, "links": links.duplicate(), "x": position.x, "y": position.y,
		"visited": visited, "monsters": ids, "event": String(event.id) if event != null else "",
	}


static func from_dict(d: Dictionary, floor_i: int, idx: int) -> MapNode:
	var n := MapNode.new()
	n.floor_index = floor_i
	n.index = idx
	n.type = int(d.get("type", 0))
	for l in d.get("links", []):
		n.links.append(int(l))
	n.position = Vector2(float(d.get("x", 0.5)), float(d.get("y", 0.5)))
	n.visited = bool(d.get("visited", false))
	for id in d.get("monsters", []):
		var m := Database.get_monster(StringName(id))
		if m != null:
			n.monsters.append(m)
	var ev: String = d.get("event", "")
	if not ev.is_empty():
		n.event = Database.events.get(StringName(ev))
	return n
