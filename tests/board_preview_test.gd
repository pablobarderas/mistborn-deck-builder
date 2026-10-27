extends SceneTree

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("La verificación visual requiere renderizador gráfico.")
		quit(1)
		return
	var original_catalog: String = FileAccess.get_file_as_string("res://data/cartas.json")
	var saved_scale: Vector2i = root.content_scale_size
	var saved_mode: int = root.content_scale_mode
	change_scene_to_file("res://scenes/MainScreen.tscn")
	await process_frame
	await process_frame
	current_scene.get_node("%BoardButton").pressed.emit()
	await process_frame
	await process_frame
	var board: Control = current_scene as Control
	_expect(board != null and board.name == "BoardPreview", "Acceso al tablero desde inicio.")
	if board == null or board.name != "BoardPreview":
		quit(1)
		return
	_expect(board.market_row.get_child_count() == 6, "Seis cartas en el mercado de muestra.")
	_expect(board.hand_cards.size() == 5 and board.hand_row.get_child_count() == 5, "Mano de cinco cartas.")
	_expect(board.metals.size() == 8, "Ocho estados visuales de metales.")
	_expect(board.played_cards.is_empty(), "Zona de juego inicialmente vacía.")
	await _capture("board-1280.png")
	_expect(board.market_row.size.x <= (board.find_child("MarketScroll", true, false) as Control).size.x + 1, "Mercado completo visible a 1280.")
	board.market_row.get_child(0).pressed.emit()
	_expect(board.overlay.visible and board.detail_action.disabled, "Detalle del mercado sin acción de juego.")
	_expect(board.detail_name.text == "Vin", "Detalle de la carta elegida.")
	_expect(root.gui_get_focus_owner() == board.detail_close, "Foco en modal.")
	var escape: InputEventKey = InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await process_frame
	await process_frame
	_expect(not board.overlay.visible, "Escape cierra el detalle.")
	var hand_card: Button = board.hand_row.get_child(2) as Button
	hand_card.pressed.emit()
	_expect(board.overlay.visible and not board.detail_action.disabled, "Carta de mano ofrece colocación visual.")
	await _capture("board-detail.png")
	board.detail_action.pressed.emit()
	await process_frame
	_expect(board.hand_cards.size() == 4 and board.played_cards.size() == 1, "Colocar mueve la carta de mano a mesa.")
	_expect(not board.overlay.visible, "Colocar cierra detalle.")
	board.place_selected_card()
	_expect(board.played_cards.size() == 1, "Doble activación no duplica carta.")
	board.metals[0].button_pressed = true
	_expect("ardiendo" in board.feedback.text, "Estado activo acompañado por texto.")
	board.reset_preview()
	_expect(board.hand_cards.size() == 5 and board.played_cards.is_empty() and not board.metals[0].button_pressed, "Reinicio reversible.")
	board.set_large_hand(true)
	_expect(board.hand_cards.size() == 10 and board.hand_row.get_child_count() == 10, "Mano saturada de diez cartas.")
	var ids: Dictionary = {}
	for card: Dictionary in board.hand_cards:
		ids[card["id"]] = true
	_expect(ids.size() == 10, "IDs de muestra únicos al ampliar mano.")
	root.size = Vector2i(1024, 640)
	await process_frame
	await process_frame
	await _capture("board-1024-ten-cards.png")
	var hand_scroll: ScrollContainer = board.find_child("HandScroll", true, false) as ScrollContainer
	_expect(hand_scroll.get_h_scroll_bar().max_value > hand_scroll.size.x, "Desplazamiento horizontal para mano saturada.")
	hand_scroll.scroll_horizontal = 10000
	await process_frame
	_expect(hand_scroll.scroll_horizontal > 0, "Últimas cartas accesibles mediante desplazamiento.")
	var page_scroll: ScrollContainer = board.find_child("PageScroll", true, false) as ScrollContainer
	page_scroll.scroll_vertical = 10000
	await process_frame
	_expect(page_scroll.scroll_vertical > 0, "Zona inferior accesible en ventana compacta.")
	await _capture("board-1024-bottom.png")
	board.hand_row.get_child(9).pressed.emit()
	_expect(board.detail_name.text == board.hand_cards[9]["name"], "Ampliar última carta de mano saturada.")
	await _capture("board-1024-detail.png")
	board.detail_close.pressed.emit()
	board.reset_preview()
	root.size = Vector2i(1920, 1080)
	await process_frame
	await process_frame
	_expect(board.market_row.get_child(0).custom_minimum_size.x > 200, "Las cartas crecen al ampliar ventana.")
	await _capture("board-1920.png")
	for index: int in 5:
		board.hand_row.get_child(0).pressed.emit()
		board.detail_action.pressed.emit()
		await process_frame
	_expect(board.hand_cards.is_empty() and board.played_cards.size() == 5, "Mano vacía se representa sin errores.")
	board.reset_preview()
	board.find_child("BackButton", true, false).pressed.emit()
	await process_frame
	await process_frame
	_expect(current_scene.name == "MainScreen", "Volver regresa al inicio.")
	_expect(root.content_scale_size == saved_scale and root.content_scale_mode == saved_mode, "Restaurar escalado al salir del tablero.")
	_expect(FileAccess.get_file_as_string("res://data/cartas.json") == original_catalog, "No modificar catálogo original.")
	if failures == 0:
		print("P05_BOARD_OK: ", checks, " comprobaciones y seis capturas reales; maqueta visual sin reglas ejecutadas.")
	quit(0 if failures == 0 else 1)


func _capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var directory: String = ProjectSettings.globalize_path("res://tmp/screenshots")
	DirAccess.make_dir_recursive_absolute(directory)
	var capture: Image = root.get_texture().get_image()
	_expect(capture != null and not capture.is_empty(), "Render con contenido: " + filename)
	if capture != null:
		_expect(capture.save_png(directory.path_join(filename)) == OK, "Captura guardada: " + filename)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("COMPROBACIÓN FALLIDA: " + message)
