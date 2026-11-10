class_name BlockPerStatusEffect
extends CardEffect
## Quem usa ganha Armadura igual aos acúmulos de um status no alvo (ex.: 1 por Sangramento).

@export var status_id: StringName = &"bleed"
@export var per_stack: int = 1


func apply(ctx: EffectContext) -> void:
	var total := 0
	for t in resolve_targets(ctx):
		total += t.get_status(status_id) * per_stack
	if total > 0:
		ctx.source.add_block(total)


func describe() -> String:
	return "Ganhe %d de %s para cada %s do alvo." % [per_stack, kw("Armadura", Palette.PETROL_BRIGHT), StatusLibrary.keyword(status_id)]


## O aprimoramento vem do Sangramento extra que a carta aplica.
func upgrade() -> bool:
	return false
