class_name CardEffect
extends Resource
## Bloco básico de comportamento. Cartas, intenções de monstros e mutações
## são listas de CardEffect — nenhuma carta tem lógica própria.
##
## Para criar um efeito novo: estenda esta classe, sobrescreva apply() e describe().

enum Target {
	TARGET, ## o alvo escolhido (ou o primeiro oponente vivo)
	SELF, ## quem usa
	ALL_OPPONENTS, ## todos os oponentes vivos
}

@export var target: Target = Target.TARGET


func apply(_ctx: EffectContext) -> void:
	pass


## Texto em BBCode para a descrição da carta/intenção.
func describe() -> String:
	return ""


## Melhora este efeito (chamado numa cópia, ao aprimorar a carta).
## Retorna false se o efeito não tem o que melhorar.
func upgrade() -> bool:
	return false


## Cópia profunda (sobrescreva se o efeito contém outros efeitos).
func clone() -> CardEffect:
	return duplicate() as CardEffect


func targets_enemy() -> bool:
	return target == Target.TARGET


func resolve_targets(ctx: EffectContext) -> Array[Combatant]:
	var result: Array[Combatant] = []
	match target:
		Target.SELF:
			if ctx.source.is_alive():
				result.append(ctx.source)
		Target.TARGET:
			if ctx.target != null and ctx.target.is_alive():
				result.append(ctx.target)
			else:
				var opponents := ctx.combat.get_living_opponents(ctx.source)
				if not opponents.is_empty():
					result.append(opponents[0])
		Target.ALL_OPPONENTS:
			result.append_array(ctx.combat.get_living_opponents(ctx.source))
	return result


static func kw(text: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(false), text]


func _target_suffix() -> String:
	return " a todos os inimigos" if target == Target.ALL_OPPONENTS else ""
