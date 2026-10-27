extends Control
## Maqueta interactiva de P05. No usa catálogo, reglas ni transporte.

const Palette = preload("res://scripts/board/board_style.gd")
const Samples = preload("res://scripts/board/board_samples.gd")
const CardView = preload("res://scripts/board/board_card.gd")

var market_row: HBoxContainer
var hand_row: HBoxContainer
var played_row: HBoxContainer
var metals: Array[Button] = []
var hand_cards: Array[Dictionary] = []
var played_cards: Array[Dictionary] = []
var detail: PanelContainer
var overlay: Control
var detail_close: Button
var detail_action: Button
var detail_name: Label
var detail_description: Label
var detail_art: TextureRect
var detail_meta: Label
var detail_value: Label
var hand_count: Label
var feedback: Label
var _selected: Dictionary = {}
var _selected_source: String = ""
var _selected_view: CardView
var _return_focus: Control
var _main_column: VBoxContainer
var _played_hint: Label
var _large_hand: bool = false
var _saved_scale_size: Vector2i
var _saved_scale_mode: int


func _ready() -> void:
	_saved_scale_size = get_window().content_scale_size
	_saved_scale_mode = get_window().content_scale_mode
	# La mesa usa píxeles de interfaz reales y desplazamiento en ventanas pequeñas.
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().content_scale_size = Vector2i.ZERO
	theme = Palette.theme()
	_build()
	_main_column.resized.connect(_fit_cards)
	reset_preview()
	resized.connect(_fit_cards)
	_fit_cards.call_deferred()


func _build() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Palette.BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var outer: MarginContainer = MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		outer.add_theme_constant_override("margin_" + side, 22)
	add_child(outer)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "PageScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	outer.add_child(scroll)
	var page: VBoxContainer = _vbox(14)
	page.custom_minimum_size = Vector2(960, 0)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(page)
	_build_header(page)
	var line: HSeparator = HSeparator.new()
	line.modulate = Palette.LINE
	page.add_child(line)
	var body: HBoxContainer = _hbox(22)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	_build_sidebar(body)
	_main_column = _vbox(10)
	_main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_main_column)
	_build_table(_main_column)
	_build_modal()


func _build_header(parent: VBoxContainer) -> void:
	var header: HBoxContainer = _hbox(20)
	header.custom_minimum_size.y = 36
	parent.add_child(header)
	var brand: Label = _label("M I S T B O R N", 22, Palette.TEXT, true)
	brand.custom_minimum_size.x = 208
	header.add_child(brand)
	var mode_label: Label = _label("COMPETITIVO   /   4 JUGADORES", 12, Palette.MUTED)
	mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(mode_label)
	header.add_child(_badge("MAQUETA · DATOS DE MUESTRA", Palette.GOLD))
	var back: Button = _button("Volver", _on_back)
	back.name = "BackButton"
	header.add_child(back)


func _build_sidebar(parent: HBoxContainer) -> void:
	var sidebar: VBoxContainer = _vbox(14)
	sidebar.custom_minimum_size.x = 208
	parent.add_child(sidebar)
	var character: PanelContainer = _panel(Palette.SURFACE)
	sidebar.add_child(character)
	var info: VBoxContainer = _vbox(8)
	character.add_child(info)
	var identity: HBoxContainer = _hbox(12)
	info.add_child(identity)
	var portrait: TextureRect = _art(0, Vector2(54, 64))
	identity.add_child(portrait)
	var names: VBoxContainer = _vbox(3)
	identity.add_child(names)
	names.add_child(_label("Vin", 25, Palette.TEXT, true))
	names.add_child(_label("TÚ · PERSONAJE", 11, Palette.BLUE))
	names.add_child(_label("30 salud", 14, Palette.MUTED))
	info.add_child(_label("ENTRENAMIENTO", 10, Palette.MUTED))
	var progress: HBoxContainer = _hbox(4)
	info.add_child(progress)
	for index: int in 8:
		var step: ColorRect = ColorRect.new()
		step.custom_minimum_size = Vector2(17, 3)
		step.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		step.color = Palette.BLUE if index < 3 else Palette.LINE
		progress.add_child(step)
	sidebar.add_child(_label("EN LA MESA", 11, Palette.MUTED))
	var players: Array[Dictionary] = [
		{"name": "Kelsier", "health": "28", "mark": "K", "color": Palette.GOLD},
		{"name": "Shan", "health": "30", "mark": "S", "color": Color("b5a3ce")},
		{"name": "Marsh", "health": "26", "mark": "M", "color": Palette.GREEN}
	]
	for person: Dictionary in players:
		var row: HBoxContainer = _hbox(10)
		sidebar.add_child(row)
		row.add_child(_badge(person["mark"], person["color"]))
		var player_name: Label = _label(person["name"], 15)
		player_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(player_name)
		row.add_child(_label(person["health"], 14, Palette.MUTED))
	var separator: HSeparator = HSeparator.new()
	separator.modulate = Palette.LINE
	sidebar.add_child(separator)
	sidebar.add_child(_label("Misiones", 21, Palette.TEXT, true))
	var missions: Array[String] = ["Tras los muros", "Red de contactos", "La ciudad despierta"]
	for index: int in missions.size():
		var mission: PanelContainer = _panel(Palette.SURFACE, 10)
		sidebar.add_child(mission)
		var contents: VBoxContainer = _vbox(7)
		mission.add_child(contents)
		contents.add_child(_label(missions[index], 14, Palette.TEXT))
		var track: HBoxContainer = _hbox(7)
		contents.add_child(track)
		for position: int in 6:
			var marker: Label = _label("◆" if position == index + 1 else "·", 14, Palette.GOLD if position == index + 1 else Palette.MUTED)
			marker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			track.add_child(marker)
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar.add_child(spacer)
	var hint: Label = _label("Una mesa compartida.\nUna ciudad por cambiar.", 12, Palette.MUTED)
	sidebar.add_child(hint)


func _build_table(parent: VBoxContainer) -> void:
	var market_header: HBoxContainer = _section("Mercado", "6 cartas · pulsa para ampliar")
	parent.add_child(market_header)
	var market_scroll: ScrollContainer = _card_scroll(204)
	market_scroll.name = "MarketScroll"
	parent.add_child(market_scroll)
	market_row = _hbox(10)
	market_scroll.add_child(market_row)
	for sample: Dictionary in Samples.market():
		var view: CardView = _make_card(sample, "market", Vector2(134, 190))
		market_row.add_child(view)
	var play_area: PanelContainer = _panel(Color("141f29"), 10)
	play_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	play_area.custom_minimum_size.y = 84
	parent.add_child(play_area)
	var play_contents: VBoxContainer = _vbox(6)
	play_area.add_child(play_contents)
	play_contents.add_child(_label("TU ZONA DE JUEGO", 10, Palette.MUTED))
	var played_scroll: ScrollContainer = _card_scroll(30)
	play_contents.add_child(played_scroll)
	played_row = _hbox(8)
	played_scroll.add_child(played_row)
	_played_hint = _label("Tu próximo movimiento comienza en la mano.", 14, Palette.MUTED)
	played_row.add_child(_played_hint)
	_build_metals(parent)
	var hand_header: HBoxContainer = _section("Tu mano", "")
	hand_count = _label("5 cartas", 12, Palette.MUTED)
	hand_header.add_child(hand_count)
	parent.add_child(hand_header)
	var hand_scroll: ScrollContainer = _card_scroll(158)
	hand_scroll.name = "HandScroll"
	parent.add_child(hand_scroll)
	hand_row = _hbox(10)
	hand_scroll.add_child(hand_row)
	_build_footer(parent)


func _build_metals(parent: VBoxContainer) -> void:
	var row: HBoxContainer = _hbox(6)
	parent.add_child(row)
	for item: Dictionary in Palette.METALS:
		var button: Button = Button.new()
		button.toggle_mode = true
		button.text = item["name"]
		button.tooltip_text = "Alternar estado visual de %s · demostración" % item["name"]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(70, 46)
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_color_override("font_color", item["color"])
		button.add_theme_color_override("font_pressed_color", Palette.BG)
		button.add_theme_stylebox_override("normal", Palette.box(Palette.SURFACE, Palette.LINE, 8, 6))
		button.add_theme_stylebox_override("pressed", Palette.box(item["color"], item["color"], 8, 6))
		button.toggled.connect(_on_metal_toggled.bind(button, item["name"]))
		metals.append(button)
		row.add_child(button)


func _build_footer(parent: VBoxContainer) -> void:
	var footer: HBoxContainer = _hbox(14)
	parent.add_child(footer)
	for resource: String in ["Recursos  3", "Ataque  2", "Atium  1"]:
		footer.add_child(_badge(resource, Palette.GOLD if "Recursos" in resource else Palette.TEXT))
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	var large_hand: Button = _button("Más cartas", func() -> void: set_large_hand(not _large_hand))
	large_hand.tooltip_text = "Alternar entre cinco y diez cartas de muestra"
	large_hand.name = "LargeHandButton"
	footer.add_child(large_hand)
	var reset: Button = _button("Restablecer", reset_preview)
	reset.name = "ResetButton"
	footer.add_child(reset)
	feedback = _label("Selecciona una carta para ver su detalle. Valores y efectos de muestra.", 12, Palette.MUTED)
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(feedback)


func _build_modal() -> void:
	overlay = Control.new()
	overlay.name = "CardOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.z_index = 10
	add_child(overlay)
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.025, 0.04, 0.06, 0.91)
	dim.gui_input.connect(_on_backdrop_input)
	overlay.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	detail = _panel(Palette.SURFACE, 24)
	detail.custom_minimum_size = Vector2(770, 460)
	center.add_child(detail)
	var layout: HBoxContainer = _hbox(28)
	detail.add_child(layout)
	detail_art = _art(0, Vector2(250, 360))
	layout.add_child(detail_art)
	var text_column: VBoxContainer = _vbox(14)
	text_column.custom_minimum_size.x = 392
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(text_column)
	var header: HBoxContainer = _hbox(12)
	text_column.add_child(header)
	detail_meta = _label("ALIADA · ACERO", 12, Palette.BLUE)
	detail_meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(detail_meta)
	detail_close = _button("Cerrar", close_detail)
	detail_close.name = "CloseDetailButton"
	header.add_child(detail_close)
	detail_name = _label("Carta", 34, Palette.TEXT, true)
	text_column.add_child(detail_name)
	detail_value = _label("+2 ataque", 23, Palette.GOLD)
	text_column.add_child(detail_value)
	detail_description = _label("", 17, Palette.TEXT)
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_column.add_child(detail_description)
	var sample_note: Label = _label("CONTENIDO DE MUESTRA\nIlustración provisional · efecto sin implementar", 12, Palette.MUTED)
	text_column.add_child(sample_note)
	detail_action = _button("Llevar a mi mesa", place_selected_card)
	detail_action.name = "PlaceCardButton"
	detail_action.add_theme_stylebox_override("normal", Palette.box(Palette.GOLD, Palette.GOLD, 8, 12))
	detail_action.add_theme_color_override("font_color", Palette.BG)
	text_column.add_child(detail_action)


func open_detail(view: CardView, source: String) -> void:
	if is_instance_valid(_selected_view):
		_selected_view.set_selected(false)
	_selected_view = view
	view.set_selected(true)
	_return_focus = view
	_selected = view.card.duplicate(true)
	_selected_source = source
	detail_name.text = _selected["name"]
	detail_meta.text = "%s · %s · COSTE %s" % [_selected["kind"], String(_selected["metal"]).to_upper(), _selected["cost"]]
	detail_meta.add_theme_color_override("font_color", _selected["color"])
	detail_art.texture = Palette.art(int(_selected["art"]))
	detail_value.text = _selected["value"]
	detail_description.text = _selected["description"]
	detail_action.disabled = source != "hand"
	detail_action.text = "Llevar a mi mesa · demo" if source == "hand" else "Vista del mercado"
	overlay.show()
	# Godot 4.7: foco exclusivo del modal, también para navegación por teclado.
	for button: Button in _all_board_buttons():
		button.focus_mode = Control.FOCUS_NONE
	detail_close.focus_mode = Control.FOCUS_ALL
	detail_action.focus_mode = Control.FOCUS_ALL
	detail_close.focus_neighbor_bottom = detail_close.get_path_to(detail_action)
	detail_close.focus_neighbor_top = detail_close.get_path_to(detail_action)
	detail_close.focus_next = detail_close.get_path_to(detail_action)
	detail_close.focus_previous = detail_close.get_path_to(detail_action)
	detail_action.focus_next = detail_action.get_path_to(detail_close)
	detail_action.focus_previous = detail_action.get_path_to(detail_close)
	detail_close.grab_focus()


func close_detail() -> void:
	overlay.hide()
	for button: Button in _all_board_buttons():
		button.focus_mode = Control.FOCUS_ALL
	if is_instance_valid(_return_focus) and _return_focus.is_inside_tree():
		_return_focus.grab_focus()


func place_selected_card() -> void:
	if _selected_source != "hand" or _selected.is_empty():
		return
	for index: int in hand_cards.size():
		if hand_cards[index]["id"] == _selected["id"]:
			played_cards.append(hand_cards[index])
			hand_cards.remove_at(index)
			close_detail()
			_render_hand()
			_render_played()
			feedback.text = "Carta colocada en la mesa · demostración visual, sin aplicar efectos."
			_selected = {}
			_selected_source = ""
			if hand_row.get_child_count() > 0:
				hand_row.get_child(0).grab_focus()
			return


func reset_preview() -> void:
	if overlay != null:
		overlay.hide()
	_large_hand = false
	hand_cards = Samples.hand()
	played_cards.clear()
	_selected = {}
	_selected_source = ""
	for button: Button in metals:
		button.set_pressed_no_signal(false)
		button.text = button.get_meta("metal_name", button.text)
	for child: Node in market_row.get_children():
		(child as CardView).set_selected(false)
	_render_hand()
	_render_played()
	feedback.text = "Selecciona una carta para ver su detalle. Valores y efectos de muestra."


func set_large_hand(enabled: bool) -> void:
	reset_preview()
	_large_hand = enabled
	if enabled:
		for sample: Dictionary in Samples.hand():
			var extra: Dictionary = sample.duplicate(true)
			extra["id"] = String(extra["id"]) + "_extra"
			hand_cards.append(extra)
	_render_hand()
	feedback.text = "Diez cartas de muestra · desplaza la mano horizontalmente." if enabled else "Mano de cinco cartas de muestra."


func _render_hand() -> void:
	_clear(hand_row)
	for sample: Dictionary in hand_cards:
		hand_row.add_child(_make_card(sample, "hand", Vector2(138, 150)))
	hand_count.text = "%d cartas  ·  Mazo 7  /  Descarte 2" % hand_cards.size()
	_fit_cards.call_deferred()


func _render_played() -> void:
	_clear(played_row)
	if played_cards.is_empty():
		_played_hint = _label("Tu próximo movimiento comienza en la mano.", 14, Palette.MUTED)
		played_row.add_child(_played_hint)
	else:
		for card: Dictionary in played_cards:
			played_row.add_child(_badge(card["name"], card["color"]))


func _fit_cards() -> void:
	if _main_column == null:
		return
	var available: float = _main_column.size.x
	var spacious: bool = available >= 1350.0
	for node: Node in market_row.get_children():
		(node as Control).custom_minimum_size = Vector2(floorf(clampf((available - 50.0) / 6.0, 112.0, 266.0)), 260 if spacious else 190)
	for node: Node in hand_row.get_children():
		(node as Control).custom_minimum_size = Vector2(floorf(clampf((available - 40.0) / 5.0, 128.0, 220.0)), 190 if spacious else 150)
	(find_child("MarketScroll", true, false) as ScrollContainer).custom_minimum_size.y = 274 if spacious else 204
	(find_child("HandScroll", true, false) as ScrollContainer).custom_minimum_size.y = 204 if spacious else 158


func _make_card(data: Dictionary, source: String, card_size: Vector2) -> CardView:
	var view: CardView = CardView.new()
	view.setup(data, card_size)
	view.pressed.connect(open_detail.bind(view, source))
	return view


func _on_metal_toggled(enabled: bool, button: Button, metal_name: String) -> void:
	button.set_meta("metal_name", metal_name)
	button.text = ("● " if enabled else "") + metal_name
	feedback.text = "%s · %s (estado visual de muestra)." % [metal_name, "ardiendo" if enabled else "disponible"]


func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_detail()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and overlay.visible:
		close_detail()
		get_viewport().set_input_as_handled()


func _all_board_buttons() -> Array[Button]:
	var result: Array[Button] = []
	for node: Node in find_children("*", "Button", true, false):
		if not overlay.is_ancestor_of(node):
			result.append(node as Button)
	return result


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/MainScreen.tscn")


func _exit_tree() -> void:
	get_window().content_scale_size = _saved_scale_size
	get_window().content_scale_mode = _saved_scale_mode as Window.ContentScaleMode


func _clear(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func _label(value: String, font_size: int = 15, color: Color = Palette.TEXT, serif: bool = false) -> Label:
	var result: Label = Label.new()
	result.text = value
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	if serif:
		result.add_theme_font_override("font", Palette.font(true))
	return result


func _button(value: String, action: Callable) -> Button:
	var result: Button = Button.new()
	result.text = value
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	result.pressed.connect(action)
	return result


func _vbox(separation: int) -> VBoxContainer:
	var result: VBoxContainer = VBoxContainer.new()
	result.add_theme_constant_override("separation", separation)
	return result


func _hbox(separation: int) -> HBoxContainer:
	var result: HBoxContainer = HBoxContainer.new()
	result.add_theme_constant_override("separation", separation)
	return result


func _panel(color: Color, padding: int = 12) -> PanelContainer:
	var result: PanelContainer = PanelContainer.new()
	result.add_theme_stylebox_override("panel", Palette.box(color, Palette.LINE, 10, padding))
	return result


func _badge(value: String, color: Color) -> PanelContainer:
	var panel: PanelContainer = _panel(Palette.SURFACE, 8)
	panel.add_child(_label(value, 13, color))
	return panel


func _section(title: String, note: String) -> HBoxContainer:
	var row: HBoxContainer = _hbox(12)
	var title_label: Label = _label(title, 24, Palette.TEXT, true)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_label)
	if not note.is_empty():
		row.add_child(_label(note, 12, Palette.MUTED))
	return row


func _art(index: int, minimum: Vector2) -> TextureRect:
	var result: TextureRect = TextureRect.new()
	result.texture = Palette.art(index)
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	result.custom_minimum_size = minimum
	return result


func _card_scroll(height: int) -> ScrollContainer:
	var result: ScrollContainer = ScrollContainer.new()
	result.custom_minimum_size.y = height
	result.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	result.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	result.follow_focus = true
	return result
