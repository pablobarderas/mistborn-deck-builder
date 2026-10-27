extends SceneTree

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Esta captura requiere renderizador gráfico.")
		quit(1)
		return
	var packed: PackedScene = load("res://scenes/MainScreen.tscn") as PackedScene
	var main: Control = packed.instantiate() as Control
	root.add_child(main)
	current_scene = main
	await process_frame
	main.get_node("%ConnectionButton").pressed.emit()
	await process_frame
	await process_frame
	var screen: Control = current_scene as Control
	_expect(screen.name == "ConnectionScreen", "Navegación desde pantalla inicial.")
	await _capture("connection-screen.png")
	var port: int = randi_range(30000, 50000)
	screen.get_node("%PortInput").value = port
	screen.get_node("%NameInput").text = "Vin"
	screen.get_node("%HostButton").pressed.emit()
	_expect(screen.session.active, "Crear prueba desde interfaz.")
	screen.get_node("%SignalButton").pressed.emit()
	_expect(screen.get_node("%CounterLabel").text == "1", "Señal visible.")
	_expect("Vin" in screen.get_node("%PeopleLabel").text, "Nombre de participante visible.")
	await _capture("connection-host.png")
	root.size = Vector2i(1024, 640)
	await process_frame
	await _capture("connection-host-1024.png")
	screen.get_node("%BackButton").pressed.emit()
	await process_frame
	await process_frame
	_expect(current_scene.name == "MainScreen", "Volver recupera pantalla inicial.")
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	_expect(peer.create_server(port, 1) == OK, "Volver libera el puerto del anfitrión.")
	peer.close()
	if failures == 0:
		print("P04_PREVIEW_OK: ", checks, " comprobaciones y tres capturas reales.")
	quit(0 if failures == 0 else 1)


func _capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var output_dir: String = ProjectSettings.globalize_path("res://tmp/screenshots")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var capture: Image = root.get_texture().get_image()
	_expect(capture != null and not capture.is_empty(), "Captura con contenido.")
	if capture != null:
		_expect(capture.save_png(output_dir.path_join(filename)) == OK, "Captura guardada.")


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("COMPROBACIÓN FALLIDA: " + message)
