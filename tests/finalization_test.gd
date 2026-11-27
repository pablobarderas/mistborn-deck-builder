extends SceneTree

const FinalizationEngine = preload("res://tests/finalization_engine.gd")
const Profile = FinalizationEngine.Profile
const Core = preload("res://scripts/game/game_engine.gd")
const Deferred = preload("res://tests/deferred_reaction_engine.gd")
const Owner: String = Profile.OWNER
const Opponent: String = Profile.OPPONENT
var _checks: int = 0
var _failures: int = 0


class FailingClose extends FinalizationEngine:
	var failure: String
	var reached_after_advance: bool = false

	func _init(kind: String) -> void:
		super()
		failure = kind

	func _commit_sequence_close(candidate: Dictionary, close: Dictionary) -> String:
		var result: String = super._commit_sequence_close(candidate, close)
		if not result.is_empty():
			return result
		reached_after_advance = candidate.missions[Profile.LAST_MISSION].progress.p1 == 12
		if failure == "close":
			return "estado_invalido"
		candidate.outcome.turn_number += 1
		return ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var engine: FinalizationEngine = FinalizationEngine.new()
	var initial: Dictionary = _fixture()
	if _load(engine, initial, "Carga inicial"):
		_test_flow(engine, initial)
	if _failures == 0:
		print("E3_FINALIZATION_OK: %d comprobaciones." % _checks)
	else:
		push_error("E3 finalizacion: %d fallos en %d comprobaciones." % [_failures, _checks])
	quit(0 if _failures == 0 else 1)


func _test_flow(engine: FinalizationEngine, initial: Dictionary) -> void:
	var start: Dictionary = _intent(initial, "solicitud_final", Profile.START)
	_reject(engine, Opponent, start, "accion_ilegal")
	_reject(engine, Owner, _with(start, "payload", {"ganador": Opponent}), "formato_invalido")
	var start_receipt: Dictionary = engine.submit(Owner, start)
	if not _expect(start_receipt.ok and start_receipt.revision_aplicada == initial.revision + 1, "Recibo del inicio"):
		return
	var pause: Dictionary = engine.get_authority_snapshot()
	if not _expect(pause.resolution is Dictionary, "El inicio abre una ventana"):
		return
	_expect(pause.revision == initial.revision + 1 and pause.lifecycle == "en_curso" and pause.outcome == null \
		and pause.players == initial.players and pause.missions == initial.missions and pause.turn == initial.turn,
		"El inicio conserva el punto y las posiciones")
	_expect(pause.authority.rng_state == initial.authority.rng_state and pause.authority.completed_sequences.is_empty() \
		and pause.authority.receipts.p1.size() == 1, "Inicio sin cierre ni consumo del RNG")
	_check_views(engine, pause)
	var answer: Dictionary = _answer(pause)
	_reject(engine, Opponent, answer, "eleccion_invalida")
	_reject(engine, Owner, _with(answer, "expected_revision", initial.revision), "revision_obsoleta")
	_reject(engine, Owner, _with(answer, "payload", {"options": [Profile.TOKEN]}), "eleccion_invalida")
	for invalid: Array in [["resolution_id", "resolution_42"], ["step_id", "otro"], ["options", ["otro"]],
			["options", []], ["options", [Profile.TOKEN, Profile.TOKEN]], ["ganador", Opponent]]:
		var payload: Dictionary = _with(answer.payload, invalid[0], invalid[1])
		_reject(engine, Owner, _with(answer, "payload", payload), "eleccion_invalida")
	var final_receipt: Dictionary = engine.submit(Owner, answer)
	if not _expect(final_receipt.ok and final_receipt.revision_aplicada == pause.revision + 1, "Recibo del cierre"):
		return
	var finished: Dictionary = engine.get_authority_snapshot()
	_check_final(pause, finished)
	_check_views(engine, finished)
	_check_replay(engine, start, answer, start_receipt, final_receipt)
	_test_restoration(engine, [initial, pause, finished], [start, answer], [start_receipt, final_receipt])
	_test_rollback(pause, answer)
	_test_invalid_loads(engine, pause, finished)
	var ordinary: FinalizationEngine = FinalizationEngine.new()
	if _load(ordinary, initial, "Carga para accion ordinaria"):
		var receipt: Dictionary = ordinary.submit(Owner, _intent(initial, "ordinaria", Profile.ORDINARY))
		_expect(receipt.ok and ordinary.get_authority_snapshot().turn.counters.get("marca_ensayo") == 1,
			"La accion bloqueada al terminar esta disponible en curso")
		var before_start: Dictionary = ordinary.get_authority_snapshot()
		if _expect(ordinary.submit(Owner, _intent(before_start, "otra_solicitud", Profile.START)).ok,
			"Una accion ordinaria puede preceder al inicio"):
			_expect(ordinary.submit(Owner, _answer(ordinary.get_authority_snapshot())).ok, "Cierre con historial previo")


func _check_final(pause: Dictionary, state: Dictionary) -> void:
	var mission: Dictionary = state.missions[Profile.LAST_MISSION]
	_expect(state.lifecycle == "finalizada" and state.turn == _with(pause.turn, "phase", "finalizada") \
		and state.resolution == null and state.outcome == Profile.outcome(pause), "Resultado terminal y turno esperado")
	for mission_id: String in Profile.MISSIONS:
		_expect(state.missions[mission_id].progress.p1 == 12 \
			and state.missions[mission_id].rewards == pause.missions[mission_id].rewards, "Cima y premios de " + mission_id)
	_expect(mission.first_arrivals.p12 == Owner and mission.arrival_order == [Owner] \
		and state.players[0].turn_resources.mision == 0, "Marcadores de llegada y punto consumido")
	var closed: Dictionary = state.authority.completed_sequences
	var expected_close: Dictionary = {"program_id": Profile.PROGRAM, "occurrence_id": Profile.OCCURRENCE,
		"owner_id": Owner, "turn_number": pause.turn.number, "revision_aplicada": pause.revision + 1}
	_expect(closed == {pause.resolution.resolution_id: expected_close} and state.revision == pause.revision + 1 \
		and state.authority.receipts.p1.size() == 2 and state.authority.receipts.p1.respuesta_final.revision_aplicada == state.revision,
		"Cierre y recibo comparten revision")
	_expect(state.authority.rng_state == pause.authority.rng_state and state.authority.rng_seed == pause.authority.rng_seed \
		and state.authority.next_id == pause.authority.next_id, "RNG e identificadores conservados")


func _check_views(engine: FinalizationEngine, state: Dictionary) -> void:
	var own: Dictionary = engine.get_view(Owner)
	var other: Dictionary = engine.get_view(Opponent)
	for view: Dictionary in [own, other]:
		_expect(view.outcome == state.outcome and view.lifecycle == state.lifecycle and view.turn == {
			"number": state.turn.number, "active_id": Owner, "phase": state.turn.phase}, "Resultado y turno visibles")
		var visible: String = var_to_str(view)
		for secret: String in ["authority", "context", Profile.OCCURRENCE, "completed_sequences", "receipts", "rng_seed", "rng_state"]:
			_expect(not visible.contains(secret), "Vista sin " + secret)
	if state.resolution == null:
		_expect(own.resolution == null and other.resolution == null, "Sin ventana terminal en ambas vistas")
		return
	var common: Dictionary = {"resolution_id": state.resolution.resolution_id, "kind": "eleccion",
		"recipients": [Owner], "pending_recipients": [Owner]}
	_expect(other.resolution == common, "B solo ve el bloqueo")
	common.merge({"step_id": Profile.STEP, "options": [Profile.TOKEN], "min": 1, "max": 1})
	_expect(own.resolution == common, "A recibe el paso, el token y sus limites")


func _check_replay(engine: FinalizationEngine, start: Dictionary, answer: Dictionary, start_receipt: Dictionary, final_receipt: Dictionary) -> void:
	var state: Dictionary = engine.get_authority_snapshot()
	_expect(engine.submit(Owner, start) == start_receipt and engine.submit(Owner, answer) == final_receipt \
		and engine.get_authority_snapshot() == state, "Recibos originales tras el cierre")
	_reject(engine, Owner, _with(start, "payload", {"otro": 1}), "id_reutilizado")
	_reject(engine, Owner, _with(answer, "expected_revision", state.revision), "id_reutilizado")
	var second: Dictionary = _with(_with(answer, "expected_revision", state.revision), "action_id", "respuesta_nueva")
	_reject(engine, Owner, second, "accion_ilegal")
	_reject(engine, Owner, _intent(state, "ordinaria_final", Profile.ORDINARY), "accion_ilegal")
	_reject(engine, Owner, _intent(state, "solicitud_nueva", Profile.START), "accion_ilegal")


func _test_restoration(continuous: FinalizationEngine, states: Array[Dictionary], intents: Array[Dictionary], receipts: Array[Dictionary]) -> void:
	for boundary: int in states.size():
		var engine: FinalizationEngine = FinalizationEngine.new()
		if not _load(engine, states[boundary], "Restauracion de frontera %d" % boundary):
			continue
		if boundary == 1:
			_check_views(engine, states[boundary])
		for action: int in range(boundary, intents.size()):
			_expect(engine.submit(Owner, intents[action]) == receipts[action] \
				and engine.get_authority_snapshot() == states[action + 1], "Sufijo y recibo reproducibles")
		for seat: String in [Owner, Opponent]:
			_expect(engine.get_view(seat) == continuous.get_view(seat), "Vista final reproducible")
		_check_replay(engine, intents[0], intents[1], receipts[0], receipts[1])


func _test_rollback(pause: Dictionary, answer: Dictionary) -> void:
	for kind: String in ["close", "candidate"]:
		var engine: FailingClose = FailingClose.new(kind)
		if _load(engine, pause, "Carga para rechazar " + kind):
			_reject(engine, Owner, answer, "estado_invalido")
			_expect(engine.reached_after_advance, "El rechazo ocurre despues de preparar el avance")
	for field: String in ["outcome", "phase", "lifecycle"]:
		var engine: FinalizationEngine = FinalizationEngine.new(_write_protected_field.bind(field))
		if _load(engine, pause, "Carga para mutacion de " + field):
			_reject(engine, Owner, answer, "estado_invalido")


static func _write_protected_field(state: Dictionary, _context: Dictionary, _params: Dictionary, rng: RandomNumberGenerator, _selected: Array, field: String) -> bool:
	rng.randi()
	match field:
		"outcome":
			state.outcome = Profile.outcome(state)
		"phase":
			state.turn.phase = "finalizada"
		"lifecycle":
			state.lifecycle = "finalizada"
	return true


func _test_invalid_loads(engine: FinalizationEngine, pause: Dictionary, finished: Dictionary) -> void:
	for change: Array in [["outcome", null], ["outcome", _with(finished.outcome, "mission_id", Profile.MISSIONS[0])],
			["outcome", _with(finished.outcome, "winner_id", Opponent)], ["lifecycle", "en_curso"],
			["turn", _with(finished.turn, "phase", "libre")], ["resolution", pause.resolution],
			["catalog_id", "test_catalog"], ["version_motor", "incompatible"], ["version_esquema", 1]]:
		_reject_load(engine, _with(finished, change[0], change[1]), "Rechaza " + change[0])
	_reject_load(engine, _with(pause, "outcome", finished.outcome), "Pausa con resultado")
	var changed: Dictionary = finished.duplicate(true)
	changed.missions[Profile.LAST_MISSION].progress.p1 = 11
	_reject_load(engine, changed, "Tercera cima ausente")
	changed = finished.duplicate(true)
	changed.missions[Profile.LAST_MISSION].first_arrivals.p12 = Opponent
	_reject_load(engine, changed, "Marcador de llegada incoherente")
	changed = finished.duplicate(true)
	changed.authority.completed_sequences.clear()
	_reject_load(engine, changed, "Cierre ausente")
	changed = finished.duplicate(true)
	var close: Dictionary = changed.authority.completed_sequences[pause.resolution.resolution_id]
	for change: Array in [["revision_aplicada", pause.revision], ["occurrence_id", "otra_ocurrencia"],
			["program_id", Deferred.Profile.PROGRAM], ["owner_id", Opponent], ["turn_number", 1]]:
		var original: Variant = close[change[0]]
		close[change[0]] = change[1]
		_reject_load(engine, changed, "Cierre con " + change[0] + " incompatible")
		close[change[0]] = original
	changed = finished.duplicate(true)
	changed.authority.receipts.p1.erase("respuesta_final")
	_reject_load(engine, changed, "Recibo terminal ausente")
	changed = finished.duplicate(true)
	changed.authority.receipts.p1.respuesta_final.revision_aplicada = pause.revision
	_reject_load(engine, changed, "Recibo terminal en otra revision")
	changed = finished.duplicate(true)
	changed.authority.receipts.p1.respuesta_final.canonical = changed.authority.receipts.p1.solicitud_final.canonical
	_reject_load(engine, changed, "Recibo terminal para otra accion")
	changed = pause.duplicate(true)
	changed.authority.receipts.clear()
	_reject_load(engine, changed, "Pausa sin recibo de inicio")
	_reject_load(engine, _with(pause, "resolution", null), "Recibo de inicio sin ventana")
	changed = finished.duplicate(true)
	changed.authority.receipts.p1.erase("solicitud_final")
	_reject_load(engine, changed, "Cierre con historial incompleto")
	changed = pause.duplicate(true)
	changed.resolution.context.mission_id = Profile.MISSIONS[0]
	_reject_load(engine, changed, "Pausa ligada a otra mision")
	var ordinary_engine: Core = Core.new(FinalizationEngine.definitions(), Profile.CATALOG)
	_reject_load(ordinary_engine, finished, "Motor ordinario excluye el perfil")
	var deferred: Deferred = Deferred.new()
	var deferred_state: Dictionary = FinalizationEngine.Fixtures.snapshot()
	deferred_state.version_esquema = Deferred.Profile.SCHEMA
	deferred_state.version_motor = Deferred.Profile.ENGINE
	deferred_state.catalog_id = Deferred.Profile.CATALOG
	deferred_state.authority["deferred_effect"] = null
	if _load(deferred, deferred_state, "Carga DIF para comprobacion cruzada"):
		_reject_load(deferred, pause, "DIF rechaza pausa FIN")
		_reject_load(deferred, finished, "DIF rechaza final FIN")
	_reject_load(engine, deferred_state, "FIN rechaza snapshot DIF")


static func _fixture() -> Dictionary:
	var state: Dictionary = FinalizationEngine.Fixtures.snapshot()
	state.version_motor = Profile.ENGINE
	state.catalog_id = Profile.CATALOG
	state.lifecycle = "en_curso"
	state.turn = {"number": 3, "active_id": Owner, "phase": "libre", "counters": {}}
	state.players[0].turn_resources.mision = 1
	state.missions.clear()
	for mission_id: String in Profile.MISSIONS:
		var position: int = 11 if mission_id == Profile.LAST_MISSION else 12
		var arrivals: Dictionary = {}
		for cell: int in range(1, 13):
			arrivals["p%02d" % cell] = Owner if cell <= position else null
		state.missions[mission_id] = {"definition_id": "test_mission", "progress": {Owner: position, Opponent: 0},
			"rewards": {Owner: ["premio_previo"], Opponent: []}, "arrival_order": [Owner] if position == 12 else [],
			"first_arrivals": arrivals}
	return state


static func _intent(state: Dictionary, id: String, action: String, payload: Dictionary = {}) -> Dictionary:
	return {"version_accion": Core.ACTION_VERSION, "match_id": state.match_id, "action_id": id,
		"expected_revision": state.revision, "tipo": action, "payload": payload}


static func _answer(pause: Dictionary) -> Dictionary:
	return _intent(pause, "respuesta_final", "responder",
		{"resolution_id": pause.resolution.resolution_id, "step_id": Profile.STEP, "options": [Profile.TOKEN]})


static func _with(dictionary: Dictionary, key: String, value: Variant) -> Dictionary:
	var copy: Dictionary = dictionary.duplicate(true)
	copy[key] = value
	return copy


func _load(engine: Core, state: Dictionary, label: String) -> bool:
	var result: Dictionary = engine.load_authority_snapshot(state)
	return _expect(result.ok and engine.get_authority_snapshot() == state, label + str(result.get("errors", [])))


func _reject_load(engine: Core, state: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	_expect(not engine.load_authority_snapshot(state).ok and engine.get_authority_snapshot() == before, label)


func _reject(engine: Core, actor: String, intent: Dictionary, expected: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var receipt: Dictionary = engine.submit(actor, intent)
	_expect(not receipt.ok and receipt.codigo == expected and engine.get_authority_snapshot() == before,
		"Rechazo atomico %s para %s: %s" % [expected, intent.action_id, receipt.codigo])


func _expect(passed: bool, label: String) -> bool:
	_checks += 1
	if not passed:
		_failures += 1
		push_error(label)
	return passed
