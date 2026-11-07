class_name DrawEffect
extends CardEffect
## Compra cartas (apenas para o jogador).

@export var count: int = 1


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	if ctx.source.is_player:
		ctx.combat.draw_cards(count)


func describe() -> String:
	return "Compre %d carta%s." % [count, "s" if count > 1 else ""]
