class_name CleanseEffect
extends CardEffect
## Remove todos os efeitos negativos de quem usa.


func _init() -> void:
	target = Target.SELF


func apply(ctx: EffectContext) -> void:
	for t in resolve_targets(ctx):
		for id in t.statuses.keys():
			if StatusLibrary.get_def(id).get("debuff", false):
				t.set_status(id, 0)


func describe() -> String:
	return "Remova seus efeitos negativos."
