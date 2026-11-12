extends RefCounted
## Misiones reales + componentes inertes y reservas NETAS ficticias de autoridad.
const Base = preload("res://tests/game_state_fixtures.gd")
const FundingFixtures = preload("res://tests/funding_fixtures.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const Training = preload("res://scripts/game/training_advance.gd")
const Play = preload("res://scripts/game/mission_play.gd")


class LatestSource extends Play.SnapshotSource:
	var _entries: Dictionary = {}

	func confirm(profile_id: String, state: Dictionary) -> void:
		var key: String = profile_id + ":" + state.match_id
		if not _entries.has(key) or _entries[key].revision < state.revision:
			_entries[key] = state.duplicate(true)

	func latest(match_id: String, profile_id: String) -> Dictionary:
		var key: String = profile_id + ":" + match_id
		if not _entries.has(key):
			return {}
		return {"profile_id": profile_id, "snapshot": _entries[key].duplicate(true)}

	func select(match_id: String, profile_id: String, revision: int) -> Dictionary:
		var entry: Dictionary = latest(match_id, profile_id)
		return entry if not entry.is_empty() and entry.snapshot.revision == revision else {}


static func catalog() -> Dictionary:
	var document: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/misiones.json"))
	var extra: Dictionary = FundingFixtures.catalog()
	document.id_catalogo = "mission_advance_fixture_es"
	document.fuentes.append_array(extra.fuentes)
	for card: Dictionary in extra.cartas:
		if card.tipo in ["accion", "aliado", "personaje", "pista_entrenamiento"]:
			document.cartas.append(card)
	return document


static func descriptors(document: Dictionary, missions: bool) -> Dictionary:
	var result: Dictionary = {}
	for card: Dictionary in document.cartas:
		if (card.tipo == "mision") == missions:
			result[card.id] = card.duplicate(true)
	return result


static func training_profile(document: Dictionary) -> Dictionary:
	return {"catalog_id": Play.identity_for(document), "track_id": "test_training_track",
		"definition": descriptors(document, false).test_training_track,
		"marks": Array(Training.PANEL)}


static func engine(document: Dictionary = {}) -> Play:
	if document.is_empty():
		document = catalog()
	return Play.new(document, descriptors(document, false), training_profile(document), descriptors(document, true))


static func snapshot(identity: String, count: int = 2) -> Dictionary:
	var state: Dictionary = Base.snapshot("competitivo", count)
	state.catalog_id = identity
	state.lifecycle = "en_curso"
	state.turn = {"number": 3, "active_id": "p1", "phase": "libre", "counters": {}}
	state.outcome = null
	state.missions = {}
	for number: int in [5, 6, 7]:
		var mission: Dictionary = {"definition_id": "mision_m%d" % number, "progress": {}, "rewards": {}, "arrival_order": [], "first_arrivals": {}}
		for position: int in range(1, 13):
			mission.first_arrivals["p%02d" % position] = null
		for player: Dictionary in state.players:
			mission.progress[player.player_id] = 0
			mission.rewards[player.player_id] = []
		state.missions["mission_%d" % number] = mission
	for player: Dictionary in state.players:
		player.ability_uses = {}
		player.health = 30
		player.burn_limit = 1
		player.turn_resources.mision = 36
	return state


static func intent(state: Dictionary, mission_id: String, action_id: String) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": action_id,
		"expected_revision": state.revision, "tipo": Play.ACTION_ID, "payload": {"mission_id": mission_id}}
