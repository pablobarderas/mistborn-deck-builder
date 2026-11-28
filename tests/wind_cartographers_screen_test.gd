extends SceneTree

const MENU: String = "res://scenes/MainScreen.tscn"

var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("La comprobación de pantalla requiere un renderizador gráfico.")
		quit(1)
		return
	seed(2086)
	root.size = Vector2i(1280, 800)
	if change_scene_to_file(MENU) != OK:
		quit(1)
		return
	await process_frame
	await process_frame
	if not _press("WindCartographersButton"):
		quit(1)
		return
	await process_frame
	await process_frame
	_expect(current_scene.scene_file_path == "res://scenes/WindCartographers.tscn", "Entrada desde el menú.")
	await _capture("setup")
	for count: int in [4, 3]:
		_press("Start%d" % count)
		_expect(current_scene._game.view().player_count == count, "Preparación para %d plazas." % count)
		_check_handoff()
		if count == 4:
			await _capture("handoff")
			_press_enter()
			await process_frame
			_expect(_button("Reveal") == null and _button("Play0") != null, "Intro revela la mano cuando el relevo tiene el foco.")
			root.size = Vector2i(1024, 640)
			await process_frame
			await _capture("compact")
			_expect(root.size == Vector2i(1024, 640), "Resolución compacta aplicada.")
			_check_layout()
			root.size = Vector2i(1280, 800)
		_press("Back")
		await process_frame
		await process_frame
		_press("WindCartographersButton")
		await process_frame
		await process_frame

	_press("Start2")
	_expect(current_scene._game.view().player_count == 2, "Preparación para dos plazas.")
	var purchases: int = 0
	var stages: int = 0
	for turn: int in 12:
		_check_handoff()
		var before: Dictionary = current_scene._game.view()
		_expect(before.round == (turn / 2) + 1, "La ronda avanza tras jugar ambas plazas.")
		if not _press("Reveal"):
			break
		_expect(_button("Reveal") == null and _button("Play3") != null, "Confirmar muestra exactamente cuatro cartas.")
		if turn == 0:
			await _capture("turn")
			_check_layout()
		var credit_card: int = _card_index(true)
		_press("Play%d" % maxi(credit_card, 0))
		var compass_card: int = _card_index(false)
		_press("Play%d" % maxi(compass_card, 0))
		_expect(_button("Play0").disabled, "La tercera carta queda deshabilitada.")
		for offer: Dictionary in current_scene._game.view().supply:
			var name_key := "Buy_" + String(offer.id)
			if not _button(name_key).disabled:
				var credits: int = current_scene._game.view().credits
				_press(name_key)
				_expect(current_scene._game.view().credits == credits - offer.cost, "Compra desde la interfaz y pago exacto.")
				_expect(_button(name_key).disabled, "La segunda compra queda deshabilitada.")
				purchases += 1
				break
		for index: int in [2, 1, 0]:
			var name_key := "Chart%d" % index
			if not _button(name_key).disabled:
				var previous_stage: int = current_scene._game.view().players[before.active_seat].routes[index]
				_press(name_key)
				_expect(current_scene._game.view().players[before.active_seat].routes[index] == previous_stage + 1, "Trazado desde la interfaz.")
				_expect(_button(name_key).disabled, "La segunda etapa queda deshabilitada.")
				stages += 1
				break
		_press("EndTurn")
		await process_frame
	_expect(purchases > 0 and stages > 0, "La partida visible incluye compra y trazado.")
	_expect(current_scene._game.view().finished and _button("NewGame") != null, "La pantalla muestra el resultado tras seis rondas.")
	_expect(_button("Reveal") == null and _button("Play0") == null, "La mano se elimina del resultado.")
	await _capture("result")
	_press("NewGame")
	_expect(_button("Start2") != null and _button("NewGame") == null, "Nueva partida vuelve a la selección de plazas.")
	_press("Start3")
	_check_handoff()
	_press("Back")
	await process_frame
	await process_frame
	_expect(current_scene.scene_file_path == MENU, "Vuelta al menú principal.")
	if _failures == 0:
		print("WIND_CARTOGRAPHERS_SCREEN_OK: %d comprobaciones y cinco capturas." % _checks)
	quit(0 if _failures == 0 else 1)


func _check_handoff() -> void:
	_expect(_button("Reveal") != null and _button("Play0") == null and _button("EndTurn") == null,
		"Relevo sin controles de turno ni cartas privadas.")
	_expect(root.gui_get_focus_owner() == _button("Reveal"), "El foco del relevo permite confirmar con teclado.")


func _check_layout() -> void:
	var scroll := current_scene.find_child("TableScroll", true, false) as ScrollContainer
	var window_rect := Rect2(Vector2.ZERO, root.get_visible_rect().size)
	for button_name: String in ["Back", "EndTurn", "Play0", "Play3", "Chart2"]:
		var button := _button(button_name)
		_expect(button != null and window_rect.encloses(button.get_global_rect()), "Control visible: " + button_name)
	_expect(scroll.get_h_scroll_bar().max_value <= scroll.get_h_scroll_bar().page, "Mesa sin desplazamiento horizontal.")


func _card_index(want_credits: bool) -> int:
	var seat: int = current_scene._game.view().active_seat
	var cards: Array[Dictionary] = current_scene._game.hand(seat)
	for index: int in cards.size():
		var amount: int = cards[index].credits if want_credits else cards[index].compasses
		if amount > 0:
			return index
	return -1


func _button(button_name: String) -> Button:
	return current_scene.find_child(button_name, true, false) as Button


func _press(button_name: String) -> bool:
	var button := _button(button_name)
	var available: bool = button != null and not button.disabled
	_expect(available, "Control disponible: " + button_name)
	if available:
		button.pressed.emit()
	return available


func _press_enter() -> void:
	var keyboard := InputEventKey.new()
	keyboard.keycode = KEY_ENTER
	keyboard.pressed = true
	root.push_input(keyboard)
	var release := keyboard.duplicate() as InputEventKey
	release.pressed = false
	root.push_input(release)


func _capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var directory: String = ProjectSettings.globalize_path("res://tmp/screenshots")
	DirAccess.make_dir_recursive_absolute(directory)
	var result: Image = root.get_texture().get_image()
	_expect(result != null and not result.is_empty(), "Render visible: " + filename)
	if result != null:
		_expect(result.save_png(directory.path_join("wind-" + filename + ".png")) == OK, "Captura guardada.")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)
