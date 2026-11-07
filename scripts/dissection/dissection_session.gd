class_name DissectionSession
extends RefCounted
## Regras de uma dissecação: incisões limitadas, chance por condição, resultado por parte.

signal part_resolved(part: AnatomyPart, success: bool)

var monster: MonsterData
var condition: BodyCondition
var incisions_left: int
var results: Dictionary = {} # part id -> bool
var collected: Array[AnatomyPart] = []
var rng := RandomNumberGenerator.new()


func _init(monster_: MonsterData, condition_: BodyCondition, incisions: int) -> void:
	monster = monster_
	condition = condition_
	incisions_left = incisions
	rng.randomize()


func can_attempt(part: AnatomyPart) -> bool:
	return incisions_left > 0 and not results.has(part.id) and condition.chance_for(part) > 0.0


func attempt(part: AnatomyPart) -> bool:
	if not can_attempt(part):
		return false
	incisions_left -= 1
	var success := rng.randf() < condition.chance_for(part)
	results[part.id] = success
	if success:
		collected.append(part)
	part_resolved.emit(part, success)
	return success


func is_finished() -> bool:
	if incisions_left <= 0:
		return true
	for p in monster.parts:
		if can_attempt(p):
			return false
	return true
