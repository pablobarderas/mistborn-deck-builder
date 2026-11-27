extends SceneTree

const TrialEngine = preload("res://tests/integrated_trial_engine.gd")
const Core = preload("res://scripts/game/game_engine.gd")
const Profile = TrialEngine.Profile
const A: String = "p1"
const B: String = "p2"

var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var initial: Dictionary = TrialEngine.snapshot()
	var states: Array[Dictionary] = []
	var actions: Array[Dictionary] = []
	var receipts: Array[Dictionary] = []
	var views: Array[Array] = []
	var engine: TrialEngine = TrialEngine.new()
	if _load(engine, initial, "Estado inicial"):
		_save(engine, states, views)
		_check_initial(initial)
		for step: int in range(1, 7):
			if step in [2, 3, 6] and not _expect(states.back().resolution is Dictionary, "Ventana antes de responder"):
				break
			var entry: Dictionary = _entry(engine, step)
			_check_adverse_inputs(engine, step, entry, actions)
			var receipt: Dictionary = _submit(engine, entry)
			if not _expect(receipt.ok and receipt.get("revision_aplicada") == step,
					"Confirmacion %d: %s" % [step, receipt]):
				break
			actions.append(entry)
			receipts.append(receipt)
			_save(engine, states, views)
			_check_boundary(engine, states)
		if states.size() == 7:
			_test_restoration(states, actions, receipts, views)
			_test_invalid_loads(engine, states, actions)
			_test_terminal_failure(states[5], actions[5], receipts[5], states[6])
	_test_conserve(initial, false)
	_test_conserve(initial, true)
	if _failures == 0:
		print("E3_INTEGRATED_OK: %d comprobaciones." % _checks)
	else:
		push_error("Ensayo integrado: %d fallos en %d comprobaciones." % [_failures, _checks])
	quit(0 if _failures == 0 else 1)


func _entry(engine: TrialEngine, step: int) -> Dictionary:
	match step:
		1:
			return _action(engine, A, "abrir_seleccion", Profile.START)
		2:
			return _answer(engine, A, "elegir_ficha", "a2")
		3:
			return _answer(engine, A, "elegir_destino", "donar")
		4:
			return _action(engine, A, Profile.HANDOFF_PREFIX + "ensayo", Profile.HANDOFF)
		5:
			# La reacción se despacha en el segundo turno.
			return _action(engine, B, Profile.DISPATCH_PREFIX + "ensayo", Profile.DISPATCH)
		_:
			return _answer(engine, B, "canjear_carga", "canjear")


func _action(engine: TrialEngine, actor: String, id: String, kind: String, payload: Dictionary = {}) -> Dictionary:
	var state: Dictionary = engine.get_authority_snapshot()
	return {"actor": actor, "intent": {"version_accion": Core.ACTION_VERSION, "match_id": state.match_id,
		"expected_revision": state.revision, "action_id": id, "tipo": kind, "payload": payload}}


func _answer(engine: TrialEngine, actor: String, id: String, option: String) -> Dictionary:
	var window: Dictionary = engine.get_view(actor).resolution
	return _action(engine, actor, id, "responder",
		{"resolution_id": window.resolution_id, "step_id": window.step_id, "options": [option]})


func _submit(engine: TrialEngine, entry: Dictionary) -> Dictionary:
	if entry.intent.tipo in [Profile.HANDOFF, Profile.DISPATCH]:
		return engine.submit_internal(entry.actor, entry.intent)
	return engine.submit(entry.actor, entry.intent)


func _check_adverse_inputs(engine: TrialEngine, step: int, entry: Dictionary, prior: Array[Dictionary]) -> void:
	if step in [2, 3, 6]:
		var wrong: Dictionary = entry.duplicate(true)
		wrong.actor = B if entry.actor == A else A
		_reject(engine, wrong, "Respuesta desde la otra plaza")
	match step:
		2:
			_reject(engine, _answer(engine, A, "ficha_ajena", "b1"), "B1 no es seleccionable")
		3:
			var stale: Dictionary = prior[1].duplicate(true)
			stale.intent.action_id = "seleccion_obsoleta"
			stale.intent.expected_revision = engine.get_authority_snapshot().revision
			_reject(engine, stale, "Respuesta a la ventana anterior")
		4:
			_reject(engine, _action(engine, B, Profile.DISPATCH_PREFIX + "prematuro", Profile.DISPATCH),
				"Despacho antes del turno de B")
		6:
			_reject(engine, _action(engine, B, Profile.DISPATCH_PREFIX + "repetido", Profile.DISPATCH),
				"El despacho no abre una segunda reacción")


func _save(engine: TrialEngine, states: Array[Dictionary], views: Array[Array]) -> void:
	states.append(engine.get_authority_snapshot())
	views.append([engine.get_view(A), engine.get_view(B)])
	_check_views(states.back(), views.back())


func _check_views(state: Dictionary, views: Array) -> void:
	for view: Dictionary in views:
		_expect(view.outcome == state.outcome and not view.has("authority") 			and not var_to_str(view).contains("deferred_effect"), "Resultado público y obligación privada")
	if state.resolution == null:
		_expect(views[0].resolution == null and views[1].resolution == null, "Sin ventana en ambas plazas")
		return
	var own_index: int = 0 if state.revision in [1, 2] else 1
	var window: Dictionary = state.resolution
	var own: Dictionary = views[own_index].resolution
	var other: Dictionary = views[1 - own_index].resolution
	var expected: Dictionary = {1: ["a1", "a2"], 2: ["donar", "conservar"], 5: ["canjear"]}
	_expect(own.get("options", []) == expected.get(state.revision) and own.has("step_id"),
		"Opciones exactas para la plaza destinataria")
	_expect(other.resolution_id == window.resolution_id and not other.has("options") 		and not other.has("step_id") and not other.has("option_cards"), "La otra plaza solo ve el bloqueo")


func _check_initial(state: Dictionary) -> void:
	_expect(state.turn.active_id == A and state.zones.p1_mano.cards == ["a1", "a2"] 		and state.zones.p2_mano.cards == ["b1"] and state.zones.p1_descarte.cards.is_empty(),
		"Plazas y fichas iniciales")
	_expect(state.players[0].turn_resources == {"recursos": 4, "ataque": 0, "mision": 0} 		and state.players[1].turn_resources.ataque == 0, "Saldos iniciales")


func _check_boundary(engine: TrialEngine, states: Array[Dictionary]) -> void:
	var state: Dictionary = states.back()
	var previous: Dictionary = states[states.size() - 2]
	var balances: Dictionary = state.players[0].turn_resources
	var balances_b: Dictionary = state.players[1].turn_resources
	_expect(state.instances.keys() == states[0].instances.keys(), "Se conservan las tres instancias")
	match int(state.revision):
		1:
			_expect(state.players == previous.players and state.zones == previous.zones, "Selección sin cambios materiales")
		2:
			_expect(state.zones.p1_mano.cards == ["a1"] and state.zones.p1_descarte.cards == ["a2"] 				and state.players == previous.players, "Traslado exacto al descarte")
		3:
			_expect(balances.recursos == 2 and balances.ataque == 0 and balances_b.ataque == 1 				and state.resolution == null and state.authority.completed_sequences.size() == 1 \
				and state.authority.deferred_effect != null, "Donación y obligación confirmadas")
		4:
			_expect(state.turn.active_id == B and state.turn.number == 2 				and balances == {"recursos": 0, "ataque": 0, "mision": 0} 				and balances_b.ataque == 1 and state.authority.deferred_effect == previous.authority.deferred_effect,
				"El relevo conserva la obligación y reinicia solo los saldos de A")
		5:
			_expect(state.players == previous.players and state.resolution != null, "El despacho no consume carga")
		6:
			_expect(state.lifecycle == "finalizada" and state.turn.phase == "finalizada" 				and state.outcome.winner_id == B and balances_b.ataque == 0 and balances_b.mision == 0 				and state.resolution == null and state.authority.deferred_effect == null,
				"Carga consumida, obligación liquidada y resultado visible")
			var close: Dictionary = state.authority.completed_sequences.get(previous.resolution.resolution_id, {})
			_expect(close.get("revision_aplicada") == state.revision 				and state.authority.receipts[B].canjear_carga.revision_aplicada == state.revision,
				"Cierre y recibo terminal confirmados juntos")
			_reject(engine, _action(engine, B, "accion_terminal", Profile.START), "Rechazo tras finalizar")


func _test_restoration(states: Array[Dictionary], actions: Array[Dictionary], receipts: Array[Dictionary],
		views: Array[Array]) -> void:
	for boundary: int in states.size():
		var engine: TrialEngine = TrialEngine.new()
		if not _load(engine, states[boundary], "Restauracion de frontera %d" % boundary):
			continue
		_check_restored_views(engine, views[boundary])
		for index: int in boundary:
			_expect(_submit(engine, actions[index]) == receipts[index] 				and engine.get_authority_snapshot() == states[boundary], "Recibo anterior a la frontera")
		for index: int in range(boundary, actions.size()):
			_expect(_submit(engine, actions[index]) == receipts[index], "Recibo reproducido")
			_expect(engine.get_authority_snapshot() == states[index + 1], "Estado reproducido")
			_check_restored_views(engine, views[index + 1])
		for index: int in actions.size():
			_expect(_submit(engine, actions[index]) == receipts[index] 				and engine.get_authority_snapshot() == states.back(), "Reenvío devuelve el recibo original")
		var changed: Dictionary = actions[0].duplicate(true)
		changed.intent.payload = {"otro": 1}
		_reject(engine, changed, "ID reutilizado con contenido distinto", "id_reutilizado")


func _check_restored_views(engine: TrialEngine, expected: Array) -> void:
	_expect([engine.get_view(A), engine.get_view(B)] == expected, "Vistas restauradas para ambas plazas")


func _test_invalid_loads(engine: TrialEngine, states: Array[Dictionary], actions: Array[Dictionary]) -> void:
	var changed: Dictionary = states[3].duplicate(true)
	changed.authority.deferred_effect = null
	_reject_load(engine, changed, "Donación sin obligación")
	for index: int in [1, 2, 5]:
		changed = states[index].duplicate(true)
		changed.resolution = null
		_reject_load(engine, changed, "Recibos sin ventana en frontera %d" % index)
	changed = states.back().duplicate(true)
	var terminal_id: String = actions.back().intent.action_id
	changed.authority.receipts[B][terminal_id].revision_aplicada -= 1
	_reject_load(engine, changed, "Recibo terminal con revisión alterada")
	changed = states.back().duplicate(true)
	var different: Dictionary = actions.back().intent.duplicate(true)
	different.payload.options = ["conservar"]
	changed.authority.receipts[B][terminal_id].canonical = Core.canonical_intent(different)
	_reject_load(engine, changed, "Recibo terminal con otra elección")
	changed = states[1].duplicate(true)
	changed.version_motor = "otro_perfil"
	_reject_load(engine, changed, "Versión de otro perfil")
	var plain: Core = Core.new(Profile.definitions(), Profile.CATALOG)
	_expect(not plain.load_authority_snapshot(states[1]).ok, "El motor ordinario rechaza el ensayo")


func _test_terminal_failure(paused: Dictionary, answer: Dictionary, receipt: Dictionary, finished: Dictionary) -> void:
	var failing: TrialEngine = TrialEngine.new(true)
	if _load(failing, paused, "Carga antes del fallo terminal"):
		_reject(failing, answer, "El fallo terminal conserva el canje pendiente")
		var restored: TrialEngine = TrialEngine.new()
		if _load(restored, failing.get_authority_snapshot(), "Restauración tras fallo"):
			_expect(_submit(restored, answer) == receipt and restored.get_authority_snapshot() == finished,
				"El reintento confirma un único resultado")


func _test_conserve(initial: Dictionary, overflow: bool) -> void:
	var engine: TrialEngine = TrialEngine.new()
	var variant: Dictionary = initial.duplicate(true)
	var charge: int = Profile.MAX_INT if overflow else 0
	variant.players[1].turn_resources.ataque = charge
	if not _load(engine, variant, "Carga para conservar"):
		return
	for step: int in [1, 2]:
		if not _expect(_submit(engine, _entry(engine, step)).ok, "Alcanzar alternativa al conservar"):
			return
	if overflow:
		_reject(engine, _entry(engine, 3), "Desbordamiento revierte el canje y conserva la alternativa")
		_expect(engine.get_authority_snapshot().zones.p1_descarte.cards == ["a2"], "El traslado confirmado persiste")
	if not _expect(_submit(engine, _answer(engine, A, "conservar", "conservar")).ok, "Conservar carga"):
		return
	var state: Dictionary = engine.get_authority_snapshot()
	_expect(state.players[0].turn_resources == {"recursos": 2, "ataque": 1, "mision": 0} 		and state.players[1].turn_resources.ataque == charge and state.resolution == null 		and state.authority.deferred_effect == null and state.authority.completed_sequences.size() == 1 		and state.instances.keys() == initial.instances.keys(), "Conservar mantiene la carga y no agenda reacción")
	_load(TrialEngine.new(), state, "Restaurar cierre de la alternativa conservar")


func _load(engine: TrialEngine, state: Dictionary, label: String) -> bool:
	var result: Dictionary = engine.load_authority_snapshot(state)
	return _expect(result.ok and engine.get_authority_snapshot() == state, label + " " + str(result.get("errors", [])))


func _reject_load(engine: TrialEngine, state: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	_expect(not engine.load_authority_snapshot(state).ok and engine.get_authority_snapshot() == before, label)


func _reject(engine: TrialEngine, entry: Dictionary, label: String, code: String = "") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = _submit(engine, entry)
	_expect(not result.ok and (code.is_empty() or result.get("codigo") == code) 		and engine.get_authority_snapshot() == before, label + ": " + str(result))


func _expect(passed: bool, label: String) -> bool:
	_checks += 1
	if not passed:
		_failures += 1
		push_error(label)
	return passed
