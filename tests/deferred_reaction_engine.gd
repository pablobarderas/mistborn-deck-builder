extends "res://scripts/game/game_engine.gd"
## Controlador local de autoridad para ejecutar DIF-01–03.

const Profile = preload("res://tests/deferred_reaction_registry.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
const Training = preload("res://scripts/game/training_advance.gd")
const SCHEDULE: String = "programar_diferido"
const DISPATCH: String = "despachar_diferido"
const SCHEDULE_PREFIX: String = "programar_diferido_"
const DISPATCH_PREFIX: String = "despachar_diferido_"
var _cleanup: Cleanup
var _training: Training


func _init() -> void:
	var profile: Profile = Profile.new()
	var definitions: Dictionary = Fixtures.definitions()
	super(definitions, Profile.CATALOG, {"avanzar_fase": _advance_phase}, profile)
	_cleanup = Cleanup.new(definitions, Profile.CATALOG, profile)
	_training = Training.new(definitions, Profile.CATALOG, {
		"catalog_id": Profile.CATALOG, "track_id": "test_training_track",
		"definition": definitions.test_training_track, "marks": Training.PANEL.duplicate()
	}, profile)


func submit_internal(actor_id: String, intent: Dictionary) -> Dictionary:
	match intent.get("tipo"):
		SCHEDULE:
			return _submit(actor_id, intent, _schedule, SCHEDULE)
		DISPATCH:
			return _submit(actor_id, intent, _dispatch, DISPATCH, true)
		START_TURN_ACTION:
			return _submit(actor_id, intent, _start_turn)
		CLEANUP_ACTION:
			return _submit(actor_id, intent, _finish_cleanup, CLEANUP_ACTION)
	return _reject("accion_no_soportada", get_authority_snapshot().get("revision", 0))


func _internal_actions() -> Dictionary:
	var actions: Dictionary = super._internal_actions()
	actions[SCHEDULE] = SCHEDULE_PREFIX
	actions[DISPATCH] = DISPATCH_PREFIX
	return actions


func _allows_new_action(current: Dictionary, action: String) -> bool:
	return not Profile.due(current) or action == (DISPATCH if current.resolution == null else "responder")


func _commit_sequence_close(candidate: Dictionary, close: Dictionary) -> void:
	if close.program_id == Profile.PROGRAM and close.occurrence_id == Profile.OCCURRENCE:
		candidate.authority.deferred_effect = null


func _schedule(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	if candidate.turn.number != 1 or candidate.turn.phase != "libre" or actor_id != Profile.RECIPIENT \
		or candidate.authority.deferred_effect != null or not candidate.authority.completed_sequences.is_empty():
		return "accion_ilegal"
	candidate.authority.deferred_effect = Profile.obligation()
	return ""


func _dispatch(current: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	if not payload.is_empty():
		return "formato_invalido"
	if actor_id != Profile.OWNER or not Profile.due(current):
		return "accion_ilegal"
	return Profile.request()


func _start_turn(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	var advanced: Dictionary = _training.advance(candidate, actor_id)
	if not advanced.ok:
		return advanced.codigo if advanced.codigo == "accion_ilegal" else "estado_invalido"
	candidate.merge(advanced.candidate, true)
	candidate.turn.phase = "libre"
	return ""


func _finish_cleanup(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	var result: Dictionary = _cleanup.finish_cleanup(candidate, actor_id, rng)
	return "" if result.ok else result.codigo


func _advance_phase(candidate: Dictionary, _actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	match candidate.turn.phase:
		"libre":
			candidate.turn.phase = "combate"
		"combate":
			candidate.turn.phase = "limpieza"
		_:
			return "accion_ilegal"
	return ""
