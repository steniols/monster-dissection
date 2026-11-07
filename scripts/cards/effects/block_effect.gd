class_name BlockEffect
extends CardEffect
## Concede Armadura (absorve dano até o início do próximo turno do portador).

@export var amount: int = 5


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		t.add_block(amount)


func describe() -> String:
	return "Ganhe %d de %s." % [amount, kw("Armadura", Palette.PETROL_BRIGHT)]


func upgrade() -> bool:
	amount += 3
	return true
