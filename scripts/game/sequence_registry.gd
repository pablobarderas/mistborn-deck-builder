extends RefCounted
## Registro cerrado de descriptores y código local. El snapshot sólo contiene datos.

const MAX_STEPS: int = 64
const MAX_OPTIONS: int = 16
const MAX_RECIPIENTS: int = 4
const MAX_INT: int = 9223372036854775807
const BASE_CONTEXT: Dictionary = {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id", "occurrence_id": "id"}
const ID_PREFIX: String = "resolution_"
var _operations: Dictionary = {}
var _programs: Dictionary = {}
var _valid: bool = true


func _init(registration: Dictionary = {}) -> void:
	if registration.is_empty():
		return
	_valid = _validate_registration(registration)
	if _valid:
		_operations = registration.operations.duplicate(true)
		_programs = registration.programs.duplicate(true)


func is_valid() -> bool:
	return _valid


func has_program(program_id: Variant) -> bool:
	return valid_id(program_id) and _programs.has(program_id)


func step_ids(program_id: String) -> Array:
	var ids: Array = []
	for step: Dictionary in _programs[program_id].steps:
		ids.append(step.step_id)
	return ids


func get_step(program_id: String, cursor: int) -> Dictionary:
	return _programs[program_id].steps[cursor].duplicate(true)


func is_window(step: Dictionary) -> bool:
	return _operations[step.operation].has("offer")


func offer(step: Dictionary, state: Dictionary, context: Dictionary) -> Variant:
	# Constructores y validadores no reciben la copia que se va a publicar.
	var pending: Variant = _operations[step.operation].offer.call(state.duplicate(true), context.duplicate(true), step.params.duplicate())
	return pending


func execute(step: Dictionary, state: Dictionary, context: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	var result: Variant = _operations[step.operation].execute.call(state, context.duplicate(true), step.params.duplicate(), rng, selected.duplicate())
	return result is bool and result


func valid_binding(state: Dictionary, resolution: Dictionary, definitions: Dictionary) -> bool:
	var program: Dictionary = _programs[resolution.program_id]
	var source: Variant = resolution.source_id
	if source == null:
		if not program.allow_null_source:
			return false
	elif not valid_id(source) or (not state.instances.has(source) and not definitions.has(source)):
		return false
	var context: Variant = resolution.context
	if not _matches_schema(context, program.context, state, definitions):
		return false
	if state.lifecycle != "en_curso" or context.turn_number <= 0 or context.turn_number != state.turn.number \
		or context.entry_phase != state.turn.phase or context.owner_id != state.turn.active_id:
		return false
	var owner: Dictionary = _player(state, context.owner_id)
	if owner.is_empty() or owner.eliminated or owner.health <= 0:
		return false
	var recipients: Variant = resolution.recipients
	if not recipients is Array or recipients.is_empty() or recipients.size() > MAX_RECIPIENTS:
		return false
	var seen: Dictionary = {}
	for recipient: Variant in recipients:
		if not valid_id(recipient) or _player(state, recipient).is_empty() or seen.has(recipient):
			return false
		seen[recipient] = true
	var scope: Variant = program.scope.call(state.duplicate(true), context.duplicate(true))
	return scope is Array and recipients == scope


func valid_pending(value: Variant, recipients: Array) -> bool:
	if not exact_keys(value, ["kind", "recipients", "options", "min", "max"]):
		return false
	if not value.kind is String or not value.kind in ["eleccion", "reaccion"]:
		return false
	if not value.recipients is Array or value.recipients.size() != 1 or not value.recipients[0] in recipients:
		return false
	if not value.options is Array or value.options.size() > MAX_OPTIONS:
		return false
	if typeof(value.min) != TYPE_INT or typeof(value.max) != TYPE_INT or value.min < 0 \
		or value.max <= 0 or value.min > value.max or value.max > value.options.size():
		return false
	var seen: Dictionary = {}
	for option: Variant in value.options:
		if not valid_id(option) or seen.has(option):
			return false
		seen[option] = true
	return true


func _validate_registration(registration: Dictionary) -> bool:
	if not exact_keys(registration, ["operations", "programs"]) or not registration.operations is Dictionary or not registration.programs is Dictionary:
		return false
	var operations: Dictionary = registration.operations
	for operation_id: Variant in operations:
		var op: Variant = operations[operation_id]
		var fields: Array = ["params", "validate_params", "execute"]
		if op is Dictionary and op.has("offer"):
			fields.append("offer")
		if not valid_id(operation_id) or not exact_keys(op, fields) or not _valid_schema(op.params, false):
			return false
		if not _valid_callable(op.execute, [TYPE_DICTIONARY, TYPE_DICTIONARY, TYPE_DICTIONARY, TYPE_OBJECT, TYPE_ARRAY], TYPE_BOOL) \
			or not _valid_callable(op.validate_params, [TYPE_DICTIONARY], TYPE_BOOL) \
			or (op.has("offer") and not _valid_callable(op.offer, [TYPE_DICTIONARY, TYPE_DICTIONARY, TYPE_DICTIONARY], TYPE_DICTIONARY)):
			return false
	for program_id: Variant in registration.programs:
		var program: Variant = registration.programs[program_id]
		if not valid_id(program_id) or not exact_keys(program, ["steps", "context", "scope", "allow_null_source"]):
			return false
		if not _valid_schema(program.context, true) or not _valid_callable(program.scope, [TYPE_DICTIONARY, TYPE_DICTIONARY], TYPE_ARRAY) or not program.allow_null_source is bool:
			return false
		for field: String in BASE_CONTEXT:
			if program.context.get(field) != BASE_CONTEXT[field]:
				return false
		if not program.steps is Array or program.steps.is_empty() or program.steps.size() > MAX_STEPS:
			return false
		var seen: Dictionary = {}
		for step: Variant in program.steps:
			if not exact_keys(step, ["step_id", "operation", "params"]) or not valid_id(step.step_id) or seen.has(step.step_id):
				return false
			if not valid_id(step.operation) or not operations.has(step.operation):
				return false
			var op: Dictionary = operations[step.operation]
			if not _matches_schema(step.params, op.params, {}, {}):
				return false
			var valid_params: Variant = op.validate_params.call(step.params.duplicate())
			if not valid_params is bool or not valid_params:
				return false
			seen[step.step_id] = true
	return true


func _valid_schema(schema: Variant, allow_references: bool) -> bool:
	if not schema is Dictionary:
		return false
	var types: Array = ["id", "int", "bool"]
	if allow_references:
		types.append_array(["player_id", "instance_id", "definition_id"])
	for field: Variant in schema:
		if not valid_id(field) or not schema[field] is String or not schema[field] in types:
			return false
	return true


func _matches_schema(value: Variant, schema: Dictionary, state: Dictionary, definitions: Dictionary) -> bool:
	if not exact_keys(value, schema.keys()):
		return false
	for field: String in schema:
		var item: Variant = value[field]
		match schema[field]:
			"int":
				if typeof(item) != TYPE_INT:
					return false
			"bool":
				if not item is bool:
					return false
			_:
				if not valid_id(item):
					return false
				match schema[field]:
					"player_id":
						if _player(state, item).is_empty():
							return false
					"instance_id":
						if not state.instances.has(item):
							return false
					"definition_id":
						if not definitions.has(item):
							return false
	return true


func _player(state: Dictionary, player_id: String) -> Dictionary:
	for player: Dictionary in state.players:
		if player.player_id == player_id:
			return player
	return {}


func _valid_callable(value: Variant, argument_types: Array, result_type: int) -> bool:
	if not value is Callable or not value.is_valid() or value.get_argument_count() != argument_types.size() \
		or value.get_unbound_arguments_count() != 0:
		return false
	# Sólo funciones GDScript con firma inspeccionable. No ejecutar callbacks para
	# probar compatibilidad: un paso incompatible tras una pausa debe fallar ahora.
	var target: Object = value.get_object()
	if not target is GDScript:
		return false
	var bound: Array = value.get_bound_arguments()
	for method: Dictionary in target.get_script_method_list():
		if method.name != value.get_method():
			continue
		if not method.flags & METHOD_FLAG_STATIC or method.args.size() != argument_types.size() + bound.size():
			return false
		if not _accepts_type(method.return, result_type):
			return false
		for index: int in argument_types.size():
			if not _accepts_type(method.args[index], argument_types[index]):
				return false
		for index: int in bound.size():
			var kind: int = typeof(bound[index])
			if not kind in [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING] \
				or not _accepts_type(method.args[argument_types.size() + index], kind):
				return false
		return true
	return false


func _accepts_type(argument: Dictionary, kind: int) -> bool:
	if argument.type == TYPE_NIL and argument.usage & PROPERTY_USAGE_NIL_IS_VARIANT:
		return true
	if argument.type != kind:
		return false
	if kind in [TYPE_ARRAY, TYPE_DICTIONARY]:
		# Los argumentos suministrados son contenedores sin tipos genéricos.
		return argument.hint == PROPERTY_HINT_NONE
	if kind == TYPE_OBJECT:
		return argument.class_name in [&"RandomNumberGenerator", &"RefCounted", &"Object"]
	return true


static func valid_id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.length() <= 128 and value.is_valid_identifier()


static func allocated_id(value: Variant, next_id: Variant) -> bool:
	if not valid_id(value) or not value.begins_with(ID_PREFIX) or typeof(next_id) != TYPE_INT:
		return false
	var suffix: String = value.substr(ID_PREFIX.length())
	if not suffix.is_valid_int():
		return false
	var number: int = suffix.to_int()
	return number >= 0 and number < next_id and value == ID_PREFIX + str(number)


static func exact_keys(value: Variant, keys: Array) -> bool:
	if not value is Dictionary or value.size() != keys.size():
		return false
	for key: String in keys:
		if not value.has(key):
			return false
	return true
