extends SceneTree

const F = preload("res://tests/m8_fixtures.gd")
const Play = preload("res://scripts/game/m8_play.gd")
const Core = preload("res://scripts/game/game_engine.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Resolver = preload("res://scripts/game/sequence_resolver.gd")
const Views = preload("res://scripts/game/game_projection.gd")
const SequenceFixtures = preload("res://tests/sequence_fixtures.gd")
static var fault_reached: bool = false
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	var initial: Play = F.engine()
	_expect(initial.is_supported(), "M8 perfil cerrado admitido")
	if not initial.is_supported():
		quit(1)
		return
	for count: int in [2, 3, 4]:
		_arrivals(count)
		_terminal(count)
	_zones_and_privacy()
	_windows()
	_responses()
	_restore_corruptions()
	_segment_failures()
	_boundaries()
	_bad_callback_returns()
	if _failures == 0:
		print("P08_M8_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _loaded(state: Dictionary) -> Play:
	var engine: Play = F.engine()
	var source = F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var loaded: Dictionary = engine.restore_match(state.match_id, source)
	_expect(loaded.ok, "M8 carga fiable " + str(loaded.get("errors", [])))
	return engine


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("M8_FAIL: " + label)


func _reject(engine: Core, actor: String, action: Dictionary, code: String = "") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, action)
	_expect(not result.ok and (code.is_empty() or result.codigo == code), "rechazo " + code + " " + str(result))
	_expect(before == engine.get_authority_snapshot(), "rechazo conserva cartas/grupos/recibos/ledger/ids/revisión/RNG")


func _arrivals(count: int) -> void:
	for position: int in [5, 9, 12]:
		for first: bool in [true, false]:
			var state: Dictionary = F.snapshot(count)
			F.cards(state, 6)
			if not first:
				F.at(state, position, "p2")
			F.at(state, position - 1)
			var engine: Play = _loaded(state)
			var action: Dictionary = F.advance(state)
			_expect(engine.submit("p1", action).ok, "M8-01 llegada %d/%d primera=%s" % [count, position, first])
			var paused: Dictionary = engine.get_authority_snapshot()
			_expect(paused.missions.mission_8.progress.p1 == position and paused.players[0].turn_resources.mision == state.players[0].turn_resources.mision - 1, "M8-01 llegada s01 gasto único")
			_expect(paused.resolution.cursor == 1 and paused.resolution.program_id == (Play.FIRST if first else Play.NORMAL), "M8-01 normal s02 antes extra")
			var view: Dictionary = engine.get_view("p1")
			_expect(view.resolution.max == (4 if position == 12 else 1), "M8-01 máximo normal")
			_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == paused, "M8-05 recibo llegada idempotente")
			var chosen: Array = view.resolution.options.slice(0, 4) if position == 12 else []
			if position == 12:
				_reject(engine, "p1", F.respond(view, view.resolution.options.slice(0, 5), "too_many"), "eleccion_invalida")
			_expect(engine.submit("p1", F.respond(view, chosen, "normal")).ok, "M8-02 normal máximo4 u omisión")
			if first:
				view = engine.get_view("p1")
				_expect(view.resolution.step_id == "s03" and view.resolution.max == 1, "M8-01 extra máximo1")
				_expect(engine.submit("p1", F.respond(view, [view.resolution.options[0]], "extra")).ok, "M8-02 usar extra tras omitir")
			var closed: Dictionary = engine.get_authority_snapshot()
			_expect(closed.zones.eliminadas.cards.size() == ((4 if position == 12 else 0) + (1 if first else 0)), "M8-01 ejecuta4+1 cima")
			_expect(closed.resolution == null and closed.authority.completed_sequences.size() == state.authority.completed_sequences.size() + 1, "M8-01 cierre exactamente una vez")
			_expect(closed.authority.rng_state == state.authority.rng_state and closed.authority.next_id == state.authority.next_id + 1, "M8-03 RNG intacto IDs sólo resolución")
			_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == closed, "M8-05 reenvío tras cierre")
	# Sin premio usa DIRECT sin asignar resolución ni ledger.
	var base: Dictionary = F.snapshot(count)
	var engine: Play = _loaded(base)
	_expect(engine.submit("p1", F.advance(base)).ok, "M8-08 casilla sin premio directa")
	var direct: Dictionary = engine.get_authority_snapshot()
	_expect(direct.resolution == null and direct.authority.next_id == base.authority.next_id and direct.authority.completed_sequences.is_empty(), "M8-08 directo sin resolución ficticia")


func _terminal(count: int) -> void:
	var state: Dictionary = F.snapshot(count)
	F.cards(state, 5)
	F.at(state, 11)
	# Usar candidatos automáticos reales para las otras cimas.
	var adapter: Play = F.engine()
	for mission_id: String in ["mission_5", "mission_7"]:
		for index: int in 12:
			var advanced: Dictionary = adapter._advance.advance(state, "p1", mission_id)
			_expect(advanced.ok, "M8-01 historia automática hacia tercera cima")
			if not advanced.ok:
				return
			state = advanced.candidate
	var engine: Play = _loaded(state)
	var request: Dictionary = F.advance(state, "victory")
	_expect(engine.submit("p1", request).ok, "M8-01 tercera cima directa")
	var final: Dictionary = engine.get_authority_snapshot()
	_expect(final.lifecycle == "finalizada" and final.outcome.mission_id == "mission_8" and final.resolution == null, "M8-01 victoria inmediata")
	_expect(final.zones == state.zones and final.authority.completed_sequences == state.authority.completed_sequences and final.missions.mission_8.rewards.p1 == state.missions.mission_8.rewards.p1, "M8-01 tercera cima sin premios/cartas/ledger")
	_expect(engine.submit("p1", request).ok and engine.get_authority_snapshot() == final, "M8-05 recibo tras victoria")
	_reject(engine, "p1", F.advance(final, "after_win"), "accion_ilegal")


func _zones_and_privacy() -> void:
	var state: Dictionary = F.snapshot(3)
	F.cards(state, 9)
	F.cards(state, 3, "p2")
	state.instances["deck"] = F.Missions.Base.instance("deck", "test_action", "p1")
	state.zones.p1_mazo.cards.append("deck")
	state.instances["market"] = F.Missions.Base.instance("market", "test_action", null)
	state.zones.mercado.cards.append("market")
	state.instances["removed"] = F.Missions.Base.instance("removed", "test_action", "p1")
	state.zones.eliminadas.cards.append("removed")
	F.at(state, 11)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "M8-02 cima zonas")
	var view: Dictionary = engine.get_view("p1")
	var options: Array = view.resolution.option_cards
	_expect(options.size() == 9 and options[0].instance_id != options[1].instance_id and options[0].definition_id == options[1].definition_id, "M8-02 copias distintas por instancia")
	_expect(options[0].zone_id == "p1_mano" and options[3].zone_id == "p1_descarte" and options[6].zone_id == "p1_juego", "M8-02 orden zonas estable")
	var foreign: Dictionary = engine.get_view("p2")
	_expect(not foreign.resolution.has("options") and not foreign.resolution.has("option_cards") and not foreign.resolution.has("step_id") and not foreign.resolution.has("max"), "M8-07 terceros sólo bloqueo")
	var hidden: Dictionary = engine.get_authority_snapshot()
	# Identidades ocultas cambian manteniendo cantidades y parte pública.
	var id: String = hidden.zones.p1_mano.cards[0]
	hidden.instances[id].definition_id = "test_ally"
	var old_id: String = hidden.zones.p1_descarte.cards[0]
	var replacement: Dictionary = hidden.instances[old_id].duplicate(true)
	hidden.instances.erase(old_id)
	replacement.instance_id = "private_other"
	hidden.instances["private_other"] = replacement
	hidden.zones.p1_descarte.cards[0] = "private_other"
	_expect(Views.new().project(hidden, "p2") == foreign, "M8-07 indistinguibilidad mano/descarte")
	var selected: Array = [options[6].option_id, options[0].option_id, options[3].option_id]
	var before: Dictionary = engine.get_authority_snapshot()
	var resources: Dictionary = before.players[0].duplicate(true)
	_expect(engine.submit("p1", F.respond(view, selected, "cross_zones")).ok, "M8-02 selección cruza tres zonas e incluye aliado")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.zones.eliminadas.cards == ["removed", options[0].instance_id, options[3].instance_id, options[6].instance_id], "M8-03 salida en orden oferta")
	_expect(after.players[0] == resources and after.instances == before.instances, "M8-03 conserva cartas/propietario/recursos/metal obtenido")
	for card: Dictionary in engine.get_view("p1").resolution.option_cards:
		_expect(card.instance_id not in after.zones.eliminadas.cards, "M8-03 extra excluye eliminadas")
	var other: Play = _loaded(before)
	selected.reverse()
	_expect(other.submit("p1", F.respond(view, selected, "cross_zones")).ok, "M8-03 permutación aceptada")
	var alternative: Dictionary = other.get_authority_snapshot()
	alternative.authority.receipts = after.authority.receipts.duplicate(true)
	_expect(alternative == after, "M8-03 permutar conjunto mismo snapshot salvo recibo")
	_expect(engine.submit("p1", F.respond(engine.get_view("p1"), [], "skip_extra")).ok, "M8-02 omitir extra")
	_expect(engine.get_view("p2").zones.eliminadas.cards.size() == 4, "M8-07 consecuencia eliminadas pública")


func _windows() -> void:
	for amount: int in [0, 1, 16, 17, 100]:
		var state: Dictionary = F.snapshot()
		F.cards(state, amount)
		F.at(state, 4)
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M8-04 oferta completa N=%d" % amount)
		var snapshot: Dictionary = engine.get_authority_snapshot()
		if amount == 0:
			_expect(snapshot.resolution == null and snapshot.missions.mission_8.rewards.p1 == ["p05_normal", "p05_primero"], "M8-02 auto_empty liquida ambos sin ventana")
		else:
			var view: Dictionary = engine.get_view("p1")
			_expect(view.resolution.options.size() == amount and view.resolution.option_cards.size() == amount and view.resolution.min == 0, "M8-04 lista y mapa completos sin truncado")
			_expect(engine.submit("p1", F.respond(view, [], "omit_normal")).ok, "M8-02 N>0 permite omisión")
			_expect(engine.submit("p1", F.respond(engine.get_view("p1"), [], "omit_extra")).ok and engine.get_authority_snapshot().resolution == null, "M8-04 omisión puede cerrar")
	var previous: Registry = Registry.new(SequenceFixtures.registration())
	var pending: Dictionary = {"kind": "eleccion", "recipients": ["p1"], "options": [], "min": 0, "max": 1}
	for index: int in 17:
		pending.options.append("o%05d" % index)
	_expect(previous.option_limit("pause_v1") == 16 and not previous.valid_pending(pending, ["p1"], "pause_v1"), "M8-04 anteriores mantienen16")
	var current: Registry = Registry.new(Play.registration())
	_expect(current.valid_pending(pending, ["p1"], Play.FIRST), "M8-04 límite M8 declara10000")
	for index: int in range(17, 10001):
		pending.options.append("o%05d" % index)
	_expect(not current.valid_pending(pending, ["p1"], Play.FIRST), "M8-04 exceso10000 rechazado")
	# Carga estructural excesiva, perfil bajo margen antes del gasto y carga pausa.
	var large: Dictionary = F.snapshot()
	F.cards(large, 7000)
	F.at(large, 4)
	var supported: Play = F.engine()
	_expect(not supported._advance.state_error(large).is_empty(), "M8-04 snapshot sobre presupuesto nodos rechazado")
	var near: Dictionary = F.snapshot()
	F.cards(near, 2)
	F.at(near, 4)
	near.authority.receipts["p1"] = {}
	for index: int in 9998:
		near.authority.receipts.p1["old_%d" % index] = {"canonical": "x", "revision_aplicada": 1}
	near.revision = 1
	_expect(supported._advance.state_error(near).is_empty(), "M8-04 base9998 recibos válida antes de oferta")
	var near_engine: Play = _loaded(near)
	_reject(near_engine, "p1", F.advance(near), "estado_invalido")
	near.authority.receipts.p1.erase("old_9997")
	near_engine = _loaded(near)
	_expect(near_engine.submit("p1", F.advance(near)).ok, "M8-04 base9997 reserva3 recibos hasta10000")
	_expect(near_engine.submit("p1", F.respond(near_engine.get_view("p1"), [], "normal")).ok, "M8-04 borde recibos omite normal")
	_expect(near_engine.submit("p1", F.respond(near_engine.get_view("p1"), [], "extra")).ok and near_engine.get_authority_snapshot().authority.receipts.p1.size() == 10000, "M8-04 borde recibos cierra sin borrar historial")
	var crowded: Dictionary = F.snapshot()
	F.cards(crowded, 6000)
	F.at(crowded, 4)
	_expect(supported._advance.state_error(crowded).is_empty(), "M8-04 base6000 cartas válida antes de oferta")
	near_engine = _loaded(crowded)
	_reject(near_engine, "p1", F.advance(crowded), "estado_invalido")
	crowded = F.snapshot()
	F.cards(crowded, 4800)
	F.at(crowded, 4)
	near_engine = _loaded(crowded)
	_expect(near_engine.submit("p1", F.advance(crowded)).ok, "M8-04 control cercano de nodos admite oferta completa")
	_expect(near_engine.submit("p1", F.respond(near_engine.get_view("p1"), [], "normal")).ok, "M8-04 control nodos omite normal")
	_expect(near_engine.submit("p1", F.respond(near_engine.get_view("p1"), [], "extra")).ok and near_engine.get_authority_snapshot().resolution == null, "M8-04 control nodos cierra extra sin truncar")
	var capacity: Dictionary = F.snapshot()
	F.cards(capacity, 3)
	F.at(capacity, 4)
	capacity.authority.next_id = Registry.MAX_INT
	var engine: Play = _loaded(capacity)
	_reject(engine, "p1", F.advance(capacity), "estado_invalido")
	capacity.authority.next_id = 3
	capacity.revision = Registry.MAX_INT - 2
	engine = _loaded(capacity)
	_reject(engine, "p1", F.advance(capacity), "estado_invalido")
	capacity.revision = Registry.MAX_INT - 3
	engine = _loaded(capacity)
	_expect(engine.submit("p1", F.advance(capacity)).ok, "M8-04 borde revisión admite cierre reservado")
	_expect(engine.submit("p1", F.respond(engine.get_view("p1"), [], "n")).ok and engine.submit("p1", F.respond(engine.get_view("p1"), [], "e")).ok and engine.get_authority_snapshot().revision == Registry.MAX_INT, "M8-04 en borde omisión cierra")


func _responses() -> void:
	var state: Dictionary = F.snapshot()
	F.cards(state, 4)
	F.at(state, 4)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "M8-05 abrir")
	var view: Dictionary = engine.get_view("p1")
	for options: Array in [["o00001", "o00001"], ["outside"], ["o00001", "o00002"]]:
		_reject(engine, "p1", F.respond(view, options), "eleccion_invalida")
	_reject(engine, "p2", F.respond(view, []), "eleccion_invalida")
	for field: String in ["resolution_id", "step_id"]:
		var wrong: Dictionary = F.respond(view, [])
		wrong.payload[field] = "wrong"
		_reject(engine, "p1", wrong, "eleccion_invalida")
	var stale: Dictionary = F.respond(view, [])
	stale.expected_revision -= 1
	_reject(engine, "p1", stale, "revision_obsoleta")
	var identities: Dictionary = F.respond(view, [])
	identities.payload["option_cards"] = view.resolution.option_cards
	_reject(engine, "p1", identities, "eleccion_invalida")
	var response: Dictionary = F.respond(view, ["o00001"], "normal")
	_expect(engine.submit("p1", response).ok, "M8-05 normal confirmado")
	var extra: Dictionary = engine.get_authority_snapshot()
	_expect(engine.submit("p1", response).ok and engine.get_authority_snapshot() == extra, "M8-05 duplicado normal devuelve recibo durante extra")
	var changed: Dictionary = response.duplicate(true)
	changed.payload.options = []
	_reject(engine, "p1", changed, "id_reutilizado")
	var old_step: Dictionary = F.respond(view, [], "old")
	old_step.expected_revision = extra.revision
	_reject(engine, "p1", old_step, "eleccion_invalida")
	_reject(engine, "p1", F.advance(extra, "interleaved"), "accion_ilegal")
	for kind: String in ["jugar_carta", "pasar", "iniciar_turno", "cerrar_limpieza"]:
		_reject(engine, "p1", F.intent(extra, "blocked", kind, {}))
	_expect(engine.submit("p1", F.respond(engine.get_view("p1"), [], "extra")).ok, "M8-05 cierra extra")
	var closed: Dictionary = engine.get_authority_snapshot()
	_expect(engine.submit("p1", response).ok and engine.get_authority_snapshot() == closed, "M8-05 duplicado responde tras cierre")
	var replay: Dictionary = F.respond(view, [], "new_after_close")
	replay.expected_revision = closed.revision
	_reject(engine, "p1", replay, "accion_ilegal")


func _restore_corruptions() -> void:
	var state: Dictionary = F.snapshot()
	F.cards(state, 7)
	F.at(state, 4)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "M8-06 pausa normal")
	var normal: Dictionary = engine.get_authority_snapshot()
	var restored: Play = _loaded(bytes_to_var(var_to_bytes(normal)))
	var answer: Dictionary = F.respond(engine.get_view("p1"), ["o00001"], "normal")
	_expect(engine.submit("p1", answer).ok and restored.submit("p1", answer).ok and engine.get_authority_snapshot() == restored.get_authority_snapshot(), "M8-06 continuidad normal fuente fiable int64")
	var extra: Dictionary = engine.get_authority_snapshot()
	restored = _loaded(extra)
	answer = F.respond(engine.get_view("p1"), ["o00001"], "extra")
	_expect(engine.submit("p1", answer).ok and restored.submit("p1", answer).ok and engine.get_authority_snapshot() == restored.get_authority_snapshot(), "M8-06 continuidad extra")
	for mutation: String in ["version", "motor", "context", "position", "source", "cursor", "first", "offer", "premarked", "missing_other", "ledger", "duplicate_zone", "program", "initial", "budget"]:
		var bad: Dictionary = normal.duplicate(true)
		match mutation:
			"version": bad.version_esquema = 4
			"motor": bad.version_motor = "p08-permanents-1/godot-4.7.2"
			"context": bad.resolution.context.injected = true
			"position": bad.resolution.context.position = 9
			"source": bad.resolution.source_id = "mision_m5"
			"cursor": bad.resolution.cursor = 2
			"first": bad.missions.mission_8.first_arrivals.p05 = "p2"
			"offer": bad.resolution.pending.options.pop_back()
			"premarked": bad.missions.mission_8.rewards.p1.append("p05_normal")
			"missing_other": bad.missions.mission_5.progress.p1 = 4
			"ledger": bad.authority.completed_sequences[bad.resolution.resolution_id] = {"program_id": Play.FIRST, "occurrence_id": bad.resolution.context.occurrence_id, "owner_id": "p1", "turn_number": 3, "revision_aplicada": bad.revision}
			"duplicate_zone": bad.zones.p1_juego.cards.append(bad.zones.p1_mano.cards[0])
			"program": bad.resolution.program_id = Play.NORMAL
			"initial": bad.resolution.cursor = 0; bad.resolution.pending = null
			"budget": bad.revision = Registry.MAX_INT - 1
		var clean: Play = F.engine()
		var source = F.Missions.LatestSource.new()
		source.confirm(clean.profile_identity(), bad)
		_expect(not clean.restore_match(bad.match_id, source).ok and clean.get_authority_snapshot().is_empty(), "M8-06 rechaza corrupción " + mutation)
	_expect(not engine.restore_match(normal.match_id, F.Missions.LatestSource.new()).ok and engine.get_authority_snapshot() == restored.get_authority_snapshot(), "M8-06 no rebobina motor ocupado")
	var clean: Play = F.engine()
	_expect(not clean.restore_match(normal.match_id, normal).ok and not clean.load_authority_snapshot(normal).ok, "M8-06 fuente cliente no admitida")
	var source = F.Missions.LatestSource.new()
	source.confirm("other_profile", normal)
	_expect(not clean.restore_match(normal.match_id, source).ok, "M8-06 perfil equivocado")
	for corruption: String in ["predicate", "limit"]:
		clean = F.engine()
		if corruption == "predicate":
			clean._m8_registry._operations.m8_remove.erase("auto_empty")
		else:
			clean._m8_registry._programs[Play.FIRST].option_limit = 16
		source = F.Missions.LatestSource.new()
		source.confirm(clean.profile_identity(), normal)
		_expect(not clean.restore_match(normal.match_id, source).ok, "M8-06 registro congelado " + corruption)


static func _fail_after_move(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var cards: Array = Play.option_cards(state, context.owner_id)
	for card: Dictionary in cards:
		if card.option_id in selected:
			state.zones[card.zone_id].cards.erase(card.instance_id)
			state.zones.eliminadas.cards.append(card.instance_id)
			fault_reached = true
			return false
	return false


static func _fail_extra_offer(state: Dictionary, context: Dictionary, params: Dictionary) -> Variant:
	if params.extra:
		fault_reached = true
		return null
	return Play._offer(state, context, params)


func _fault_engine(state: Dictionary, registration: Dictionary) -> Core:
	var profile: Play = F.engine()
	var engine: Core = Core.new(profile._advance._definitions, profile.catalog_identity(), {}, Registry.new(registration))
	_expect(engine.load_authority_snapshot(state).ok, "M8-05 fixture inyección admite pausa original")
	return engine


func _segment_failures() -> void:
	var state: Dictionary = F.snapshot()
	F.cards(state, 8)
	F.at(state, 11)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "M8-05 abrir fallos segmentos")
	var normal: Dictionary = engine.get_authority_snapshot()
	var registration: Dictionary = Play.registration()
	registration.operations.m8_remove.execute = _fail_after_move
	var fault: Core = _fault_engine(normal, registration)
	fault_reached = false
	_reject(fault, "p1", F.respond(Views.new().project(normal, "p1"), ["o00001", "o00002"]))
	_expect(fault_reached, "M8-05 fallo después de mover primera carta realmente alcanzado")
	registration = Play.registration()
	registration.operations.m8_remove.offer = _fail_extra_offer
	fault = _fault_engine(normal, registration)
	fault_reached = false
	_reject(fault, "p1", F.respond(Views.new().project(normal, "p1"), ["o00001"]))
	_expect(fault_reached, "M8-05 fallo al preparar extra revierte normal mismo segmento")
	_expect(engine.submit("p1", F.respond(engine.get_view("p1"), ["o00001"], "normal")).ok, "M8-05 normal antes fallo extra confirmado")
	var extra: Dictionary = engine.get_authority_snapshot()
	registration = Play.registration()
	registration.operations.m8_remove.execute = _fail_after_move
	fault = _fault_engine(extra, registration)
	fault_reached = false
	_reject(fault, "p1", F.respond(Views.new().project(extra, "p1"), ["o00001"], "extra"))
	_expect(fault_reached and fault.get_authority_snapshot().zones.eliminadas.cards == extra.zones.eliminadas.cards and extra.zones.eliminadas.cards.size() == 1, "M8-05 fallo extra conserva normal confirmado")


static func _bad_auto(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Variant:
	return "no"


static func _bad_binding(_state: Dictionary, _resolution: Dictionary) -> Variant:
	return 1


static func _invalid_selector(_state: Dictionary, _actor: String, _payload: Dictionary) -> Variant:
	return 88


static func _typed_wrong_selector(_state: int, _actor: String, _payload: Dictionary) -> int:
	return 0


static func _malicious_rng(candidate: Dictionary, actor: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not F.Advance.arrive(candidate, actor, payload.mission_id, 1):
		return "estado_invalido"
	rng.randi()
	return ""


static func _malicious(candidate: Dictionary, _actor: String, _payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	candidate.missions.mission_8.first_arrivals.p01 = "p1"
	candidate.missions.mission_8.progress.p1 = 1
	candidate.players[0].turn_resources.mision -= 1
	candidate.missions.mission_7.progress.p1 = 1
	candidate.missions.mission_7.first_arrivals.p01 = "p1"
	return ""


func _boundaries() -> void:
	var state: Dictionary = F.snapshot()
	F.cards(state, 2)
	for selector: Callable in [_invalid_selector, _typed_wrong_selector]:
		var engine: Play = _loaded(state)
		engine._selectors.avanzar_mision = selector
		_reject(engine, "p1", F.advance(state), "estado_invalido")
	var engine: Play = _loaded(state)
	engine._handlers.erase("avanzar_mision")
	_reject(engine, "p1", F.advance(state), "estado_invalido")
	F.at(state, 4)
	engine = _loaded(state)
	engine._starters.erase("avanzar_mision")
	_reject(engine, "p1", F.advance(state), "estado_invalido")
	state = F.snapshot()
	engine = _loaded(state)
	engine._handlers.avanzar_mision = _malicious
	_reject(engine, "p1", F.advance(state), "estado_invalido")
	engine = _loaded(state)
	engine._handlers.avanzar_mision = _malicious_rng
	_reject(engine, "p1", F.advance(state), "estado_invalido")
	var catalog: Dictionary = F.Missions.catalog()
	catalog.cartas[-1].habilidades[0].efectos = [{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"}]
	_expect(not F.engine(catalog).is_supported(), "M8-03 rechaza contenido activo aunque descriptor coincida")
	var old: RefCounted = F.Missions.engine()
	_expect(not old._advance.state_error(F.snapshot()).is_empty(), "M8-08 perfil anterior no admite M8")
	for mode: String in ["cooperativo", "solitario"]:
		var wrong: Dictionary = F.snapshot()
		wrong.mode = mode
		var source = F.Missions.LatestSource.new()
		engine = F.engine()
		source.confirm(engine.profile_identity(), wrong)
		_expect(not engine.restore_match(wrong.match_id, source).ok, "M8-08 no habilita modo " + mode)
	# Un registro sin auto_empty no convierte oferta vacía en cierre.
	state = F.snapshot()
	F.cards(state, 0)
	F.at(state, 4)
	var registration: Dictionary = Play.registration()
	registration.operations.m8_remove.erase("auto_empty")
	var registry: Registry = Registry.new(registration)
	var request: Dictionary = {"program_id": Play.FIRST, "source_id": "mision_m8", "recipients": ["p1"], "context": {"owner_id": "p1", "turn_number": 3, "entry_phase": "libre", "occurrence_id": F.Advance.occurrence(state, "p1", "mission_8", 5), "mission_id": "mission_8", "position": 5}}
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var result: Resolver.Result = Resolver.new(registry, F.engine()._advance._definitions).begin(state, "p1", request, rng)
	_expect(result.status == Resolver.Result.Status.INVALID, "M8-08 vacío sin predicado sigue inválido")


func _bad_callback_returns() -> void:
	var state: Dictionary = F.snapshot()
	F.cards(state, 2)
	F.at(state, 4)
	var profile: Play = F.engine()
	var request: Dictionary = profile._start_m8(state, "p1", {"mission_id": "mission_8"})
	for kind: String in ["auto_empty", "binding"]:
		var registration: Dictionary = Play.registration()
		if kind == "auto_empty":
			registration.operations.m8_remove.auto_empty = _bad_auto
		else:
			registration.programs[Play.FIRST].binding = _bad_binding
		var registry: Registry = Registry.new(registration)
		_expect(registry.is_valid(), "M8-08 fixture firma Variant inspeccionable")
		var runner: Resolver = Resolver.new(registry, profile._advance._definitions)
		var result: Resolver.Result = runner.begin(state.duplicate(true), "p1", request, RandomNumberGenerator.new())
		_expect(result.status in [Resolver.Result.Status.INVALID, Resolver.Result.Status.ILLEGAL], "M8-08 retorno no bool rechazado " + kind)
	# Sobre sobredimensionado no se duplica para el delta antes del límite P07.
	var engine: Play = _loaded(state)
	var huge: Dictionary = F.advance(state)
	huge.payload["extra"] = []
	for index: int in 300:
		huge.payload.extra.append(index)
	_reject(engine, "p1", huge, "formato_invalido")
