extends "res://scripts/game/mission_play.gd"
## Servicio interno competitivo. La selección procede exclusivamente de SnapshotSource.

const M1 = preload("res://scripts/game/m1_play.gd")
const M2 = preload("res://scripts/game/m2_play.gd")
const M8 = preload("res://scripts/game/m8_play.gd")
const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
const VERSION: String = "integrated_registry_v1_m1_m2_m8"
var _combined_registry: Registry
var _ally_ids: String = ""
var _training_profile: Dictionary = {}
var _content: Dictionary = {}
var _submission: Dictionary = {}
var _submission_actor: String = ""
var _expected_rng: int = 0


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	super(catalog, inert_descriptors, training_profile, mission_descriptors)
	# El padre ya verifica catálogo completo, fuentes físicas y descriptores.
	# Reutilizar ese resultado evita volver a leer/hashear las mismas imágenes.
	var admitted: bool = _supported
	var content: Dictionary = _state._definitions
	_supported = false
	_profile_id = ""
	_handlers.clear()
	var ids: Array = []
	for id: String in content:
		if content[id].tipo == "aliado":
			ids.append(id)
	ids.sort()
	_ally_ids = ",".join(ids)
	_combined_registry = Registry.new(registration(_ally_ids))
	if admitted:
		_content = content.duplicate(true)
		_training_profile = training_profile.duplicate(true)
		_advance = _trusted_advance()
		_supported = _combined_registry.is_valid() and _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
		if _supported:
			_profile_id = "integrated_profile_" + (_identity + Funding._canonical_content(training_profile) + VERSION).sha256_text()
			_handlers[ACTION_ID] = _advance_action
			_starters[ACTION_ID] = _start_sequence
			_selectors[ACTION_ID] = _select_route
	_state = State.new(content, _identity, _combined_registry)
	_resolver = Resolver.new(_combined_registry, content)


static func registration(ally_ids: String) -> Dictionary:
	var result: Dictionary = {"operations": {}, "programs": {}}
	for family: Dictionary in [M1.registration(), M2.registration(ally_ids), M8.registration()]:
		for section: String in ["operations", "programs"]:
			for id: String in family[section]:
				if result[section].has(id):
					return {}
				result[section][id] = family[section][id]
	return result


func _trusted_advance() -> Advance:
	return Advance.new(_content, _identity, _training_profile, true, true, Registry.new(registration(_ally_ids)), true, true, true)


func _registry_intact() -> bool:
	var expected: Registry = Registry.new(registration(_ally_ids))
	return _combined_registry.is_valid() and _combined_registry._operations == expected._operations and _combined_registry._programs == expected._programs


func submit(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, Callable(), START_TURN_ACTION)


func start_turn(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, _start, START_TURN_ACTION)


func finish_cleanup(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, _cleanup, CLEANUP_ACTION)


func _operation(actor_id: String, input: Variant, handler: Callable, kind: String) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	_submission = input.duplicate(true) if _check_syntax(input).is_empty() else {}
	_submission_actor = actor_id
	var result: Dictionary = _submit(actor_id, input, handler, kind)
	_submission = {}
	_submission_actor = ""
	_busy = false
	return result


func _restore(match_id: String, source: Variant) -> Dictionary:
	if not _registry_intact():
		return _load_rejected("Registro integrado incompatible.")
	var result: Dictionary = super._restore(match_id, source)
	if result.ok:
		var snapshot: Dictionary = _state.get_snapshot()
		if not _fits(snapshot) or (snapshot.resolution != null and not _budget(snapshot, {})):
			_state = State.new(_content, _identity, _combined_registry)
			return _load_rejected("Estado integrado sin margen para vista/cierre.")
	return result


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
	var sequence: bool = (mission.definition_id == "mision_m1" and position in [5, 9]) or (mission.definition_id == "mision_m8" and position in [5, 9, 12]) or (mission.definition_id == "mision_m2" and position in [4, 7, 10] and mission.first_arrivals["p%02d" % position] == null)
	var third: bool = position == 12
	for key: String in state.missions:
		if key != payload.mission_id:
			third = third and state.missions[key].progress[actor_id] == 12
	if sequence and not third:
		return Route.SEQUENCE
	var rng: RandomNumberGenerator = _rng_for(state)
	var result: Dictionary = _advance.advance(state, actor_id, payload.mission_id, rng)
	if not result.ok or not _reserve(result.candidate, actor_id, 1) or not _fits(result.candidate):
		return "estado_invalido"
	return Route.DIRECT


func _start_sequence(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	var route: Variant = _select_route(state, actor_id, payload)
	if not route is int or route != Route.SEQUENCE:
		return route if route is String else "accion_ilegal"
	var mission: Dictionary = state.missions[payload.mission_id]
	var position: int = mission.progress[actor_id] + 1
	var first: bool = mission.first_arrivals["p%02d" % position] == null
	var request: Dictionary = {"program_id": mission.definition_id.trim_prefix("mision_") + ("_first_v1" if first else "_normal_v1"), "source_id": mission.definition_id, "recipients": [actor_id],
		"context": {"owner_id": actor_id, "turn_number": state.turn.number, "entry_phase": "libre", "occurrence_id": Advance.occurrence(state, actor_id, payload.mission_id, position), "mission_id": payload.mission_id, "position": position}}
	return request if _budget(state, request) else "estado_invalido"


func _advance_action(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["mission_id"]) or not Registry.valid_id(payload.mission_id):
		return "formato_invalido"
	var result: Dictionary = _advance.advance(candidate, actor_id, payload.mission_id, rng)
	if not result.ok:
		return result.codigo
	candidate.merge(result.candidate, true)
	return ""


func _start(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	return _internal_candidate(candidate, actor_id, payload, START_TURN_ACTION, rng, _advance)


func _cleanup(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	return _internal_candidate(candidate, actor_id, payload, CLEANUP_ACTION, rng, _advance)


func _internal_candidate(candidate: Dictionary, actor_id: String, payload: Dictionary, kind: String, rng: RandomNumberGenerator, advance: Advance) -> String:
	if not Registry.exact_keys(payload, ["turn_number"]) or not payload.turn_number is int or payload.turn_number < 1:
		return "formato_invalido"
	if candidate.turn.phase != ("inicio" if kind == START_TURN_ACTION else "limpieza") or candidate.turn.number != payload.turn_number:
		return "accion_ilegal"
	if not _registry_intact() or not advance.state_error(candidate).is_empty():
		return "estado_invalido"
	if kind == CLEANUP_ACTION:
		var result: Dictionary = Cleanup.new(_content, _identity, advance._registry).finish_cleanup(candidate, actor_id, rng)
		if not result.ok:
			return result.codigo
	else:
		var result: Dictionary = advance._training.advance(candidate, actor_id)
		if not result.ok:
			return result.codigo
		candidate.merge(result.candidate, true)
		var player: Dictionary = Advance._player(candidate, actor_id)
		for mission_id: String in candidate.authority.mission_permanents:
			var entries: Dictionary = candidate.authority.mission_permanents[mission_id]
			if entries.has(actor_id):
				var resource: String = "ataque" if candidate.missions[mission_id].definition_id == "mision_m2" else "recursos"
				if player.turn_resources[resource] > Registry.MAX_INT - 2:
					return "estado_invalido"
				player.turn_resources[resource] += 2
				entries[actor_id].last_applied_turn = candidate.turn.number
		candidate.turn.phase = "libre"
	var budget: Dictionary = candidate.duplicate(true)
	return "" if _reserve(budget, actor_id, 1) and _fits(budget) else "estado_invalido"


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if not super._protected_fields(candidate, current) or not _registry_intact():
		return false
	# Reejecutar con registro y candidato nuevos; comparar RNG después de su sellado
	# P07. Admitir robo en M4 no permite azar en ningún otro segmento.
	var expected: Dictionary = current.duplicate(true)
	var rng: RandomNumberGenerator = _rng_for(current)
	var payload: Dictionary = _submission.get("payload", {})
	var kind: String = _submission.get("tipo", "")
	var runner: Resolver = Resolver.new(Registry.new(registration(_ally_ids)), _content)
	if kind == "responder":
		var result: Resolver.Result = runner.resume(expected, payload.options, rng)
		if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
			return false
	elif kind in [START_TURN_ACTION, CLEANUP_ACTION]:
		if not _internal_candidate(expected, _submission_actor, payload, kind, rng, _trusted_advance()).is_empty():
			return false
	elif kind == ACTION_ID:
		var route: Variant = _select_route(current, _submission_actor, payload)
		if route == Route.DIRECT:
			var result: Dictionary = _trusted_advance().advance(current, _submission_actor, payload.mission_id, rng)
			if not result.ok:
				return false
			expected = result.candidate
		elif route == Route.SEQUENCE:
			var request: Variant = _start_sequence(current, _submission_actor, payload)
			if not request is Dictionary:
				return false
			var result: Resolver.Result = runner.begin(expected, _submission_actor, request, rng)
			if result.status in [Resolver.Result.Status.ILLEGAL, Resolver.Result.Status.INVALID]:
				return false
		else:
			return false
	else:
		return false
	_expected_rng = rng.state
	return candidate == expected


func _candidate_error(candidate: Dictionary) -> String:
	return "" if candidate.authority.rng_state == _expected_rng and _fits(candidate) else "estado_invalido"


static func _rng_for(state: Dictionary) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = state.authority.rng_seed
	rng.state = state.authority.rng_state
	return rng


func _reserve(state: Dictionary, owner: String, remaining: int) -> bool:
	if state.revision > Registry.MAX_INT - remaining:
		return false
	if not state.authority.receipts.has(owner):
		state.authority.receipts[owner] = {}
	if state.authority.receipts[owner].size() > 10000 - remaining:
		return false
	for index: int in remaining:
		var key: String = "integrated_budget_" + str(index)
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
		if not preload("res://scripts/game/state_validator.gd").new()._plain(ViewBuilder.new().project(state, player.player_id, _content), 0):
			return false
	return true


func _budget(state: Dictionary, request: Dictionary) -> bool:
	if not _fits(state):
		return false
	var candidate: Dictionary = state.duplicate(true)
	var active: Dictionary = request if not request.is_empty() else candidate.resolution
	var owner: String = active.context.owner_id
	var family: String = active.source_id
	var cursor: int = 0 if not request.is_empty() else active.cursor
	var groups: int = (2 if active.program_id.ends_with("first_v1") else 1) - maxi(0, cursor - 1)
	var remaining: int = groups + (1 if not request.is_empty() else 0)
	if family == "mision_m1":
		remaining = mini(M1.option_metals(candidate, owner).size(), groups) + (1 if not request.is_empty() else 0)
	var representatives: Array = []
	if family == "mision_m2":
		var options: Array = M2.Targets.options(candidate, _content)
		if options.size() > 10000:
			return false
		var destinations: Dictionary = {}
		for option: Dictionary in options:
			var destination: Dictionary = M2.Targets.discard_zone(candidate, option.owner_id)
			if destination.is_empty() or destination.cards.size() >= 10000:
				return false
			if not destinations.has(option.owner_id):
				destinations[option.owner_id] = true
				representatives.append(option.option_id)
		remaining = (1 if options.is_empty() else 2) if not request.is_empty() else 1
	elif family == "mision_m8":
		var maximum: int = (4 if active.context.position == 12 else 1) if cursor <= 1 else 0
		if active.program_id == M8.FIRST:
			maximum += 1
		if M8._eliminated(candidate).cards.size() > 10000 - mini(M8.option_cards(candidate, owner).size(), maximum):
			return false
	if not _reserve(candidate, owner, remaining):
		return false
	# La frontera cargada también necesita margen, antes de reducir su oferta.
	if request.is_empty() and not _fits(candidate):
		return false
	var rng: RandomNumberGenerator = _rng_for(state)
	var runner: Resolver = Resolver.new(_combined_registry, _content)
	if not request.is_empty():
		var result: Resolver.Result = runner.begin(candidate, owner, request, rng)
		if not _frontier(candidate, result, rng, state.authority.rng_state):
			return false
		if result.status == Resolver.Result.Status.CLOSED:
			return true
	if family == "mision_m2":
		# Contenido inerte: cada objetivo mueve una instancia. Comprobar todos los
		# destinos y una rama por propietario cubre los tamaños de todas las ramas.
		for option_id: String in representatives:
			var branch: Dictionary = candidate.duplicate(true)
			var result: Resolver.Result = runner.resume(branch, [option_id], rng)
			if result.status != Resolver.Result.Status.CLOSED or not _frontier(branch, result, rng, state.authority.rng_state):
				return false
		return not representatives.is_empty()
	# M1: refrescar una candidata siempre reduce la oferta en un nodo equivalente.
	# M8: omitir maximiza la oferta y correspondencias del propietario; sus cartas
	# ya eran visibles y trasladarlas conserva fichas y reduce correspondencias.
	# Para terceros eliminar revela cartas: domina la cota del snapshot validado
	# (instancia privada >=7 nodos + referencia, frente a ficha visible de 4).
	# Esta prueba requiere contenido inerte. El destino común se acotó arriba
	# para TODAS las selecciones legales.
	for iteration: int in 3:
		var selected: Array = [candidate.resolution.pending.options[0]] if family == "mision_m1" else []
		var result: Resolver.Result = runner.resume(candidate, selected, rng)
		if not _frontier(candidate, result, rng, state.authority.rng_state):
			return false
		if result.status == Resolver.Result.Status.CLOSED:
			return true
	return false


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
