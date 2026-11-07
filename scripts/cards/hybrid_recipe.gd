class_name HybridRecipe
extends Resource
## Combinação de duas partes (de famílias diferentes) que gera uma carta híbrida.

@export var id: StringName
@export var part_a: AnatomyPart
@export var part_b: AnatomyPart
@export var result: CardData
## Pista exibida no caderno antes da descoberta.
@export_multiline var hint: String = ""


func matches(a: AnatomyPart, b: AnatomyPart) -> bool:
	if a == null or b == null:
		return false
	return (a.id == part_a.id and b.id == part_b.id) or (a.id == part_b.id and b.id == part_a.id)
