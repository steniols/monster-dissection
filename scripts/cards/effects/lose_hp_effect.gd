class_name LoseHpEffect
extends CardEffect
## Perde vida diretamente (ignora Armadura). Usado para trocar vida por poder.

@export var amount: int = 3


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		t.lose_hp(amount)


func describe() -> String:
	return "Perca %d de vida." % amount
