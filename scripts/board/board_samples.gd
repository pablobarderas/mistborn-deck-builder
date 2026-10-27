extends RefCounted
## Contenido para explorar la interfaz. No es catálogo ni estado legal de partida.

static func market() -> Array[Dictionary]:
	return [
		{"id": "sample_vin", "name": "Vin", "kind": "ALIADA", "metal": "Acero", "cost": "5", "value": "+2 ataque", "art": 0, "color": Color("75b7dd"), "description": "Una aliada entre los tejados de Luthadel. Esta carta muestra el aspecto de una habilidad y su relación con un metal; no reproduce un efecto oficial."},
		{"id": "sample_kelsier", "name": "Kelsier", "kind": "ALIADO", "metal": "Latón", "cost": "6", "value": "+2 recurso", "art": 1, "color": Color("d4b77a"), "description": "El comienzo de una rebelión. Nombre y valores usados para explorar la interfaz; sus efectos deberán incorporarse desde una fuente verificada."},
		{"id": "sample_fund", "name": "Financiación", "kind": "ACCIÓN", "metal": "Cobre", "cost": "3", "value": "+2 recurso", "art": 2, "color": Color("d69b72"), "description": "Monedas, contactos y una oportunidad. Ejemplo visual de carta de recursos; no aplica efectos ni transcribe una carta del juego."},
		{"id": "sample_mists", "name": "Entre la bruma", "kind": "ACCIÓN", "metal": "Hierro", "cost": "4", "value": "+1 ataque", "art": 3, "color": Color("75b7dd"), "description": "La ciudad se pierde entre la niebla. Texto de muestra para valorar el tamaño de letra, el contraste y el espacio del detalle ampliado."},
		{"id": "sample_rebel", "name": "La rebelión", "kind": "ACCIÓN", "metal": "Peltre", "cost": "5", "value": "+2 ataque", "art": 1, "color": Color("ce8894"), "description": "Cada plan comienza con una decisión. Carta de muestra para revisar el estado seleccionado; el tablero no comprueba reglas de compra o combate."},
		{"id": "sample_city", "name": "Luthadel", "kind": "ACCIÓN", "metal": "Bronce", "cost": "4", "value": "+1 recurso", "art": 3, "color": Color("68b6a1"), "description": "Torres, canales y ceniza. Ejemplo para comparar los acentos de color con la base azul y grafito de la mesa."}
	]


static func hand() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index: int in 5:
		var card: Dictionary = market()[[2, 3, 0, 2, 4][index]].duplicate(true)
		card["id"] = "hand_%d" % index
		if index == 0 or index == 3:
			card["name"] = "Moneda de cobre"
			card["value"] = "+1 recurso"
			card["cost"] = "—"
		result.append(card)
	return result
