class_name DamageEffect
extends CardEffect
## Causa dano de ataque (afetado por Força, Fraqueza, Vulnerável e Espinhos).

@export var amount: int = 6
@export var hits: int = 1
## Dano extra por carta já jogada neste turno (antes desta).
@export var bonus_per_card_played: int = 0
## Dano penetrante: ignora a Armadura e vai direto na vida.
@export var pierce: bool = false
## Dano extra por carta no descarte / por carta banida neste combate (no momento em que é jogada).
@export var bonus_per_discard: int = 0
@export var bonus_per_exhausted: int = 0
## Limite do bônus das pilhas (descarte + banidas). 0 = sem limite.
@export var pile_bonus_cap: int = 0


func get_base_amount(ctx: EffectContext) -> int:
	var base := amount
	if bonus_per_card_played != 0 and ctx != null:
		base += bonus_per_card_played * ctx.combat.cards_played_this_turn
	if ctx != null and ctx.combat != null:
		var pile_bonus := bonus_per_discard * ctx.combat.discard_pile.size() + bonus_per_exhausted * ctx.combat.exhaust_pile.size()
		if pile_bonus_cap > 0:
			pile_bonus = mini(pile_bonus, pile_bonus_cap)
		base += pile_bonus
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
	if bonus_per_discard != 0:
		text += ", +%d para cada carta no %s" % [bonus_per_discard, kw("descarte", Palette.BONE_LIGHT)]
	if bonus_per_exhausted != 0:
		text += ", +%d para cada carta %s neste combate" % [bonus_per_exhausted, kw("banida", Palette.VIOLET_BRIGHT)]
	if pile_bonus_cap > 0 and (bonus_per_discard != 0 or bonus_per_exhausted != 0):
		text += " (máx. +%d)" % pile_bonus_cap
	return text + "."


func upgrade() -> bool:
	if bonus_per_card_played > 0:
		bonus_per_card_played += 1
	if bonus_per_discard > 0 or bonus_per_exhausted > 0:
		if bonus_per_discard > 0:
			bonus_per_discard += 1
		if bonus_per_exhausted > 0:
			bonus_per_exhausted += 1
		if pile_bonus_cap > 0:
			pile_bonus_cap += 2
		return true
	amount += 1 if hits > 1 else maxi(3, amount / 3)
	return true
