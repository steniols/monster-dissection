extends SceneTree
## Recorta figuras de uma folha (fundo já transparente) usando caixas marcadas à mão.
## Mantém, dentro de cada caixa, só as partes (componentes de alpha) cujo centro cai dentro dela,
## então pedaços das vizinhas são descartados e respingos da própria figura são mantidos.
## Uso:
##   Godot_console.exe --headless -s res://tools/crop_items.gd -- <folha.png> <pasta_saida> <aspecto> id:x,y,w,h ...
## Termine o id com "!" para manter tudo o que está na caixa (quando duas figuras se encostam).

const CELL := 3


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var out_dir: String = a[1]
	var aspect := float(a[2])
	var w := img.get_width()
	var h := img.get_height()
	var gw := w / CELL + 1
	var gh := h / CELL + 1
	var occ := PackedByteArray()
	occ.resize(gw * gh)
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.3:
				occ[(y / CELL) * gw + x / CELL] = 1
	var label := PackedInt32Array()
	label.resize(gw * gh)
	var centers := {}
	var next := 1
	for i in gw * gh:
		if occ[i] == 0 or label[i] != 0:
			continue
		var stack := [i]
		label[i] = next
		var r := Rect2i(i % gw, i / gw, 1, 1)
		while not stack.is_empty():
			var k: int = stack.pop_back()
			var x := k % gw
			var y := k / gw
			r = r.expand(Vector2i(x + 1, y + 1)).expand(Vector2i(x, y))
			for d in [1, -1, gw, -gw]:
				var j: int = k + d
				if j < 0 or j >= gw * gh or occ[j] == 0 or label[j] != 0:
					continue
				label[j] = next
				stack.append(j)
		centers[next] = Vector2(r.get_center()) * CELL
		next += 1
	DirAccess.make_dir_recursive_absolute(out_dir)
	for spec in a.slice(3):
		var parts: PackedStringArray = spec.split(":")
		var keep_all := parts[0].ends_with("!")
		parts[0] = parts[0].trim_suffix("!")
		var n := parts[1].split(",")
		var box := Rect2i(int(n[0]), int(n[1]), int(n[2]), int(n[3]))
		var piece := Image.create(box.size.x, box.size.y, false, Image.FORMAT_RGBA8)
		var x0 := box.size.x
		var y0 := box.size.y
		var x1 := 0
		var y1 := 0
		for y in range(box.position.y, mini(h, box.end.y)):
			for x in range(box.position.x, mini(w, box.end.x)):
				var c := img.get_pixel(x, y)
				if c.a <= 0.02:
					continue
				var l := label[(y / CELL) * gw + x / CELL]
				if not keep_all and l != 0 and not Rect2(box).has_point(centers[l]):
					continue
				piece.set_pixel(x - box.position.x, y - box.position.y, c)
				x0 = mini(x0, x - box.position.x)
				y0 = mini(y0, y - box.position.y)
				x1 = maxi(x1, x - box.position.x)
				y1 = maxi(y1, y - box.position.y)
		var cw := x1 - x0 + 1
		var ch := y1 - y0 + 1
		var canvas_w := int(ceil(maxf(cw * 1.1, ch * 1.12 * aspect)))
		var canvas_h := int(round(canvas_w / aspect))
		var canvas := Image.create(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		canvas.blit_rect(piece, Rect2i(x0, y0, cw, ch), Vector2i((canvas_w - cw) / 2, (canvas_h - ch) / 2))
		canvas.save_png(out_dir.path_join(parts[0] + ".png"))
		print("%s: %dx%d" % [parts[0], cw, ch])
	quit()
