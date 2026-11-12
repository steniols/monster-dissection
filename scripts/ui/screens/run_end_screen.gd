extends Control
## Resumo da expedição (vitória ou derrota).

const LabScreen := preload("res://scripts/ui/screens/laboratory_screen.gd")


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var s: Dictionary = RunState.last_summary
	var won: bool = s.get("won", false)
	var bg := UiTheme.add_background(self, Palette.CHARCOAL, "menu", 0.6) as BackgroundView
	bg.glow_color = Palette.MOSS if won else Palette.BLOOD
	bg.glow_center = Vector2(0.5, 0.3)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size.x = 760
	center.add_child(box)

	var t := UiTheme.make_label("Expedição concluída" if won else "Expedição fracassada", 42, Palette.BONE_LIGHT if won else Palette.BLOOD_BRIGHT, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var sub := UiTheme.make_label("%s · Andar alcançado: %d · Criaturas abatidas: %d" % [s.get("expedition", ""), s.get("floor", 0), s.get("kills", 0)], 17, Palette.TEXT_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	for region in s.get("unlocked_regions", []):
		var u := UiTheme.make_label("Nova região liberada: %s" % region, 22, Palette.MOSS_BRIGHT, true)
		u.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(u)
	if int(s.get("ng_unlocked", -1)) > 0:
		var ng := int(s["ng_unlocked"])
		var nu := UiTheme.make_label("Nova dificuldade liberada: NG+%d" % ng, 22, Palette.BLOOD_BRIGHT, true)
		nu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(nu)
		var nd := UiTheme.make_label(RunState.ng_summary(ng), 15, Palette.TEXT_DIM)
		nd.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(nd)
	Sfx.play(&"unlock" if won else &"death")

	box.add_child(UiTheme.make_label("Materiais levados ao laboratório", 18, Palette.BONE, true))
	var kept := HFlowContainer.new()
	kept.add_theme_constant_override("h_separation", 8)
	box.add_child(kept)
	var kept_d: Dictionary = s.get("kept", {})
	if kept_d.is_empty():
		kept.add_child(UiTheme.make_label("Nenhum.", 15, Palette.TEXT_DIM))
	for id in kept_d:
		var part := Database.get_part(id)
		if part:
			kept.add_child(LabScreen.material_chip(part, kept_d[id]))
	var lost_d: Dictionary = s.get("lost", {})
	if not lost_d.is_empty():
		var n := 0
		for id in lost_d:
			n += int(lost_d[id])
		box.add_child(UiTheme.make_label("Perdidos no caminho: %d materiais." % n, 15, Palette.BLOOD_BRIGHT))

	var new_cards: Array = s.get("new_cards", [])
	if not new_cards.is_empty():
		box.add_child(UiTheme.make_label("Cartas catalogadas nesta expedição", 18, Palette.BONE, true))
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 10)
		box.add_child(row)
		for card in Database.cards_from_ids(new_cards):
			var v := CardView.create(card)
			v.interactive = false
			v.scale = Vector2(0.85, 0.85)
			row.add_child(v)

	var b := UiTheme.with_icon(UiTheme.make_button("Voltar ao laboratório", func(): Game.goto("lab"), 280), &"nav_lab")
	b.custom_minimum_size.y = 48
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(b)
	b.grab_focus()
