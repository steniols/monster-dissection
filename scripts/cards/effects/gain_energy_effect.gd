class_name GainEnergyEffect
extends CardEffect
## Ganha energia neste turno.

@export var amount: int = 1


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	if ctx.source is PlayerCombatant:
		var p := ctx.source as PlayerCombatant
		p.set_energy(p.energy + amount)


func describe() -> String:
	return "Ganhe %d de %s." % [amount, kw("Energia", Palette.PETROL_BRIGHT)]
