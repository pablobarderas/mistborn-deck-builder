extends RefCounted
## Única autoridad lógica. Los manejadores son código local fiable, nunca datos del cliente.

const State = preload("res://scripts/game/game_state.gd")
const ViewBuilder = preload("res://scripts/game/game_projection.gd")
const ACTION_VERSION: int = 1
const MAX_ACTION_NODES: int = 256
const MAX_CANONICAL_LENGTH: int = 4096
var _state: RefCounted
var _handlers: Dictionary
var _remaining_nodes: int = MAX_ACTION_NODES


func _init(definitions: Dictionary, catalog_id: String, handlers: Dictionary = {}) -> void:
	_state = State.new(definitions, catalog_id)
	_handlers = handlers.duplicate()


func load_authority_snapshot(document: Variant) -> Dictionary:
	# Solo autoridad y tests pueden llamar esta API. Nunca se conecta a un mensaje remoto.
	return _state.try_load(document)


func get_authority_snapshot() -> Dictionary:
	return _state.get_snapshot()


func get_view(recipient_id: String) -> Dictionary:
	return ViewBuilder.new().project(_state.get_snapshot(), recipient_id)


func submit(actor_id: String, input: Variant) -> Dictionary:
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
	if not _handlers.has(intent.tipo) or not _handlers[intent.tipo] is Callable or not _handlers[intent.tipo].is_valid():
		return _reject("accion_no_soportada", revision)
	if current.resolution != null:
		if intent.tipo != "responder":
			return _reject("accion_ilegal", revision)
		if not _valid_response(current.resolution, actor_id, intent.payload):
			return _reject("eleccion_invalida", revision)
	else:
		if intent.tipo == "responder" or current.lifecycle != "en_curso" or current.turn.active_id != actor_id:
			return _reject("accion_ilegal", revision)
	var candidate: Dictionary = current.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = current.authority.rng_seed
	rng.state = current.authority.rng_state
	var result: Variant = _handlers[intent.tipo].call(candidate, actor_id, intent.payload.duplicate(true), rng)
	if not result is String:
		return _reject("estado_invalido", revision)
	if not result.is_empty():
		# El manejador solo devuelve códigos de la lista, sin texto de contenido privado.
		if result in ["formato_invalido", "accion_ilegal", "eleccion_invalida", "estado_invalido"]:
			return _reject(result, revision)
		return _reject("estado_invalido", revision)
	if not _state.validate_candidate(candidate).ok:
		return _reject("estado_invalido", revision)
	for key: String in ["version_esquema", "version_motor", "catalog_id", "match_id", "mode", "player_order", "revision"]:
		if candidate[key] != current[key]:
			return _reject("estado_invalido", revision)
	if candidate.authority.receipts != current.authority.receipts or candidate.authority.rng_seed != current.authority.rng_seed:
		return _reject("estado_invalido", revision)
	if candidate.authority.next_id < current.authority.next_id:
		return _reject("estado_invalido", revision)
	candidate.revision = revision + 1
	candidate.authority.rng_state = rng.state
	if not candidate.authority.receipts.has(actor_id):
		candidate.authority.receipts[actor_id] = {}
	candidate.authority.receipts[actor_id][intent.action_id] = {"canonical": canonical, "revision_aplicada": candidate.revision}
	var validation: Dictionary = _state.try_load(candidate)
	if not validation.ok:
		return _reject("estado_invalido", revision)
	return _accepted(intent.action_id, candidate.revision)


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
