class_name ConditionalEffect
extends CardEffect
## Executa sub-efeitos somente se a condição for satisfeita.
## Deve vir depois dos efeitos que causam dano (para TARGET_KILLED).

enum Condition {
	TARGET_KILLED, ## algum alvo morreu durante esta carta
	TARGET_HAS_STATUS, ## o alvo possui o status indicado
	SOURCE_HP_BELOW_HALF, ## quem usa está com menos da metade da vida
}

@export var condition: Condition = Condition.TARGET_KILLED
@export var status_id: StringName = &""
@export var effects: Array[CardEffect] = []


func apply(ctx: EffectContext) -> void:
	if _check(ctx):
		for e in effects:
			e.apply(ctx)


func _check(ctx: EffectContext) -> bool:
	match condition:
		Condition.TARGET_KILLED:
			return not ctx.killed_targets.is_empty()
		Condition.TARGET_HAS_STATUS:
			return ctx.target != null and ctx.target.get_status(status_id) > 0
		Condition.SOURCE_HP_BELOW_HALF:
			return ctx.source.hp * 2 < ctx.source.max_hp
	return false


func targets_enemy() -> bool:
	for e in effects:
		if e.targets_enemy():
			return true
	return condition == Condition.TARGET_HAS_STATUS


func describe() -> String:
	var parts: PackedStringArray = []
	for e in effects:
		parts.append(e.describe())
	var prefix := ""
	match condition:
		Condition.TARGET_KILLED:
			prefix = "Se matar o alvo: "
		Condition.TARGET_HAS_STATUS:
			prefix = "Se o alvo tiver %s: " % StatusLibrary.keyword(status_id)
		Condition.SOURCE_HP_BELOW_HALF:
			prefix = "Se estiver abaixo de 50% da vida: "
	return prefix + " ".join(parts)


func upgrade() -> bool:
	var improved := false
	for e in effects:
		improved = e.upgrade() or improved
	return improved


func clone() -> CardEffect:
	var c := duplicate() as ConditionalEffect
	var inner: Array[CardEffect] = []
	for e in effects:
		inner.append(e.clone())
	c.effects = inner
	return c
