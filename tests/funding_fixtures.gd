extends RefCounted
## Contenido ficticio completo. Sólo test_funding representa la regla Funding.
## La revisión declarada del fixture NO incorpora cartas españolas al producto.

const Base = preload("res://tests/game_state_fixtures.gd")
const Funding = preload("res://scripts/game/funding_play.gd")


static func catalog() -> Dictionary:
	var cards: Array = []
	for pair: Array in [["test_funding", "funding"], ["test_action", "accion"], ["test_ally", "aliado"],
		["test_character", "personaje"], ["test_training_track", "pista_entrenamiento"], ["test_mission", "mision"],
		["test_rival", "rival"], ["test_domination", "dominacion"], ["test_enemy", "adversario"]]:
		var card: Dictionary = {"id": pair[0], "nombre": "Fixture " + pair[0], "tipo": pair[1], "cantidad": 50,
			"coste_compra": 0 if pair[1] in ["accion", "aliado"] else null,
			"texto_original": "Contenido ficticio para pruebas; no transcripción oficial.",
			"resumen": {"recurso": 1 if pair[1] == "funding" else 0, "ataque": 0}, "metales": [], "ruta_imagen": null,
			"fuentes": [{"id": "FIXTURE", "localizador": "Fixture técnico explícito, regla Funding SRC-001 p.11"}],
			"revision": {"estado": "verificada", "idioma_verificado": true, "dudas": []}, "vinculos": [], "rasgos": {},
			"habilidades": [{"id": "principal", "momento": "al_jugar", "condicion": {"op": "siempre"}, "limite_por_turno": null,
				"efectos": [{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"}] if pair[1] == "funding" else [{"op": "sin_efecto"}]}]}
		if pair[1] in ["mision", "pista_entrenamiento", "dominacion"]:
			card.rasgos = {"recorridos": [{"id": "track", "casillas": [{"id": "cell", "efectos": [{"op": "sin_efecto"}]}]}]}
			if pair[1] == "dominacion":
				card.rasgos.recorridos.append({"id": "reverse", "casillas": [{"id": "cell", "efectos": [{"op": "sin_efecto"}]}]})
		elif pair[1] == "rival":
			card.rasgos = {"salud": 20}
		elif pair[1] == "adversario":
			card.rasgos = {"escudos": 3}
		cards.append(card)
	return {"version_esquema": 1, "id_catalogo": "funding_fixture_es", "idioma": "es",
		"fuentes": [{"id": "FIXTURE", "tipo": "editorial", "descripcion": "Fuente técnica ficticia declarada para tests, no validación editorial.",
			"ruta": "res://tests/funding_fixtures.gd", "url": null}], "cartas": cards}


static func inerts(document: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for card: Dictionary in document.cartas:
		if card.id != "test_funding":
			result[card.id] = card.duplicate(true)
	return result


static func definitions(document: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for card: Dictionary in document.cartas:
		result[card.id] = card.duplicate(true)
	return result


static func snapshot(mode: String = "competitivo", count: int = 2) -> Dictionary:
	var state: Dictionary = Base.snapshot(mode, count)
	var doc: Dictionary = catalog()
	state.catalog_id = Funding.new(doc, "test_funding", inerts(doc)).catalog_identity()
	state.lifecycle = "en_curso"
	state.turn = {"number": 3, "active_id": "p1", "phase": "libre", "counters": {}}
	for player: Dictionary in state.players:
		player.ability_uses = {}
	for mission: Dictionary in state.missions.values():
		for player_id: String in mission.rewards:
			mission.rewards[player_id] = []
	state.instances.c1.definition_id = "test_funding"
	state.instances["funding_b"] = Base.instance("funding_b", "test_funding", "p1")
	state.instances["remaining"] = Base.instance("remaining", "test_action", "p1")
	state.instances["played"] = Base.instance("played", "test_ally", "p1")
	state.instances["foreign"] = Base.instance("foreign", "test_funding", "p2" if count > 1 else "p1")
	state.zones.p1_mano.cards = ["remaining", "c1", "funding_b"]
	state.zones.p1_juego.cards = ["played"]
	state.zones["p2_mano" if count > 1 else "p1_mazo"].cards.append("foreign")
	# IDs deliberadamente independientes de kind/holder_id.
	var renamed: Dictionary = {}
	for id: String in state.zones:
		var zone: Dictionary = state.zones[id]
		var new_id: String = "slot_" + str(renamed.size())
		zone.zone_id = new_id
		renamed[new_id] = zone
		if state.rival != null:
			for field: String in ["deck_zone", "discard_zone", "adversary_zone"]:
				if state.rival[field] == id:
					state.rival[field] = new_id
	state.zones = renamed
	return state
