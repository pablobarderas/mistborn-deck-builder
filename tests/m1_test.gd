extends SceneTree

const F = preload("res://tests/m1_fixtures.gd")
const Play = preload("res://scripts/game/m1_play.gd")
const Core = preload("res://scripts/game/game_engine.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Resolver = preload("res://scripts/game/sequence_resolver.gd")
const Views = preload("res://scripts/game/game_projection.gd")
const SequenceFixtures = preload("res://tests/sequence_fixtures.gd")
const M8 = preload("res://tests/m8_fixtures.gd")
const Permanents = preload("res://tests/permanents_fixtures.gd")
static var fault_reached: bool = false
var _checks: int = 0
var _failures: int = 0


class FailingAdvance extends "res://scripts/game/mission_advance.gd":
	var reached: bool = false
	var calls: int = 0
	func _apply(state: Dictionary, owner: String, effect: Dictionary, rng: RandomNumberGenerator = null) -> bool:
		if effect.op == "refrescar_agotados":
			calls += 1
			# Primera llamada: preflight real exitoso; segunda: handler candidato.
			if calls == 1:
				return super._apply(state, owner, effect, rng)
			var candidates: Array = Refresh.options(state, owner)
			if not candidates.is_empty():
				Refresh.apply(state, owner, [candidates[0].token_id])
				reached = true
			return false
		return super._apply(state, owner, effect, rng)


func _initialize() -> void:
	_expect(F.engine().is_supported(), "M1-08 perfil cerrado soportado")
	if _failures > 0:
		quit(1)
		return
	for count: int in [2, 3, 4]:
		_arrivals(count)
		_summits(count)
		_terminal(count)
		_restore_and_responses(count)
		_segment_failures(count)
	_windows_and_budgets()
	_restore_view_budget()
	_admission()
	if _failures == 0:
		print("P08_M1_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("M1_FAIL: " + label)


func _loaded(state: Dictionary) -> Play:
	var engine: Play = F.engine()
	var source = F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var result: Dictionary = engine.restore_match(state.match_id, source)
	_expect(result.ok, "M1 carga fiable " + str(result.get("errors", [])))
	return engine


func _reject(engine: Core, actor: String, action: Dictionary, code: String = "") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, action)
	_expect(not result.ok and (code.is_empty() or result.codigo == code), "rechazo " + code + " " + str(result))
	_expect(engine.get_authority_snapshot() == before, "rechazo conserva estado/recibos/ledger/revision/ids/RNG")


func _bad_load(state: Dictionary, label: String) -> void:
	var engine: Play = F.engine()
	var source = F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot().is_empty(), "M1-06 carga rechazada " + label)


func _arrivals(count: int) -> void:
	for position: int in [5, 9]:
		for first: bool in [true, false]:
			for amount: int in [0, 1, 2, 4]:
				var state: Dictionary = F.snapshot(count)
				F.metals(state, amount)
				F.metals(state, 3, "p2")
				if not first:
					F.at(state, position, "p2")
				F.at(state, position - 1)
				var engine: Play = _loaded(state)
				var action: Dictionary = F.advance(state)
				_expect(engine.submit("p1", action).ok, "M1-01 llegada %d/%d primera=%s N=%d" % [count, position, first, amount])
				var arrived: Dictionary = engine.get_authority_snapshot()
				_expect(arrived.missions.mission_1.progress.p1 == position and arrived.players[0].turn_resources.mision == state.players[0].turn_resources.mision - 1, "M1-01 gasto/llegada unico")
				_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == arrived, "M1-05 duplicado llegada")
				var selected_ids: Array = []
				for step: int in (2 if first else 1):
					var view: Dictionary = engine.get_view("p1")
					if selected_ids.size() == amount:
						_expect(view.resolution == null, "M1-01 auto_empty sin ventana ni deuda")
						break
					_expect(view.resolution.step_id == ("s02" if step == 0 else "s03") and view.resolution.min == 1 and view.resolution.max == 1, "M1-01 ventana obligatoria orden normal-extra")
					_expect(view.resolution.option_metals.size() == amount - step, "M1-01 reconstruye oferta sin ficha refrescada")
					_reject(engine, "p1", F.respond(view, [], "omit"), "eleccion_invalida")
					var option: Dictionary = view.resolution.option_metals[0]
					_expect(option.token_id not in selected_ids, "M1-01 no repite ficha")
					selected_ids.append(option.token_id)
					_expect(engine.submit("p1", F.respond(view, [option.option_id], "answer_%d" % step)).ok, "M1-01 refresco elegido")
				var closed: Dictionary = engine.get_authority_snapshot()
				_expect(closed.resolution == null and closed.authority.completed_sequences.size() == state.authority.completed_sequences.size() + 1, "M1-01 cierre unico incluso vacio")
				var expected: Dictionary = state.players[0].duplicate(true)
				expected.turn_resources.mision -= 1
				for token: Dictionary in expected.metals:
					if token.token_id in selected_ids:
						token.exhausted = false
				_expect(closed.players[0] == expected and closed.players.slice(1) == state.players.slice(1), "M1-02 solo agotamiento propio conserva usados quemados capacidad propietario orden Atium")
				_expect(closed.zones == state.zones and closed.instances == state.instances and closed.authority.rng_state == state.authority.rng_state, "M1-02 sin cartas/habilidades/RNG")
				_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == closed, "M1-05 duplicado cerrado")
	# Primer historico no se reasigna si esa plaza fue eliminada.
	if count >= 3:
		var state: Dictionary = F.snapshot(count)
		F.at(state, 5, "p2")
		state.players[1].health = 0
		state.players[1].eliminated = true
		F.at(state, 4)
		F.metals(state, 2)
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok and engine.get_authority_snapshot().resolution.program_id == Play.NORMAL, "M1-01 primero eliminado conserva prioridad")


func _summits(count: int) -> void:
	for training: int in [2, 3, 9, 15]:
		for first: bool in [true, false]:
			for amount: int in [0, 3]:
				var state: Dictionary = F.snapshot(count)
				state.players[0].training = training
				state.players[0].burn_limit = [2, 3, 9, 15].find(training) + 1
				F.metals(state, amount)
				if not first:
					F.at(state, 12, "p2")
				F.at(state, 11)
				var engine: Play = _loaded(state)
				var action: Dictionary = F.advance(state)
				_expect(engine.submit("p1", action).ok, "M1-02 cima automatica 2/3/4 base1-4 N0/3 primera/posterior")
				var after: Dictionary = engine.get_authority_snapshot()
				_expect(after.players[0].burn_limit == state.players[0].burn_limit + 1 and "p12_permanente" in after.missions.mission_1.rewards.p1, "M1-03 bonus inmediato 2-5 con grupo permanente")
				_expect(after.resolution == null and after.authority.next_id == state.authority.next_id and after.authority.completed_sequences == state.authority.completed_sequences, "M1-02 cima directa sin programa ni ledger")
				var expected: Dictionary = state.players[0].duplicate(true)
				expected.turn_resources.mision -= 1
				expected.burn_limit += 1
				if first:
					for token: Dictionary in expected.metals:
						if token.metal != "atium":
							token.exhausted = false
				_expect(after.players[0] == expected and after.players.slice(1) == state.players.slice(1), "M1-02 total obligatorio propio solo agotamiento sin reiniciar usos")
				_expect(after.missions.mission_1.rewards.p1.has("p12_primero") == first and not after.missions.mission_1.rewards.p1.has("p12_normal"), "M1-06 grupos exactos cima")
				var restored: Play = _loaded(after)
				_expect(restored.get_authority_snapshot() == after and restored.submit("p1", action).ok and restored.get_authority_snapshot() == after, "M1-03 carga/recibo no reaplica bonus ni total")
				# Servicio futuro de entrenamiento usa su entrada interna real libre.
				if training == 2:
					var trained: Dictionary = engine._advance._training.advance_for_mission(after, "p1")
					_expect(trained.ok and trained.candidate.players[0].burn_limit == 3 and engine._advance.state_error(trained.candidate).is_empty(), "M1-03 candidato de entrenamiento conserva bonus sin falsear fase")
				for delta: int in [-1, 1]:
					var bad: Dictionary = after.duplicate(true)
					bad.players[0].burn_limit += delta
					_bad_load(bad, "bonus ausente/duplicado")
	var orphan: Dictionary = F.snapshot(count)
	orphan.players[0].burn_limit += 1
	_bad_load(orphan, "bonus huerfano")
	if count >= 3:
		var state: Dictionary = F.snapshot(count)
		F.at(state, 12, "p2")
		state.players[1].eliminated = true
		state.players[1].health = 0
		var engine: Play = _loaded(state)
		_expect(not engine.get_authority_snapshot().is_empty(), "M1-03 eliminada conserva bonus valido")
		state.players[1].burn_limit += 1
		_bad_load(state, "capacidad eliminada alterada")


func _advance_auto(state: Dictionary, mission_id: String, target: int = 12) -> Dictionary:
	var advance = F.engine()._advance
	while state.missions[mission_id].progress.p1 < target:
		var result: Dictionary = advance.advance(state, "p1", mission_id)
		_expect(result.ok, "M1-04 candidato automatico " + mission_id)
		if not result.ok:
			return state
		state = result.candidate
	return state


func _terminal(count: int) -> void:
	for terminal: String in ["mission_1", "mission_5", "mission_7"]:
		var state: Dictionary = F.snapshot(count)
		F.metals(state, 3)
		F.at(state, 11 if terminal == "mission_1" else 12)
		for mission_id: String in ["mission_5", "mission_7"]:
			state = _advance_auto(state, mission_id, 11 if mission_id == terminal else 12)
		var engine: Play = _loaded(state)
		var action: Dictionary = F.Missions.intent(state, terminal, "victory")
		_expect(engine.submit("p1", action).ok, "M1-04 tercera cima " + terminal)
		var after: Dictionary = engine.get_authority_snapshot()
		_expect(after.lifecycle == "finalizada" and after.outcome.mission_id == terminal and after.resolution == null, "M1-04 victoria inmediata")
		_expect(after.players[0].metals == state.players[0].metals and after.players[0].burn_limit == state.players[0].burn_limit and after.authority.completed_sequences == state.authority.completed_sequences and after.missions[terminal].rewards == state.missions[terminal].rewards, "M1-04 terminal sin premios ni bonus conserva M1 anterior")
		_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == after, "M1-04 recibo ganador")
		_reject(engine, "p1", F.advance(after, "after_win"), "accion_ilegal")
		_expect(_loaded(after).get_authority_snapshot() == after, "M1-06 carga final sin reejecucion")
		var bad: Dictionary = after.duplicate(true)
		bad.players[0].burn_limit += 1
		_bad_load(bad, "bonus terminal instalado/duplicado")
		if terminal == "mission_1":
			bad = after.duplicate(true)
			bad.players[0].burn_limit += 1
			bad.missions.mission_1.rewards.p1.append("p12_permanente")
			_bad_load(bad, "permanente terminal con total coherente")
	var atium: Dictionary = F.snapshot(count)
	for index: int in 3:
		atium.players[0].metals.append({"token_id": "more_atium_%d" % index, "metal": "atium", "exhausted": false, "used_this_turn": false})
	atium.players[0].persistent.atium = 4
	var engine: Play = _loaded(atium)
	_expect(engine.submit("p1", F.advance(atium)).ok and engine.get_authority_snapshot().lifecycle == "en_curso", "M1-04 cuatro Atium sin Confrontacion no ganan")


func _restore_and_responses(count: int) -> void:
	for position: int in [5, 9]:
		var state: Dictionary = F.snapshot(count)
		F.metals(state, 4)
		F.at(state, position - 1)
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M1-06 pausa normal")
		var normal: Dictionary = engine.get_authority_snapshot()
		var view: Dictionary = engine.get_view("p1")
		var foreign: Dictionary = engine.get_view("p2")
		_expect(view.resolution.option_metals.size() == 4 and view.resolution.option_metals[0].token_id != view.resolution.option_metals[1].token_id and view.resolution.option_metals[0].metal == view.resolution.option_metals[1].metal, "M1-07 mapa completo copias del mismo metal distintas")
		_expect(Registry.exact_keys(view.resolution.option_metals[0], ["option_id", "token_id", "metal", "exhausted", "used_this_turn"]), "M1-07 esquema de option_metals exacto")
		_expect(Registry.exact_keys(foreign.resolution, ["resolution_id", "recipients", "kind", "pending_recipients"]) and foreign.players[0].metals == normal.players[0].metals, "M1-07 terceros solo bloqueo con metales publicos")
		_expect(not foreign.has("authority") and not foreign.has("instances") and not view.resolution.has("option_cards"), "M1-07 sin RNG recibos ledger ni mapeo de cartas")
		for options: Array in [[], ["outside"], ["o00001", "o00001"], ["o00001", "o00002"]]:
			_reject(engine, "p1", F.respond(view, options), "eleccion_invalida")
		_reject(engine, "p2", F.respond(view, ["o00001"]), "eleccion_invalida")
		for field: String in ["resolution_id", "step_id"]:
			var wrong: Dictionary = F.respond(view, ["o00001"])
			wrong.payload[field] = "wrong"
			_reject(engine, "p1", wrong, "eleccion_invalida")
		var wrong: Dictionary = F.respond(view, ["o00001"])
		wrong.expected_revision -= 1
		_reject(engine, "p1", wrong, "revision_obsoleta")
		wrong = F.respond(view, ["o00001"])
		wrong.payload["option_metals"] = view.resolution.option_metals
		_reject(engine, "p1", wrong, "eleccion_invalida")
		_reject(engine, "p1", F.advance(normal, "interleaved"), "accion_ilegal")
		var restored: Play = _loaded(bytes_to_var(var_to_bytes(normal)))
		var answer: Dictionary = F.respond(view, [view.resolution.option_metals[0].option_id], "normal")
		_expect(engine.submit("p1", answer).ok and restored.submit("p1", answer).ok and engine.get_authority_snapshot() == restored.get_authority_snapshot(), "M1-06 continuidad normal desde vista suficiente")
		var extra: Dictionary = engine.get_authority_snapshot()
		_expect(engine.submit("p1", answer).ok and engine.get_authority_snapshot() == extra, "M1-05 reenvio normal durante extra")
		wrong = answer.duplicate(true)
		wrong.payload.options = []
		_reject(engine, "p1", wrong, "id_reutilizado")
		wrong = F.respond(view, ["o00001"], "stale_step")
		wrong.expected_revision = extra.revision
		_reject(engine, "p1", wrong, "eleccion_invalida")
		restored = _loaded(extra)
		_expect(restored.submit("p1", answer).ok and restored.get_authority_snapshot() == extra, "M1-05 recibo se conserva al cargar")
		answer = F.respond(engine.get_view("p1"), ["o00001"], "extra")
		_expect(engine.submit("p1", answer).ok and restored.submit("p1", answer).ok and engine.get_authority_snapshot() == restored.get_authority_snapshot(), "M1-06 continuidad extra")
		var closed: Dictionary = engine.get_authority_snapshot()
		_expect(engine.submit("p1", answer).ok and engine.get_authority_snapshot() == closed, "M1-05 recibo tras cierre")
		for mutation: String in ["version", "motor", "context", "position", "source", "cursor", "first", "offer", "min", "premarked", "missing_other", "ledger", "program", "initial", "budget", "capacity", "empty"]:
			var bad: Dictionary = normal.duplicate(true)
			match mutation:
				"version": bad.version_esquema = 5
				"motor": bad.version_motor = "p08-m8-choices-1/godot-4.7.2"
				"context": bad.resolution.context.injected = true
				"position": bad.resolution.context.position = 12
				"source": bad.resolution.source_id = "mision_m5"
				"cursor": bad.resolution.cursor = 2
				"first": bad.missions.mission_1.first_arrivals["p%02d" % position] = "p2"
				"offer": bad.resolution.pending.options.pop_back()
				"min": bad.resolution.pending.min = 0
				"premarked": bad.missions.mission_1.rewards.p1.append("p%02d_normal" % position)
				"missing_other": bad.missions.mission_5.progress.p2 = 4; bad.missions.mission_5.first_arrivals.p01 = "p2"; bad.missions.mission_5.first_arrivals.p02 = "p2"; bad.missions.mission_5.first_arrivals.p03 = "p2"; bad.missions.mission_5.first_arrivals.p04 = "p2"
				"ledger": bad.authority.completed_sequences[bad.resolution.resolution_id] = {"program_id": Play.FIRST, "occurrence_id": bad.resolution.context.occurrence_id, "owner_id": "p1", "turn_number": 3, "revision_aplicada": bad.revision}
				"program": bad.resolution.program_id = Play.NORMAL
				"initial": bad.resolution.cursor = 0; bad.resolution.pending = null
				"budget": bad.revision = Registry.MAX_INT - 1
				"capacity": bad.players[0].burn_limit += 1
				"empty": F.metals(bad, 0); bad.resolution.pending.options = []; bad.resolution.pending.min = 0; bad.resolution.pending.max = 0
			_bad_load(bad, mutation)
		var clean: Play = F.engine()
		_expect(not clean.load_authority_snapshot(normal).ok and not clean.restore_match(normal.match_id, normal).ok, "M1-06 cliente no es fuente fiable")
		_expect(not engine.restore_match(normal.match_id, F.Missions.LatestSource.new()).ok and engine.get_authority_snapshot() == closed, "M1-06 motor ocupado conserva estado")
		var source = F.Missions.LatestSource.new()
		source.confirm("wrong_profile", normal)
		_expect(not clean.restore_match(normal.match_id, source).ok, "M1-08 identidad perfil congelada")
		for mutation: String in ["predicate", "limit", "execute"]:
			clean = F.engine()
			match mutation:
				"predicate": clean._m1_registry._operations.m1_refresh.erase("auto_empty")
				"limit": clean._m1_registry._programs[Play.FIRST].option_limit = 16
				"execute": clean._m1_registry._operations.m1_refresh.execute = _fail_after_refresh
			source = F.Missions.LatestSource.new()
			source.confirm(clean.profile_identity(), normal)
			_expect(not clean.restore_match(normal.match_id, source).ok, "M1-08 registro congelado " + mutation)


static func _fail_after_refresh(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	Play._refresh(state, context, params, rng, selected)
	fault_reached = true
	return false


static func _fail_extra_offer(state: Dictionary, context: Dictionary, params: Dictionary) -> Variant:
	if params.extra:
		fault_reached = true
		return null
	return Play._offer(state, context, params)


static func _fail_initial_offer(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Variant:
	fault_reached = true
	return null


static func _fail_arrival(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	Play._arrive(state, context, params, rng, selected)
	fault_reached = true
	return false


func _fault_engine(state: Dictionary, registration: Dictionary) -> Core:
	var profile: Play = F.engine()
	var engine: Core = Core.new(profile._advance._definitions, profile.catalog_identity(), {}, Registry.new(registration))
	_expect(engine.load_authority_snapshot(state).ok, "M1-05 fixture inyeccion usa pausa real")
	return engine


static func _request(_state: Dictionary, _actor: String, _payload: Dictionary, request: Dictionary) -> Variant:
	return request


func _segment_failures(count: int) -> void:
	var state: Dictionary = F.snapshot(count)
	F.metals(state, 3)
	F.at(state, 4)
	var profile: Play = F.engine()
	var request: Dictionary = profile._start_m1(state, "p1", {"mission_id": "mission_1"})
	for kind: String in ["arrival", "offer"]:
		var registration: Dictionary = Play.registration()
		if kind == "arrival":
			registration.operations.m1_arrive.execute = _fail_arrival
		else:
			registration.operations.m1_refresh.offer = _fail_initial_offer
		var fault: Core = _fault_engine(state, registration)
		fault._starters["avanzar_mision"] = _request.bind(request)
		fault_reached = false
		_reject(fault, "p1", F.advance(state))
		_expect(fault_reached, "M1-05 fallo tras gasto/llegada/preparar oferta alcanzado " + kind)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "M1-05 pausa antes inyeccion")
	var normal: Dictionary = engine.get_authority_snapshot()
	for kind: String in ["refresh", "extra_offer"]:
		var registration: Dictionary = Play.registration()
		if kind == "refresh":
			registration.operations.m1_refresh.execute = _fail_after_refresh
		else:
			registration.operations.m1_refresh.offer = _fail_extra_offer
		var fault: Core = _fault_engine(normal, registration)
		fault_reached = false
		_reject(fault, "p1", F.respond(engine.get_view("p1"), ["o00001"]))
		_expect(fault_reached, "M1-05 fallo refresco/extra revierte segmento completo " + kind)
	_expect(engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "normal")).ok, "M1-05 normal confirmado antes fallo posterior")
	var extra: Dictionary = engine.get_authority_snapshot()
	var registration: Dictionary = Play.registration()
	registration.operations.m1_refresh.execute = _fail_after_refresh
	var fault: Core = _fault_engine(extra, registration)
	fault_reached = false
	_reject(fault, "p1", F.respond(engine.get_view("p1"), ["o00001"], "extra"))
	_expect(fault_reached and fault.get_authority_snapshot().players[0].metals[0].exhausted == false, "M1-05 fallo extra conserva normal ya confirmado")
	state = F.snapshot(count)
	F.metals(state, 3)
	F.at(state, 11)
	engine = _loaded(state)
	var failing: FailingAdvance = FailingAdvance.new(engine._advance._definitions, engine.catalog_identity(), F.Missions.training_profile(F.Missions.catalog()), false, true, engine._m1_registry, true)
	engine._advance = failing
	_reject(engine, "p1", F.advance(state), "estado_invalido")
	_expect(failing.reached and failing.calls == 2, "M1-02 preflight exitoso y fallo handler real tras primera ficha total revierte cima permanente gasto llegada")


static func _malicious_rng(candidate: Dictionary, actor: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not F.Advance.arrive(candidate, actor, payload.mission_id, 1):
		return "estado_invalido"
	rng.randi()
	return ""


static func _malicious(candidate: Dictionary, _actor: String, _payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	F.Advance.arrive(candidate, "p1", "mission_1", 1)
	F.Advance.arrive(candidate, "p1", "mission_7", 1)
	return ""


static func _sequence_rng(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	rng.randi()
	return Play._refresh(state, context, params, rng, selected)


func _windows_and_budgets() -> void:
	for amount: int in [16, 17, 100]:
		var state: Dictionary = F.snapshot()
		F.metals(state, amount)
		F.at(state, 4)
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M1-07 oferta completa N=%d" % amount)
		_expect(engine.get_view("p1").resolution.option_metals.size() == amount and engine.get_view("p1").resolution.options.size() == amount, "M1-07 no truncado")
		_expect(engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "n")).ok and engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "e")).ok, "M1-07 pausa admitida puede cerrar")
	var pending: Dictionary = {"kind": "eleccion", "recipients": ["p1"], "options": [], "min": 1, "max": 1}
	for index: int in 17:
		pending.options.append("o%05d" % index)
	var old: Registry = Registry.new(SequenceFixtures.registration())
	var current: Registry = Registry.new(Play.registration())
	_expect(old.option_limit("pause_v1") == 16 and not old.valid_pending(pending, ["p1"], "pause_v1") and current.valid_pending(pending, ["p1"], Play.FIRST), "M1-07 techo10000 propio anteriores16")
	for index: int in range(17, 10001):
		pending.options.append("o%05d" % index)
	_expect(not current.valid_pending(pending, ["p1"], Play.FIRST), "M1-07 exceso10000 rechazado")
	for direct: bool in [false, true]:
		var state: Dictionary = F.snapshot()
		F.metals(state, 3)
		F.at(state, 11 if direct else 4)
		state.authority.receipts["p1"] = {}
		# La historia de p05/p09 conserva sus revisiones de cierre.
		state.revision = maxi(state.revision, 1)
		var maximum: int = 10000 if direct else 9998
		for index: int in maximum:
			state.authority.receipts.p1["old_%d" % index] = {"canonical": "x", "revision_aplicada": 1}
		_expect(F.engine()._advance.state_error(state).is_empty(), "M1-07 base recibos valida")
		var engine: Play = _loaded(state)
		_reject(engine, "p1", F.advance(state), "estado_invalido")
		state.authority.receipts.p1.erase("old_%d" % (maximum - 1))
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M1-07 borde recibos reserva cierre directo/selectivo")
		if not direct:
			_expect(engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "n")).ok and engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "e")).ok, "M1-07 borde cierra sin borrar historial")
		_expect(engine.get_authority_snapshot().authority.receipts.p1.size() == 10000, "M1-07 historial completo10000")
		state = F.snapshot()
		F.metals(state, 3)
		F.at(state, 11 if direct else 4)
		state.revision = Registry.MAX_INT - (0 if direct else 2)
		engine = _loaded(state)
		_reject(engine, "p1", F.advance(state), "estado_invalido")
		state.revision -= 1
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M1-07 borde revision admite")
		if not direct:
			_expect(engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "n")).ok and engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "e")).ok, "M1-07 ultima revision cierra")
		_expect(engine.get_authority_snapshot().revision == Registry.MAX_INT, "M1-07 revision maxima exacta")
	# N0/1 cierra grupos automaticamente; no reservar respuestas inexistentes.
	for amount: int in [0, 1]:
		var state: Dictionary = F.snapshot()
		F.metals(state, amount)
		F.at(state, 4)
		state.revision = Registry.MAX_INT - (amount + 1)
		state.authority.receipts["p1"] = {}
		for index: int in 10000 - (amount + 1):
			state.authority.receipts.p1["old_%d" % index] = {"canonical": "x", "revision_aplicada": 1}
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M1-07 N0/1 reserva exacta sin respuestas inexistentes")
		if amount == 1:
			_expect(engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "only")).ok, "M1-07 una candidata extra auto_empty en ultimo recibo")
		_expect(engine.get_authority_snapshot().revision == Registry.MAX_INT and engine.get_authority_snapshot().authority.receipts.p1.size() == 10000 and engine.get_authority_snapshot().resolution == null, "M1-07 N0/1 cierre exacto de revision/recibos")

	var ids: Dictionary = F.snapshot()
	F.metals(ids, 2)
	F.at(ids, 4)
	ids.authority.next_id = Registry.MAX_INT
	_reject(_loaded(ids), "p1", F.advance(ids), "estado_invalido")
	var crowded: Dictionary = F.snapshot()
	F.metals(crowded, 7000)
	F.at(crowded, 4)
	_expect(F.engine()._advance.state_error(crowded).is_empty(), "M1-07 base7000 metales valida")
	_reject(_loaded(crowded), "p1", F.advance(crowded), "estado_invalido")
	var over: Dictionary = F.snapshot()
	F.metals(over, 10000)
	_bad_load(over, "contenedor10002 excede10000")


func _admission() -> void:
	var state: Dictionary = F.snapshot()
	for callback: Callable in [_malicious, _malicious_rng]:
		var engine: Play = _loaded(state)
		engine._handlers.avanzar_mision = callback
		_reject(engine, "p1", F.advance(state), "estado_invalido")
	for kind: String in ["iniciar_turno", "cerrar_limpieza", "quemar", "activar_habilidad", "pasar"]:
		_reject(_loaded(state), "p1", F.intent(state, "unsupported", kind, {}), "accion_no_soportada")
	var engine: Play = _loaded(state)
	_reject(engine, "p2", F.advance(state), "accion_ilegal")
	var wrong: Dictionary = F.advance(state)
	wrong.payload["cantidad"] = 2
	_reject(engine, "p1", wrong, "formato_invalido")
	wrong = F.advance(state)
	wrong.payload["fichas"] = ["p1_token_00000"]
	_reject(engine, "p1", wrong, "formato_invalido")
	var catalog: Dictionary = F.Missions.catalog()
	catalog.cartas[-1].habilidades[0].efectos = [{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"}]
	_expect(not F.engine(catalog).is_supported(), "M1-08 obligaciones activas desconocidas rechazadas")
	catalog = F.Missions.catalog()
	catalog.cartas[0].rasgos.recorridos[0].casillas[4].efectos[0].cantidad = 2
	_expect(not F.engine(catalog).is_supported(), "M1-08 descriptor M1 alterado rechazado")
	for old_profile: RefCounted in [F.Missions.engine(), M8.engine(), Permanents.engine()]:
		_expect(not old_profile._advance.state_error(state).is_empty(), "M1-08 perfiles previos no admiten M1")
	for mode: String in ["cooperativo", "solitario"]:
		wrong = state.duplicate(true)
		wrong.mode = mode
		_bad_load(wrong, "modo " + mode)
	for phase: String in ["inicio", "limpieza"]:
		wrong = state.duplicate(true)
		wrong.turn.phase = phase
		_bad_load(wrong, "fase " + phase)
	wrong = state.duplicate(true)
	wrong.missions.mission_1.definition_id = "mision_m8"
	_bad_load(wrong, "seleccion distinta de M1/M5/M7")
	catalog = F.Missions.catalog()
	catalog.cartas[0].nombre += " alterado"
	var changed: Play = F.engine(catalog)
	var source = F.Missions.LatestSource.new()
	source.confirm(changed.profile_identity(), state)
	_expect(not changed.restore_match(state.match_id, source).ok, "M1-08 identidad catalogo congelada")
	F.metals(state, 2)
	F.at(state, 4)
	engine = _loaded(state)
	var huge: Dictionary = F.advance(state)
	huge.payload["extra"] = []
	for index: int in 300:
		huge.payload.extra.append(index)
	_reject(engine, "p1", huge, "formato_invalido")
	_expect(engine.submit("p1", F.advance(state)).ok, "M1-05 pausa control RNG")
	var normal: Dictionary = engine.get_authority_snapshot()
	# Registro manipulado rechazado antes de permitir delta o RNG.
	engine._m1_registry._operations.m1_refresh.execute = _sequence_rng
	_reject(engine, "p1", F.respond(Views.new().project(normal, "p1"), ["o00001"]), "estado_invalido")
	# Callback del resolver ajeno al registro congelado: mismo delta, RNG cambiado.
	engine = _loaded(normal)
	var altered: Dictionary = Play.registration()
	altered.operations.m1_refresh.execute = _sequence_rng
	engine._resolver = Resolver.new(Registry.new(altered), engine._advance._definitions)
	_reject(engine, "p1", F.respond(engine.get_view("p1"), ["o00001"]), "estado_invalido")


static func _node_count(value: Variant) -> int:
	var total: int = 1
	if value is Dictionary:
		for item: Variant in value.values():
			total += _node_count(item)
	elif value is Array:
		for item: Variant in value:
			total += _node_count(item)
	return total


func _restore_view_budget() -> void:
	var state: Dictionary = F.snapshot()
	F.metals(state, 2)
	F.at(state, 4)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "M1-07 origen real de pausa para frontera vista")
	var boundary: Dictionary = engine.get_authority_snapshot()
	F.metals(boundary, 0)
	boundary.resolution.pending = Play._offer(boundary, boundary.resolution.context, {"extra": false})
	var constant_nodes: int = _node_count(Views.new().project(boundary, "p1"))
	# Derivar el coste real: ficha publica + mapa privado + opcion opaca.
	F.metals(boundary, 1)
	boundary.resolution.pending = Play._offer(boundary, boundary.resolution.context, {"extra": false})
	var per_candidate: int = _node_count(Views.new().project(boundary, "p1")) - constant_nodes
	var count: int = int(float(50001 - constant_nodes) / per_candidate)
	F.metals(boundary, count)
	boundary.resolution.pending = Play._offer(boundary, boundary.resolution.context, {"extra": false})
	var padding: int = 50001 - _node_count(Views.new().project(boundary, "p1"))
	var available: Dictionary = {"token_id": "budget_available", "metal": "hierro", "exhausted": false, "used_this_turn": false}
	var available_nodes: int = _node_count(available)
	if padding >= available_nodes:
		boundary.players[0].metals.append(available)
		padding -= available_nodes
	for metal: String in ["hierro", "acero", "peltre", "estano", "bronce", "zinc", "laton", "atium"]:
		if padding == 0:
			break
		boundary.players[0].burned[metal] = 0
		padding -= 1
	_expect(padding == 0 and _node_count(Views.new().project(boundary, "p1")) == 50001, "M1-07 frontera exacta vista actual50001")
	_expect(engine._advance.state_error(boundary).is_empty() and not engine._fits(boundary), "M1-06 pausa estructural valida pero vista actual no cabe")
	var next: Dictionary = boundary.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = next.authority.rng_seed
	rng.state = next.authority.rng_state
	var result: Resolver.Result = Resolver.new(Registry.new(Play.registration()), engine._advance._definitions).resume(next, ["o00001"], rng)
	next.resolution = result.resolution
	_expect(result.status == Resolver.Result.Status.PAUSED and engine._fits(next), "M1-06 refresco siguiente si cabe no legitima pausa actual")
	_bad_load(boundary, "vista actual sobre presupuesto aunque siguiente cabe")
