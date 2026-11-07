class_name ReturnFromDiscardEffect
extends CardEffect
## Devolve cartas aleatórias do descarte para a mão (reutilizar cartas).

@export var count: int = 1


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	if ctx.source.is_player:
		ctx.combat.return_from_discard(count)


func describe() -> String:
	return "Devolva %d carta%s aleatória%s do descarte para a mão." % [count, "s" if count > 1 else "", "s" if count > 1 else ""]


func upgrade() -> bool:
	count += 1
	return true
