extends Control
## Acampamento: descansar (cura), aprimorar uma carta ou estudar restos (escolher 1 de 3 materiais).

const EventScreen := preload("res://scripts/ui/screens/event_screen.gd")
const HEAL_FRACTION := 0.3

## Os 3 materiais sorteados ficam fixos nesta visita (voltar e abrir de novo não sorteia outros).
var _study_picks: Array[AnatomyPart] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if not RunState.active:
		RunState.start(Database.expeditions.get(Database.DEFAULT_EXPEDITION))
	var bg := UiTheme.add_background(self, Color("#24231F"), "camp", 0.3) as BackgroundView
	bg.glow_color = Palette.BONE
	bg.glow_center = Vector2(0.5, 0.62)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)

	var t := UiTheme.make_label("Acampamento", 44, Palette.BONE_LIGHT, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var s := UiTheme.make_label("Uma fogueira baixa, longe das trilhas. Vida: %d / %d" % [RunState.hp, RunState.max_hp], 17, Palette.TEXT_DIM)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(s)

	# fogueira: assets/art/camp/campfire.png (sem arquivo, o círculo desenhado em código)
	var fire_art := Database.get_art("camp", &"campfire")
	if fire_art != null:
		var fr := _art_rect(fire_art, 150)
		fr.custom_minimum_size = Vector2(270, 230)
		box.add_child(fr)
	else:
		var fire := IconView.create(&"energy", Palette.BONE, 90)
		fire.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(fire)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	var heal := int(ceil(RunState.max_hp * HEAL_FRACTION))
	row.add_child(_option(&"rest", "Descansar", "Recupere %d de vida." % heal, _rest.bind(heal), RunState.hp < RunState.max_hp))
	row.add_child(_option(&"upgrade", "Aprimorar", "Melhore permanentemente uma carta do baralho desta expedição.",
		_upgrade, not RunState.get_upgradable_cards().is_empty()))
	row.add_child(_option(&"study", "Estudar restos", "Escolha 1 entre 3 materiais de partes que você já conhece.", _study, not _study_pool().is_empty()))


## Opção do acampamento; o ícone vem de assets/art/camp/<art_id>.png, se existir.
func _option(art_id: StringName, title: String, desc: String, cb: Callable, enabled: bool) -> Control:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(250, 160)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var art := Database.get_art("camp", art_id)
	if art == null and art_id == &"study":
		art = Database.get_art("ui", &"nav_book") # até ter um ícone próprio (assets/art/camp/study.png)
	if art != null:
		var r := _art_rect(art, 96)
		if not enabled:
			r.modulate = Color(0.55, 0.55, 0.55, 0.8)
		v.add_child(r)
	v.add_child(UiTheme.make_label(title, 26, Palette.BONE_LIGHT, true))
	var d := UiTheme.make_label(desc, 15, Palette.PAPER)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(d)
	var b := UiTheme.make_button(title, cb)
	b.disabled = not enabled
	b.custom_minimum_size.y = 50
	v.add_child(b)
	return p


func _rest(amount: int) -> void:
	RunState.change_hp(amount)
	Sfx.play(&"heal")
	Game.goto("map")


func _upgrade() -> void:
	EventScreen.open_upgrade_picker(self, func(): Game.goto("map"))


## Materiais possíveis para estudar: partes já conhecidas; se forem menos de 3, completa com as das criaturas desta região.
func _study_pool() -> Array[AnatomyPart]:
	var pool: Array[AnatomyPart] = []
	for p: AnatomyPart in Database.parts.values():
		if Profile.is_part_known(p.id):
			pool.append(p)
	if pool.size() < 3 and RunState.expedition != null:
		for enc in RunState.expedition.encounters:
			for m: MonsterData in enc.monsters:
				for p in m.parts:
					if not pool.has(p):
						pool.append(p)
	return pool


## Estudar restos: 3 materiais sorteados, o jogador leva 1 (entra nos materiais da expedição).
func _study() -> void:
	if _study_picks.is_empty():
		var pool := _study_pool()
		while _study_picks.size() < 3 and not pool.is_empty():
			_study_picks.append(pool.pop_at(RunState.rng.randi_range(0, pool.size() - 1)))
	var picks := _study_picks

	var o := Control.new()
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.mouse_filter = Control.MOUSE_FILTER_STOP
	o.z_index = 200
	add_child(o)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.03, 0.04, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	var t := UiTheme.make_label("Estudar restos", 34, Palette.BONE_LIGHT, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var sub := UiTheme.make_label("Escolha um material para levar ao laboratório.", 16, Palette.TEXT_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	for p in picks:
		row.add_child(_study_card(p))
	var cancel := UiTheme.make_button("Voltar", o.queue_free, 200)
	cancel.custom_minimum_size.y = 50
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(cancel)


func _study_card(p: AnatomyPart) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(240, 0)
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style(Palette.CHARCOAL, Family.get_color(p.family), 2, 8, 14))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	panel.add_child(v)
	var art := MotifArt.new()
	art.custom_minimum_size = Vector2(0, 130)
	art.setup(p.art_motif, Family.get_color(p.family), p.icon)
	v.add_child(art)
	var name_l := UiTheme.make_label(p.display_name, 22, Family.get_color(p.family), true)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(name_l)
	var owner := Database.get_part_owner(p.id)
	var from := UiTheme.make_label(owner.display_name if owner else "", 14, Palette.TEXT_DIM)
	from.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(from)
	var have := Profile.get_material(p.id) + int(RunState.gathered.get(p.id, 0))
	var have_l := UiTheme.make_label("Você tem: %d" % have, 15, Palette.PAPER)
	have_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(have_l)
	var b := UiTheme.make_button("Levar", func():
		RunState.gathered[p.id] = int(RunState.gathered.get(p.id, 0)) + 1
		Sfx.play(&"unlock")
		Game.goto("map"), 0, "MossButton")
	b.custom_minimum_size.y = 50
	v.add_child(b)
	return panel


static func _art_rect(tex: Texture2D, px: int) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(px, px)
	r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
