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
## Força com que os monstros começam cada combate nesta região.
@export var monster_strength: int = 0
## A cada quantos andares os monstros ganham +1 de Força (0 = nunca). Não vale para o chefe.
@export var strength_floor_step: int = 0
@export var accent: Color = Color("#426D78")
