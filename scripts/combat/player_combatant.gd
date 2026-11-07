class_name PlayerCombatant
extends Combatant
## O caçador-pesquisador em combate.

signal energy_changed(energy: int, max_energy: int)

var energy: int = 0
var max_energy: int = 3


func _init(name_: String, hp_: int, max_hp_: int, max_energy_: int) -> void:
	display_name = name_
	max_hp = max_hp_
	hp = clampi(hp_, 1, max_hp_)
	max_energy = max_energy_
	is_player = true


func set_energy(value: int) -> void:
	energy = max(0, value)
	energy_changed.emit(energy, max_energy)
