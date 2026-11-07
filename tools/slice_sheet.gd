extends SceneTree
## Recorta uma folha de figuras (fundo transparente) em arquivos individuais.
## As figuras são achadas por componentes conexos de alpha e ordenadas em linhas (cima→baixo, esq→dir).
## Uso:
##   Godot_console.exe --headless -s res://tools/slice_sheet.gd -- <folha.png> <pasta_saida> <aspecto> <id1,id2,...>
## [celula=6]: use 3 quando as figuras estão muito próximas. [dilatar=0]: junta respingos à figura (ex.: 4).
## aspecto: 1.0 (partes), 1.7778 (cartas), 1.3333 (monstros; base alinhada embaixo).
## Imprime as caixas encontradas; se a contagem não bater com os ids, nada é salvo.

var CELL := 6
var MIN_CELLS := 40


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() < 4:
		push_error("uso: <folha.png> <pasta_saida> <aspecto> <ids separados por vírgula>")
		quit(1)
		return
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var out_dir: String = a[1]
	var aspect := float(a[2])
	var ids := a[3].split(",", false)
	if a.size() > 4:
		CELL = int(a[4]) # células menores separam figuras muito próximas
		MIN_CELLS = 1440 / (CELL * CELL)
	var w := img.get_width()
	var h := img.get_height()
	var gw := w / CELL + 1
	var gh := h / CELL + 1

	var occ := PackedByteArray()
	occ.resize(gw * gh)
	for gy in h / CELL:
		for gx in w / CELL:
			for yy in range(0, CELL, 2):
				for xx in range(0, CELL, 2):
					if img.get_pixel(gx * CELL + xx, gy * CELL + yy).a > 0.5:
						occ[gy * gw + gx] = 1
	# [dilatar=0]: junta fragmentos soltos (respingos, riscos) à figura mais próxima
	var dilate := int(a[5]) if a.size() > 5 else 0
	for _i in dilate:
		var grown := occ.duplicate()
		for gy in range(1, gh - 1):
			for gx in range(1, gw - 1):
				var k := gy * gw + gx
				if occ[k] == 0 and (occ[k - 1] == 1 or occ[k + 1] == 1 or occ[k - gw] == 1 or occ[k + gw] == 1):
					grown[k] = 1
		occ = grown

	var label := PackedInt32Array()
	label.resize(gw * gh)
	var boxes := {} # label -> Rect2i (em células)
	var sizes := {}
	var next := 1
	for i in gw * gh:
		if occ[i] == 0 or label[i] != 0:
			continue
		var stack := [i]
		label[i] = next
		var r := Rect2i(i % gw, i / gw, 1, 1)
		var n := 0
		while not stack.is_empty():
			var k: int = stack.pop_back()
			n += 1
			var x := k % gw
			var y := k / gw
			r = r.expand(Vector2i(x, y)).expand(Vector2i(x + 1, y + 1))
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					var nx: int = x + dx
					var ny: int = y + dy
					if nx < 0 or ny < 0 or nx >= gw or ny >= gh:
						continue
					var j := ny * gw + nx
					if occ[j] == 1 and label[j] == 0:
						label[j] = next
						stack.append(j)
		boxes[next] = r
		sizes[next] = n
		next += 1

	var found: Array = []
	for l in boxes:
		if sizes[l] >= MIN_CELLS:
			found.append(l)
	# ordena em linhas: agrupa por sobreposição vertical do centro
	found.sort_custom(func(p, q): return boxes[p].get_center().y < boxes[q].get_center().y)
	var rows: Array = []
	for l in found:
		var placed := false
		for row in rows:
			var b0: Rect2i = boxes[row[0]]
			var c: int = boxes[l].get_center().y
			if c >= b0.position.y and c <= b0.end.y:
				row.append(l)
				placed = true
				break
		if not placed:
			rows.append([l])
	var ordered: Array = []
	for row in rows:
		row.sort_custom(func(p, q): return boxes[p].position.x < boxes[q].position.x)
		ordered.append_array(row)

	for i in ordered.size():
		var b: Rect2i = boxes[ordered[i]]
		print("%2d: x=%d y=%d w=%d h=%d -> %s" % [i + 1, b.position.x * CELL, b.position.y * CELL, b.size.x * CELL, b.size.y * CELL, ids[i] if i < ids.size() else "?"])
	if ordered.size() != ids.size():
		push_error("encontradas %d figuras, mas %d ids. Nada salvo." % [ordered.size(), ids.size()])
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute(out_dir)
	for i in ordered.size():
		var lab: int = ordered[i]
		var cb: Rect2i = boxes[lab]
		var x0 := w
		var y0 := h
		var x1 := 0
		var y1 := 0
		var piece := Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in range(maxi(0, (cb.position.y - 1) * CELL), mini(h, (cb.end.y + 1) * CELL)):
			for x in range(maxi(0, (cb.position.x - 1) * CELL), mini(w, (cb.end.x + 1) * CELL)):
				var c := img.get_pixel(x, y)
				if c.a <= 0.02:
					continue
				var gx := x / CELL
				var gy := y / CELL
				var mine := false
				var other := false
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						var nx: int = gx + dx
						var ny: int = gy + dy
						if nx < 0 or ny < 0 or nx >= gw or ny >= gh:
							continue
						var l := label[ny * gw + nx]
						if l == lab:
							mine = true
						elif l != 0:
							other = true
				if mine and not (other and label[gy * gw + gx] != lab):
					piece.set_pixel(x, y, c)
					x0 = mini(x0, x)
					y0 = mini(y0, y)
					x1 = maxi(x1, x)
					y1 = maxi(y1, y)
		var cw := x1 - x0 + 1
		var ch := y1 - y0 + 1
		var canvas_w := int(ceil(maxf(cw * 1.1, ch * 1.12 * aspect)))
		var canvas_h := int(round(canvas_w / aspect))
		var canvas := Image.create(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		var px := (canvas_w - cw) / 2
		# monstros (4:3) ficam com a base perto do chão; o resto, centralizado
		var py := canvas_h - int(canvas_h * 0.05) - ch if absf(aspect - 4.0 / 3.0) < 0.01 else (canvas_h - ch) / 2
		canvas.blit_rect(piece, Rect2i(x0, y0, cw, ch), Vector2i(px, py))
		canvas.save_png(out_dir.path_join(ids[i] + ".png"))
	print("OK: %d arquivos em %s" % [ordered.size(), out_dir])
	quit()
