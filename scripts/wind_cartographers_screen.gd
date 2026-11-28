extends Control

const Game = preload("res://scripts/game/wind_cartographers.gd")
const MENU: String = "res://scenes/MainScreen.tscn"
const INK: Color = Color("#0c1e24")
const PANEL: Color = Color("#122b31")
const PAPER: Color = Color("#f5f3e7")
const MUTED: Color = Color("#b3c8c4")
const MINT: Color = Color("#a7efd1")
const GOLD: Color = Color("#ffd591")

var _game: Game = Game.new()
var _page: VBoxContainer
var _started: bool = false
var _covered: bool = false
var _notice: String = ""


func _ready() -> void:
	var background := ColorRect.new()
	background.color = INK
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var scroll := ScrollContainer.new()
	scroll.name = "TableScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	scroll.add_child(margin)
	_page = VBoxContainer.new()
	_page.add_theme_constant_override("separation", 12)
	margin.add_child(_page)
	_render()


func _render(preferred_focus: StringName = &"") -> void:
	for child: Node in _page.get_children():
		_page.remove_child(child)
		child.queue_free()

	var header := _row(_page, 16)
	var title := _label(header, "Cartógrafos del Viento", 31, PAPER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(header, "Back", "Volver al menú", _return_to_menu)
	var focus: Button
	if not _started:
		focus = _render_setup()
	else:
		var view: Dictionary = _game.view()
		_render_scoreboard(view)
		if view.finished:
			focus = _render_result(view)
		elif _covered:
			focus = _render_handoff(view)
		else:
			focus = _render_turn(view)
	if preferred_focus != &"":
		var previous := _page.find_child(String(preferred_focus), true, false) as Button
		if previous != null and not previous.disabled:
			focus = previous
	if focus != null:
		focus.grab_focus()


func _render_setup() -> Button:
	var box := _panel(_page)
	_label(box, "Partida local", 24, MINT)
	_label(box, "2–4 personas · 6 rondas · Un equipo compartido", 16, MUTED)
	_wrap(_label(box, "Juega hasta dos cartas por turno. Invierte créditos en instrumentos y usa brújulas para avanzar por las rutas. Avanzar en las tres da 3 puntos adicionales al final.", 17, PAPER))
	_label(box, "Número de plazas", 17, PAPER)
	var choices := _row(box, 10)
	var two := _button(choices, "Start2", "2 plazas", _start.bind(2), true)
	_button(choices, "Start3", "3 plazas", _start.bind(3))
	_button(choices, "Start4", "4 plazas", _start.bind(4))
	_show_notice(box)
	return two


func _render_scoreboard(view: Dictionary) -> void:
	var players := _row(_page, 10)
	for player: Dictionary in view.players:
		var active: bool = not view.finished and player.seat == view.active_seat
		var box := _panel(players, active)
		var name_text: String = player.name + (" · Turno" if active else "")
		_label(box, name_text, 17, MINT if active else PAPER)
		_label(box, "%d puntos" % player.score, 15, MUTED)


func _render_handoff(view: Dictionary) -> Button:
	var box := _panel(_page, true)
	_label(box, "Ronda %d de 6" % view.round, 17, MUTED)
	var player: Dictionary = view.players[view.active_seat]
	_label(box, "Pasa el equipo a %s" % player.name, 28, PAPER)
	_wrap(_label(box, "Muestra tu mano cuando tengas el equipo.", 17, MUTED))
	return _button(box, "Reveal", "Mostrar mi mano", _reveal, true)


func _render_result(view: Dictionary) -> Button:
	var box := _panel(_page, true)
	_label(box, "Resultado final", 25, PAPER)
	var names: Array[String] = []
	for seat: int in view.winners:
		names.append(view.players[seat].name)
	if names.size() == 1:
		_label(box, "Gana %s" % names[0], 21, MINT)
	else:
		_label(box, "Victoria compartida · %s" % ", ".join(names), 21, MINT)
	return _button(box, "NewGame", "Nueva partida", _reset, true)


func _render_turn(view: Dictionary) -> Button:
	var seat: int = view.active_seat
	var turn := _row(_page, 12)
	var indicator := _label(turn, "Ronda %d de 6" % view.round, 20, PAPER)
	indicator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(turn, "%d créditos  ·  %d brújulas" % [view.credits, view.compasses], 19, GOLD)
	var finish := _button(turn, "EndTurn", "Terminar turno", _act.bind(_game.end_turn.bind(seat), true, &""))
	var hand := _panel(_page)
	_label(hand, "Tu mano · %d de 2 cartas jugadas" % view.played_count, 17, PAPER)
	var cards := _row(hand, 8)
	var first_playable: Button
	var hand_cards: Array[Dictionary] = _game.hand(seat)
	for index: int in hand_cards.size():
		var card: Dictionary = hand_cards[index]
		var node_name := StringName("Play%d" % index)
		var card_button := _button(cards, node_name, "%s\n%s" % [card.name, _gain(card)],
			_act.bind(_game.play.bind(seat, index), false, &""), true)
		card_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_button.disabled = view.played_count >= 2
		if first_playable == null and not card_button.disabled:
			first_playable = card_button

	var columns := _row(_page, 10)
	var market := _panel(columns)
	_label(market, "Instrumentos · %s" % ("Compra hecha" if view.bought else "1 compra disponible"), 17, PAPER)
	for card: Dictionary in view.supply:
		var node_name := StringName("Buy_" + String(card.id))
		var text := "%s · %s · %d cr. · %d en oferta" % [card.name, _gain(card), card.cost, card.remaining]
		var offer := _button(market, node_name, text, _act.bind(_game.buy.bind(seat, card.id), false, node_name))
		offer.disabled = view.bought or view.credits < card.cost or card.remaining <= 0

	var routes := _panel(columns)
	_label(routes, "Rutas · %s" % ("Etapa trazada" if view.charted else "1 etapa disponible"), 17, PAPER)
	var progress: Array = view.players[seat].routes
	for index: int in view.routes.size():
		var route: Dictionary = view.routes[index]
		var stage: int = progress[index]
		var node_name := StringName("Chart%d" % index)
		var text: String = "%s · %d/3" % [route.name, stage]
		if stage < route.costs.size():
			text += " · %d br. · +%d pt." % [route.costs[stage], route.points[stage]]
		var route_button := _button(routes, node_name, text,
			_act.bind(_game.chart.bind(seat, index), false, node_name))
		route_button.disabled = view.charted or stage >= route.costs.size() or view.compasses < route.costs[stage]
	_show_notice(_page)
	return first_playable if first_playable != null else finish


func _start(count: int) -> void:
	if not _game.start(count, randi()):
		_notice = _game.last_error
		_render()
		return
	_started = true
	_covered = true
	_notice = ""
	_render()


func _act(action: Callable, ends_turn: bool, preferred_focus: StringName) -> void:
	if _covered:
		return
	var accepted: bool = action.call()
	_notice = "" if accepted else _game.last_error
	if accepted and ends_turn:
		_covered = true
	_render(preferred_focus)


func _reveal() -> void:
	_covered = false
	_render()


func _reset() -> void:
	_started = false
	_covered = false
	_notice = ""
	_render()


func _return_to_menu() -> void:
	if get_tree().change_scene_to_file(MENU) != OK:
		push_error("No se pudo abrir el menú principal.")


func _show_notice(parent: VBoxContainer) -> void:
	if not _notice.is_empty():
		_wrap(_label(parent, _notice, 16, GOLD))


func _gain(card: Dictionary) -> String:
	var gains: Array[String] = []
	if card.credits > 0:
		gains.append("+%d cr." % card.credits)
	if card.compasses > 0:
		gains.append("+%d br." % card.compasses)
	return "  ".join(gains)


func _wrap(label: Label) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _label(parent: Container, text: String, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	parent.add_child(label)
	return label


func _row(parent: Container, distance: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", distance)
	parent.add_child(row)
	return row


func _panel(parent: Container, highlighted: bool = false) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(PANEL, MINT if highlighted else Color("#28454b"), 12))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	return box


func _button(parent: Container, node_name: StringName, text: String, callback: Callable, accent: bool = false) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size.y = 34
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 16)
	var fill := Color("#206254") if accent else Color("#203d44")
	button.add_theme_stylebox_override("normal", _style(fill, Color("#3a6267"), 7))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.12), MINT, 7))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.12), MINT, 7))
	button.add_theme_stylebox_override("disabled", _style(INK, Color("#28454b"), 7))
	button.add_theme_color_override("font_color", PAPER)
	button.add_theme_color_override("font_disabled_color", MUTED)
	var focus := _style(Color.TRANSPARENT, GOLD, 7)
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _style(fill: Color, border: Color, padding: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding
	box.content_margin_bottom = padding
	return box
