class_name HealEffect
extends CardEffect
## Recupera vida.

@export var amount: int = 5


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		t.heal(amount)


func describe() -> String:
	return "Recupere %d de %s." % [amount, kw("vida", Palette.MOSS_BRIGHT)]
