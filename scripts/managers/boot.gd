extends Node
## Cena inicial: apenas encaminha para o menu (autoloads já estão prontos aqui).


func _ready() -> void:
	Game.goto("menu")
