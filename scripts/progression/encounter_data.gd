class_name EncounterData
extends Resource
## Grupo de monstros enfrentado em um nó de combate comum.

@export var id: StringName
@export var monsters: Array[MonsterData] = []
## Andar mínimo (0 = primeiro) em que o encontro pode aparecer.
@export var min_floor: int = 0
@export var weight: int = 1
