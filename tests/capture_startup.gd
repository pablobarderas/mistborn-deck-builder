extends SceneTree

const DESKTOP_SIZE: Vector2i = Vector2i(1280, 800)
const COMPACT_SIZE: Vector2i = Vector2i(1024, 640)
const ACTIONS: Dictionary = {
	"ReloadButton": "_on_reload_pressed",
	"BoardButton": "_on_board_pressed",
	"LocalGameButton": "_on_local_game_pressed",
	"ConnectionButton": "_on_connection_pressed",
	"ExitButton": "_on_exit_pressed",
}

var _failures: int = 0


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("La captura requiere un renderizador gráfico, sin --headless.")
		quit(1)
		return
	var scene: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene")) as PackedScene
	if scene == null:
		push_error("No se pudo cargar la escena para capturarla.")
		quit(1)
		return
	root.size = DESKTOP_SIZE
	var screen: Control = scene.instantiate() as Control
	root.add_child(screen)
	await process_frame
	await process_frame
	var menu: ScrollContainer = screen.get_node("%MenuScroll") as ScrollContainer
	for button_name: String in ACTIONS:
		var button: Button = screen.get_node("%" + button_name) as Button
		_expect(button.pressed.is_connected(Callable(screen, ACTIONS[button_name])),
			"Se conserva la acción de " + button_name)
		_expect(_inside_menu(button, menu), "Botón visible a 1280×800: " + button_name)
	_expect(_inside_menu(screen.find_child("Brand"), menu), "Cabecera visible a 1280×800.")
	_expect(_inside_menu(screen.find_child("Roadmap"), menu), "Pie visible a 1280×800.")
	_expect(not menu.get_v_scroll_bar().visible, "El menú de referencia se muestra completo.")
	var output_path: String = await _save_frame("main-screen.png", DESKTOP_SIZE)

	root.size = COMPACT_SIZE
	await process_frame
	await process_frame
	_expect(_inside_menu(screen.find_child("Brand"), menu), "Cabecera visible a 1024×640.")
	await _save_frame("main-screen-compact.png", COMPACT_SIZE)

	var first: Button = screen.get_node("%ReloadButton") as Button
	first.grab_focus()
	await process_frame
	for button_name: String in ACTIONS:
		var button: Button = screen.get_node("%" + button_name) as Button
		if button != first:
			_tab()
			await process_frame
			await process_frame
		_expect(root.gui_get_focus_owner() == button, "Tab alcanza " + button_name)
		_expect(_inside_menu(button, menu), "El foco mantiene visible " + button_name)
	await _save_frame("main-screen-compact-exit.png", COMPACT_SIZE)
	await _check_overflow(screen, menu)
	if _failures > 0:
		quit(1)
		return
	print("P03_PREVIEW_OK: ", output_path, " · menú y foco comprobados a 1280×800 y 1024×640.")
	var exit_button: Button = screen.get_node("%ExitButton") as Button
	exit_button.pressed.emit()


func _check_overflow(screen: Control, menu: ScrollContainer) -> void:
	var status: Label = screen.get_node("%StatusLabel") as Label
	status.text += "\nAviso de catálogo para comprobar el desplazamiento.".repeat(24)
	await process_frame
	await process_frame
	_expect(menu.get_v_scroll_bar().visible, "Un diagnóstico largo activa el desplazamiento vertical.")
	menu.scroll_vertical = 0
	await process_frame
	_wheel_down()
	await process_frame
	await process_frame
	_expect(menu.scroll_vertical > 0, "La rueda permite desplazar el contenido.")
	var connection: Button = screen.get_node("%ConnectionButton") as Button
	var exit_button: Button = screen.get_node("%ExitButton") as Button
	connection.grab_focus()
	await process_frame
	await process_frame
	_tab()
	await process_frame
	await process_frame
	_expect(root.gui_get_focus_owner() == exit_button and _inside_menu(exit_button, menu),
		"Tab desplaza la vista hasta el botón de salida si hay desbordamiento.")


func _inside_menu(control: Control, menu: ScrollContainer) -> bool:
	return menu.get_global_rect().encloses(control.get_global_rect())


func _wheel_down() -> void:
	var wheel := InputEventMouseButton.new()
	wheel.position = Vector2(12, 300)
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	root.push_input(wheel)


func _tab() -> void:
	var key := InputEventKey.new()
	key.keycode = KEY_TAB
	key.pressed = true
	root.push_input(key)
	var release := key.duplicate() as InputEventKey
	release.pressed = false
	root.push_input(release)


func _save_frame(filename: String, expected_size: Vector2i) -> String:
	await RenderingServer.frame_post_draw
	var output_dir: String = ProjectSettings.globalize_path("res://tmp/screenshots")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var capture: Image = root.get_texture().get_image()
	_expect(capture != null and not capture.is_empty(), "El renderizador devuelve una imagen.")
	if capture == null or capture.is_empty():
		return ""
	_expect(capture.get_size() == expected_size, "La captura tiene las dimensiones solicitadas.")
	var output_path: String = output_dir.path_join(filename)
	_expect(capture.save_png(output_path) == OK, "Se guardó " + filename)
	return output_path


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error(message)
