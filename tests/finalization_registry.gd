extends "res://scripts/game/sequence_registry.gd"
## Perfil aislado para el ensayo FIN-01–03.

const Core = preload("res://scripts/game/game_engine.gd")
const ENGINE: String = "e3-finalization-fixture-1/godot-4.7.2"
const CATALOG: String = "e3_finalization_fixture"
const PROGRAM: String = "finalizacion_ensayo_v1"
const STEP: String = "confirmar_final"
const OCCURRENCE: String = "finalizacion_ensayo_1"
const OWNER: String = "p1"
const OPPONENT: String = "p2"
const MISSIONS: Array[String] = ["mision_ensayo_1", "mision_ensayo_2", "mision_ensayo_3"]
const LAST_MISSION: String = "mision_ensayo_3"
const START: String = "iniciar_finalizacion"
const ORDINARY: String = "registrar_ensayo"
const TOKEN: String = "confirmar"


func _init(step_override: Callable = Callable()) -> void:
	var context: Dictionary = BASE_CONTEXT.duplicate()
	context["mission_id"] = "id"
	super({
		"operations": {"confirmacion_ficticia": {
			"params": {}, "validate_params": _empty, "offer": _offer,
			"execute": step_override if step_override.is_valid() else _confirm
		}},
		"programs": {PROGRAM: {
			"steps": [{"step_id": STEP, "operation": "confirmacion_ficticia", "params": {}}],
			"context": context, "scope": _scope, "allow_null_source": true, "binding": _bound
		}}
	})


func snapshot_profile() -> Dictionary:
	return {"engine_version": ENGINE}


func accepts_snapshot(state: Dictionary) -> bool:
	if not scenario_matches(state):
		return false
	var ledger: Dictionary = state.authority.completed_sequences
	var last_id: String = ID_PREFIX + str(state.authority.next_id - 1)
	if state.lifecycle == "en_curso":
		if not can_finish(state) or not ledger.is_empty():
			return false
		if state.resolution == null:
			return _receipts_match(state)
		return state.resolution.resolution_id == last_id and _receipts_match(state, state.revision)
	if state.lifecycle != "finalizada" or state.turn.phase != "finalizada" or state.resolution != null \
		or state.outcome != outcome(state) or not _layout_matches(state, 12, 0) \
		or ledger.size() != 1 or not ledger.has(last_id):
		return false
	var close: Dictionary = ledger[last_id]
	return close_matches(state, close) and close.revision_aplicada == state.revision \
		and state.revision >= 2 and _receipts_match(state, state.revision - 1, last_id)


static func scenario_matches(state: Dictionary) -> bool:
	if state.catalog_id != CATALOG or state.mode != "competitivo" \
		or state.player_order != [OWNER, OPPONENT] or state.turn.active_id != OWNER or state.turn.number < 1:
		return false
	for player: Dictionary in state.players:
		if player.eliminated or player.health <= 0:
			return false
	return true


static func can_finish(state: Dictionary) -> bool:
	return state.lifecycle == "en_curso" and state.turn.phase == "libre" \
		and state.outcome == null and _layout_matches(state, 11, 1)


static func request(state: Dictionary) -> Dictionary:
	return {"program_id": PROGRAM, "source_id": null, "recipients": [OWNER],
		"context": {"owner_id": OWNER, "turn_number": state.turn.number, "entry_phase": "libre",
			"occurrence_id": OCCURRENCE, "mission_id": LAST_MISSION}}


static func close_matches(state: Dictionary, close: Dictionary) -> bool:
	return close.program_id == PROGRAM and close.occurrence_id == OCCURRENCE \
		and close.owner_id == OWNER and close.turn_number == state.turn.number


static func outcome(state: Dictionary) -> Dictionary:
	return {"winner_id": OWNER, "reason": "tres_misiones", "mission_id": LAST_MISSION,
		"turn_number": state.turn.number}


static func owner(state: Dictionary) -> Dictionary:
	for player: Dictionary in state.players:
		if player.player_id == OWNER:
			return player
	return {}


static func _layout_matches(state: Dictionary, last_position: int, points: int) -> bool:
	if state.missions.size() != MISSIONS.size() or owner(state).turn_resources.mision != points:
		return false
	for mission_id: String in MISSIONS:
		if not state.missions.has(mission_id):
			return false
		var mission: Dictionary = state.missions[mission_id]
		var position: int = last_position if mission_id == LAST_MISSION else 12
		if mission.progress != {OWNER: position, OPPONENT: 0} \
			or mission.arrival_order != ([OWNER] if position == 12 else []):
			return false
		for cell: int in range(1, 13):
			if not mission.first_arrivals.has("p%02d" % cell) \
				or mission.first_arrivals["p%02d" % cell] != (OWNER if cell <= position else null):
				return false
	return true


static func _receipts_match(state: Dictionary, start_revision: int = -1, resolution_id: String = "") -> bool:
	var revisions: Dictionary = {}
	var receipts: Dictionary = state.authority.receipts
	if not receipts.is_empty() and not exact_keys(receipts, [OWNER]):
		return false
	for action_id: String in receipts.get(OWNER, {}):
		var receipt: Dictionary = receipts[OWNER][action_id]
		var revision: int = receipt.revision_aplicada
		var action: String = ORDINARY
		var payload: Dictionary = {}
		if revision == start_revision:
			action = START
		elif not resolution_id.is_empty() and revision == state.revision:
			action = "responder"
			payload = {"resolution_id": resolution_id, "step_id": STEP, "options": [TOKEN]}
		var intent: Dictionary = {"version_accion": Core.ACTION_VERSION, "match_id": state.match_id,
			"expected_revision": revision - 1, "action_id": action_id, "tipo": action, "payload": payload}
		if revisions.has(revision) or action_id.begins_with(Core.START_TURN_ID_PREFIX) \
			or action_id.begins_with(Core.CLEANUP_ID_PREFIX) or receipt.canonical != Core.canonical_intent(intent):
			return false
		revisions[revision] = true
	return revisions.size() == state.revision


static func _bound(state: Dictionary, resolution: Dictionary) -> bool:
	return scenario_matches(state) and can_finish(state) and resolution.source_id == null \
		and resolution.context == request(state).context


static func _empty(params: Dictionary) -> bool:
	return params.is_empty()


static func _scope(_state: Dictionary, _context: Dictionary) -> Array:
	return [OWNER]


static func _offer(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Dictionary:
	return {"kind": "eleccion", "recipients": [OWNER], "options": [TOKEN], "min": 1, "max": 1}


static func _confirm(_state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	return selected == [TOKEN]
