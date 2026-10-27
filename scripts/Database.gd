extends Node

signal catalog_loaded(card_count: int)
signal catalog_failed(message: String)

const CARDS_PATH: String = "res://data/cartas.json"
const Validator = preload("res://scripts/catalog/catalog_validator.gd")
const MAX_CATALOG_BYTES: int = 4194304

var _cards: Dictionary = {}
var _verified: Dictionary = {}
var cartas: Dictionary:
	get:
		return _cards.duplicate(true)
var is_loaded: bool = false
var last_error: String = ""
var catalog_warnings: PackedStringArray = []
var counts: Dictionary = {}
var catalog_id: String = ""


func _ready() -> void:
	load_cards()


func load_cards(path: String = CARDS_PATH) -> bool:
	# Una recarga fallida no debe mantener un catálogo anterior como si fuera válido.
	_cards.clear()
	_verified.clear()
	is_loaded = false
	last_error = ""
	catalog_warnings.clear()
	counts.clear()
	catalog_id = ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("No se pudo abrir %s (error %s)." % [path, FileAccess.get_open_error()])
	if file.get_length() > MAX_CATALOG_BYTES:
		file.close()
		return _fail("El catálogo %s supera el límite técnico de 4 MiB." % path)
	var json_text: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(json_text) != OK:
		return _fail("JSON inválido en %s, línea %d: %s" % [path, json.get_error_line(), json.get_error_message()])
	var validation: Dictionary = Validator.new().validate(json.data)
	if not validation["ok"]:
		return _fail("Catálogo inválido %s:\n%s" % [path, "\n".join(validation["errors"])])
	_cards = validation["cards"]
	_verified = validation["verified"]
	catalog_warnings = validation["warnings"]
	counts = validation["counts"]
	catalog_id = json.data["id_catalogo"]
	is_loaded = true
	catalog_loaded.emit(_cards.size())
	return true


func get_definition(id: String) -> Dictionary:
	return _cards.get(id, {}).duplicate(true)


func get_verified_definitions() -> Dictionary:
	# Verificada significa revisión de contenido declarada, no efectos implementados.
	return _verified.duplicate(true)


func _fail(message: String) -> bool:
	last_error = message
	push_error(message)
	catalog_failed.emit(message)
	return false
