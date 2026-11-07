class_name ExpeditionData
extends Resource
## Uma região explorável, suas criaturas e eventos.

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
## Ordem de exibição no laboratório.
@export var order: int = 0
## Expedição que precisa ser concluída para liberar esta (vazio = liberada).
@export var unlock_requirement: StringName = &""
@export var floors: int = 8
@export var encounters: Array[EncounterData] = []
@export var elite_pool: Array[MonsterData] = []
@export var boss: MonsterData
@export var events: Array[EventData] = []
## Vida extra dos monstros por andar avançado (não se aplica ao chefe).
@export var hp_per_floor: int = 2
@export var accent: Color = Color("#426D78")
