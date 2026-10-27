extends SceneTree


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
	var screen: Control = scene.instantiate() as Control
	root.add_child(screen)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var output_dir: String = ProjectSettings.globalize_path("res://tmp/screenshots")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var capture: Image = root.get_texture().get_image()
	if capture == null or capture.is_empty():
		push_error("El renderizador no devolvió una imagen.")
		quit(1)
		return
	var output_path: String = output_dir.path_join("main-screen.png")
	if capture.save_png(output_path) != OK:
		push_error("No se pudo guardar la captura.")
		quit(1)
		return
	print("P03_PREVIEW_OK: ", output_path)
	# Salir mediante la misma señal que usa el botón visible.
	var exit_button: Button = screen.get_node("%ExitButton") as Button
	if not exit_button.pressed.is_connected(Callable(screen, "_on_exit_pressed")):
		push_error("La salida de la pantalla no está conectada.")
		quit(1)
		return
	exit_button.pressed.emit()
