extends SceneTree

const Probe = preload("res://scripts/network/connection_probe.gd")
const TEST_KEY: String = "p04-local-test-not-a-secret"
var checks: int = 0
var failures: int = 0
var processes: Array[Dictionary] = []
var session: Probe
var test_port: int = 0
var rejection_count: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var options: Dictionary = {}
	for argument: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = argument.split("=", true, 1)
		if parts.size() == 2:
			options[parts[0]] = parts[1]
	if options.has("role"):
		await _run_child(String(options["role"]), int(options["port"]))
		return
	await _run_parent()


func _run_parent() -> void:
	session = Probe.new()
	root.add_child(session)
	_expect(session.host_session("", 24567) != OK, "Nombre vacío rechazado.")
	_expect(session.host_session("Nombre", 80) != OK, "Puerto fuera de rango rechazado.")
	_expect(session.join_session("Nombre", "no-es-ip", 24567, TEST_KEY) != OK, "Dirección inválida rechazada.")
	_expect(session.join_session("Nombre", "127.0.0.1", 24567, "") != OK, "Clave vacía rechazada.")
	test_port = randi_range(30000, 50000)
	_expect(session.host_session("Anfitrión", test_port, TEST_KEY) == OK, "Servidor UDP iniciado.")
	if not session.active:
		_finish()
		return
	var occupied: Probe = Probe.new()
	root.add_child(occupied)
	print("FALLO ESPERADO: segundo servidor en el mismo puerto UDP.")
	_expect(occupied.host_session("Otro", test_port) != OK, "Puerto ocupado rechazado.")
	occupied.queue_free()
	_expect(session.host_session("Otro", test_port + 1) != OK and session.active, "Crear otra sesión no destruye la activa.")
	for role: String in ["wrong_key", "wrong_version", "unauthenticated"]:
		var child: Dictionary = _spawn(role)
		_expect(await _wait_until(func() -> bool: return not OS.is_process_running(int(child["pid"])), 12.0), role + " finaliza.")
		_expect(_has_marker(child), role + " rechazado realmente desde otro proceso.")
		_expect(session.participants.size() == 1 and session.counter == 0, role + " no modifica el estado.")
	_expect(session.rejected_requests == 3, "Tres accesos negativos registrados.")
	var main_clients: Array[Dictionary] = [_spawn("client_a"), _spawn("client_b"), _spawn("observer")]
	_expect(await _wait_until(func() -> bool: return session.participants.size() == 4, 8.0), "Cuatro personas, incluyendo anfitrión.")
	session.request_signal()
	_expect(await _wait_until(func() -> bool: return session.counter == 4, 8.0), "Autoridad aplica tres señales cliente y una propia.")
	_expect(session.rejected_requests == 8, "Duplicado, operación, JSON, tamaño y estado forjado rechazados.")
	for child: Dictionary in main_clients:
		_expect(await _wait_until(func() -> bool: return _log_contains(child, "P04_CONVERGED"), 5.0), "Cada proceso recibe lista y contador autoritativos.")
	var overflow: Dictionary = _spawn("overflow")
	_expect(await _wait_until(func() -> bool: return not OS.is_process_running(int(overflow["pid"])), 13.0), "Quinto participante termina por falta de plaza.")
	_expect(_has_marker(overflow), "Aforo máximo probado por transporte real.")
	_expect(session.participants.size() == 4 and session.counter == 4, "Quinto participante no cambia el estado.")
	# Salida de un cliente admitido y difusión del nuevo listado.
	var leaving_id: int = 0
	for id: int in session.participants:
		if session.participants[id] == "observer":
			leaving_id = id
	if leaving_id != 0:
		session.peer.disconnect_peer(leaving_id)
	_expect(await _wait_until(func() -> bool: return session.participants.size() == 3, 5.0), "Desconectar retira al cliente del listado.")
	session.close_session()
	for child: Dictionary in main_clients:
		_expect(await _wait_until(func() -> bool: return not OS.is_process_running(int(child["pid"])), 8.0), "Cliente detecta fin de anfitrión.")
		_expect(_has_marker(child), "Cliente termina sin errores tras convergencia y desconexión.")
	_expect(not session.active and session.participants.is_empty() and session.counter == 0, "Cierre limpia estado.")
	_expect(session.host_session("Reintento", test_port) == OK, "Puerto liberado y sesión nueva posible.")
	_expect(session.room_key.length() == 16 and session.room_key != TEST_KEY, "Clave nueva generada por sesión.")
	session.close_session()
	# UI usa los mismos botones/señales que el usuario.
	var packed: PackedScene = load("res://scenes/ConnectionScreen.tscn") as PackedScene
	var screen: Control = packed.instantiate() as Control
	root.add_child(screen)
	await process_frame
	_expect(screen.get_node("%SignalButton").disabled, "No enviar señales antes de entrar.")
	screen.get_node("%PortInput").value = test_port
	screen.get_node("%HostButton").pressed.emit()
	_expect(screen.session.active and not screen.get_node("%SignalButton").disabled, "Botón crear inicia una sesión real.")
	screen.get_node("%SignalButton").pressed.emit()
	_expect(screen.get_node("%CounterLabel").text == "1", "Botón señal actualiza el contador visible.")
	screen.get_node("%DisconnectButton").pressed.emit()
	_expect(not screen.session.active and screen.get_node("%Invitation").text.is_empty(), "Botón desconectar borra sesión y clave visible.")
	screen.queue_free()
	await process_frame
	_finish()


func _run_child(role: String, port: int) -> void:
	session = Probe.new()
	root.add_child(session)
	session.notice.connect(func(_message: String) -> void: rejection_count += 1)
	var key: String = "incorrecta" if role == "wrong_key" else TEST_KEY
	var version: int = 99 if role == "wrong_version" else Probe.PROTOCOL
	_expect(session.join_session(role, "127.0.0.1", port, key, version) == OK, "Cliente inicia conexión.")
	if role == "unauthenticated":
		session.set("_hello_sent", true)
		_expect(await _wait_until(func() -> bool: return session.peer != null and session.peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED, 5.0), "Cliente sin handshake conectado.")
		session.call("_send", 1, {"type": "increment", "seq": 1})
	if role in ["wrong_key", "wrong_version", "unauthenticated", "overflow"]:
		_expect(await _wait_until(func() -> bool: return not session.active, 12.0), "Acceso negativo finaliza.")
		var expected_text: String = {"wrong_key": "Clave incorrecta", "wrong_version": "Versión", "unauthenticated": "no admitida", "overflow": "10 segundos"}[role]
		_expect(expected_text in session.status, "Motivo de rechazo o tiempo límite correcto.")
		_child_finish(role)
		return
	_expect(await _wait_until(func() -> bool: return session.accepted, 8.0), "Cliente admitido.")
	if role == "client_a":
		session.request_signal()
		session.call("_send", 1, {"type": "increment", "seq": 1})
		session.call("_send", 1, {"type": "invented", "seq": 2})
		session.call("_send", 1, {"type": "snapshot", "counter": 999, "seq": 2})
		session.peer.set_target_peer(1)
		session.peer.put_packet("[]".to_utf8_buffer())
		session.peer.put_packet("x".repeat(Probe.MAX_PACKET_BYTES + 1).to_utf8_buffer())
		_expect(await _wait_until(func() -> bool: return rejection_count == 5, 5.0), "Cinco mensajes inválidos rechazados.")
		session.request_signal()
	elif role == "client_b":
		session.request_signal()
	_expect(await _wait_until(func() -> bool: return session.counter == 4 and session.participants.size() == 4, 8.0), "Lista y contador convergen en proceso independiente.")
	print("P04_CONVERGED: ", role)
	_expect(await _wait_until(func() -> bool: return not session.active, 25.0), "Detecta cierre del anfitrión o expulsión.")
	_child_finish(role)


func _spawn(role: String) -> Dictionary:
	var log_path: String = ProjectSettings.globalize_path("res://tmp/godot/p04-%s.log" % role)
	var arguments: PackedStringArray = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--log-file", log_path, "--script", "res://tests/network_test.gd", "--", "role=" + role, "port=" + str(test_port)]
	var pid: int = OS.create_process(OS.get_executable_path(), arguments, false)
	_expect(pid > 0, "Proceso independiente creado: " + role)
	var child: Dictionary = {"pid": pid, "log": log_path, "role": role}
	processes.append(child)
	return child


func _log_contains(child: Dictionary, marker: String) -> bool:
	if not FileAccess.file_exists(child["log"]):
		return false
	return marker in FileAccess.get_file_as_string(child["log"])


func _has_marker(child: Dictionary) -> bool:
	return _log_contains(child, "P04_CHILD_OK") and not _log_contains(child, "SCRIPT ERROR") and not _log_contains(child, "COMPROBACIÓN FALLIDA")


func _wait_until(predicate: Callable, seconds: float) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(seconds * 1000)
	while not predicate.call() and Time.get_ticks_msec() < deadline:
		await process_frame
	return predicate.call()


func _child_finish(role: String) -> void:
	session.close_session()
	if failures == 0:
		print("P04_CHILD_OK: ", role, " · ", checks, " comprobaciones")
	quit(0 if failures == 0 else 1)


func _finish() -> void:
	if session != null:
		session.close_session()
	for child: Dictionary in processes:
		if OS.is_process_running(int(child["pid"])):
			OS.kill(int(child["pid"]))
	if failures == 0:
		print("P04_NETWORK_OK: ", checks, " comprobaciones del coordinador; clientes en procesos independientes, solo localhost.")
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("COMPROBACIÓN FALLIDA: " + message)
