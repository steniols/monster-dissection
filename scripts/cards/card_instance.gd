class_name CardInstance
extends RefCounted
## Uma cópia física de carta durante o combate (o CardData é compartilhado e imutável).

var data: CardData
var cost_modifier: int = 0 # válido por todo o combate
var turn_cost_modifier: int = 0 # zerado no fim do turno


func _init(card_data: CardData) -> void:
	data = card_data


func get_cost() -> int:
	return max(0, data.cost + cost_modifier + turn_cost_modifier)
