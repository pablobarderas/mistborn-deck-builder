extends RefCounted
## Sólo Perseguir/misiones son reales. El combustible y demás componentes son
## fixtures ficticios; la revisión verificada de Perseguir existe sólo en memoria.

const F = preload("res://tests/integrated_missions_fixtures.gd")
const Play = preload("res://scripts/game/perseguir_play.gd")


static func catalog() -> Dictionary:
	var document: Dictionary = F.Missions.catalog()
	var card: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/perseguir.json"))
	document.version_esquema = 4
	document.id_catalogo = "perseguir_isolated_fixture"
	document.fuentes.append_array(card.fuentes)
	card.cartas[0].revision = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
	document.cartas.append(card.cartas[0])
	# v4 exige fuente física en TODAS las acciones verificadas. Esta fuente es
	# deliberadamente un fixture, nunca acreditación del contenido del juego.
	for source: Dictionary in document.fuentes:
		if source.id == "FIXTURE":
			source.tipo = "carta_fisica"
			source.sha256 = FileAccess.get_sha256(source.ruta)
	for definition: Dictionary in document.cartas:
		if definition.id == "test_action":
			definition.metales = ["bronce"]
	return document


static func inerts(document: Dictionary) -> Dictionary:
	var result: Dictionary = F.Missions.descriptors(document, false)
	result.erase("perseguir")
	return result


static func engine(document: Dictionary = {}) -> Play:
	if document.is_empty():
		document = catalog()
	return Play.new(document, inerts(document), F.Missions.training_profile(document), F.Missions.descriptors(document, true))


static func snapshot(count: int = 2, numbers: Array = [1, 5, 8]) -> Dictionary:
	var state: Dictionary = F.snapshot(numbers, count)
	state.catalog_id = Play.identity_for(catalog())
	state.instances.c1.definition_id = "perseguir"
	state.zones.p1_mazo.cards.erase("c2")
	state.zones.p1_mano.cards.append("c2")
	for player: Dictionary in state.players:
		player.turn_resources = {"recursos": 0, "ataque": 0, "mision": 0}
		player.burned = {}
		for token: Dictionary in player.metals:
			token.used_this_turn = false
		player.metals.append({"token_id": "bronce_" + player.player_id, "metal": "bronce", "exhausted": false, "used_this_turn": false})
	return state


static func payload(route: String = "primaria", apply_effect: bool = true, source: String = "bronce_p1", metal: Variant = "bronce") -> Dictionary:
	return {"instance_id": "c1", "ruta": route, "aplicar": apply_effect, "metal": metal,
		"origen": {} if route == "metal" or not apply_effect else {"tipo": "carta" if source == "c2" else "ficha", "id": source}}


static func intent(state: Dictionary, payload_value: Dictionary, id: String = "perseguir") -> Dictionary:
	return F.intent(state, id, "jugar_perseguir", payload_value)
