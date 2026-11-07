class_name MonsterIntent
extends Resource
## Uma ação que o monstro anuncia no turno anterior.

enum Kind { ATTACK, DEFEND, BUFF, DEBUFF, ATTACK_DEBUFF, ATTACK_DEFEND }

@export var display_name: String = "Ataque"
@export var kind: Kind = Kind.ATTACK
@export var effects: Array[CardEffect] = []
## Peso no sorteio (padrão RANDOM_NO_REPEAT).
@export var weight: int = 1


func is_attack() -> bool:
	return kind in [Kind.ATTACK, Kind.ATTACK_DEBUFF, Kind.ATTACK_DEFEND]


func describe() -> String:
	var parts: PackedStringArray = []
	for e in effects:
		parts.append(e.describe())
	return " ".join(parts)
