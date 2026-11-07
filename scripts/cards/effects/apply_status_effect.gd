class_name ApplyStatusEffect
extends CardEffect
## Aplica (ou concede a si mesmo) acúmulos de um status de StatusLibrary.

@export var status_id: StringName = &"bleed"
@export var stacks: int = 1


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		t.add_status(status_id, stacks)


func describe() -> String:
	var key := StatusLibrary.keyword(status_id)
	if target == Target.SELF:
		return "Ganhe %d de %s." % [stacks, key]
	return "Aplique %d de %s%s." % [stacks, key, _target_suffix()]
