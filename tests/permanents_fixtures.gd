extends RefCounted
## Entregas de autoridad ficticias: las fases limpieza no prueban combate/Target.
const Missions = preload("res://tests/mission_advance_fixtures.gd")
const Play = preload("res://scripts/game/permanents_play.gd")


class LatestSource extends Play.SnapshotSource:
	var entries: Dictionary = {}

	func confirm(profile_id: String, state: Dictionary) -> void:
		var key: String = profile_id + ":" + state.match_id
		if not entries.has(key) or entries[key].revision < state.revision:
			entries[key] = state.duplicate(true)

	func latest(match_id: String, profile_id: String) -> Dictionary:
		var key: String = profile_id + ":" + match_id
		return {} if not entries.has(key) else {"profile_id": profile_id, "snapshot": entries[key].duplicate(true)}


static func engine(document: Dictionary = {}) -> Play:
	if document.is_empty():
		document = Missions.catalog()
	return Play.new(document, Missions.descriptors(document, false), Missions.training_profile(document), Missions.descriptors(document, true))


static func snapshot(count: int = 2) -> Dictionary:
	var state: Dictionary = Missions.snapshot(Play.identity_for(Missions.catalog()), count)
	state.missions["mission_3"] = state.missions.mission_5
	state.missions.mission_3.definition_id = "mision_m3"
	state.missions.erase("mission_5")
	state.missions["mission_4"] = state.missions.mission_6
	state.missions.mission_4.definition_id = "mision_m4"
	state.missions.erase("mission_6")
	return state


static func intent(state: Dictionary, action_id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": action_id,
		"expected_revision": state.revision, "tipo": kind, "payload": payload}


static func cards(state: Dictionary, count: int, zone: String = "p1_mazo") -> void:
	for id: String in state.instances.keys():
		if state.instances[id].owner_id == "p1":
			for value: Dictionary in state.zones.values():
				value.cards.erase(id)
			state.instances.erase(id)
	for index: int in count:
		var id: String = "fixture_card_%d" % index
		state.instances[id] = Missions.Base.instance(id, "test_action", "p1")
		state.zones[zone].cards.append(id)
