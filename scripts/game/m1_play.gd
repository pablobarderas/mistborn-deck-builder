extends "res://scripts/game/mission_play.gd"
## Perfil de autoridad aislado M1/M5/M7. No habilita turnos ni contenido activo.

const M1_VERSION: String = "m1_registry_v1_arrive_refresh_mandatory_auto_empty_limit10000"
const NORMAL: String = "m1_normal_v1"
const FIRST: String = "m1_first_v1"
var _m1_registry: Registry
var _submission: Dictionary = {}
var _submission_actor: String = ""


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	super(catalog, inert_descriptors, training_profile, mission_descriptors)
	_supported = false
	_profile_id = ""
	_handlers.clear()
	var checked: Dictionary = CatalogValidator.new().validate(catalog)
	_m1_registry = Registry.new(registration())
	if checked.ok and checked.cards.size() == checked.verified.size() and _matches(checked.cards, inert_descriptors, mission_descriptors):
		_identity = identity_for(catalog)
		_advance = Advance.new(checked.cards, _identity, training_profile, false, true, _m1_registry, true)
		_supported = _m1_registry.is_valid() and _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
		if _supported:
			_profile_id = "m1_profile_" + (_identity + Funding._canonical_content(training_profile) + M1_VERSION).sha256_text()
			_handlers[ACTION_ID] = _advance_action
			_starters[ACTION_ID] = _start_m1
			_selectors[ACTION_ID] = _select_route
	_state = State.new(checked.cards, _identity, _m1_registry)
	_resolver = Resolver.new(_m1_registry, checked.cards)


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
		return _load_rejected("Registro M1 incompatible.")
	var result: Dictionary = super._restore(match_id, source)
	if result.ok:
		var snapshot: Dictionary = _state.get_snapshot()
		if snapshot.resolution != null and (not _fits(snapshot) or not _budget(snapshot, {})):
			# El motor estaba vacío y la carga no puede publicar una pausa sin margen.
			_state = State.new(_advance._definitions, _identity, _m1_registry)
			return _load_rejected("Pausa M1 sin margen para terminar.")
	return result


func _candidate_error(candidate: Dictionary) -> String:
	# El RNG se sella después del delta P07. Este perfil no tiene ninguna
	# operación aleatoria, tampoco en su ruta directa de premios automáticos.
	if candidate.authority.rng_state != _state.get_snapshot().authority.rng_state:
		return "estado_invalido"
	return _advance.state_error(candidate)


func _registry_intact() -> bool:
	var expected: Registry = Registry.new(registration())
	return _m1_registry.is_valid() and _m1_registry._operations == expected._operations and _m1_registry._programs == expected._programs


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
	var route: int = Route.SEQUENCE if mission.definition_id == "mision_m1" and position in [5, 9] and not third else Route.DIRECT
	if route == Route.DIRECT and not _budget_direct(state, actor_id, payload.mission_id):
		push_warning("Llegada M1 directa sin presupuesto de cierre.")
		return "estado_invalido"
	return route


func _start_m1(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	var route: Variant = _select_route(state, actor_id, payload)
	if not route is int or route != Route.SEQUENCE:
		return route if route is String else "accion_ilegal"
	var mission: Dictionary = state.missions[payload.mission_id]
	var position: int = mission.progress[actor_id] + 1
	var first: bool = mission.first_arrivals["p%02d" % position] == null
	var request: Dictionary = {"program_id": FIRST if first else NORMAL, "source_id": "mision_m1", "recipients": [actor_id],
		"context": {"owner_id": actor_id, "turn_number": state.turn.number, "entry_phase": "libre",
			"occurrence_id": Advance.occurrence(state, actor_id, payload.mission_id, position), "mission_id": payload.mission_id, "position": position}}
	if not _budget(state, request):
		push_warning("Llegada M1 rechazada: presupuesto insuficiente para oferta/vista/cierre.")
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
			var request: Variant = _start_m1(current, _submission_actor, payload)
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


func _reserve(state: Dictionary, owner: String, remaining: int) -> bool:
	if state.revision > Registry.MAX_INT - remaining:
		return false
	if not state.authority.receipts.has(owner):
		state.authority.receipts[owner] = {}
	if state.authority.receipts[owner].size() > 10000 - remaining:
		return false
	for index: int in remaining:
		var key: String = "m1_budget_" + str(index)
		while state.authority.receipts[owner].has(key):
			key += "x"
			if key.length() > 128:
				return false
		state.authority.receipts[owner][key] = {"canonical": "x".repeat(4096), "revision_aplicada": state.revision + remaining}
	state.revision += remaining
	return true


func _fits(state: Dictionary) -> bool:
	if not _advance.state_error(state).is_empty():
		return false
	for player: Dictionary in state.players:
		if not _view_fits(ViewBuilder.new().project(state, player.player_id)):
			return false
	return true


func _budget_direct(state: Dictionary, owner: String, mission_id: String) -> bool:
	var result: Dictionary = _advance.advance(state, owner, mission_id)
	return result.ok and _reserve(result.candidate, owner, 1) and _fits(result.candidate)


func _budget(state: Dictionary, request: Dictionary) -> bool:
	# Reserva conservadora de todos los recibos y simula cada frontera completa.
	# Cada refresco elimina exactamente una candidata; la oferta nunca crece.
	var candidate: Dictionary = state.duplicate(true)
	var owner: String = request.context.owner_id if not request.is_empty() else candidate.resolution.context.owner_id
	var groups: int = (2 if request.program_id == FIRST else 1) if not request.is_empty() else candidate.resolution.steps.size() - candidate.resolution.cursor
	var remaining: int = mini(option_metals(candidate, owner).size(), groups) + (1 if not request.is_empty() else 0)
	if not _reserve(candidate, owner, remaining):
		return false
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = candidate.authority.rng_seed
	rng.state = candidate.authority.rng_state
	var runner: Resolver = Resolver.new(_m1_registry, _advance._definitions)
	var selected: Array = [] if not request.is_empty() else [candidate.resolution.pending.options[0]]
	var result: Resolver.Result = runner.begin(candidate, owner, request, rng) if not request.is_empty() else runner.resume(candidate, selected, rng)
	for iteration: int in 4:
		if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID] or rng.state != state.authority.rng_state:
			return false
		if result.status == Resolver.Result.Status.PAUSED:
			candidate.resolution = result.resolution
		else:
			result.close["revision_aplicada"] = candidate.revision
			candidate.authority.completed_sequences[result.closed_id] = result.close
			candidate.resolution = null
		if not _fits(candidate):
			return false
		if result.status == Resolver.Result.Status.CLOSED:
			return true
		result = runner.resume(candidate, [candidate.resolution.pending.options[0]], rng)
	return false


static func _view_fits(value: Dictionary) -> bool:
	var validator: RefCounted = preload("res://scripts/game/state_validator.gd").new()
	return validator._plain(value, 0)


static func registration() -> Dictionary:
	var operations: Dictionary = {"m1_arrive": {"params": {}, "validate_params": _empty_params, "execute": _arrive},
		"m1_refresh": {"params": {"extra": "bool"}, "validate_params": _refresh_params, "execute": _refresh, "offer": _offer, "auto_empty": _auto_empty}}
	var programs: Dictionary = {}
	for id: String in [NORMAL, FIRST]:
		var steps: Array = [{"step_id": "s01", "operation": "m1_arrive", "params": {}}, {"step_id": "s02", "operation": "m1_refresh", "params": {"extra": false}}]
		if id == FIRST:
			steps.append({"step_id": "s03", "operation": "m1_refresh", "params": {"extra": true}})
		programs[id] = {"steps": steps, "context": {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id", "occurrence_id": "id", "mission_id": "id", "position": "int"},
			"scope": _scope, "binding": _binding, "allow_null_source": false, "option_limit": 10000}
	return {"operations": operations, "programs": programs}


static func _empty_params(params: Dictionary) -> bool:
	return params.is_empty()


static func _refresh_params(params: Dictionary) -> bool:
	return Registry.exact_keys(params, ["extra"]) and params.extra is bool


static func _scope(_state: Dictionary, context: Dictionary) -> Array:
	return [context.owner_id]


static func _binding(state: Dictionary, resolution: Dictionary) -> bool:
	var c: Dictionary = resolution.context
	if state.mode != "competitivo" or c.entry_phase != "libre" or resolution.source_id != "mision_m1" or c.position not in [5, 9]:
		return false
	var mission: Dictionary = state.missions.get(c.mission_id, {})
	if mission.get("definition_id") != "mision_m1" or not mission.progress.has(c.owner_id) or c.occurrence_id != Advance.occurrence(state, c.owner_id, c.mission_id, c.position):
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


static func option_metals(state: Dictionary, owner: String) -> Array:
	return Advance.Refresh.options(state, owner)


static func _offer(state: Dictionary, context: Dictionary, _params: Dictionary) -> Variant:
	var options: Array = []
	for token: Dictionary in option_metals(state, context.owner_id):
		options.append(token.option_id)
	var count: int = 0 if options.is_empty() else 1
	return {"kind": "eleccion", "recipients": [context.owner_id], "options": options, "min": count, "max": count}


static func _auto_empty(state: Dictionary, context: Dictionary, _params: Dictionary) -> bool:
	return option_metals(state, context.owner_id).is_empty()


static func _refresh(state: Dictionary, context: Dictionary, params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var offer: Dictionary = _offer(state, context, params)
	if selected.size() != offer.min or (not selected.is_empty() and (not selected[0] is String or not selected[0] in offer.options)):
		return false
	var group: String = "p%02d_" % context.position + ("primero" if params.extra else "normal")
	var rewards: Array = state.missions[context.mission_id].rewards[context.owner_id]
	if group in rewards:
		return false
	var ids: Array = []
	for option: Dictionary in option_metals(state, context.owner_id):
		if option.option_id in selected:
			ids.append(option.token_id)
	if not Advance.Refresh.apply(state, context.owner_id, ids):
		return false
	rewards.append(group)
	return true
