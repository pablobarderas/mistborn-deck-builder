extends RefCounted
## Única autoridad lógica. Los manejadores son código local fiable, nunca datos del cliente.

const State = preload("res://scripts/game/game_state.gd")
const ViewBuilder = preload("res://scripts/game/game_projection.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Resolver = preload("res://scripts/game/sequence_resolver.gd")
const ACTION_VERSION: int = 1
const START_TURN_ACTION: String = "iniciar_turno"
const START_TURN_ID_PREFIX: String = "inicio_"
const CLEANUP_ACTION: String = "cerrar_limpieza"
const CLEANUP_ID_PREFIX: String = "limpieza_"
const MAX_ACTION_NODES: int = 256
const MAX_CANONICAL_LENGTH: int = 4096
var _state: RefCounted
var _handlers: Dictionary
var _starters: Dictionary
var _resolver: Resolver
var _remaining_nodes: int = MAX_ACTION_NODES


func _init(definitions: Dictionary, catalog_id: String, handlers: Dictionary = {}, registry: Registry = null, starters: Dictionary = {}) -> void:
	if registry == null:
		registry = Registry.new()
	_state = State.new(definitions, catalog_id, registry)
	_handlers = handlers.duplicate()
	_starters = starters.duplicate()
	_resolver = Resolver.new(registry, definitions)


func load_authority_snapshot(document: Variant) -> Dictionary:
	# Solo autoridad y tests pueden llamar esta API. Nunca se conecta a un mensaje remoto.
	return _state.try_load(document)


func get_authority_snapshot() -> Dictionary:
	return _state.get_snapshot()


func get_view(recipient_id: String) -> Dictionary:
	return ViewBuilder.new().project(_state.get_snapshot(), recipient_id)


func submit(actor_id: String, input: Variant) -> Dictionary:
	return _submit(actor_id, input)


func _submit(actor_id: String, input: Variant, internal_start: Callable = Callable(), internal_action: String = START_TURN_ACTION) -> Dictionary:
	var current: Dictionary = _state.get_snapshot()
	if current.is_empty():
		return _reject("estado_invalido", 0)
	var revision: int = current.revision
	if not _actor_exists(current.players, actor_id):
		return _reject("identidad_no_autorizada", revision)
	var syntax: String = _check_syntax(input)
	if not syntax.is_empty():
		return _reject(syntax, revision)
	var intent: Dictionary = input
	var internal_type: bool = intent.tipo in [START_TURN_ACTION, CLEANUP_ACTION]
	var internal_id: bool = intent.action_id.begins_with(START_TURN_ID_PREFIX) or intent.action_id.begins_with(CLEANUP_ID_PREFIX)
	if internal_start.is_valid():
		var prefix: String = START_TURN_ID_PREFIX if internal_action == START_TURN_ACTION else CLEANUP_ID_PREFIX
		if intent.tipo != internal_action or not intent.action_id.begins_with(prefix):
			return _reject("formato_invalido", revision)
	elif internal_type or internal_id:
		return _reject("accion_no_soportada", revision)
	if intent.match_id != current.match_id:
		return _reject("partida_incorrecta", revision)
	var canonical: String = _canonical(intent)
	if canonical.length() > MAX_CANONICAL_LENGTH:
		return _reject("formato_invalido", revision)
	var receipts: Dictionary = current.authority.receipts
	if receipts.has(actor_id) and receipts[actor_id].has(intent.action_id):
		var old: Dictionary = receipts[actor_id][intent.action_id]
		if old.canonical != canonical:
			return _reject("id_reutilizado", revision)
		return _accepted(intent.action_id, old.revision_aplicada)
	if intent.expected_revision != revision:
		return _reject("revision_obsoleta", revision)
	var responding: bool = intent.tipo == "responder"
	var starter: Variant = null if internal_type else _starters.get(intent.tipo)
	var handler: Variant = internal_start if internal_type else _handlers.get(intent.tipo)
	if current.resolution != null:
		if not responding:
			return _reject("accion_ilegal", revision)
		if not _valid_response(current.resolution, actor_id, intent.payload):
			return _reject("eleccion_invalida", revision)
	else:
		if not responding and not _valid_callable(starter) and not _valid_callable(handler):
			return _reject("accion_no_soportada", revision)
		if responding or current.lifecycle != "en_curso" or current.turn.active_id != actor_id:
			return _reject("accion_ilegal", revision)
	if revision == Registry.MAX_INT:
		push_warning("Acción rechazada: contador de revisiones agotado.")
		return _reject("estado_invalido", revision)
	var candidate: Dictionary = current.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = current.authority.rng_seed
	rng.state = current.authority.rng_state
	var payload: Dictionary = intent.payload.duplicate(true)
	var sequence: Resolver.Result
	if responding:
		sequence = _resolver.resume(candidate, payload.options, rng)
	elif _valid_callable(starter):
		# El adaptador sólo propone un inicio. Su copia y su resultado no son un commit.
		var request: Variant = starter.call(current.duplicate(true), actor_id, payload)
		if request is String:
			return _reject(_public_error(request), revision)
		sequence = _resolver.begin(candidate, actor_id, request, rng)
	else:
		var result: Variant = handler.call(candidate, actor_id, payload, rng)
		if not result is String or not result.is_empty():
			if internal_type and result is String and result == "regla_pendiente":
				return _reject("regla_pendiente", revision)
			return _reject(_public_error(result), revision)
	if sequence != null:
		match sequence.status:
			Resolver.Result.Status.ILLEGAL:
				return _reject("accion_ilegal", revision)
			Resolver.Result.Status.INVALID:
				return _reject("estado_invalido", revision)
	if not _protected_fields(candidate, current):
		return _reject("estado_invalido", revision)
	if internal_type:
		var expected_turn: Dictionary = current.turn.duplicate(true)
		if internal_action == START_TURN_ACTION:
			expected_turn.phase = "libre"
		else:
			if current.mode != "competitivo" or current.turn.number == Registry.MAX_INT:
				return _reject("estado_invalido", revision)
			expected_turn.number += 1
			expected_turn.phase = "inicio"
			var index: int = current.player_order.find(actor_id)
			for offset: int in range(1, current.player_order.size()):
				var next_id: String = current.player_order[(index + offset) % current.player_order.size()]
				for player: Dictionary in current.players:
					if player.player_id == next_id and not player.eliminated:
						expected_turn.active_id = next_id
						break
				if expected_turn.active_id != actor_id:
					break
		if not candidate.get("turn") is Dictionary or candidate.turn != expected_turn \
			or not candidate.get("lifecycle") is String or candidate.lifecycle != current.lifecycle:
			return _reject("estado_invalido", revision)
	if sequence != null:
		if candidate.get("turn") != current.turn or candidate.get("lifecycle") != current.lifecycle:
			return _reject("estado_invalido", revision)
		if sequence.status == Resolver.Result.Status.PAUSED:
			candidate.resolution = sequence.resolution
		else:
			var ledger: Dictionary = candidate.authority.completed_sequences
			if ledger.has(sequence.closed_id):
				return _reject("estado_invalido", revision)
			sequence.close["revision_aplicada"] = revision + 1
			ledger[sequence.closed_id] = sequence.close
			candidate.resolution = null
	candidate.revision = revision + 1
	candidate.authority.rng_state = rng.state
	if not candidate.authority.receipts.has(actor_id):
		candidate.authority.receipts[actor_id] = {}
	candidate.authority.receipts[actor_id][intent.action_id] = {"canonical": canonical, "revision_aplicada": candidate.revision}
	var validation: Dictionary = _state.try_load(candidate)
	if not validation.ok:
		return _reject("estado_invalido", revision)
	return _accepted(intent.action_id, candidate.revision)


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if candidate.is_typed() or candidate.is_read_only():
		return false
	for key: String in ["version_esquema", "version_motor", "catalog_id", "match_id", "mode", "player_order", "revision", "resolution"]:
		if not candidate.has(key) or typeof(candidate[key]) != typeof(current[key]) or candidate[key] != current[key]:
			return false
	var authority: Variant = candidate.get("authority")
	if not authority is Dictionary or authority.is_typed() or authority.is_read_only():
		return false
	for key: String in ["receipts", "completed_sequences", "rng_seed", "rng_state"]:
		if not authority.has(key) or typeof(authority[key]) != typeof(current.authority[key]) or authority[key] != current.authority[key]:
			return false
	if authority.receipts.is_typed() or authority.completed_sequences.is_typed() \
		or authority.receipts.is_read_only() or authority.completed_sequences.is_read_only():
		return false
	for per_player: Dictionary in authority.receipts.values():
		if per_player.is_typed() or per_player.is_read_only():
			return false
	return typeof(authority.get("next_id")) == TYPE_INT and authority.next_id >= current.authority.next_id


func _public_error(value: Variant) -> String:
	# Los manejadores sólo devuelven códigos de la lista, sin texto de contenido privado.
	if value is String and value in ["formato_invalido", "accion_ilegal", "eleccion_invalida", "estado_invalido"]:
		return value
	return "estado_invalido"


func _valid_callable(value: Variant) -> bool:
	return value is Callable and value.is_valid()


func _check_syntax(input: Variant) -> String:
	_remaining_nodes = MAX_ACTION_NODES
	if not _plain(input, 0) or not input is Dictionary:
		return "formato_invalido"
	var intent: Dictionary = input
	if not _keys(intent, ["version_accion", "match_id", "action_id", "expected_revision", "tipo", "payload"]):
		return "formato_invalido"
	if typeof(intent.version_accion) != TYPE_INT or intent.version_accion != ACTION_VERSION:
		return "version_incompatible"
	if not _id(intent.match_id) or not _id(intent.action_id) or not _id(intent.tipo):
		return "formato_invalido"
	if typeof(intent.expected_revision) != TYPE_INT or intent.expected_revision < 0 or not intent.payload is Dictionary:
		return "formato_invalido"
	return ""


func _valid_response(resolution: Dictionary, actor_id: String, payload: Dictionary) -> bool:
	var pending: Variant = resolution.pending
	if not pending is Dictionary or not _keys(payload, ["resolution_id", "step_id", "options"]):
		return false
	if not _id(payload.resolution_id) or not _id(payload.step_id):
		return false
	if payload.resolution_id != resolution.resolution_id or payload.step_id != resolution.steps[resolution.cursor]:
		return false
	if not actor_id in pending.recipients or not payload.options is Array:
		return false
	var selected: Array = payload.options
	if selected.size() < pending.min or selected.size() > pending.max:
		return false
	var seen: Dictionary = {}
	for option: Variant in selected:
		if not option is String or not option in pending.options or seen.has(option):
			return false
		seen[option] = true
	return true


func _actor_exists(players: Array, actor_id: String) -> bool:
	for player: Dictionary in players:
		if player.player_id == actor_id:
			return true
	return false


func _keys(value: Dictionary, expected: Array) -> bool:
	if value.size() != expected.size():
		return false
	for key: String in expected:
		if not value.has(key):
			return false
	return true


func _id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.length() <= 128 and value.is_valid_identifier()


func _plain(value: Variant, depth: int) -> bool:
	_remaining_nodes -= 1
	if depth > 8 or _remaining_nodes < 0:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return not value is String or value.length() <= 1024
		TYPE_ARRAY, TYPE_DICTIONARY:
			if value.size() > MAX_ACTION_NODES:
				return false
			for key: Variant in value:
				if value is Dictionary and (not key is String or not _plain(value[key], depth + 1)):
					return false
				if value is Array and not _plain(key, depth + 1):
					return false
			return true
	return false


func _canonical(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return "n"
		TYPE_BOOL:
			return "b1" if value else "b0"
		TYPE_INT:
			return "i" + str(value) + ";"
		TYPE_STRING:
			return "s" + str(value.length()) + ":" + value
		TYPE_ARRAY:
			var result: String = "a" + str(value.size()) + "["
			for item: Variant in value:
				result += _canonical(item)
			return result + "]"
		TYPE_DICTIONARY:
			var result: String = "d" + str(value.size()) + "{"
			var keys: Array = value.keys()
			keys.sort()
			for key: String in keys:
				result += _canonical(key) + _canonical(value[key])
			return result + "}"
	return ""


func _reject(code: String, revision: int) -> Dictionary:
	return {"ok": false, "codigo": code, "revision": revision}


func _accepted(action_id: String, applied: int) -> Dictionary:
	return {"ok": true, "codigo": "aceptada", "action_id": action_id, "revision": applied, "revision_aplicada": applied}
