extends "res://scripts/game/mission_play.gd"
## Autoridad cerrada M3/M4/M7. Limpieza sólo procede de una fuente fiable;
## ninguna intención pública acredita las obligaciones previas del fin de turno.

const Cleanup = preload("res://scripts/game/turn_cleanup.gd")


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	super(catalog, inert_descriptors, training_profile, mission_descriptors)
	_supported = false
	_profile_id = ""
	_handlers.clear()
	var checked: Dictionary = CatalogValidator.new().validate(catalog)
	if checked.ok and checked.cards.size() == checked.verified.size() \
		and _matches(checked.cards, inert_descriptors, mission_descriptors):
		_advance = Advance.new(checked.cards, _identity, training_profile, true)
		_supported = _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
		if _supported:
			_profile_id = "permanents_profile_" + (_identity + Funding._canonical_content(training_profile)).sha256_text()
			_handlers[ACTION_ID] = _advance_action


func start_turn(actor_id: String, input: Variant) -> Dictionary:
	return _internal(actor_id, input, _start, START_TURN_ACTION)


func finish_cleanup(actor_id: String, input: Variant) -> Dictionary:
	return _internal(actor_id, input, _cleanup, CLEANUP_ACTION)


func _internal(actor_id: String, input: Variant, handler: Callable, kind: String) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	var result: Dictionary = _submit(actor_id, input, handler, kind)
	_busy = false
	return result


func _advance_action(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["mission_id"]) or not Registry.valid_id(payload.mission_id):
		return "formato_invalido"
	var result: Dictionary = _advance.advance(candidate, actor_id, payload.mission_id, rng)
	if not result.ok:
		return result.codigo
	candidate.merge(result.candidate, true)
	return ""


func _request_error(candidate: Dictionary, payload: Dictionary, phase: String) -> String:
	if not Registry.exact_keys(payload, ["turn_number"]) or not payload.turn_number is int or payload.turn_number < 1:
		return "formato_invalido"
	if candidate.turn.phase != phase or candidate.turn.number != payload.turn_number:
		return "accion_ilegal"
	return _advance.state_error(candidate)


func _start(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	var error: String = _request_error(candidate, payload, "inicio")
	if not error.is_empty():
		return error
	var result: Dictionary = _advance._training.advance(candidate, actor_id)
	if not result.ok:
		return result.codigo
	var staged: Dictionary = result.candidate
	var player: Dictionary = Advance._player(staged, actor_id)
	for entries: Dictionary in staged.authority.mission_permanents.values():
		if entries.has(actor_id):
			if player.turn_resources.recursos > Registry.MAX_INT - 2:
				return "estado_invalido"
			player.turn_resources.recursos += 2
			entries[actor_id].last_applied_turn = staged.turn.number
	staged.turn.phase = "libre"
	error = _advance.state_error(staged)
	if not error.is_empty():
		return error
	candidate.merge(staged, true)
	return ""


func _cleanup(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	var error: String = _request_error(candidate, payload, "limpieza")
	if not error.is_empty():
		return error
	var service: Cleanup = Cleanup.new(_advance._definitions, _identity, _advance._registry)
	var result: Dictionary = service.finish_cleanup(candidate, actor_id, rng)
	if not result.ok:
		return result.codigo
	return _advance.state_error(candidate)
