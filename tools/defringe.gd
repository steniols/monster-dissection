extends SceneTree
## Tira a borda clara (halo) que sobra do fundo liso em volta do contorno escuro, e apaga respingos soltos.
## A cada passada, pixels opacos encostados no transparente que sejam claros e sem cor viram transparentes.
## O miolo claro da figura (ex.: um manto branco) fica protegido pelo contorno escuro.
## Uso:
##   Godot_console.exe --headless -s res://tools/defringe.gd -- <entrada.png> <saida.png> [passadas=3] [lum_min=0.55] [sat_max=0.18] [respingo_max_px=60]

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var passes := int(a[2]) if a.size() > 2 else 3
	var lum_min := float(a[3]) if a.size() > 3 else 0.55
	var sat_max := float(a[4]) if a.size() > 4 else 0.18
	var speck_max := int(a[5]) if a.size() > 5 else 60
	var w := img.get_width()
	var h := img.get_height()
	var removed := 0
	for p in passes:
		var kill: Array[Vector2i] = []
		for y in h:
			for x in w:
				var c := img.get_pixel(x, y)
				if c.a < 0.02:
					continue
				if not _touches_clear(img, x, y, w, h):
					continue
				# semitransparente na borda, ou claro e sem cor: é halo
				if c.a < 0.6 or (c.get_luminance() >= lum_min and c.s <= sat_max):
					kill.append(Vector2i(x, y))
		for q in kill:
			img.set_pixel(q.x, q.y, Color(0, 0, 0, 0))
		removed += kill.size()
	var specks := _remove_specks(img, w, h, speck_max)
	img.save_png(a[1])
	print("OK: halo %d px, respingos %d px" % [removed, specks])
	quit()


func _touches_clear(img: Image, x: int, y: int, w: int, h: int) -> bool:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var q: Vector2i = Vector2i(x, y) + d
		if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h:
			return true
		if img.get_pixel(q.x, q.y).a < 0.02:
			return true
	return false


## Apaga grupos de pixels opacos pequenos e isolados (respingos e sobras de efeitos).
func _remove_specks(img: Image, w: int, h: int, max_px: int) -> int:
	var seen := PackedByteArray()
	seen.resize(w * h)
	var total := 0
	for y in h:
		for x in w:
			var i := y * w + x
			if seen[i] or img.get_pixel(x, y).a < 0.02:
				continue
			var region: Array[Vector2i] = []
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			seen[i] = 1
			while not stack.is_empty():
				var p: Vector2i = stack.pop_back()
				region.append(p)
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var q := Vector2i(p.x + dx, p.y + dy)
						if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h:
							continue
						var j := q.y * w + q.x
						if seen[j] or img.get_pixel(q.x, q.y).a < 0.02:
							continue
						seen[j] = 1
						stack.append(q)
			if region.size() <= max_px:
				for p in region:
					img.set_pixel(p.x, p.y, Color(0, 0, 0, 0))
				total += region.size()
	return total
