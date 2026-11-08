extends Control
## Bancada de baralho: monta o baralho inicial a partir das cartas catalogadas.

var _collection: GridContainer
var _deck_list: VBoxContainer
var _count_label: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UiTheme.add_background(self, Color("#25231F"), "lab", 0.7)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_right = -24
	root.offset_top = 16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(titles)
	titles.add_child(UiTheme.make_label("Bancada de Baralho", 32, Palette.BONE_LIGHT, true))
	titles.add_child(UiTheme.make_label("Clique numa carta catalogada para adicioná-la; clique no baralho para remover. Máximo de %d cópias (%d para cartas básicas)." % [Profile.MAX_COPIES, Profile.MAX_COPIES_STARTER], 14, Palette.TEXT_DIM))
	top.add_child(UiTheme.make_button("Restaurar padrão", _reset_default))
	top.add_child(UiTheme.make_button("Voltar ao laboratório", _leave))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_collection = GridContainer.new()
	_collection.columns = 5
	_collection.add_theme_constant_override("h_separation", 12)
	_collection.add_theme_constant_override("v_separation", 12)
	scroll.add_child(UiTheme.padded(_collection))

	var side := PanelContainer.new()
	side.custom_minimum_size.x = 300
	body.add_child(side)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 6)
	side.add_child(sv)
	_count_label = UiTheme.make_label("", 18, Palette.BONE_LIGHT, true)
	sv.add_child(_count_label)
	var ds := ScrollContainer.new()
	ds.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ds.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sv.add_child(ds)
	_deck_list = VBoxContainer.new()
	_deck_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ds.add_child(_deck_list)

	_refresh()


func _refresh() -> void:
	for c in _collection.get_children():
		c.queue_free()
	for card in Database.get_sorted_cards():
		if not Profile.is_card_unlocked(card.id):
			continue
		var v := CardView.create(card)
		var count := Profile.starting_deck.count(card.id)
		v.set_note("%d/%d" % [count, Profile.max_copies(card)] if count > 0 else "")
		v.ready.connect(func(): v.playable = Profile.can_add_to_deck(card.id))
		v.pressed.connect(func(_v):
			if Profile.add_to_deck(card.id):
				_refresh())
		_collection.add_child(v)

	for c in _deck_list.get_children():
		c.queue_free()
	var counts := {}
	for id in Profile.starting_deck:
		counts[id] = counts.get(id, 0) + 1
	var cards := Database.cards_from_ids(counts.keys())
	cards.sort_custom(func(a: CardData, b: CardData) -> bool: return a.cost < b.cost or (a.cost == b.cost and a.display_name < b.display_name))
	for card in cards:
		var b := Button.new()
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text = "(%d)  %s  ×%d" % [card.cost, card.display_name, counts[card.id]]
		b.add_theme_font_size_override("font_size", 15)
		b.add_theme_color_override("font_color", Family.get_color(card.family) if card.family != Family.Id.NEUTRAL else Palette.PAPER)
		b.tooltip_text = CardView._strip_bbcode(card.get_description())
		b.pressed.connect(func():
			if Profile.remove_from_deck(card.id):
				_refresh())
		_deck_list.add_child(b)
	var n := Profile.starting_deck.size()
	_count_label.text = "Baralho inicial: %d cartas  (%d–%d)" % [n, Profile.DECK_MIN, Profile.DECK_MAX]


func _reset_default() -> void:
	Profile.starting_deck = Database.STARTER_DECK.duplicate()
	_refresh()


func _leave() -> void:
	Profile.save_profile()
	Game.goto("lab")
