extends RefCounted
## Misiones reales; todo el resto y las fases entregadas son fixtures inertes.
const Missions = preload("res://tests/mission_advance_fixtures.gd")
const Play = preload("res://scripts/game/integrated_missions_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")


static func engine(document: Dictionary = {}) -> Play:
	if document.is_empty():
		document = Missions.catalog()
	return Play.new(document, Missions.descriptors(document, false), Missions.training_profile(document), Missions.descriptors(document, true))


static func snapshot(numbers: Array = [1, 2, 8], count: int = 2) -> Dictionary:
	var state: Dictionary = Missions.snapshot(Play.identity_for(Missions.catalog()), count)
	var template: Dictionary = state.missions.mission_5.duplicate(true)
	state.missions.clear()
	for number: int in numbers:
		var mission: Dictionary = template.duplicate(true)
		mission.definition_id = "mision_m%d" % number
		state.missions["mission_%d" % number] = mission
	return state


static func at(state: Dictionary, number: int, position: int, owner: String = "p1") -> void:
	var mission_id: String = "mission_%d" % number
	var mission: Dictionary = state.missions[mission_id]
	var cells: Array = Missions.descriptors(Missions.catalog(), true)[mission.definition_id].rasgos.recorridos[0].casillas
	mission.progress[owner] = position
	for index: int in range(1, position + 1):
		var cell: Dictionary = cells[index - 1]
		if mission.first_arrivals[cell.id] == null:
			mission.first_arrivals[cell.id] = owner
		var first: bool = mission.first_arrivals[cell.id] == owner
		if not cell.efectos.is_empty():
			mission.rewards[owner].append(cell.id + "_normal")
		if first and not cell.primero.is_empty():
			mission.rewards[owner].append(cell.id + "_primero")
		var choice: bool = (number == 1 and index in [5, 9]) or (number == 2 and index in [4, 7, 10] and first) or (number == 8 and index in [5, 9, 12])
		if choice:
			var id: String = "resolution_" + str(state.authority.next_id)
			state.authority.next_id += 1
			state.revision += 1
			state.authority.completed_sequences[id] = {"program_id": "m%d_" % number + ("first_v1" if first else "normal_v1"),
				"occurrence_id": Advance.occurrence(state, owner, mission_id, index), "owner_id": owner,
				"turn_number": state.turn.number, "revision_aplicada": state.revision}
		if cell.get("permanente") != null:
			mission.rewards[owner].append(cell.id + "_permanente")
	if position == 12:
		mission.arrival_order.append(owner)
		if number == 1:
			Advance._player(state, owner).burn_limit += 1
		if number in [2, 3]:
			if not state.authority.mission_permanents.has(mission_id):
				state.authority.mission_permanents[mission_id] = {}
			state.authority.mission_permanents[mission_id][owner] = {"acquired_turn": state.turn.number, "last_applied_turn": state.turn.number}


static func cards(state: Dictionary, count: int, zone: String = "p1_descarte", owner: String = "p1", definition: String = "test_action") -> void:
	for index: int in count:
		var id: String = "integrated_" + zone + "_%05d" % index
		state.instances[id] = Missions.Base.instance(id, definition, owner)
		state.zones[zone].cards.append(id)


static func intent(state: Dictionary, id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision, "tipo": kind, "payload": payload}


static func advance(state: Dictionary, number: int, id: String = "advance") -> Dictionary:
	return intent(state, id, "avanzar_mision", {"mission_id": "mission_%d" % number})


static func respond(view: Dictionary, selected: Array, id: String = "answer") -> Dictionary:
	return intent(view, id, "responder", {"resolution_id": view.resolution.resolution_id, "step_id": view.resolution.step_id, "options": selected})
