extends Node

var cartas: Dictionary = {}

func _ready():
	var file = FileAccess.open("res://data/cartas.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el archivo cartas.json")
		return
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("Error al parsear JSON: ", json.get_error_message())
		return
	var data = json.data
	if data is Array:
		for carta in data:
			cartas[carta.id] = carta
	else:
		push_error("El JSON no contiene un array")
