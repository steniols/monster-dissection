extends Node
## Lista todas as cartas (custo, tipo, raridade, família, texto). Uso: Godot_console --headless --path . res://tools/dump_cards.tscn
func _ready() -> void:
	var list := Database.get_sorted_cards()
	list.sort_custom(func(a, b): return a.cost < b.cost or (a.cost == b.cost and String(a.id) < String(b.id)))
	for c: CardData in list:
		var d := CardView._strip_bbcode(c.get_description())
		print("%d | %-18s | %-8s | %-10s | %-10s | %s" % [c.cost, c.id, c.get_type_name(), c.get_rarity_name(), Family.get_name_of(c.family), d])
	get_tree().quit()
