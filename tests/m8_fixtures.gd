extends RefCounted
## Catálogo de misiones real; cartas/reservas y fuente fiables ficticias explícitas.
const Missions = preload("res://tests/mission_advance_fixtures.gd")
const Play = preload("res://scripts/game/m8_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")


static func engine(document: Dictionary = {}) -> Play:
	if document.is_empty():
		document = Missions.catalog()
	return Play.new(document, Missions.descriptors(document, false), Missions.training_profile(document), Missions.descriptors(document, true))


static func snapshot(count: int = 2) -> Dictionary:
	var state: Dictionary = Missions.snapshot(Play.identity_for(Missions.catalog()), count)
	state.missions["mission_8"] = state.missions.mission_6
	state.missions.mission_8.definition_id = "mision_m8"
	state.missions.erase("mission_6")
	return state


static func cards(state: Dictionary, count: int, owner: String = "p1") -> void:
	for id: String in state.instances.keys():
		if state.instances[id].owner_id == owner:
			for zone: Dictionary in state.zones.values():
				zone.cards.erase(id)
			state.instances.erase(id)
	for index: int in count:
		var id: String = owner + "_fixture_%04d" % index
		state.instances[id] = Missions.Base.instance(id, "test_ally" if index % 3 == 2 else "test_action", owner)
		state.zones[owner + "_" + ["mano", "descarte", "juego"][index % 3]].cards.append(id)


static func at(state: Dictionary, position: int, owner: String = "p1") -> void:
	# Historia coherente ya confirmada para llegar a una frontera sin falsas fases.
	var mission: Dictionary = state.missions.mission_8
	mission.progress[owner] = position
	for index: int in range(1, position + 1):
		var cell: String = "p%02d" % index
		if mission.first_arrivals[cell] == null:
			mission.first_arrivals[cell] = owner
		if index in [5, 9, 12]:
			mission.rewards[owner].append(cell + "_normal")
			var first: bool = mission.first_arrivals[cell] == owner
			if first:
				mission.rewards[owner].append(cell + "_primero")
			var id: String = "resolution_" + str(state.authority.next_id)
			state.authority.next_id += 1
			state.revision += 1
			state.authority.completed_sequences[id] = {"program_id": Play.FIRST if first else Play.NORMAL,
				"occurrence_id": Advance.occurrence(state, owner, "mission_8", index), "owner_id": owner,
				"turn_number": state.turn.number, "revision_aplicada": state.revision}
	if position == 12:
		mission.arrival_order.append(owner)


static func intent(state: Dictionary, id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision, "tipo": kind, "payload": payload}


static func advance(state: Dictionary, id: String = "advance") -> Dictionary:
	return intent(state, id, "avanzar_mision", {"mission_id": "mission_8"})


static func respond(view: Dictionary, selected: Array, id: String = "answer") -> Dictionary:
	return intent(view, id, "responder", {"resolution_id": view.resolution.resolution_id, "step_id": view.resolution.step_id, "options": selected})
