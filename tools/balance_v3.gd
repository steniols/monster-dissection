extends SceneTree
## Balanceamento 3 (pedidos do teste no tablet). Edita os .tres em data/. Pode rodar de novo.
## Uso: Godot_console.exe --headless --path . --script res://tools/balance_v3.gd

const COMMON := CardData.Rarity.COMMON
const UNCOMMON := CardData.Rarity.UNCOMMON
const RARE := CardData.Rarity.RARE


func _init() -> void:
	_card(&"regenerative_flesh", -1, -1, func(c: CardData):
		for e in c.effects:
			if e is ApplyStatusEffect and e.status_id == &"regen":
				e.stacks = 3)
	_card(&"hb_hematic_tide", 2, UNCOMMON)
	_card(&"reactive_mandible", -1, UNCOMMON)
	_card(&"void_eyes", -1, UNCOMMON)
	_card(&"marrow_spark", -1, RARE)
	_card(&"moss_mantle", -1, RARE)
	_card(&"matrix_pulse", 2, -1)
	_card(&"muscle_memory", -1, -1, func(c: CardData):
		var r := ReturnFromDiscardEffect.new()
		r.count = 2
		r.energy_if_block = 1
		c.effects.assign([r]))

	# Pesquisador Ferido: as anotações deixam de dar a carta Anotações de Campo (removida)
	var ev: EventData = load("res://data/events/ev_wounded_researcher.tres")
	for ch in ev.choices:
		if ch.label == "Aceitar as anotações":
			var none: Array[CardData] = []
			ch.add_cards = none
			ch.remove_card = true
			ch.description = "Remova uma carta do baralho."
			ch.result_text = "As anotações mostram o que não funciona. Você deixa uma técnica para trás."
	ResourceSaver.save(ev, ev.resource_path)

	# Anotações de Campo e Bisturi Duplo saem do jogo
	for id in [&"field_notes", &"double_scalpel"]:
		var path := "res://data/cards/%s.tres" % id
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("Balanceamento 3 aplicado.")
	quit()


func _card(id: StringName, cost: int, rarity: int, edit: Callable = Callable()) -> void:
	var c: CardData = load("res://data/cards/%s.tres" % id)
	if cost >= 0:
		c.cost = cost
	if rarity >= 0:
		c.rarity = rarity
	if edit.is_valid():
		edit.call(c)
	ResourceSaver.save(c, c.resource_path)
