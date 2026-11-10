extends RefCounted
## Ejecuta un segmento sobre la copia de P07 y devuelve su frontera privada.

const Registry = preload("res://scripts/game/sequence_registry.gd")

class Result:
	enum Status { ILLEGAL, INVALID, PAUSED, CLOSED }
	var status: Status
	var resolution: Dictionary = {}
	var closed_id: String
	var close: Dictionary = {}

	func _init(value: Status) -> void:
		status = value


var _registry: Registry
var _definitions: Dictionary


func _init(registry: Registry, definitions: Dictionary) -> void:
	_registry = registry
	_definitions = definitions.duplicate(true)


func begin(state: Dictionary, actor_id: String, request: Variant, rng: RandomNumberGenerator) -> Result:
	if not Registry.exact_keys(request, ["program_id", "source_id", "context", "recipients"]) or not _registry.has_program(request.program_id):
		return Result.new(Result.Status.INVALID)
	if state.resolution != null or not _registry.valid_binding(state, request, _definitions) or request.context.owner_id != actor_id:
		return Result.new(Result.Status.ILLEGAL)
	for closed: Dictionary in state.authority.completed_sequences.values():
		if closed.occurrence_id == request.context.occurrence_id:
			return Result.new(Result.Status.ILLEGAL)
	var next_id: int = state.authority.next_id
	if next_id == Registry.MAX_INT:
		push_warning("Secuencia rechazada: contador de identificadores agotado.")
		return Result.new(Result.Status.INVALID)
	var resolution: Dictionary = request.duplicate(true)
	resolution["resolution_id"] = Registry.ID_PREFIX + str(next_id)
	resolution["steps"] = _registry.step_ids(resolution.program_id)
	resolution["cursor"] = 0
	resolution["pending"] = null
	state.authority.next_id += 1
	return _advance(state, resolution, rng)


func resume(state: Dictionary, selected: Array, rng: RandomNumberGenerator) -> Result:
	var resolution: Dictionary = state.resolution.duplicate(true)
	var step: Dictionary = _registry.get_step(resolution.program_id, resolution.cursor)
	# La respuesta ya pasó la comprobación de actor, ventana y opciones de P07.
	if not _registry.valid_binding(state, resolution, _definitions) or _registry.offer(step, state, resolution.context) != resolution.pending:
		return Result.new(Result.Status.ILLEGAL)
	if not _registry.execute(step, state, resolution.context, rng, selected):
		return Result.new(Result.Status.ILLEGAL)
	resolution.cursor += 1
	resolution.pending = null
	return _advance(state, resolution, rng)


func _advance(state: Dictionary, resolution: Dictionary, rng: RandomNumberGenerator) -> Result:
	while true:
		if not _registry.valid_binding(state, resolution, _definitions):
			return Result.new(Result.Status.INVALID)
		if resolution.cursor == resolution.steps.size():
			var result: Result = Result.new(Result.Status.CLOSED)
			result.closed_id = resolution.resolution_id
			result.close = {"program_id": resolution.program_id, "occurrence_id": resolution.context.occurrence_id,
				"owner_id": resolution.context.owner_id, "turn_number": resolution.context.turn_number}
			return result
		var step: Dictionary = _registry.get_step(resolution.program_id, resolution.cursor)
		if _registry.is_window(step):
			var pending: Variant = _registry.offer(step, state, resolution.context)
			if pending == null:
				return Result.new(Result.Status.ILLEGAL)
			if not _registry.valid_pending(pending, resolution.recipients):
				return Result.new(Result.Status.INVALID)
			resolution.pending = pending.duplicate(true)
			var result: Result = Result.new(Result.Status.PAUSED)
			result.resolution = resolution
			return result
		if not _registry.execute(step, state, resolution.context, rng, []):
			return Result.new(Result.Status.ILLEGAL)
		resolution.cursor += 1
	return Result.new(Result.Status.INVALID)
