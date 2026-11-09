class_name MultiplyStatusEffect
extends CardEffect
## Multiplica os acúmulos de um status (ex.: dobra a Brasa do alvo ou a própria Regeneração).

@export var status_id: StringName = &"ember"
@export var factor: int = 2


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		var stacks := t.get_status(status_id)
		if stacks > 0:
			t.set_status(status_id, stacks * factor)


func describe() -> String:
	var verb := "Dobre" if factor == 2 else "Multiplique por %d" % factor
	if target == Target.SELF:
		return "%s sua %s." % [verb, StatusLibrary.keyword(status_id)]
	return "%s a %s do alvo%s." % [verb, StatusLibrary.keyword(status_id), _target_suffix()]
