extends RefCounted
## Fixture explícito E2: promoción provisional sólo en memoria; mercado ficticio.
const Play = preload("res://scripts/game/local_competitive_play.gd")
const Base = preload("res://tests/funding_fixtures.gd")
const Bindings = preload("res://scripts/catalog/initial_competitive_bindings.gd")
const Setup = preload("res://scripts/game/game_setup.gd")
static var _cached: Dictionary = {}
static var _seeds: Dictionary = {}


static func catalog() -> Dictionary:
	if not _cached.is_empty():
		return _cached.duplicate(true)
	var result: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/inicio_competitivo.json"))
	result.id_catalogo = "e2_local_provisional_fixture"
	for card: Dictionary in result.cartas:
		card.revision = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
		if card.tipo == "personaje":
			# II se ejecuta como regla de compra, no como texto ni programa pendiente.
			card.habilidades.remove_at(1)
		if card.tipo == "pista_entrenamiento":
			for cell: Dictionary in card.rasgos.recorridos[0].casillas:
				cell.efectos = [{"op": "sin_efecto"}]
	result.fuentes.append({"id": "E2_FIXTURE", "tipo": "carta_fisica", "sha256": FileAccess.get_sha256("res://tests/local_competitive_fixtures.gd"), "descripcion": "Mercado ficticio y copia técnica de misiones para ensayo E2. No catálogo de producto.", "ruta": "res://tests/local_competitive_fixtures.gd", "url": null})
	var template: Dictionary = Base.definitions(Base.catalog()).test_action
	for id: String in Play.MARKET:
		var card: Dictionary = template.duplicate(true)
		card.id = id
		card.nombre = {"e2_mision": "Ensayo: misión", "e2_combate": "Ensayo: combate", "e2_monedas": "Ensayo: monedas", "e2_equilibrio": "Ensayo: equilibrio"}[id]
		card.cantidad = 82
		card.coste_compra = 2
		card.metales = ["peltre", "estano"]
		card.fuentes = [{"id": "E2_FIXTURE", "localizador": "Acción ficticia simple E2"}]
		var gains: Array = Play.MARKET[id]
		card.habilidades = [{"id": "primaria", "momento": "al_jugar", "condicion": {"op": "metal_asignado", "metales": ["peltre"]}, "limite_por_turno": null, "efectos": Play._effects(gains[0], gains[1], gains[2], 0)}]
		result.cartas.append(card)
	var missions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/misiones.json"))
	for card: Dictionary in missions.cartas:
		card.fuentes = [{"id": "E2_FIXTURE", "localizador": "Fixture de descriptor de misión " + card.id + "; reglas SRC-001/002, no promoción física"}]
		card.ruta_imagen = null
		card.revision = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
		result.cartas.append(card)
	_cached = result.duplicate(true)
	return result


static func manifest() -> Dictionary:
	var result: Dictionary = {"characters": [], "funding_id": "financiacion", "training_track_id": "pista_entrenamiento", "market_cards": [], "missions": [], "rival": null}
	for owner: String in Bindings.STARTERS:
		result.characters.append({"character_id": owner, "starters": Bindings.STARTERS[owner].duplicate()})
	var market: Array = Play.MARKET.keys()
	for index: int in 82:
		result.market_cards.append(market[index % market.size()])
	for number: int in range(1, 9):
		result.missions.append("mision_m%d" % number)
	return result


static func seats(count: int) -> Array:
	var result: Array = []
	for index: int in count:
		result.append({"player_id": "p%d" % (index + 1), "name": "Jugador %d" % (index + 1)})
	return result


static func supported_seed(count: int, after: int = 0) -> int:
	var key: String = str(count) + ":" + str(after)
	if _seeds.has(key):
		return _seeds[key]
	var content: Dictionary = Base.definitions(catalog())
	for card: Dictionary in content.values():
		card.cantidad = int(card.cantidad)
	for seed_value: int in range(after + 1, after + 2000):
		var prepared: Dictionary = Setup.new(content, "seed_probe").create("seed_probe", "competitivo", seats(count), "p1", manifest(), seed_value)
		if prepared.ok:
			var supported: bool = true
			for mission: Dictionary in prepared.snapshot.missions.values():
				supported = supported and mission.definition_id in Play.Mission.ACTIVE_DEFINITIONS
			if supported:
				_seeds[key] = seed_value
				return seed_value
	return -1


static func definition(id: String) -> Dictionary:
	for card: Dictionary in catalog().cartas:
		if card.id == id:
			return card.duplicate(true)
	return {}


static func intent(state: Dictionary, id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision, "tipo": kind, "payload": payload}
