extends SceneTree
## Balanceamento 4: descarte e banidas ganham uso (escolher do descarte, dano que escala com as pilhas).
## Rodar depois de balance_v1, v2 e v3. Pode rodar de novo.
## Uso: Godot_console.exe --headless --path . --script res://tools/balance_v4.gd


func _init() -> void:
	# Rede Micélica: custo 2
	_card(&"mycelial_web", func(c: CardData): c.cost = 2)
	# Memória Muscular e Oráculo Necrótico: o jogador escolhe as cartas do descarte
	_card(&"muscle_memory", func(c: CardData):
		for e in c.effects:
			if e is ReturnFromDiscardEffect:
				e.choose = true)
	_card(&"hb_necro_oracle", func(c: CardData):
		for e in c.effects:
			if e is ReturnFromDiscardEffect:
				e.choose = true)
	# Bile Necrótica (Rotwalker): dano cresce com o descarte
	_card(&"necrotic_bile", func(c: CardData):
		var d := DamageEffect.new()
		d.amount = 3
		d.bonus_per_discard = 1
		var w := ApplyStatusEffect.new()
		w.status_id = &"weak"
		w.stacks = 1
		c.effects.assign([d, w]))
	# Toque Corruptor (Voidspawn): dano cresce com as cartas banidas
	_card(&"corrupting_touch", func(c: CardData):
		for e in c.effects:
			if e is DamageEffect:
				e.amount = 4
				e.bonus_per_exhausted = 3)
	print("Balanceamento 4 aplicado.")
	quit()


func _card(id: StringName, edit: Callable) -> void:
	var c: CardData = load("res://data/cards/%s.tres" % id)
	edit.call(c)
	ResourceSaver.save(c, c.resource_path)
