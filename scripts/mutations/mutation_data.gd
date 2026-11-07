class_name MutationData
extends Resource
## Alteração biológica instalada no caçador (no laboratório, com materiais).

@export var id: StringName
@export var display_name: String = ""
@export var family: Family.Id = Family.Id.NEUTRAL
@export_multiline var description: String = ""
## part_id (String) -> quantidade necessária.
@export var material_cost: Dictionary = {}
@export var max_hp_bonus: int = 0
@export var energy_bonus: int = 0
@export var first_turn_draw_bonus: int = 0
## Efeitos resolvidos no início de cada combate (fonte = jogador).
@export var combat_start_effects: Array[CardEffect] = []
## Pontos adicionados ao medidor de Corrupção do caçador.
@export var corruption: int = 1
@export var art_motif: StringName = &"heart"
