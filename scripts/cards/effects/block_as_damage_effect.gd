class_name BlockAsDamageEffect
extends CardEffect
## Causa dano de ataque igual à Armadura atual de quem usa.

func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		var dmg := ctx.combat.calc_attack_damage(ctx.source, t, ctx.source.block)
		t.take_damage(dmg, ctx.source, true)
		if not t.is_alive() and not ctx.killed_targets.has(t):
			ctx.killed_targets.append(t)


func describe() -> String:
	return "Cause dano igual à sua %s." % kw("Armadura", Palette.PETROL_BRIGHT)
