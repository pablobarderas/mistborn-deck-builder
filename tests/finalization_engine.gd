extends "res://scripts/game/game_engine.gd"
## Autoridad local exclusiva del ensayo de finalización.

const Profile = preload("res://tests/finalization_registry.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")


func _init(step_override: Callable = Callable()) -> void:
	super(definitions(), Profile.CATALOG, {Profile.ORDINARY: _record}, Profile.new(step_override),
		{Profile.START: _start})


static func definitions() -> Dictionary:
	var result: Dictionary = Fixtures.definitions()
	var cells: Array[Dictionary] = []
	for position: int in range(1, 13):
		cells.append({"id": "p%02d" % position})
	result.test_mission["rasgos"] = {"recorridos": [{"casillas": cells}]}
	return result


func _start(current: Dictionary, _actor_id: String, payload: Dictionary) -> Variant:
	if not payload.is_empty():
		return "formato_invalido"
	return Profile.request(current)


func _record(candidate: Dictionary, _actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	candidate.turn.counters["marca_ensayo"] = 1
	return ""


func _commit_sequence_close(candidate: Dictionary, close: Dictionary) -> String:
	if not Profile.close_matches(candidate, close) or not Profile.scenario_matches(candidate) \
		or not Profile.can_finish(candidate) or candidate.authority.completed_sequences.size() != 1:
		return "estado_invalido"
	if not Advance.arrive(candidate, Profile.OWNER, Profile.LAST_MISSION, 12):
		return "estado_invalido"
	candidate.outcome = Profile.outcome(candidate)
	candidate.lifecycle = "finalizada"
	candidate.turn.phase = "finalizada"
	return ""
