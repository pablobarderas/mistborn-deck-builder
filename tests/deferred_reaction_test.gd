extends SceneTree

const DeferredEngine = preload("res://tests/deferred_reaction_engine.gd")
const BaseEngine = preload("res://scripts/game/game_engine.gd")
const Profile = DeferredEngine.Profile
const Fixtures = DeferredEngine.Fixtures
var _checks: int = 0
var _failures: int = 0
var _states: Array[Dictionary] = []
var _intents: Array[Dictionary] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var continuous: DeferredEngine = _record_run()
	if _states.size() == 8 and continuous.get_authority_snapshot().resolution == null:
		_test_restoration(continuous)
		_test_rejection_and_replay()
		_test_overflow()
		_test_load()
	if _failures == 0:
		print("E3_DEFERRED_OK: %d comprobaciones." % _checks)
	else:
		push_error("E3 diferidos: %d fallos en %d comprobaciones." % [_failures, _checks])
	quit(0 if _failures == 0 else 1)


func _record_run() -> DeferredEngine:
	var initial: Dictionary = Fixtures.snapshot()
	initial.version_esquema = Profile.SCHEMA
	initial.version_motor = Profile.ENGINE
	initial.catalog_id = Profile.CATALOG
	initial.lifecycle = "en_curso"
	initial.turn = {"number": 1, "active_id": "p1", "phase": "libre", "counters": {}}
	initial.authority["deferred_effect"] = null
	initial.players[0].health = 10
	initial.players[1].turn_resources.recursos = 2
	var engine: DeferredEngine = _engine(initial)
	_states.append(initial)
	var schedule: Dictionary = _intent(initial, "programar_diferido_1", DeferredEngine.SCHEDULE)
	var dispatch: Dictionary = _intent(initial, "despachar_diferido_1", DeferredEngine.DISPATCH)
	_reject(engine, "p1", schedule, "Programación pública")
	_reject(engine, "p1", _with(schedule, "payload", {"turno": 2}), "Programación con payload", true)
	_reject(engine, "p1", dispatch, "Despacho en turno 1", true)
	if not _record(engine, "p1", schedule, true):
		return engine
	_expect(_states[1].resolution == null and _states[1].authority.deferred_effect == Profile.obligation(), "Obligación sin pausa")
	_reject(engine, "p1", _intent(_states[1], "programar_diferido_2", DeferredEngine.SCHEDULE), "Obligación duplicada", true)
	for move: Array in [["combate", "avanzar_fase", false], ["limpieza", "avanzar_fase", false],
			["limpieza_1", DeferredEngine.CLEANUP_ACTION, true]]:
		if not _record(engine, "p1", _intent(_states.back(), move[0], move[1]), move[2]):
			return engine
	_expect(_states[2].turn.phase == "combate" and _states[3].turn.phase == "limpieza", "Fronteras de transición")
	_expect(_states[4].turn == {"number": 2, "active_id": "p2", "phase": "inicio", "counters": {}}, "Limpieza entrega turno 2")
	_expect(_states[4].players[0].turn_resources.recursos == 0 and _states[4].zones.p1_mano.cards.size() == 2, "Ciclo real de limpieza")
	_reject(engine, "p2", _with(dispatch, "expected_revision", _states[4].revision), "Despacho durante inicio", true)
	if not _record(engine, "p2", _intent(_states[4], "inicio_2", DeferredEngine.START_TURN_ACTION), true):
		return engine
	_expect(_states[5].turn.phase == "libre" and _states[5].players[1].training == initial.players[1].training + 1, "Avance real de inicio")
	for boundary: int in range(1, 6):
		_expect(_states[boundary].authority.deferred_effect == Profile.obligation() and _states[boundary].resolution == null, "Obligación se conserva antes de despachar")
		_expect(_states[boundary].players[0].health == 10 and _states[boundary].players[1].turn_resources.recursos == 2, "Saldos antes de responder")
	_reject(engine, "p2", _intent(_states[5], "nueva_ordinaria", "avanzar_fase"), "La acción ordinaria no adelanta el evento")
	dispatch.expected_revision = _states[5].revision
	_reject(engine, "p1", dispatch, "Actor equivocado", true)
	_reject(engine, "p2", dispatch, "Despacho público")
	_reject(engine, "p2", _with(dispatch, "payload", {"turno": 2}), "Despacho con payload", true)
	var without: Dictionary = _states[5].duplicate(true)
	without.authority.deferred_effect = null
	_reject(_engine(without), "p2", dispatch, "Despacho sin obligación", true)
	_expect(engine.submit_internal("p1", schedule).get("revision_aplicada") == 1, "Reenvío antes del bloqueo por despacho")
	if not _record(engine, "p2", dispatch, true):
		return engine
	_expect(_states[6].authority.deferred_effect == Profile.obligation(), "Obligación persiste en pausa")
	_expect(_states[6].players == _states[5].players and _states[6].turn == _states[5].turn and _states[6].authority.rng_state == _states[5].authority.rng_state, "Despacho sólo abre la ventana")
	_test_privacy(engine)
	_record(engine, "p1", _answer(_states[6], ["activar"]), false)
	if _states.size() == 8:
		_check_closed(_states[6], _states[7], 11)
	return engine


func _test_restoration(continuous: DeferredEngine) -> void:
	for boundary: int in range(1, 7):
		var restored: DeferredEngine = _engine(_states[boundary])
		for index: int in range(boundary, _intents.size()):
			var recorded: Dictionary = _intents[index]
			var receipt: Dictionary = _submit(restored, recorded.actor, recorded.intent, recorded.internal)
			_expect(receipt == recorded.receipt and restored.get_authority_snapshot() == _states[index + 1], "Sufijo y recibo reproducibles desde frontera %d" % boundary)
		for player: String in ["p1", "p2"]:
			_expect(restored.get_view(player) == continuous.get_view(player), "Vista reproducible tras restaurar %d" % boundary)
	var passing: DeferredEngine = _engine(_states[6])
	_expect(passing.submit("p1", _answer(_states[6], [])).ok, "Pasar desde la misma pausa")
	_check_closed(_states[6], passing.get_authority_snapshot(), 10)
	var advancing: Dictionary = _intent(_states[7], "continuar", "avanzar_fase")
	_expect(continuous.submit("p2", advancing).ok and continuous.get_authority_snapshot().turn.phase == "combate", "La partida avanza tras cierre")


func _test_privacy(engine: DeferredEngine) -> void:
	var public: Dictionary = engine.get_view("p2")
	var private: Dictionary = engine.get_view("p1")
	var common: Dictionary = {"resolution_id": _states[6].resolution.resolution_id,
		"recipients": ["p1"], "kind": "reaccion", "pending_recipients": ["p1"]}
	_expect(public.resolution == common, "B recibe sólo el bloqueo público")
	common.merge({"step_id": Profile.STEP, "options": ["activar"], "min": 0, "max": 1})
	_expect(private.resolution == common, "A recibe la oferta privada")
	for view: Dictionary in [public, private]:
		var encoded: String = var_to_str(view)
		for secret: String in ["authority", "deferred_effect", "context", Profile.OCCURRENCE, "completed_sequences", "receipts", "rng_state", "rng_seed"]:
			_expect(not encoded.contains(secret), "Vista sin " + secret)


func _test_rejection_and_replay() -> void:
	var pause: Dictionary = _states[6]
	var engine: DeferredEngine = _engine(pause)
	var answer: Dictionary = _intents[6].intent
	var dispatch: Dictionary = _intents[5].intent
	_expect(engine.submit_internal("p2", dispatch) == _intents[5].receipt and engine.get_authority_snapshot() == pause, "Reenvío de despacho durante pausa")
	_reject(engine, "p2", answer, "Respuesta de B")
	_reject(engine, "p2", _intent(pause, "avanzar_pausa", "avanzar_fase"), "Bloqueo durante la pausa")
	for field: Array in [["options", ["desconocido"]], ["options", ["activar", "activar"]],
			["resolution_id", "resolution_999"], ["step_id", "paso_incorrecto"]]:
		_reject(engine, "p1", _with(answer, "payload", _with(answer.payload, field[0], field[1])), "Campo de respuesta incompatible")
	_reject(engine, "p1", _with(answer, "expected_revision", pause.revision - 1), "Revisión de respuesta incompatible")
	_expect(engine.submit("p1", answer) == _intents[6].receipt, "Respuesta original confirmada")
	for replay_engine: DeferredEngine in [engine, _engine(_states[7])]:
		_expect(replay_engine.submit_internal("p2", dispatch) == _intents[5].receipt, "Recibo original del despacho")
		_expect(replay_engine.submit("p1", answer) == _intents[6].receipt, "Recibo original de respuesta")
		_expect(replay_engine.get_authority_snapshot() == _states[7], "Reenvíos preservan cierre")
		_reject(replay_engine, "p2", _intent(_states[7], "despachar_diferido_2", DeferredEngine.DISPATCH), "Otro ID para despacho cerrado", true)
		_reject(replay_engine, "p1", _answer(_states[7], [], pause.resolution.resolution_id), "Segunda respuesta con nuevo ID")
		_reject(replay_engine, "p1", _with(answer, "payload", _with(answer.payload, "options", [])), "ID confirmado con contenido distinto")
		_reject(replay_engine, "p2", _with(dispatch, "payload", {"alterado": true}), "ID de despacho reutilizado", true)
	for action_id: String in ["programar_diferido_publico", "despachar_diferido_publico"]:
		_reject(engine, "p2", _intent(_states[7], action_id, "avanzar_fase"), "Prefijo reservado en acción ordinaria")


func _test_overflow() -> void:
	var resources: Dictionary = _states[6].duplicate(true)
	resources.players[1].turn_resources.recursos = Profile.MAX_INT
	var capped: DeferredEngine = _engine(resources)
	_reject(capped, "p1", _answer(resources, ["activar"]), "Recursos agotados al activar")
	_reject(capped, "p1", _answer(resources, []), "Recursos agotados al pasar")
	var health: Dictionary = _states[6].duplicate(true)
	health.players[0].health = Profile.MAX_INT
	capped = _engine(health)
	_reject(capped, "p1", _answer(health, ["activar"]), "Salud agotada después del primer incremento")
	_expect(capped.submit("p1", _answer(health, [])).ok, "Pasar tras el rechazo")
	_check_closed(health, capped.get_authority_snapshot(), Profile.MAX_INT)


func _test_load() -> void:
	var pause: Dictionary = _states[6]
	var closed: Dictionary = _states[7]
	var engine: DeferredEngine = _engine(pause)
	var close_id: String = pause.resolution.resolution_id
	for row: Array in [
		[_states[1], ["turn", "phase"], "inicio"], [_states[1], ["turn", "active_id"], "p2"],
		[_states[5], ["turn", "number"], 3], [_states[5], ["turn", "phase"], "combate"],
		[_states[5], ["player_order"], ["p2", "p1"]], [_states[5], ["players", 0, "eliminated"], true],
		[pause, ["authority", "deferred_effect", "recipient_id"], "p2"],
		[pause, ["authority", "deferred_effect", "occurrence_id"], "otro"],
		[pause, ["authority", "deferred_effect", "scheduled_turn"], true],
		[pause, ["authority", "deferred_effect", "due_turn"], 1],
		[pause, ["authority", "deferred_effect", "extra"], 0],
		[pause, ["authority", "deferred_effect"], null],
		[pause, ["resolution", "pending", "options"], ["otro"]],
		[pause, ["resolution", "pending", "min"], 1],
		[pause, ["resolution", "source_id"], "c1"],
		[pause, ["resolution", "context", "occurrence_id"], "otro"],
		[closed, ["authority", "deferred_effect"], Profile.obligation()],
		[closed, ["authority", "completed_sequences", close_id, "occurrence_id"], "otro"],
		[closed, ["authority", "completed_sequences", close_id, "owner_id"], "p1"],
		[closed, ["authority", "completed_sequences", close_id, "turn_number"], 1],
		[closed, ["authority", "completed_sequences", close_id, "program_id"], "otro"],
		[pause, ["version_esquema"], 8], [pause, ["version_motor"], Fixtures.Validator.ENGINE_VERSION],
		[pause, ["catalog_id"], "test_catalog"], [pause, ["authority", "extra"], null]]:
		_load_rejected(engine, _replace_at(row[0], row[1], row[2]), "Snapshot incompatible " + str(row[1]), pause)
	var missing: Dictionary = pause.duplicate(true)
	missing.authority.erase("deferred_effect")
	_load_rejected(engine, missing, "Falta la entrada privada", pause)
	missing = pause.duplicate(true)
	missing.authority.deferred_effect.erase("due_turn")
	_load_rejected(engine, missing, "Obligación incompleta", pause)
	var ordinary: BaseEngine = BaseEngine.new(Fixtures.definitions(), "test_catalog")
	var normal_snapshot: Dictionary = Fixtures.snapshot()
	_expect(ordinary.load_authority_snapshot(normal_snapshot).ok, "Snapshot normal sigue admitido")
	_load_rejected(ordinary, pause, "Perfil ficticio rechazado por cargador normal", normal_snapshot)
	_load_rejected(engine, normal_snapshot, "Snapshot normal rechazado por perfil ficticio", pause)
	var wrong_registry: BaseEngine = BaseEngine.new(Fixtures.definitions(), Profile.CATALOG)
	_expect(not wrong_registry.load_authority_snapshot(pause).ok, "Catálogo de ensayo sin registro adecuado")
	var wrong_catalog: BaseEngine = BaseEngine.new(Fixtures.definitions(), "test_catalog", {}, Profile.new())
	var wrong_catalog_snapshot: Dictionary = _with(pause, "catalog_id", "test_catalog")
	_expect(not wrong_catalog.load_authority_snapshot(wrong_catalog_snapshot).ok, "El perfil rechaza el catálogo anterior aunque coincida con el configurado")


func _check_closed(before: Dictionary, after: Dictionary, health: int) -> void:
	var authority: Dictionary = after.authority
	_expect(after.players[0].health == health and after.players[1].turn_resources.recursos == 3, "Saldos del cierre")
	_expect(after.resolution == null and authority.deferred_effect == null, "Liquida ventana y obligación juntas")
	var close: Dictionary = {"program_id": Profile.PROGRAM, "occurrence_id": Profile.OCCURRENCE, "owner_id": "p2",
		"turn_number": 2, "revision_aplicada": after.revision}
	_expect(authority.completed_sequences == {before.resolution.resolution_id: close}, "Cierre único y ligado a la reacción")
	_expect(after.turn == before.turn and authority.rng_state == before.authority.rng_state, "Cierre sin avance ni RNG")
	_expect(after.revision == before.revision + 1 and authority.receipts.p1.size() == before.authority.receipts.p1.size() + 1, "Respuesta confirma una revisión y un recibo")


func _record(engine: DeferredEngine, actor: String, intent: Dictionary, internal: bool) -> bool:
	var receipt: Dictionary = _submit(engine, actor, intent, internal)
	_expect(receipt.ok, "Confirma " + intent.tipo)
	if not receipt.ok:
		return false
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.revision == intent.expected_revision + 1 and receipt.revision_aplicada == after.revision \
		and after.authority.receipts[actor][intent.action_id].revision_aplicada == after.revision, "Revisión y recibo de " + intent.tipo)
	_intents.append({"actor": actor, "intent": intent, "internal": internal, "receipt": receipt})
	_states.append(after)
	return true


func _submit(engine: DeferredEngine, actor: String, intent: Dictionary, internal: bool) -> Dictionary:
	return engine.submit_internal(actor, intent) if internal else engine.submit(actor, intent)


func _engine(state: Dictionary) -> DeferredEngine:
	var engine: DeferredEngine = DeferredEngine.new()
	var loaded: Dictionary = engine.load_authority_snapshot(state)
	_expect(loaded.ok, "Carga snapshot de ensayo " + str(loaded.get("errors", [])))
	return engine


func _intent(state: Dictionary, id: String, action: String, payload: Dictionary = {}) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision,
		"tipo": action, "payload": payload}


func _answer(state: Dictionary, options: Array, closed_id: String = "") -> Dictionary:
	var resolution_id: String = state.resolution.resolution_id if closed_id.is_empty() else closed_id
	return _intent(state, "responder_%d" % state.revision, "responder",
		{"resolution_id": resolution_id, "step_id": Profile.STEP, "options": options})


func _with(document: Dictionary, field: String, value: Variant) -> Dictionary:
	return _replace_at(document, [field], value)


func _replace_at(document: Dictionary, path: Array, value: Variant) -> Dictionary:
	var copy: Dictionary = document.duplicate(true)
	var node: Variant = copy
	for index: int in range(path.size() - 1):
		node = node[path[index]]
	node[path.back()] = value
	return copy


func _reject(engine: DeferredEngine, actor: String, intent: Dictionary, message: String, internal: bool = false) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = _submit(engine, actor, intent, internal)
	_expect(not result.ok and engine.get_authority_snapshot() == before, message)


func _load_rejected(engine: BaseEngine, snapshot: Dictionary, message: String, baseline: Dictionary) -> void:
	var result: Dictionary = engine.load_authority_snapshot(snapshot)
	_expect(not result.ok and engine.get_authority_snapshot() == baseline, message)


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)
