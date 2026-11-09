class_name DamageEffect
extends CardEffect
## Causa dano de ataque (afetado por Força, Fraqueza, Vulnerável e Espinhos).

@export var amount: int = 6
@export var hits: int = 1
## Dano extra por carta já jogada neste turno (antes desta).
@export var bonus_per_card_played: int = 0
## Dano penetrante: ignora a Armadura e vai direto na vida.
@export var pierce: bool = false


func get_base_amount(ctx: EffectContext) -> int:
	var base := amount
	if bonus_per_card_played != 0 and ctx != null:
		base += bonus_per_card_played * ctx.combat.cards_played_this_turn
	return base


func apply(ctx: EffectContext) -> void:
	for i in hits:
		for t in resolve_targets(ctx):
			var dmg := ctx.combat.calc_attack_damage(ctx.source, t, get_base_amount(ctx))
			t.take_damage(dmg, ctx.source, true, pierce)
			if not t.is_alive() and not ctx.killed_targets.has(t):
				ctx.killed_targets.append(t)
		if not ctx.source.is_alive():
			return


func describe() -> String:
	var text := "Cause %d de %s" % [amount, kw("dano penetrante", Palette.BONE_LIGHT) if pierce else "dano"]
	if hits > 1:
		text += " %d vezes" % hits
	text += _target_suffix()
	if bonus_per_card_played != 0:
		text += ", +%d para cada carta jogada neste turno" % bonus_per_card_played
	return text + "."


func upgrade() -> bool:
	if bonus_per_card_played > 0:
		bonus_per_card_played += 1
	amount += 1 if hits > 1 else maxi(3, amount / 3)
	return true
