class_name EffectContext
extends RefCounted
## Tudo que um efeito precisa saber para se resolver.

var combat: CombatManager
var source: Combatant
var target: Combatant ## alvo escolhido (pode ser null)
var card: CardInstance ## null quando o efeito vem de um monstro/mutação
var killed_targets: Array[Combatant] = []


func _init(combat_: CombatManager, source_: Combatant, target_: Combatant, card_: CardInstance = null) -> void:
	combat = combat_
	source = source_
	target = target_
	card = card_
