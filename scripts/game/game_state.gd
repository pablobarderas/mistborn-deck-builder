extends RefCounted
## Almacén privado de autoridad. No es API de cliente ni preparación reglamentaria.

const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
var _registry: Registry
var _definitions: Dictionary
var _catalog_id: String
var _snapshot: Dictionary = {}


func _init(definitions: Dictionary, catalog_id: String, registry: Registry = null) -> void:
	# El adaptador entrega definiciones ya validadas. Tests inyectan fixtures propios.
	_definitions = definitions.duplicate(true)
	_catalog_id = catalog_id
	_registry = registry if registry != null else Registry.new()


func try_load(document: Variant) -> Dictionary:
	var result: Dictionary = validate_candidate(document)
	if result.ok:
		_snapshot = document.duplicate(true)
	else:
		# Diagnóstico detallado solo en el resultado local; nunca un payload de red.
		push_warning("Estado de partida rechazado; se conserva el snapshot anterior.")
	return result


func validate_candidate(document: Variant) -> Dictionary:
	# Comprobación sin publicar. Solo la autoridad la usa antes de un commit.
	return Validator.new().validate(document, _definitions, _catalog_id, _registry)


func get_snapshot() -> Dictionary:
	# Snapshot completo y privado. La vista se construye por separado.
	return _snapshot.duplicate(true)


func get_definition(definition_id: String) -> Dictionary:
	return _definitions.get(definition_id, {}).duplicate(true)
