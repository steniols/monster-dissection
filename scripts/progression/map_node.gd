class_name MapNode
extends RefCounted
## Um ponto no mapa da expedição.

enum Type { COMBAT, ELITE, REST, BOSS }

const TYPE_NAMES := {
	Type.COMBAT: "Encontro",
	Type.ELITE: "Covil",
	Type.REST: "Acampamento",
	Type.BOSS: "Matriarca",
}

var floor_index: int = 0
var index: int = 0
var type: Type = Type.COMBAT
var links: Array[int] = [] ## índices dos nós no andar seguinte
var position: Vector2 = Vector2.ZERO ## normalizado 0..1
var visited: bool = false
var monsters: Array[MonsterData] = []


func get_type_name() -> String:
	return TYPE_NAMES.get(type, "?")
