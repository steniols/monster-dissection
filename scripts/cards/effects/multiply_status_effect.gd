class_name MultiplyStatusEffect
extends CardEffect
## Multiplica os acúmulos de um status (ex.: dobra a Brasa do alvo ou a própria Regeneração).

@export var status_id: StringName = &"ember"
@export var factor: int = 2
## Se maior que 0, o total depois de multiplicar não passa disso (o que já estava acima não diminui).
## O aprimoramento remove o limite.
@export var max_total: int = 0


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		var stacks := t.get_status(status_id)
		if stacks > 0:
			var total := stacks * factor
			if max_total > 0:
				total = maxi(stacks, mini(total, max_total))
			t.set_status(status_id, total)


func upgrade() -> bool:
	if max_total > 0:
		max_total = 0
		return true
	return false


func describe() -> String:
	var verb := "Dobre" if factor == 2 else "Multiplique por %d" % factor
	var cap := " (máx. %d)" % max_total if max_total > 0 else ""
	if target == Target.SELF:
		return "%s sua %s%s." % [verb, StatusLibrary.keyword(status_id), cap]
	return "%s a %s do alvo%s%s." % [verb, StatusLibrary.keyword(status_id), _target_suffix(), cap]
