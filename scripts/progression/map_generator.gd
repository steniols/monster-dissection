class_name MapGenerator
extends RefCounted
## Gera um mapa ramificado em andares. O último andar é o chefe; o penúltimo, descanso.

const ELITE_MIN_FLOOR := 3


static func generate(expedition: ExpeditionData, rng: RandomNumberGenerator) -> Array:
	var floors: Array = []
	var count := expedition.floors
	for f in count:
		var row: Array[MapNode] = []
		var width := 1
		if f == count - 1:
			width = 1
		elif f == 0:
			width = 3
		elif f == count - 2:
			width = 2
		else:
			width = rng.randi_range(2, 4)
		for i in width:
			var n := MapNode.new()
			n.floor_index = f
			n.index = i
			n.type = _pick_type(f, count, rng)
			n.position = Vector2((i + 1.0) / (width + 1.0), 1.0 - float(f) / float(count - 1))
			n.position.x += rng.randf_range(-0.04, 0.04)
			_assign_monsters(n, expedition, f, rng)
			row.append(n)
		floors.append(row)
	_link(floors, rng)
	return floors


static func _pick_type(f: int, count: int, rng: RandomNumberGenerator) -> MapNode.Type:
	if f == count - 1:
		return MapNode.Type.BOSS
	if f == count - 2:
		return MapNode.Type.REST
	if f == 0:
		return MapNode.Type.COMBAT
	var roll := rng.randf()
	if f == 1:
		return MapNode.Type.EVENT if roll < 0.3 else MapNode.Type.COMBAT
	if f >= ELITE_MIN_FLOOR and roll < 0.2:
		return MapNode.Type.ELITE
	if roll < 0.36:
		return MapNode.Type.REST
	if roll < 0.56:
		return MapNode.Type.EVENT
	return MapNode.Type.COMBAT


static func _assign_monsters(n: MapNode, expd: ExpeditionData, f: int, rng: RandomNumberGenerator) -> void:
	match n.type:
		MapNode.Type.COMBAT:
			var enc := _pick_encounter(expd, f, rng)
			if enc != null:
				n.monsters.assign(enc.monsters)
		MapNode.Type.EVENT:
			if expd.events.is_empty():
				n.type = MapNode.Type.COMBAT
				_assign_monsters(n, expd, f, rng)
			else:
				n.event = expd.events[rng.randi_range(0, expd.events.size() - 1)]
		MapNode.Type.ELITE:
			if not expd.elite_pool.is_empty():
				n.monsters.append(expd.elite_pool[rng.randi_range(0, expd.elite_pool.size() - 1)])
		MapNode.Type.BOSS:
			if expd.boss != null:
				n.monsters.append(expd.boss)


static func _pick_encounter(expd: ExpeditionData, f: int, rng: RandomNumberGenerator) -> EncounterData:
	var pool: Array[EncounterData] = []
	var total := 0
	for e in expd.encounters:
		if e.min_floor <= f:
			pool.append(e)
			total += maxi(1, e.weight)
	if pool.is_empty():
		return null
	var roll := rng.randi_range(1, total)
	for e in pool:
		roll -= maxi(1, e.weight)
		if roll <= 0:
			return e
	return pool.back()


## Liga cada nó a 1–2 nós do andar seguinte, garantindo que todos sejam alcançáveis.
static func _link(floors: Array, rng: RandomNumberGenerator) -> void:
	for f in floors.size() - 1:
		var cur: Array = floors[f]
		var nxt: Array = floors[f + 1]
		var has_incoming := {}
		for n: MapNode in cur:
			var t := n.position.x
			var nearest := 0
			var best := INF
			for j in nxt.size():
				var d := absf(nxt[j].position.x - t)
				if d < best:
					best = d
					nearest = j
			n.links.append(nearest)
			has_incoming[nearest] = true
			if nxt.size() > 1 and rng.randf() < 0.45:
				var alt := clampi(nearest + (1 if rng.randf() < 0.5 else -1), 0, nxt.size() - 1)
				if not n.links.has(alt):
					n.links.append(alt)
					has_incoming[alt] = true
		for j in nxt.size():
			if not has_incoming.has(j):
				var best_n: MapNode = cur[0]
				for n: MapNode in cur:
					if absf(n.position.x - nxt[j].position.x) < absf(best_n.position.x - nxt[j].position.x):
						best_n = n
				best_n.links.append(j)
