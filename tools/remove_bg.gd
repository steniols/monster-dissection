extends SceneTree
## Remove o fundo liso/borrado de uma folha de ícones com contorno escuro.
## O fundo é tudo que se alcança a partir da borda da imagem passando só por pixels "lisos"
## (pouca variação com os vizinhos) e não escuros. Contornos e texturas dos objetos param o preenchimento.
## Uso:
##   Godot_console.exe --headless -s res://tools/remove_bg.gd -- <entrada.png> <saida.png> [limiar_gradiente=0.05]

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var grad_max := float(a[2]) if a.size() > 2 else 0.05
	var w := img.get_width()
	var h := img.get_height()
	var lum := PackedFloat32Array()
	lum.resize(w * h)
	for y in h:
		for x in w:
			var c := img.get_pixel(x, y)
			lum[y * w + x] = c.r * 0.3 + c.g * 0.59 + c.b * 0.11
	var smooth := PackedByteArray()
	smooth.resize(w * h)
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			var i := y * w + x
			var l := lum[i]
			var g := maxf(maxf(absf(l - lum[i - 1]), absf(l - lum[i + 1])), maxf(absf(l - lum[i - w]), absf(l - lum[i + w])))
			if g < grad_max and l > 0.12:
				smooth[i] = 1
	for x in w:
		smooth[x] = 1
		smooth[(h - 1) * w + x] = 1
	for y in h:
		smooth[y * w] = 1
		smooth[y * w + w - 1] = 1
	var bg := PackedByteArray()
	bg.resize(w * h)
	var stack := PackedInt32Array()
	for x in w:
		stack.append(x)
		stack.append((h - 1) * w + x)
	for y in h:
		stack.append(y * w)
		stack.append(y * w + w - 1)
	while not stack.is_empty():
		var i: int = stack[stack.size() - 1]
		stack.resize(stack.size() - 1)
		if bg[i] == 1 or smooth[i] == 0:
			continue
		bg[i] = 1
		var x := i % w
		var y := i / w
		if x > 0: stack.append(i - 1)
		if x < w - 1: stack.append(i + 1)
		if y > 0: stack.append(i - w)
		if y < h - 1: stack.append(i + w)
	# alpha: fundo some; 1 px de transição suave na borda do objeto
	for y in h:
		for x in w:
			var i := y * w + x
			if bg[i] == 1:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif (x > 0 and bg[i - 1] == 1) or (x < w - 1 and bg[i + 1] == 1) or (y > 0 and bg[i - w] == 1) or (y < h - 1 and bg[i + w] == 1):
				var c := img.get_pixel(x, y)
				c.a = 0.6
				img.set_pixel(x, y, c)
	img.save_png(a[1])
	print("OK: ", a[1])
	quit()
