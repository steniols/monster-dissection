extends SceneTree
## Balanceamento 2 (pedidos do teste no celular). Edita os .tres em data/.
## Uso: Godot_console.exe --headless --path . --script res://tools/balance_v2.gd
## Pode rodar de novo. Rode depois do balance_v1.gd.

const BF := Family.Id.BLOODFANG


func _init() -> void:
	# Investida da Matilha: custo 1, +2 por carta jogada
	var pack: CardData = load("res://data/cards/pack_lunge.tres")
	pack.cost = 1
	var d := DamageEffect.new()
	d.amount = 6
	d.bonus_per_card_played = 2
	pack.effects.assign([d])
	_save(pack)

	# Glândula Ácida: sem Fraqueza
	var acid: CardData = load("res://data/cards/acid_gland.tres")
	var dmg6 := DamageEffect.new()
	dmg6.amount = 6
	acid.effects.assign([RemoveBlockEffect.new(), dmg6])
	_save(acid)

	# Anotações de Campo+: custa 0 (continua comprando 2)
	var notes: CardData = load("res://data/cards/field_notes.tres")
	notes.upgrade_cost = 0
	_save(notes)

	# Olhos do Vazio: 2 de Corrupção
	var eyes: CardData = load("res://data/cards/void_eyes.tres")
	var corr := ApplyStatusEffect.new()
	corr.status_id = &"corruption"
	corr.stacks = 2
	var dr := DrawEffect.new()
	dr.count = 1
	eyes.effects.assign([corr, dr])
	_save(eyes)

	# Carta nova: Lambida Coagulante (Filhote de Bloodfang, parte nova "Língua Áspera")
	var c := CardData.new()
	c.id = &"clotting_lick"
	c.display_name = "Lambida Coagulante"
	c.cost = 1
	c.card_type = CardData.CardType.SKILL
	c.rarity = CardData.Rarity.UNCOMMON
	c.family = BF
	c.source_part = "Língua Áspera"
	c.art_motif = &"blood"
	var bleed := ApplyStatusEffect.new()
	bleed.status_id = &"bleed"
	bleed.stacks = 3
	var guard := BlockPerStatusEffect.new()
	guard.status_id = &"bleed"
	c.effects.assign([bleed, guard])
	c.flavor = "A saliva do filhote fecha as próprias feridas e abre as da presa."
	c.take_over_path("res://data/cards/clotting_lick.tres")
	_save(c)

	var p := AnatomyPart.new()
	p.id = &"bp_tongue"
	p.display_name = "Língua Áspera"
	p.family = BF
	p.region = AnatomyPart.Region.HEAD
	p.rarity = CardData.Rarity.UNCOMMON
	p.preserve_chance = 0.7
	p.unlocks_card = c
	p.art_motif = &"blood"
	p.description = "Coberta de farpas finas. A saliva coagula o sangue de quem lambe, e afina o de quem é lambido."
	p.take_over_path("res://data/organs/bp_tongue.tres")
	_save(p)

	var pup: MonsterData = load("res://data/monsters/bloodfang_pup.tres")
	var parts: Array[AnatomyPart] = []
	for old in pup.parts:
		if old.id != &"bp_tongue":
			parts.append(old)
	parts.append(p)
	pup.parts = parts
	_save(pup)

	print("Balanceamento 2 aplicado.")
	quit()


func _save(res: Resource) -> void:
	var err := ResourceSaver.save(res, res.resource_path)
	if err != OK:
		push_error("Falha ao salvar %s (%d)" % [res.resource_path, err])
