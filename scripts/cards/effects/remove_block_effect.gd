class_name RemoveBlockEffect
extends CardEffect
## Remove toda a Armadura do alvo (quebra o escudo antes do golpe).


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		t.clear_block()


func describe() -> String:
	return "Remova toda a %s do alvo%s." % [kw("Armadura", Palette.PETROL_BRIGHT), _target_suffix()]
