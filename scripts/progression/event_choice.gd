class_name EventChoice
extends Resource
## Uma opção de um evento do mapa. Todos os resultados são dados (sem código por evento).

@export var label: String = ""
@export_multiline var description: String = ""
## Chance de sucesso (1.0 = sempre). Em caso de falha, usa os campos fail_*.
@export_range(0.0, 1.0, 0.05) var success_chance: float = 1.0

@export_group("Sucesso")
@export_multiline var result_text: String = ""
@export var hp_change: int = 0
@export var max_hp_change: int = 0
@export var gain_parts: Array[AnatomyPart] = []
@export var add_cards: Array[CardData] = []
@export var remove_card: bool = false
@export var upgrade_card: bool = false
@export var fight: Array[MonsterData] = []

@export_group("Falha")
@export_multiline var fail_text: String = ""
@export var fail_hp_change: int = 0
@export var fail_fight: Array[MonsterData] = []


## Opções que custam vida não podem ser escolhidas se matariam o caçador.
func is_available(current_hp: int) -> bool:
	return current_hp + mini(hp_change, fail_hp_change) > 0
