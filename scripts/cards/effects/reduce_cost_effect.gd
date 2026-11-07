class_name ReduceCostEffect
extends CardEffect
## Reduz o custo de cartas na mão.

enum Scope { RANDOM_CARD, ALL_HAND }

@export var amount: int = 1
@export var scope: Scope = Scope.RANDOM_CARD
## Se verdadeiro, a redução vale até o fim do combate; senão, só neste turno.
@export var whole_combat: bool = false


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	if not ctx.source.is_player:
		return
	var candidates: Array[CardInstance] = []
	for c in ctx.combat.hand:
		if c != ctx.card and c.get_cost() > 0:
			candidates.append(c)
	if candidates.is_empty():
		return
	if scope == Scope.RANDOM_CARD:
		candidates = [candidates[ctx.combat.rng.randi_range(0, candidates.size() - 1)]]
	for c in candidates:
		if whole_combat:
			c.cost_modifier -= amount
		else:
			c.turn_cost_modifier -= amount
	ctx.combat.hand_changed.emit()


func describe() -> String:
	var what := "uma carta aleatória da mão" if scope == Scope.RANDOM_CARD else "todas as cartas da mão"
	var when := " neste combate" if whole_combat else " neste turno"
	return "Reduza em %d o custo de %s%s." % [amount, what, when]
