extends Node
## Experimento P04. No representa plazas persistentes ni estado de partida.

signal changed
signal notice(message: String)

const PROTOCOL: int = 1
const DEFAULT_PORT: int = 24567
const MAX_PEOPLE: int = 4
const TIMEOUT_MS: int = 10000
const MAX_PACKET_BYTES: int = 2048
const MAX_PACKETS_PER_FRAME: int = 64

var peer: ENetMultiplayerPeer
var is_host: bool = false
var active: bool = false
var accepted: bool = false
var status: String = "Sin conexión."
var room_key: String = ""
var participants: Dictionary = {}
var counter: int = 0
var revision: int = 0
var rejected_requests: int = 0
var local_id: int = 0

var _name: String = ""
var _started_ms: int = 0
var _hello_sent: bool = false
var _sequence: int = 0
var _last_sequences: Dictionary = {}
var _pending: Dictionary = {}
var _hello_version: int = PROTOCOL
var _closing: bool = false


func host_session(display_name: String, port: int, key: String = "") -> Error:
	if active:
		return _input_error("Desconecta la sesión actual antes de crear otra.")
	if not _valid_name(display_name) or not _valid_port(port):
		return _input_error("Indica un nombre de 1–24 caracteres y un puerto de 1024–65535.")
	close_session()
	peer = ENetMultiplayerPeer.new()
	# Sin relay entre clientes: todas las solicitudes pasan por la autoridad.
	var result: Error = peer.create_server(port, MAX_PEOPLE - 1, 1)
	if result != OK:
		peer = null
		return _input_error("No se pudo escuchar en UDP %d; comprueba si está ocupado." % port, result)
	is_host = true
	active = true
	accepted = true
	local_id = 1
	_name = display_name.strip_edges()
	room_key = key if not key.is_empty() else Crypto.new().generate_random_bytes(8).hex_encode()
	participants = {1: _name}
	_last_sequences = {1: 0}
	_connect_peer_signals()
	status = "Prueba creada · anfitrión · UDP %d." % port
	changed.emit()
	return OK


func join_session(display_name: String, address: String, port: int, key: String, version: int = PROTOCOL) -> Error:
	if active:
		return _input_error("Desconecta la sesión actual antes de entrar en otra.")
	# IP literal en este ensayo: evita resolución DNS bloqueante en la interfaz.
	if not _valid_name(display_name) or not _valid_port(port) or not address.strip_edges().is_valid_ip_address():
		return _input_error("Revisa el nombre, la dirección IP y el puerto de 1024–65535.")
	if key.strip_edges().is_empty() or key.length() > 64:
		return _input_error("Introduce la clave que muestra el anfitrión.")
	close_session()
	peer = ENetMultiplayerPeer.new()
	var result: Error = peer.create_client(address.strip_edges(), port, 1)
	if result != OK:
		peer = null
		return _input_error("No se pudo iniciar la conexión (%d)." % result, result)
	active = true
	_name = display_name.strip_edges()
	room_key = key.strip_edges()
	_hello_version = version
	_started_ms = Time.get_ticks_msec()
	_connect_peer_signals()
	status = "Conectando con el anfitrión…"
	changed.emit()
	return OK


func request_signal() -> void:
	if not accepted:
		return
	_sequence += 1
	var request: Dictionary = {"type": "increment", "seq": _sequence}
	if is_host:
		_handle_host_packet(1, request)
	else:
		_send(1, request)


func close_session(message: String = "Sin conexión.") -> void:
	_closing = true
	if peer != null:
		peer.close()
	peer = null
	active = false
	accepted = false
	is_host = false
	participants.clear()
	_pending.clear()
	_last_sequences.clear()
	room_key = ""
	counter = 0
	revision = 0
	rejected_requests = 0
	local_id = 0
	_sequence = 0
	_hello_sent = false
	_closing = false
	status = message
	changed.emit()


func _process(_delta: float) -> void:
	if not active or peer == null:
		return
	peer.poll()
	if not is_host:
		var connection_status: int = peer.get_connection_status()
		if connection_status == MultiplayerPeer.CONNECTION_CONNECTED and not _hello_sent:
			_hello_sent = true
			local_id = peer.get_unique_id()
			_send(1, {"type": "hello", "version": _hello_version, "key": room_key, "name": _name})
		if connection_status == MultiplayerPeer.CONNECTION_DISCONNECTED:
			close_session("Se ha perdido la conexión con el anfitrión.")
			return
		if not accepted and Time.get_ticks_msec() - _started_ms >= TIMEOUT_MS:
			close_session("No se pudo entrar en 10 segundos. Revisa IP, puerto, clave y acceso de red.")
			return
	var remaining: int = MAX_PACKETS_PER_FRAME
	while peer != null and peer.get_available_packet_count() > 0 and remaining > 0:
		remaining -= 1
		var sender: int = peer.get_packet_peer()
		var packet: PackedByteArray = peer.get_packet()
		if packet.size() > MAX_PACKET_BYTES:
			_reject(sender, "Mensaje demasiado grande.")
			continue
		var parsed: Variant = JSON.parse_string(packet.get_string_from_utf8())
		if not parsed is Dictionary:
			_reject(sender, "Formato de mensaje inválido.")
			continue
		if is_host:
			_handle_host_packet(sender, parsed)
		elif sender == 1:
			_handle_server_packet(parsed)
	if is_host:
		for pending_id: int in _pending.keys():
			if Time.get_ticks_msec() - int(_pending[pending_id]) >= TIMEOUT_MS:
				peer.disconnect_peer(pending_id)
				_pending.erase(pending_id)


func _handle_host_packet(sender: int, message: Dictionary) -> void:
	if message.get("type") == "hello":
		if participants.has(sender):
			_reject(sender, "La conexión ya fue admitida.")
			return
		if message.get("version") != PROTOCOL:
			_reject(sender, "Versión de prueba incompatible.")
			return
		if message.get("key") != room_key:
			_reject(sender, "Clave incorrecta.")
			return
		if not _valid_name(message.get("name")) or participants.size() >= MAX_PEOPLE:
			_reject(sender, "Nombre inválido o prueba completa.")
			return
		participants[sender] = String(message["name"]).strip_edges()
		_last_sequences[sender] = 0
		_pending.erase(sender)
		revision += 1
		_broadcast()
		return
	if not participants.has(sender):
		_reject(sender, "Conexión no admitida.")
		return
	var sequence: Variant = message.get("seq")
	if message.get("type") != "increment" or not _is_integer(sequence) or sequence != int(_last_sequences[sender]) + 1:
		_reject(sender, "Solicitud inválida o repetida.")
		return
	_last_sequences[sender] = int(sequence)
	counter += 1
	revision += 1
	_broadcast()


func _handle_server_packet(message: Dictionary) -> void:
	if message.get("type") == "rejected":
		var reason: String = String(message.get("reason", "Solicitud rechazada.")).left(160)
		if accepted:
			notice.emit(reason)
		else:
			close_session(reason)
		return
	if message.get("type") != "snapshot":
		return
	var people: Variant = message.get("people")
	if not people is Array or people.is_empty() or people.size() > MAX_PEOPLE:
		return
	if not _is_integer(message.get("counter")) or not _is_integer(message.get("revision")):
		return
	var new_revision: int = int(message["revision"])
	if new_revision < revision or int(message["counter"]) < 0:
		return
	var next_participants: Dictionary = {}
	for person: Variant in people:
		if not person is Dictionary or not _is_integer(person.get("id")) or not _valid_name(person.get("name")):
			return
		var person_id: int = int(person["id"])
		if person_id <= 0 or next_participants.has(person_id):
			return
		next_participants[person_id] = person["name"]
	if not next_participants.has(1) or not next_participants.has(local_id):
		return
	participants = next_participants
	counter = int(message["counter"])
	revision = new_revision
	accepted = true
	status = "Conectado · anfitrión como autoridad."
	changed.emit()


func _broadcast() -> void:
	var people: Array[Dictionary] = []
	for id: int in participants:
		people.append({"id": id, "name": participants[id]})
	var snapshot: Dictionary = {"type": "snapshot", "counter": counter, "revision": revision, "people": people}
	for id: int in participants:
		if id != 1:
			_send(id, snapshot)
	changed.emit()


func _reject(sender: int, reason: String) -> void:
	if not is_host:
		return
	rejected_requests += 1
	if sender != 1:
		_send(sender, {"type": "rejected", "reason": reason})
	else:
		notice.emit(reason)


func _send(target: int, message: Dictionary) -> void:
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	peer.set_target_peer(target)
	peer.transfer_mode = MultiplayerPeer.TRANSFER_MODE_RELIABLE
	peer.transfer_channel = 0
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())


func _connect_peer_signals() -> void:
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(id: int) -> void:
	if is_host:
		_pending[id] = Time.get_ticks_msec()


func _on_peer_disconnected(id: int) -> void:
	if _closing:
		return
	if is_host:
		_pending.erase(id)
		if participants.has(id):
			participants.erase(id)
			_last_sequences.erase(id)
			revision += 1
			_broadcast()


func _input_error(message: String, code: Error = ERR_INVALID_PARAMETER) -> Error:
	status = message
	changed.emit()
	return code


func _valid_name(value: Variant) -> bool:
	if not value is String:
		return false
	var trimmed: String = value.strip_edges()
	return not trimmed.is_empty() and trimmed.length() <= 24 and not "\n" in trimmed and not "\r" in trimmed and not "\t" in trimmed


func _valid_port(value: int) -> bool:
	return value >= 1024 and value <= 65535


func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))


func _exit_tree() -> void:
	if peer != null:
		peer.close()
