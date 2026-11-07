class_name LabUpgradeData
extends Resource
## Melhoria permanente do laboratório, paga com materiais de uma família (qualquer parte dela).

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
## Família (int de Family.Id) -> quantidade de partes dessa família.
@export var family_cost: Dictionary = {}
## Melhoria exigida antes desta (opcional).
@export var requires: StringName = &""
@export var incisions_bonus: int = 0
@export_range(0.0, 1.0, 0.05) var preserve_bonus: float = 0.0
## Multiplicador para partes danificadas (0 = não altera; padrão do jogo é 0.5).
@export_range(0.0, 1.0, 0.05) var damaged_multiplier: float = 0.0
@export var max_hp_bonus: int = 0
@export var art_motif: StringName = &"scalpel"
