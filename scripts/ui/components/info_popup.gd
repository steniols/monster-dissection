class_name InfoPopup
extends Control
## Janela de explicação que funciona no toque: mostra o que uma carta, status ou intenção faz.
## Toque em qualquer lugar para fechar.

## Termos que não são status mas aparecem nas cartas.
const EXTRA_TERMS := {
	"Armadura": "Absorve dano de ataques. Some no início do seu próximo turno.",
	"dano penetrante": "Ignora a Armadura e vai direto na vida.",
	"Energia": "Usada para jogar cartas. Volta ao máximo no início de cada turno.",
	"Banir": "A carta sai do combate depois de jogada (volta no próximo combate).",
	"Permanente no combate": "O efeito dura até o fim do combate.",
}


## Abre a janela por cima da tela atual.
static func open(host: Node, title: String, body_bbcode: String) -> void:
	if host == null or not host.is_inside_tree():
		return
	var p := InfoPopup.new()
	p._build(title, body_bbcode)
	host.get_tree().current_scene.add_child(p)


## Explicação de uma carta: o texto dela e o que significa cada termo que aparece nele.
static func open_card(host: Node, card: CardData) -> void:
	var body := "%s\n[color=#8E877A]%s · %s · custo %d[/color]" % [card.get_description(), card.get_type_name(), card.get_rarity_name(), card.cost]
	var terms := explain(card.get_description())
	if not terms.is_empty():
		body += "\n\n" + terms
	open(host, card.display_name, body)


## Explicação de um status com a quantidade atual.
static func open_status(host: Node, id: StringName, stacks: int) -> void:
	var d := StatusLibrary.get_def(id)
	var col: Color = d["color"]
	open(host, "%s %d" % [d["name"], stacks], "[color=#%s]%s[/color]" % [col.to_html(false), String(d["description"]).replace("{x}", str(stacks))])


## Lista "Termo: o que faz" para cada status ou termo citado no texto.
static func explain(bbcode: String) -> String:
	var plain := CardView._strip_bbcode(bbcode)
	var lines: PackedStringArray = []
	for id in StatusLibrary.DEFS:
		var d: Dictionary = StatusLibrary.DEFS[id]
		if plain.contains(String(d["name"])):
			var col: Color = d["color"]
			lines.append("[color=#%s]%s[/color]: %s" % [col.to_html(false), d["name"], String(d["description"]).replace("{x}", "X")])
	for term in EXTRA_TERMS:
		if plain.contains(term):
			lines.append("[color=#%s]%s[/color]: %s" % [Palette.BONE_LIGHT.to_html(false), term, EXTRA_TERMS[term]])
	return "\n".join(lines)


func _build(title: String, body_bbcode: String) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 300
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.CHARCOAL_DEEP, Palette.BONE, 2, 10, 18))
	panel.custom_minimum_size = Vector2(520, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	var t := UiTheme.make_label(title, 26, Palette.BONE_LIGHT, true)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(t)
	var b := UiTheme.make_rich(body_bbcode, 18, Palette.PAPER)
	b.custom_minimum_size.x = 480
	box.add_child(b)
	var hint := UiTheme.make_label("Toque para fechar", 13, Palette.TEXT_DIM)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(hint)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		accept_event()
		queue_free()
