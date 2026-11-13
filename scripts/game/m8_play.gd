extends "res://scripts/game/mission_play.gd"
## Perfil de autoridad aislado M5/M7/M8. No habilita turnos ni contenido activo.

const M8_VERSION: String = "m8_registry_v1_arrive_remove_auto_empty_limit10000"
const NORMAL: String = "m8_normal_v1"
const FIRST: String = "m8_first_v1"
var _m8_registry: Registry
var _submission: Dictionary = {}
var _submission_actor: String = ""


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	super(catalog, inert_descriptors, training_profile, mission_descriptors)
	_supported = false
	_profile_id = ""
	_handlers.clear()
	var checked: Dictionary = CatalogValidator.new().validate(catalog)
	_m8_registry = Registry.new(registration())
	if checked.ok and checked.cards.size() == checked.verified.size() and _matches(checked.cards, inert_descriptors, mission_descriptors):
		_identity = identity_for(catalog)
		_advance = Advance.new(checked.cards, _identity, training_profile, false, true, _m8_registry)
		_supported = _m8_registry.is_valid() and _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
		if _supported:
			_profile_id = "m8_profile_" + (_identity + Funding._canonical_content(training_profile) + M8_VERSION).sha256_text()
			_handlers[ACTION_ID] = _advance_action
			_starters[ACTION_ID] = _start_m8
			_selectors[ACTION_ID] = _select_route
	_state = State.new(checked.cards, _identity, _m8_registry)
	_resolver = Resolver.new(_m8_registry, checked.cards)


func submit(actor_id: String, input: Variant) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	_submission = input.duplicate(true) if _check_syntax(input).is_empty() else {}
	_submission_actor = actor_id
	var result: Dictionary = _submit(actor_id, input)
	_submission = {}
	_submission_actor = ""
	_busy = false
	return result


func _restore(match_id: String, source: Variant) -> Dictionary:
	if not _registry_intact():
		return _load_rejected("Registro M8 incompatible.")
	var result: Dictionary = super._restore(match_id, source)
	if result.ok:
		var snapshot: Dictionary = _state.get_snapshot()
		if snapshot.resolution != null and not _budget(snapshot, {}):
			# El motor estaba vacío y la carga no puede publicar una pausa sin margen.
			_state = State.new(_advance._definitions, _identity, _m8_registry)
			return _load_rejected("Pausa M8 sin margen para terminar.")
	return result


func _candidate_error(candidate: Dictionary) -> String:
	# El RNG se sella después del delta P07. Este perfil no tiene ninguna
	# operación aleatoria, tampoco en su ruta directa de premios automáticos.
	if candidate.authority.rng_state != _state.get_snapshot().authority.rng_state:
		return "estado_invalido"
	return _advance.state_error(candidate)


func _registry_intact() -> bool:
	var expected: Registry = Registry.new(registration())
	return _m8_registry.is_valid() and _m8_registry._operations == expected._operations and _m8_registry._programs == expected._programs


func _select_route(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	if not Registry.exact_keys(payload, ["mission_id"]) or not Registry.valid_id(payload.mission_id):
		return "formato_invalido"
	if not _registry_intact() or not _advance.state_error(state).is_empty():
		return "estado_invalido"
	if state.turn.phase != "libre" or not state.missions.has(payload.mission_id):
		return "accion_ilegal"
	var mission: Dictionary = state.missions[payload.mission_id]
	var position: int = mission.progress[actor_id] + 1
	if position > 12 or Advance._player(state, actor_id).turn_resources.mision < 1:
		return "accion_ilegal"
	var third: bool = position == 12
	for key: String in state.missions:
		if key != payload.mission_id:
			third = third and state.missions[key].progress[actor_id] == 12
	return Route.SEQUENCE if mission.definition_id == "mision_m8" and position in [5, 9, 12] and not third else Route.DIRECT


func _start_m8(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	var route: Variant = _select_route(state, actor_id, payload)
	if not route is int or route != Route.SEQUENCE:
		return route if route is String else "accion_ilegal"
	var mission: Dictionary = state.missions[payload.mission_id]
	var position: int = mission.progress[actor_id] + 1
	var first: bool = mission.first_arrivals["p%02d" % position] == null
	var request: Dictionary = {"program_id": FIRST if first else NORMAL, "source_id": "mision_m8", "recipients": [actor_id],
		"context": {"owner_id": actor_id, "turn_number": state.turn.number, "entry_phase": "libre",
			"occurrence_id": Advance.occurrence(state, actor_id, payload.mission_id, position), "mission_id": payload.mission_id, "position": position}}
	if not _budget(state, request):
		push_warning("Llegada M8 rechazada: presupuesto insuficiente para oferta/vista/cierre.")
		return "estado_invalido"
	return request


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if not super._protected_fields(candidate, current) or not _registry_intact():
		return false
	# Recalcular el delta con los programas congelados; un handler ordinario no
	# puede fabricar primeras llegadas/grupos ni tocar turnos/ledger ajenos.
	var expected: Dictionary = current.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = current.authority.rng_seed
	rng.state = current.authority.rng_state
	var payload: Dictionary = _submission.get("payload", {})
	if _submission.get("tipo") == "responder":
		var result: Resolver.Result = Resolver.new(Registry.new(registration()), _advance._definitions).resume(expected, payload.options, rng)
		if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
			return false
	elif _submission.get("tipo") == ACTION_ID:
		var route: Variant = _select_route(current, _submission_actor, payload)
		if route == Route.DIRECT:
			var direct: Dictionary = _advance.advance(current, _submission_actor, payload.mission_id)
			if not direct.ok:
				return false
			expected = direct.candidate
		elif route == Route.SEQUENCE:
			var request: Variant = _start_m8(current, _submission_actor, payload)
			if not request is Dictionary:
				return false
			var result: Resolver.Result = Resolver.new(Registry.new(registration()), _advance._definitions).begin(expected, _submission_actor, request, rng)
			if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
				return false
		else:
			return false
	else:
		return false
	return candidate == expected


func _budget(state: Dictionary, request: Dictionary) -> bool:
	# Omitir conserva el máximo de candidatas y por tanto la oferta/vista mayor.
	# Reservar todos los recibos restantes antes de simular cada frontera garantiza
	# que ninguna pausa admitida dependa de borrar historial para poder cerrarse.
	var candidate: Dictionary = state.duplicate(true)
	var owner: String = request.context.owner_id if not request.is_empty() else candidate.resolution.context.owner_id
	var eligible: int = option_cards(candidate, owner).size()
	var context: Dictionary = request.context if not request.is_empty() else candidate.resolution.context
	var program_id: String = request.program_id if not request.is_empty() else candidate.resolution.program_id
	var initial_cursor: int = 0 if not request.is_empty() else candidate.resolution.cursor
	var maximum: int = (4 if context.position == 12 else 1) if initial_cursor <= 1 else 0
	if program_id == FIRST:
		maximum += 1
	if not request.is_empty() and candidate.authority.next_id == Registry.MAX_INT:
		return false
	if _eliminated(candidate).cards.size() > 10000 - mini(eligible, maximum):
		return false
	var remaining: int = (3 if request.program_id == FIRST else 2) if not request.is_empty() else candidate.resolution.steps.size() - candidate.resolution.cursor
	if candidate.revision > Registry.MAX_INT - remaining:
		return false
	if not candidate.authority.receipts.has(owner):
		candidate.authority.receipts[owner] = {}
	for index: int in remaining:
		var key: String = "m8_budget_" + str(index)
		while candidate.authority.receipts[owner].has(key):
			key += "x"
			if key.length() > 128:
				return false
		candidate.authority.receipts[owner][key] = {"canonical": "x".repeat(4096), "revision_aplicada": candidate.revision + remaining}
	candidate.revision += remaining
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = candidate.authority.rng_seed
	rng.state = candidate.authority.rng_state
	var runner: Resolver = Resolver.new(_m8_registry, _advance._definitions)
	var result: Resolver.Result = runner.begin(candidate, owner, request, rng) if not request.is_empty() else runner.resume(candidate, [], rng)
	for iteration: int in 4:
		if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
			return false
		if result.status == Resolver.Result.Status.PAUSED:
			candidate.resolution = result.resolution
		else:
			result.close["revision_aplicada"] = candidate.revision
			candidate.authority.completed_sequences[result.closed_id] = result.close
			candidate.resolution = null
		if not _advance.state_error(candidate).is_empty():
			return false
		for player: Dictionary in candidate.players:
			var view: Dictionary = ViewBuilder.new().project(candidate, player.player_id)
			if not _view_fits(view):
				return false
		if result.status == Resolver.Result.Status.CLOSED:
			return true
		result = runner.resume(candidate, [], rng)
	return false


static func _view_fits(value: Dictionary) -> bool:
	var validator: RefCounted = preload("res://scripts/game/state_validator.gd").new()
	return validator._plain(value, 0)


static func registration() -> Dictionary:
	var operations: Dictionary = {"m8_arrive": {"params": {}, "validate_params": _empty_params, "execute": _arrive},
		"m8_remove": {"params": {"extra": "bool"}, "validate_params": _remove_params, "execute": _remove, "offer": _offer, "auto_empty": _auto_empty}}
	var programs: Dictionary = {}
	for id: String in [NORMAL, FIRST]:
		var steps: Array = [{"step_id": "s01", "operation": "m8_arrive", "params": {}}, {"step_id": "s02", "operation": "m8_remove", "params": {"extra": false}}]
		if id == FIRST:
			steps.append({"step_id": "s03", "operation": "m8_remove", "params": {"extra": true}})
		programs[id] = {"steps": steps, "context": {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id", "occurrence_id": "id", "mission_id": "id", "position": "int"},
			"scope": _scope, "binding": _binding, "allow_null_source": false, "option_limit": 10000}
	return {"operations": operations, "programs": programs}


static func _empty_params(params: Dictionary) -> bool:
	return params.is_empty()


static func _remove_params(params: Dictionary) -> bool:
	return Registry.exact_keys(params, ["extra"]) and params.extra is bool


static func _scope(_state: Dictionary, context: Dictionary) -> Array:
	return [context.owner_id]


static func _binding(state: Dictionary, resolution: Dictionary) -> bool:
	var c: Dictionary = resolution.context
	if state.mode != "competitivo" or c.entry_phase != "libre" or resolution.source_id != "mision_m8" or c.position not in [5, 9, 12]:
		return false
	var mission: Dictionary = state.missions.get(c.mission_id, {})
	if mission.get("definition_id") != "mision_m8" or not mission.progress.has(c.owner_id) or c.occurrence_id != Advance.occurrence(state, c.owner_id, c.mission_id, c.position):
		return false
	var cursor: int = resolution.get("cursor", 0)
	var cell: String = "p%02d" % c.position
	var first: Variant = mission.first_arrivals[cell]
	var is_first: bool = first == null if cursor == 0 else first == c.owner_id
	if resolution.program_id != (FIRST if is_first else NORMAL) or cursor < 0 or cursor > (3 if is_first else 2):
		return false
	if mission.progress[c.owner_id] != c.position - (1 if cursor == 0 else 0):
		return false
	if cursor == 0 and Advance._player(state, c.owner_id).turn_resources.mision < 1:
		return false
	var normal: bool = cell + "_normal" in mission.rewards[c.owner_id]
	var extra: bool = cell + "_primero" in mission.rewards[c.owner_id]
	if normal != (cursor >= 2) or extra != (cursor >= 3):
		return false
	for closed: Dictionary in state.authority.completed_sequences.values():
		if closed.occurrence_id == c.occurrence_id:
			return false
	return true


static func _arrive(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	return selected.is_empty() and Advance.arrive(state, context.owner_id, context.mission_id, context.position)


static func option_cards(state: Dictionary, owner: String) -> Array:
	return ViewBuilder._option_cards(state, owner)


static func _offer(state: Dictionary, context: Dictionary, params: Dictionary) -> Variant:
	var cards: Array = option_cards(state, context.owner_id)
	var options: Array = []
	for card: Dictionary in cards:
		options.append(card.option_id)
	var maximum: int = 1 if params.extra or context.position != 12 else 4
	return {"kind": "eleccion", "recipients": [context.owner_id], "options": options, "min": 0, "max": mini(maximum, cards.size())}


static func _auto_empty(state: Dictionary, context: Dictionary, _params: Dictionary) -> bool:
	return option_cards(state, context.owner_id).is_empty()


static func _remove(state: Dictionary, context: Dictionary, params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var offer: Dictionary = _offer(state, context, params)
	if selected.size() > offer.max:
		return false
	var seen: Dictionary = {}
	for token: Variant in selected:
		if not token is String or not token in offer.options or seen.has(token):
			return false
		seen[token] = true
	var eliminated: Dictionary = _eliminated(state)
	var group: String = "p%02d_" % context.position + ("primero" if params.extra else "normal")
	var rewards: Array = state.missions[context.mission_id].rewards[context.owner_id]
	if eliminated.is_empty() or group in rewards:
		return false
	for card: Dictionary in option_cards(state, context.owner_id):
		if not seen.has(card.option_id):
			continue
		state.zones[card.zone_id].cards.erase(card.instance_id)
		eliminated.cards.append(card.instance_id)
	rewards.append(group)
	return true


static func _eliminated(state: Dictionary) -> Dictionary:
	for zone: Dictionary in state.zones.values():
		if zone.kind == "eliminadas" and zone.holder_id == null:
			return zone
	return {}
