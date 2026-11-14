extends RefCounted
## Fuente fiable y aliados explícitamente ficticios, sin habilidades ni reacciones.

const Missions = preload("res://tests/mission_advance_fixtures.gd")
const Play = preload("res://scripts/game/m2_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")


static func engine(document: Dictionary = {}) -> Play:
	if document.is_empty():
		document = Missions.catalog()
	return Play.new(document, Missions.descriptors(document, false), Missions.training_profile(document), Missions.descriptors(document, true))


static func snapshot(count: int = 2) -> Dictionary:
	var state: Dictionary = Missions.snapshot(Play.identity_for(Missions.catalog()), count)
	state.missions["mission_2"] = state.missions.mission_6
	state.missions.mission_2.definition_id = "mision_m2"
	state.missions.erase("mission_6")
	return state


static func allies(state: Dictionary, count: int, owner: String = "p1", kind: String = "juego") -> void:
	for index: int in count:
		var id: String = owner + "_" + kind + "_ally_%05d" % index
		state.instances[id] = Missions.Base.instance(id, "test_ally", owner)
		state.zones[owner + "_" + kind].cards.append(id)


static func at(state: Dictionary, position: int, owner: String = "p1") -> void:
	var mission: Dictionary = state.missions.mission_2
	mission.progress[owner] = position
	for index: int in range(1, position + 1):
		var cell: String = "p%02d" % index
		if mission.first_arrivals[cell] == null:
			mission.first_arrivals[cell] = owner
		if index in [4, 7, 10]:
			mission.rewards[owner].append(cell + "_normal")
			if mission.first_arrivals[cell] == owner:
				mission.rewards[owner].append(cell + "_primero")
				var id: String = "resolution_" + str(state.authority.next_id)
				state.authority.next_id += 1
				state.revision += 1
				state.authority.completed_sequences[id] = {"program_id": Play.FIRST,
					"occurrence_id": Advance.occurrence(state, owner, "mission_2", index), "owner_id": owner,
					"turn_number": state.turn.number, "revision_aplicada": state.revision}
	if position == 12:
		mission.arrival_order.append(owner)
		mission.rewards[owner].append("p12_permanente")
		if mission.first_arrivals.p12 == owner:
			mission.rewards[owner].append("p12_primero")
		if not state.authority.mission_permanents.has("mission_2"):
			state.authority.mission_permanents["mission_2"] = {}
		state.authority.mission_permanents.mission_2[owner] = {"acquired_turn": state.turn.number, "last_applied_turn": state.turn.number}


static func intent(state: Dictionary, id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision, "tipo": kind, "payload": payload}


static func advance(state: Dictionary, id: String = "advance", mission_id: String = "mission_2") -> Dictionary:
	return intent(state, id, "avanzar_mision", {"mission_id": mission_id})


static func respond(view: Dictionary, selected: Array, id: String = "answer") -> Dictionary:
	return intent(view, id, "responder", {"resolution_id": view.resolution.resolution_id, "step_id": view.resolution.step_id, "options": selected})


static func complete_other(state: Dictionary, number: int, owner: String = "p1") -> void:
	var mission: Dictionary = state.missions["mission_%d" % number]
	mission.progress[owner] = 12
	mission.arrival_order.append(owner)
	for position: int in range(1, 13):
		var cell: String = "p%02d" % position
		if mission.first_arrivals[cell] == null:
			mission.first_arrivals[cell] = owner
		if position in ([4, 8, 12] if number == 5 else [6, 12]):
			mission.rewards[owner].append(cell + "_normal")
			if mission.first_arrivals[cell] == owner:
				mission.rewards[owner].append(cell + "_primero")
