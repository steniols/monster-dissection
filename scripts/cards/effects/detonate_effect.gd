class_name DetonateEffect
extends CardEffect
## Consome todo o status do alvo: ele perde vida igual aos acúmulos × multiplicador (ignora Armadura).

@export var status_id: StringName = &"spores"
@export var multiplier: int = 2


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		var stacks := t.get_status(status_id)
		if stacks <= 0:
			continue
		t.set_status(status_id, 0)
		t.lose_hp(stacks * multiplier, Combatant.DeathCause.STATUS)
		if not t.is_alive() and not ctx.killed_targets.has(t):
			ctx.killed_targets.append(t)


func describe() -> String:
	var who := "de todos os inimigos" if target == Target.ALL_OPPONENTS else "do alvo"
	return "Detone os %s %s: perde %d de vida por acúmulo, ignorando a Armadura." % [StatusLibrary.keyword(status_id), who, multiplier]


func upgrade() -> bool:
	multiplier += 1
	return true
