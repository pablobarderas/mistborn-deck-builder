extends "res://scripts/game/game_engine.gd"
## Autoridad exclusiva del ensayo ficticio INT-E3-01–03.

const Profile = preload("res://tests/integrated_trial_registry.gd")
var _fail_close: bool


func _init(fail_close: bool = false) -> void:
	_fail_close = fail_close
	super(Profile.definitions(), Profile.CATALOG, {}, Profile.new(), {Profile.START: _start})


static func snapshot() -> Dictionary:
	return Profile.initial()


func submit_internal(actor_id: String, intent: Dictionary) -> Dictionary:
	match intent.get("tipo"):
		Profile.HANDOFF:
			return _submit(actor_id, intent, _handoff, Profile.HANDOFF)
		Profile.DISPATCH:
			return _submit(actor_id, intent, _dispatch, Profile.DISPATCH, true)
	return _reject("accion_no_soportada", get_authority_snapshot().get("revision", 0))


func _internal_actions() -> Dictionary:
	var actions: Dictionary = super._internal_actions()
	actions[Profile.DISPATCH] = Profile.DISPATCH_PREFIX
	return actions


func _allows_new_action(current: Dictionary, action: String) -> bool:
	if current.lifecycle != "en_curso":
		return false
	match current.revision:
		0:
			return action == Profile.START
		1, 2, 5:
			return action == "responder"
		3:
			return current.authority.deferred_effect != null and action == Profile.HANDOFF
		4:
			return action == Profile.DISPATCH
	return false


func _start(_current: Dictionary, _actor_id: String, payload: Dictionary) -> Variant:
	return Profile.request(false) if payload.is_empty() else "formato_invalido"


func _dispatch(_current: Dictionary, _actor_id: String, payload: Dictionary) -> Variant:
	return Profile.request(true) if payload.is_empty() else "formato_invalido"


func _handoff(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	return "" if Profile.handoff(candidate, actor_id, rng) else "estado_invalido"


func _commit_sequence_close(candidate: Dictionary, close: Dictionary) -> String:
	if not Profile.close_sequence(candidate, close):
		return "estado_invalido"
	return "estado_invalido" if _fail_close and close.program_id == Profile.REACTION else ""
