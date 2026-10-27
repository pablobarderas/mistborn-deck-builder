extends Node

signal catalog_loaded(card_count: int)
signal catalog_failed(message: String)

const CARDS_PATH: String = "res://data/cartas.json"

var cartas: Dictionary = {}
var is_loaded: bool = false
var last_error: String = ""


func _ready() -> void:
	load_cards()


func load_cards(path: String = CARDS_PATH) -> bool:
	# Una recarga fallida no debe mantener un catálogo anterior como si fuera válido.
	cartas.clear()
	is_loaded = false
	last_error = ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("No se pudo abrir %s (error %s)." % [path, FileAccess.get_open_error()])
	var json_text: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(json_text) != OK:
		return _fail("JSON inválido en %s, línea %d: %s" % [path, json.get_error_line(), json.get_error_message()])
	if not json.data is Array:
		return _fail("El catálogo %s debe contener un array." % path)

	var pending_cards: Dictionary = {}
	var entries: Array = json.data
	for index: int in range(entries.size()):
		var entry: Variant = entries[index]
		if not entry is Dictionary:
			return _fail("%s, entrada %d: se esperaba un objeto." % [path, index + 1])
		var card_id: Variant = entry.get("id")
		if not card_id is String or str(card_id).strip_edges().is_empty():
			return _fail("%s, entrada %d: id ausente, vacío o no textual." % [path, index + 1])
		if pending_cards.has(card_id):
			return _fail("%s, entrada %d: id duplicado '%s'." % [path, index + 1, card_id])
		pending_cards[card_id] = entry

	cartas = pending_cards
	is_loaded = true
	catalog_loaded.emit(cartas.size())
	return true


func _fail(message: String) -> bool:
	last_error = message
	push_error(message)
	catalog_failed.emit(message)
	return false
