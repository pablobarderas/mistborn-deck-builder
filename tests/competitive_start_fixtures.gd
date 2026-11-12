extends RefCounted
## Componentes inertes ficticios para INI-01–05 y fuente de autoridad de prueba.

const Base = preload("res://tests/game_state_fixtures.gd")
const CatalogValidator = preload("res://scripts/catalog/catalog_validator.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const FundingFixtures = preload("res://tests/funding_fixtures.gd")
const Start = preload("res://scripts/game/competitive_start.gd")
const FUNDING_ID: String = "test_funding"
const MATCH_ID: String = "test_match"
const TRACK_ID: String = "test_training_track"


class LatestSource extends Start.SnapshotSource:
	var _profiles: Dictionary = {}

	func confirm(profile_id: String, snapshot: Dictionary) -> void:
		if not _profiles.has(profile_id):
			_profiles[profile_id] = {}
		var confirmed: Dictionary = _profiles[profile_id]
		var previous: Dictionary = confirmed.get(snapshot.match_id, {})
		if previous.is_empty() or snapshot.revision > previous.revision:
			confirmed[snapshot.match_id] = snapshot.duplicate(true)

	func latest(match_id: String, profile_id: String) -> Dictionary:
		var snapshot: Dictionary = _profiles.get(profile_id, {}).get(match_id, {})
		if snapshot.is_empty():
			return {}
		return {"profile_id": profile_id, "snapshot": snapshot.duplicate(true)}

	func select(match_id: String, profile_id: String, requested_revision: int) -> Dictionary:
		var entry: Dictionary = latest(match_id, profile_id)
		return entry if not entry.is_empty() and entry.snapshot.revision == requested_revision else {}


class ScriptedSource extends Start.SnapshotSource:
	var _callback: Callable

	func _init(callback: Callable) -> void:
		_callback = callback

	func latest(match_id: String, profile_id: String) -> Dictionary:
		return _callback.call(match_id, profile_id)


static func catalog() -> Dictionary:
	var document: Dictionary = FundingFixtures.catalog()
	var original: Dictionary = FundingFixtures.definitions(document)
	for index: int in range(2, 5):
		_add_copy(document, original.test_character, "test_character_%d" % index)
	for index: int in range(2, 9):
		_add_copy(document, original.test_mission, "test_mission_%d" % index)
	_add_copy(document, original.test_action, "test_starter", "entrenamiento").coste_compra = null
	return document


static func _add_copy(document: Dictionary, base: Dictionary, id: String, kind: String = "") -> Dictionary:
	var copy: Dictionary = base.duplicate(true)
	copy.id = id
	copy.nombre = "Fixture " + id
	if not kind.is_empty():
		copy.tipo = kind
	document.cartas.append(copy)
	return copy


static func training_profile(document: Dictionary) -> Dictionary:
	var catalog_id: String = Funding.new(document, FUNDING_ID, FundingFixtures.inerts(document)).catalog_identity()
	var definitions: Dictionary = CatalogValidator.new().validate(document).cards
	var marks: Array = []
	marks.resize(21)
	marks.fill("")
	for position: int in [0, 3, 9, 15]:
		marks[position] = "quema"
	for position: int in [11, 16]:
		marks[position] = "atium"
	marks[5] = "nivel_1"
	marks[8] = "nivel_2"
	marks[13] = "nivel_3"
	marks[20] = "atium_continuo"
	return {"catalog_id": catalog_id, "track_id": TRACK_ID,
		"definition": definitions.get(TRACK_ID, {}).duplicate(true), "marks": marks}


static func seats(count: int) -> Array:
	var result: Array = []
	for index: int in range(1, count + 1):
		result.append({"player_id": "p%d" % index, "name": "Plaza %d" % index})
	return result


static func manifest() -> Dictionary:
	var characters: Array = []
	var missions: Array = ["test_mission"]
	var market_cards: Array = []
	for index: int in range(1, 5):
		var id: String = "test_character" if index == 1 else "test_character_%d" % index
		characters.append({"character_id": id, "starters": ["test_starter", "test_starter", "test_starter", "test_starter"]})
	for index: int in range(2, 9):
		missions.append("test_mission_%d" % index)
	for index: int in 82:
		market_cards.append("test_action" if index < 41 else "test_ally")
	return {"characters": characters, "funding_id": FUNDING_ID, "training_track_id": TRACK_ID,
		"market_cards": market_cards, "missions": missions, "rival": null}


static func compact_snapshot(catalog_id: String, mode: String = "competitivo", count: int = 2) -> Dictionary:
	var state: Dictionary = Base.snapshot(mode, count)
	state.catalog_id = catalog_id
	state.lifecycle = "en_curso"
	state.turn = {"number": 3, "active_id": "p1", "phase": "inicio", "counters": {}}
	for player: Dictionary in state.players:
		player.ability_uses.clear()
		state.missions.mission_1.progress[player.player_id] = 0
		state.missions.mission_1.rewards[player.player_id] = []
	for index: int in range(2, 4):
		var mission: Dictionary = state.missions.mission_1.duplicate(true)
		mission.definition_id = "test_mission_%d" % index
		state.missions["mission_%d" % index] = mission
	for mission: Dictionary in state.missions.values():
		mission.first_arrivals = {"cell": null}
	state.instances.c1.definition_id = FUNDING_ID
	return state
