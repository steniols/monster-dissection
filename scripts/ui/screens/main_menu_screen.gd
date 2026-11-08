extends Control
## Menu inicial.


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := UiTheme.add_background(self, Palette.CHARCOAL, "menu", 0.2) as BackgroundView
	bg.glow_color = Palette.VIOLET
	bg.glow_center = Vector2(0.72, 0.5)

	var art := MonsterArt.new()
	art.setup(Database.get_monster(&"void_matriarch") if Database.get_monster(&"void_matriarch") else Database.get_sorted_monsters()[0])
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.anchor_left = 0.45
	art.offset_top = 60
	art.offset_bottom = -40
	# arte nítida e opaca (antes ficava translúcida, parecendo borrada)
	art.modulate = Color(0.92, 0.9, 0.95, 1.0)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	box.offset_left = 70
	box.offset_right = 700
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var logo_tex := Database.get_art("ui", &"logo")
	if logo_tex != null:
		var logo := TextureRect.new()
		logo.texture = logo_tex
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.custom_minimum_size = Vector2(600, 305)
		logo.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		box.add_child(logo)
	else:
		var t1 := UiTheme.make_label("MONSTER", 64, Palette.PAPER, true)
		var t2 := UiTheme.make_label("DISSECTION", 64, Palette.BLOOD_BRIGHT, true)
		t2.add_theme_constant_override("line_spacing", -10)
		box.add_child(t1)
		box.add_child(t2)
	var sub := UiTheme.make_label("Cada criatura derrotada pode transformar seu baralho —\ne seu próprio corpo.", 18, Palette.TEXT_DIM)
	box.add_child(sub)
	var gap := Control.new()
	gap.custom_minimum_size.y = 24
	box.add_child(gap)

	if RunState.has_save():
		var cont := UiTheme.make_button("Continuar expedição", Game.continue_expedition, 300)
		cont.custom_minimum_size.y = 50
		cont.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		box.add_child(cont)
	var enter := UiTheme.make_button("Entrar no laboratório", func(): Game.goto("lab"), 300)
	enter.custom_minimum_size.y = 50
	enter.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(enter)
	var opts := UiTheme.make_button("Opções", func(): Game.open_options("menu"), 300)
	opts.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(opts)
	var reset := UiTheme.make_button("Apagar progresso", _confirm_reset, 300)
	reset.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(reset)
	var quit := UiTheme.make_button("Sair", func(): get_tree().quit(), 300)
	quit.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(quit)
	enter.grab_focus()

	var ver := UiTheme.make_label("Protótipo 0.2 · %d expedições · %d vitórias" % [Profile.runs_started, Profile.runs_won], 13, Palette.TEXT_DIM)
	ver.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	ver.offset_left = 16
	ver.offset_top = -30
	add_child(ver)


func _confirm_reset() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Apagar progresso"
	d.dialog_text = "Isso apaga cartas desbloqueadas, materiais, mutações e bestiário.\nNão pode ser desfeito."
	d.ok_button_text = "Apagar"
	d.cancel_button_text = "Cancelar"
	d.confirmed.connect(func():
		Profile.reset()
		RunState.delete_save()
		get_tree().reload_current_scene())
	add_child(d)
	d.popup_centered()
