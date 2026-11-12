class_name ReturnFromDiscardEffect
extends CardEffect
## Devolve cartas aleatórias do descarte para a mão (reutilizar cartas).

@export var count: int = 1
## Energia ganha se alguma das cartas devolvidas der Armadura (0 = sem bônus).
@export var energy_if_block: int = 0


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	if not ctx.source.is_player:
		return
	var returned := ctx.combat.return_from_discard(count)
	if energy_if_block <= 0:
		return
	for c in returned:
		if _gives_block(c.data):
			ctx.combat.player.set_energy(ctx.combat.player.energy + energy_if_block)
			return


static func _gives_block(card: CardData) -> bool:
	for e in card.effects:
		if e is BlockEffect:
			return true
	return false


func describe() -> String:
	var text := "Devolva %d carta%s aleatória%s do descarte para a mão." % [count, "s" if count > 1 else "", "s" if count > 1 else ""]
	if energy_if_block > 0:
		text += " Se alguma der %s, ganhe %d de %s." % [kw("Armadura", Palette.PETROL_BRIGHT), energy_if_block, kw("Energia", Palette.PETROL_BRIGHT)]
	return text


func upgrade() -> bool:
	count += 1
	return true
