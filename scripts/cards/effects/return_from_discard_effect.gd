class_name ReturnFromDiscardEffect
extends CardEffect
## Devolve cartas do descarte para a mão. Com `choose`, o jogador escolhe quais (a tela de combate abre o
## descarte); sem tela (testes) ou sem `choose`, são aleatórias.

@export var count: int = 1
## O jogador escolhe as cartas em vez de virem aleatórias.
@export var choose: bool = false
## Energia ganha se alguma das cartas devolvidas der Armadura (0 = sem bônus).
@export var energy_if_block: int = 0


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	if not ctx.source.is_player:
		return
	if choose and ctx.combat.discard_choice_requested.get_connections().size() > 0:
		ctx.combat.discard_choice_requested.emit(count, energy_if_block)
		return
	var returned := ctx.combat.return_from_discard(count)
	reward(ctx.combat, returned, energy_if_block)


## Dá a energia de bônus se alguma das cartas devolvidas der Armadura.
static func reward(combat: CombatManager, returned: Array, energy: int) -> void:
	if energy <= 0:
		return
	for c: CardInstance in returned:
		if _gives_block(c.data):
			combat.player.set_energy(combat.player.energy + energy)
			return


static func _gives_block(card: CardData) -> bool:
	for e in card.effects:
		if e is BlockEffect:
			return true
	return false


func describe() -> String:
	var plural := "s" if count > 1 else ""
	var text: String
	if choose:
		text = "Escolha %s%d carta%s do %s e coloque na mão." % ["até " if count > 1 else "", count, plural, kw("descarte", Palette.BONE_LIGHT)]
	else:
		text = "Devolva %d carta%s aleatória%s do %s para a mão." % [count, plural, plural, kw("descarte", Palette.BONE_LIGHT)]
	if energy_if_block > 0:
		text += " Se alguma der %s, ganhe %d de %s." % [kw("Armadura", Palette.PETROL_BRIGHT), energy_if_block, kw("Energia", Palette.PETROL_BRIGHT)]
	return text


func upgrade() -> bool:
	count += 1
	return true
