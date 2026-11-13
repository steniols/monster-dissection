extends SceneTree
## Balanceamento 5: monstros ganham Armadura com mais frequência.
## Cada intenção sem Armadura ganha uma pequena (~8% da vida, de 3 a 10), exceto o golpe mais forte de cada monstro.
## Rodar depois de balance_v1..v4. Não repete: intenções que já dão Armadura ficam como estão.
## Uso: Godot_console.exe --headless --path . --script res://tools/balance_v5.gd


func _init() -> void:
	for f in DirAccess.get_files_at("res://data/monsters"):
		if not f.ends_with(".tres"):
			continue
		var m: MonsterData = load("res://data/monsters/" + f)
		var amount := clampi(roundi(m.max_hp * 0.08), 3, 10)
		var strongest: MonsterIntent = null
		var best := -1
		for it in m.intents:
			var dmg := 0
			for e in it.effects:
				if e is DamageEffect:
					dmg += e.amount * e.hits
			if dmg > best:
				best = dmg
				strongest = it
		var changed := 0
		for it in m.intents:
			if it == strongest:
				continue
			var has_block := false
			for e in it.effects:
				if e is BlockEffect:
					has_block = true
			if has_block:
				continue
			var b := BlockEffect.new()
			b.amount = amount
			var list: Array[CardEffect] = []
			list.assign(it.effects)
			list.append(b)
			it.effects = list
			changed += 1
		ResourceSaver.save(m, m.resource_path)
		print("%-22s +%d de Armadura em %d intenções" % [m.id, amount, changed])
	print("Balanceamento 5 aplicado.")
	quit()
