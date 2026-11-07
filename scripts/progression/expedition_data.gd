class_name ExpeditionData
extends Resource
## Uma região explorável e as criaturas que a habitam.

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var floors: int = 8
@export var normal_pool: Array[MonsterData] = []
@export var elite_pool: Array[MonsterData] = []
@export var boss: MonsterData
## Vida extra dos monstros por andar avançado.
@export var hp_per_floor: int = 2
