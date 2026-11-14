extends "res://scripts/game/mission_play.gd"
## Piloto de autoridad M2/M5/M7; catálogo inerte, sin entrada a limpieza.

const Targets = preload("res://scripts/game/ally_targets.gd")
const FIRST: String = "m2_first_v1"
const M2_VERSION: String = "m2_registry_v1_arrive_defeat_mandatory_auto_empty_limit10000"
var _m2_registry: Registry
var _ally_ids: String = ""
var _submission: Dictionary = {}
var _submission_actor: String = ""


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	super(catalog, inert_descriptors, training_profile, mission_descriptors)
	_supported = false
	_profile_id = ""
	_handlers.clear()
	var checked: Dictionary = CatalogValidator.new().validate(catalog)
	var ids: Array = []
	for id: String in checked.cards:
		if checked.cards[id].tipo == "aliado":
			ids.append(id)
	ids.sort()
	_ally_ids = ",".join(ids)
	_m2_registry = Registry.new(registration(_ally_ids))
	if checked.ok and checked.cards.size() == checked.verified.size() and _matches(checked.cards, inert_descriptors, mission_descriptors):
		_identity = identity_for(catalog)
		_advance = Advance.new(checked.cards, _identity, training_profile, false, true, _m2_registry, false, true)
		_supported = _m2_registry.is_valid() and _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
		if _supported:
			_profile_id = "m2_profile_" + (_identity + Funding._canonical_content(training_profile) + M2_VERSION).sha256_text()
			_handlers[ACTION_ID] = _advance_action
			_starters[ACTION_ID] = _start_m2
			_selectors[ACTION_ID] = _select_route
	_state = State.new(checked.cards, _identity, _m2_registry)
	_resolver = Resolver.new(_m2_registry, checked.cards)


func submit(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, false)


func start_turn(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, true)


func _operation(actor_id: String, input: Variant, internal: bool) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	_submission = input.duplicate(true) if _check_syntax(input).is_empty() else {}
	_submission_actor = actor_id
	var result: Dictionary = _submit(actor_id, input, _start if internal else Callable())
	_submission = {}
	_submission_actor = ""
	_busy = false
	return result


func _restore(match_id: String, source: Variant) -> Dictionary:
	if not _registry_intact():
		return _load_rejected("Registro M2 incompatible.")
	var result: Dictionary = super._restore(match_id, source)
	if result.ok:
		var snapshot: Dictionary = _state.get_snapshot()
		if not _fits(snapshot) or (snapshot.resolution != null and not _budget(snapshot, {})):
			_state = State.new(_advance._definitions, _identity, _m2_registry)
			return _load_rejected("Estado M2 sin margen de vista/cierre.")
	return result


func _registry_intact() -> bool:
	var expected: Registry = Registry.new(registration(_ally_ids))
	return _m2_registry.is_valid() and _m2_registry._operations == expected._operations and _m2_registry._programs == expected._programs


func _candidate_error(candidate: Dictionary) -> String:
	if candidate.authority.rng_state != _state.get_snapshot().authority.rng_state or not _fits(candidate):
		return "estado_invalido"
	return ""


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
	var route: int = Route.SEQUENCE if mission.definition_id == "mision_m2" and position in [4, 7, 10] and mission.first_arrivals["p%02d" % position] == null else Route.DIRECT
	if route == Route.DIRECT:
		var result: Dictionary = _advance.advance(state, actor_id, payload.mission_id)
		if not result.ok or not _reserve(result.candidate, actor_id, 1) or not _fits(result.candidate):
			return "estado_invalido"
	return route


func _start_m2(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	var route: Variant = _select_route(state, actor_id, payload)
	if not route is int or route != Route.SEQUENCE:
		return route if route is String else "accion_ilegal"
	var position: int = state.missions[payload.mission_id].progress[actor_id] + 1
	var request: Dictionary = {"program_id": FIRST, "source_id": "mision_m2", "recipients": [actor_id],
		"context": {"owner_id": actor_id, "turn_number": state.turn.number, "entry_phase": "libre",
			"occurrence_id": Advance.occurrence(state, actor_id, payload.mission_id, position), "mission_id": payload.mission_id, "position": position}}
	return request if _budget(state, request) else "estado_invalido"


func _start(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	var result: Dictionary = _start_candidate(candidate, actor_id, payload)
	if not result.ok:
		return result.codigo
	var budget: Dictionary = result.candidate.duplicate(true)
	if not _reserve(budget, actor_id, 1) or not _fits(budget):
		return "estado_invalido"
	candidate.merge(result.candidate, true)
	return ""


func _start_candidate(state: Dictionary, actor_id: String, payload: Dictionary) -> Dictionary:
	if not Registry.exact_keys(payload, ["turn_number"]) or not payload.turn_number is int or payload.turn_number < 1:
		return {"ok": false, "codigo": "formato_invalido"}
	if state.turn.phase != "inicio" or state.turn.number != payload.turn_number:
		return {"ok": false, "codigo": "accion_ilegal"}
	if not _registry_intact() or not _advance.state_error(state).is_empty():
		return {"ok": false, "codigo": "estado_invalido"}
	var result: Dictionary = _advance._training.advance(state, actor_id)
	if not result.ok:
		return result
	var staged: Dictionary = result.candidate
	var player: Dictionary = Advance._player(staged, actor_id)
	for mission_id: String in staged.authority.mission_permanents:
		var entries: Dictionary = staged.authority.mission_permanents[mission_id]
		if entries.has(actor_id):
			# La misión exacta fue validada; no despachar M2 por el recurso de M3.
			if staged.missions[mission_id].definition_id != "mision_m2" or player.turn_resources.ataque > Registry.MAX_INT - 2:
				return {"ok": false, "codigo": "estado_invalido"}
			player.turn_resources.ataque += 2
			entries[actor_id].last_applied_turn = staged.turn.number
	staged.turn.phase = "libre"
	return {"ok": true, "candidate": staged} if _advance.state_error(staged).is_empty() else {"ok": false, "codigo": "estado_invalido"}


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if not super._protected_fields(candidate, current) or not _registry_intact():
		return false
	var expected: Dictionary = current.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = current.authority.rng_seed
	rng.state = current.authority.rng_state
	var payload: Dictionary = _submission.get("payload", {})
	if _submission.get("tipo") == "responder":
		var result: Resolver.Result = Resolver.new(Registry.new(registration(_ally_ids)), _advance._definitions).resume(expected, payload.options, rng)
		if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
			return false
	elif _submission.get("tipo") == START_TURN_ACTION:
		var result: Dictionary = _start_candidate(current, _submission_actor, payload)
		if not result.ok:
			return false
		expected = result.candidate
	elif _submission.get("tipo") == ACTION_ID:
		var route: Variant = _select_route(current, _submission_actor, payload)
		if route == Route.DIRECT:
			var result: Dictionary = _advance.advance(current, _submission_actor, payload.mission_id)
			if not result.ok:
				return false
			expected = result.candidate
		elif route == Route.SEQUENCE:
			var request: Variant = _start_m2(current, _submission_actor, payload)
			if not request is Dictionary:
				return false
			var result: Resolver.Result = Resolver.new(Registry.new(registration(_ally_ids)), _advance._definitions).begin(expected, _submission_actor, request, rng)
			if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
				return false
		else:
			return false
	else:
		return false
	return candidate == expected and rng.state == current.authority.rng_state


func _reserve(state: Dictionary, owner: String, remaining: int) -> bool:
	if state.revision > Registry.MAX_INT - remaining:
		return false
	if not state.authority.receipts.has(owner):
		state.authority.receipts[owner] = {}
	if state.authority.receipts[owner].size() > 10000 - remaining:
		return false
	for index: int in remaining:
		var key: String = "m2_budget_" + str(index)
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
		if not preload("res://scripts/game/state_validator.gd").new()._plain(ViewBuilder.new().project(state, player.player_id, _advance._definitions), 0):
			return false
	return true


func _budget(state: Dictionary, request: Dictionary) -> bool:
	if not _fits(state):
		return false
	var candidate: Dictionary = state.duplicate(true)
	var owner: String = request.context.owner_id if not request.is_empty() else candidate.resolution.context.owner_id
	var options: Array = Targets.options(candidate, _advance._definitions)
	if options.size() > 10000:
		return false
	# Cada opción mueve una sola instancia. El tamaño de snapshot no cambia por
	# propietario; la vista de cierre sólo pierde la oferta y una carta pública,
	# y conserva esa carta en la vista de su propietario. Todas las ramas del
	# mismo propietario tienen idénticos nodos, profundidad y tamaños de arrays.
	# Comprobar TODOS los destinos y simular un representante por propietario
	# cubre todas las opciones sin un coste cuadrático en el número de aliados.
	var representatives: Dictionary = {}
	for option: Dictionary in options:
		var destination: Dictionary = Targets.discard_zone(candidate, option.owner_id)
		if destination.is_empty() or destination.cards.size() >= 10000:
			return false
		if not representatives.has(option.owner_id):
			representatives[option.owner_id] = option.option_id
	var remaining: int = (1 if options.is_empty() else 2) if not request.is_empty() else 1
	if not _reserve(candidate, owner, remaining):
		return false
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = candidate.authority.rng_seed
	rng.state = candidate.authority.rng_state
	var runner: Resolver = Resolver.new(_m2_registry, _advance._definitions)
	if not request.is_empty():
		var result: Resolver.Result = runner.begin(candidate, owner, request, rng)
		if not _frontier(candidate, result, rng, state.authority.rng_state):
			return false
		if result.status == Resolver.Result.Status.CLOSED:
			return true
	for option_id: String in representatives.values():
		var branch: Dictionary = candidate.duplicate(true)
		var result: Resolver.Result = runner.resume(branch, [option_id], rng)
		if result.status != Resolver.Result.Status.CLOSED or not _frontier(branch, result, rng, state.authority.rng_state):
			return false
	return not representatives.is_empty()


func _frontier(state: Dictionary, result: Resolver.Result, rng: RandomNumberGenerator, expected_rng: int) -> bool:
	if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID] or rng.state != expected_rng:
		return false
	if result.status == Resolver.Result.Status.PAUSED:
		state.resolution = result.resolution
	else:
		result.close["revision_aplicada"] = state.revision
		state.authority.completed_sequences[result.closed_id] = result.close
		state.resolution = null
	return _fits(state)


static func registration(ally_ids: String) -> Dictionary:
	return {"operations": {"m2_arrive": {"params": {}, "validate_params": _empty_params, "execute": _arrive},
		"m2_defeat": {"params": {}, "validate_params": _empty_params, "execute": _defeat.bind(ally_ids), "offer": _offer.bind(ally_ids), "auto_empty": _auto_empty.bind(ally_ids)}},
		"programs": {FIRST: {"steps": [{"step_id": "s01", "operation": "m2_arrive", "params": {}}, {"step_id": "s02", "operation": "m2_defeat", "params": {}}],
			"context": {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id", "occurrence_id": "id", "mission_id": "id", "position": "int"},
			"scope": _scope, "binding": _binding, "allow_null_source": false, "option_limit": 10000}}}


static func _empty_params(params: Dictionary) -> bool:
	return params.is_empty()


static func _scope(_state: Dictionary, context: Dictionary) -> Array:
	return [context.owner_id]


static func _binding(state: Dictionary, resolution: Dictionary) -> bool:
	var c: Dictionary = resolution.context
	if state.mode != "competitivo" or c.entry_phase != "libre" or resolution.source_id != "mision_m2" or resolution.program_id != FIRST or c.position not in [4, 7, 10]:
		return false
	var mission: Dictionary = state.missions.get(c.mission_id, {})
	if mission.get("definition_id") != "mision_m2" or not mission.progress.has(c.owner_id) or c.occurrence_id != Advance.occurrence(state, c.owner_id, c.mission_id, c.position):
		return false
	var cursor: int = resolution.get("cursor", 0)
	var cell: String = "p%02d" % c.position
	if cursor not in [0, 1, 2] or mission.progress[c.owner_id] != c.position - (1 if cursor == 0 else 0):
		return false
	if mission.first_arrivals[cell] != (null if cursor == 0 else c.owner_id):
		return false
	if cursor == 0 and Advance._player(state, c.owner_id).turn_resources.mision < 1:
		return false
	if (cell + "_normal" in mission.rewards[c.owner_id]) != (cursor >= 1) or (cell + "_primero" in mission.rewards[c.owner_id]) != (cursor >= 2):
		return false
	for closed: Dictionary in state.authority.completed_sequences.values():
		if closed.occurrence_id == c.occurrence_id:
			return false
	return true


static func _arrive(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var amount: int = [4, 7, 10].find(context.position) + 1
	var player: Dictionary = Advance._player(state, context.owner_id)
	if not selected.is_empty() or amount < 1 or player.turn_resources.ataque > Registry.MAX_INT - amount:
		return false
	if not Advance.arrive(state, context.owner_id, context.mission_id, context.position):
		return false
	player.turn_resources.ataque += amount
	state.missions[context.mission_id].rewards[context.owner_id].append("p%02d_normal" % context.position)
	return true


static func _definitions_for(ally_ids: String) -> Dictionary:
	var definitions: Dictionary = {}
	for id: String in ally_ids.split(",", false):
		definitions[id] = {"tipo": "aliado"}
	return definitions


static func _offer(state: Dictionary, context: Dictionary, _params: Dictionary, ally_ids: String) -> Dictionary:
	var options: Array = []
	for option: Dictionary in Targets.options(state, _definitions_for(ally_ids)):
		options.append(option.option_id)
	var count: int = 0 if options.is_empty() else 1
	return {"kind": "eleccion", "recipients": [context.owner_id], "options": options, "min": count, "max": count}


static func _auto_empty(state: Dictionary, _context: Dictionary, _params: Dictionary, ally_ids: String) -> bool:
	return Targets.options(state, _definitions_for(ally_ids)).is_empty()


static func _defeat(state: Dictionary, context: Dictionary, params: Dictionary, _rng: RandomNumberGenerator, selected: Array, ally_ids: String) -> bool:
	var offer: Dictionary = _offer(state, context, params, ally_ids)
	if selected.size() != offer.min or (not selected.is_empty() and (not selected[0] is String or selected[0] not in offer.options)):
		return false
	var group: String = "p%02d_primero" % context.position
	var rewards: Array = state.missions[context.mission_id].rewards[context.owner_id]
	if group in rewards or (not selected.is_empty() and not Targets.defeat(state, _definitions_for(ally_ids), selected[0])):
		return false
	rewards.append(group)
	return true
