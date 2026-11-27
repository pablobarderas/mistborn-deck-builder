extends SceneTree

const EngineCore = preload("res://scripts/game/game_engine.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Cycle = preload("res://scripts/game/card_cycle.gd")
const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const Sequences = preload("res://tests/sequence_fixtures.gd")
const Handlers = preload("res://tests/game_engine_handlers.gd")
const Registry = Sequences.Registry
const MAX_INT: int = Registry.MAX_INT
static var _selection_failure_trace: Array = []
var _registry: Registry = Registry.new(Sequences.registration())
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_automatic()
	_test_resource_exchange()
	_test_alternatives()
	_test_move_from_hand()
	_test_private_hand_selection()
	_test_hand_selection_limits()
	_test_hand_selection_with_history()
	_test_hand_selection_rollback()
	_test_pause_and_resume()
	_test_successive_windows()
	_test_segment_rollback()
	_test_replay()
	_test_incompatibility()
	_test_response_validation()
	_test_privacy()
	_test_authority()
	_test_limits_and_modes()
	if _failures == 0:
		print("P08_SEQUENCE_OK: %d comprobaciones." % _checks)
	else:
		push_error("P08 secuencias: %d fallos en %d comprobaciones." % [_failures, _checks])
	quit(0 if _failures == 0 else 1)


func _prepared(mode: String = "competitivo", count: int = 2) -> Dictionary:
	var state: Dictionary = Fixtures.snapshot(mode, count)
	state.lifecycle = "en_curso"
	state.turn = {"number": 3, "active_id": "p1", "phase": "libre", "counters": {}}
	state.authority.rng_seed = -9223372036854774001
	state.authority.rng_state = 9007199254740997
	return state


func _engine(state: Dictionary, registry: Registry = null, handlers: Dictionary = {}, starters: Dictionary = {}) -> EngineCore:
	var actions: Dictionary = Handlers.registry() if handlers.is_empty() else handlers
	var starts: Dictionary = Sequences.starters() if starters.is_empty() else starters
	var engine: EngineCore = EngineCore.new(Fixtures.definitions(), state.catalog_id, actions, registry if registry != null else _registry, starts)
	var loaded: Dictionary = engine.load_authority_snapshot(state)
	_expect(loaded.ok, "Fixture v2 válido: %s" % [loaded.errors])
	return engine


func _intent(id: String, type: String, revision: int, payload: Dictionary = {}) -> Dictionary:
	return {"version_accion": 1, "match_id": "test_match", "action_id": id,
		"expected_revision": revision, "tipo": type, "payload": payload}


func _answer(view: Dictionary, id: String = "answer", selected: Array = ["accept"]) -> Dictionary:
	return {"version_accion": 1, "match_id": view.match_id, "action_id": id, "expected_revision": view.revision, "tipo": "responder",
		"payload": {"resolution_id": view.resolution.resolution_id, "step_id": view.resolution.step_id, "options": selected}}


func _rng(state: Dictionary) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = state.authority.rng_seed
	rng.state = state.authority.rng_state
	return rng


func _resource(state: Dictionary, index: int = 0) -> int:
	return state.players[index].turn_resources.recursos


func _test_automatic() -> void:
	var initial: Dictionary = _prepared()
	var a: EngineCore = _engine(initial)
	var b: EngineCore = _engine(initial)
	var intent: Dictionary = _intent("start", "test_auto", 0)
	var receipt: Dictionary = a.submit("p1", intent)
	_expect(receipt == {"ok": true, "codigo": "aceptada", "action_id": "start", "revision": 1, "revision_aplicada": 1}
		and b.submit("p1", intent) == receipt, "SEQ-01 acuse público de un solo commit")
	var after: Dictionary = a.get_authority_snapshot()
	var expected_rng: RandomNumberGenerator = _rng(initial)
	var expected_resource: int = _resource(initial) + 2 + expected_rng.randi_range(0, 9)
	_expect(after == b.get_authority_snapshot() and _resource(after) == expected_resource and after.authority.rng_state == expected_rng.state, "SEQ-01 orden y RNG exactos")
	_expect(after.resolution == null and after.turn == initial.turn and after.lifecycle == initial.lifecycle and after.revision == 1, "SEQ-01 cierre consume cursor y conserva turno")
	var id: String = Registry.ID_PREFIX + str(initial.authority.next_id)
	_expect(after.authority.completed_sequences == {id: _close("automatic_v1", initial.turn.number, 1)}
		and after.authority.next_id == initial.authority.next_id + 1 and after.authority.receipts.p1.size() == 1, "SEQ-01 cierre único con identidad asignada y revisión sellada")
	var unregistered: EngineCore = EngineCore.new(Fixtures.definitions(), "test_catalog")
	_expect(unregistered.load_authority_snapshot(initial).ok, "SEQ-01 motor sin registro acepta estado base")
	_reject(unregistered, "p1", intent, "accion_no_soportada", "SEQ-01 programas ausentes de producto")


func _test_resource_exchange() -> void:
	var initial: Dictionary = _prepared()
	initial.players[0].turn_resources.recursos = 2
	var engine: EngineCore = _engine(initial)
	var intent: Dictionary = _intent("exchange", "test_exchange", 0)
	var receipt: Dictionary = engine.submit("p1", intent)
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(receipt.ok and after.revision == initial.revision + 1 and after.resolution == null
		and after.players[0].turn_resources == {"recursos": 0, "ataque": 8, "mision": 0}
		and after.players[1] == initial.players[1] and after.authority.rng_state == initial.authority.rng_state,
		"Intercambio: confirma ambos saldos del actor en un solo segmento")
	_expect(engine.submit("p1", intent) == receipt and engine.get_authority_snapshot() == after,
		"Intercambio: reenvío conserva el recibo e ignora el cargo duplicado")

	var insufficient: Dictionary = initial.duplicate(true)
	insufficient.players[0].turn_resources.recursos = 1
	_reject(_engine(insufficient), "p1", intent, "accion_ilegal", "Intercambio: saldo insuficiente conserva todo el snapshot")
	var overflowing: Dictionary = initial.duplicate(true)
	overflowing.players[0].turn_resources.ataque = MAX_INT - 2
	_reject(_engine(overflowing), "p1", intent, "accion_ilegal", "Intercambio: desbordamiento conserva todo el snapshot")
	var maximum: Dictionary = initial.duplicate(true)
	maximum.players[0].turn_resources.ataque = MAX_INT - 3
	var boundary: EngineCore = _engine(maximum)
	_expect(boundary.submit("p1", intent).ok and boundary.get_authority_snapshot().players[0].turn_resources.ataque == MAX_INT,
		"Intercambio: el límite entero exacto es válido")

	var balances: Dictionary = {"a": 2, "b": 1}
	for args: Array in [["a", 0, "b", 3], ["a", 2, "b", -1], ["a", 2, "a", 1], ["a", 2, "missing", 3], ["missing", 2, "b", 3]]:
		_expect(not Sequences.Exchange.apply(balances, args[0], args[1], args[2], args[3])
			and balances == {"a": 2, "b": 1}, "Intercambio: entrada inválida conserva el diccionario")
	var malformed: Dictionary = {"a": 2, "b": "3"}
	_expect(not Sequences.Exchange.apply(malformed, "a", 2, "b", 3) and malformed == {"a": 2, "b": "3"},
		"Intercambio: saldo no entero se rechaza")
	var negative: Dictionary = {"a": 2, "b": -1}
	_expect(not Sequences.Exchange.apply(negative, "a", 2, "b", 3) and negative == {"a": 2, "b": -1},
		"Intercambio: saldo negativo se rechaza")


func _alternatives_state(recursos: int, mision: int) -> Dictionary:
	var state: Dictionary = _prepared()
	state.catalog_id = Sequences.ALTERNATIVES_PROFILE
	state.players[0].turn_resources = {"recursos": recursos, "ataque": 0, "mision": mision}
	return state


func _alternatives_engine(state: Dictionary) -> EngineCore:
	var engine: EngineCore = EngineCore.new(Fixtures.definitions(), Sequences.ALTERNATIVES_PROFILE,
		Handlers.registry(), Registry.new(Sequences.alternatives_registration()), Sequences.alternatives_starters())
	var loaded: Dictionary = engine.load_authority_snapshot(state)
	_expect(loaded.ok, "ALT-02 snapshot válido del perfil: %s" % [loaded.errors])
	return engine


func _test_alternatives() -> void:
	var start: Dictionary = _intent("start_branches", "test_alternatives", 0)
	var initial: Dictionary = _alternatives_state(4, 0)
	var overflow: EngineCore = _alternatives_engine(_alternatives_state(MAX_INT, 0))
	_reject(overflow, "p1", start, "accion_ilegal", "ALT-03 el desborde inicial conserva todo el snapshot")

	var live: EngineCore = _alternatives_engine(initial)
	_reject(live, "p2", start, "accion_ilegal", "ALT-01 solo el jugador activo abre la elección")
	if not live.submit("p1", start).ok:
		_expect(false, "ALT-03 se abre la elección")
		return
	var paused: Dictionary = live.get_authority_snapshot()
	var owner: Dictionary = live.get_view("p1")
	var other: Dictionary = live.get_view("p2")
	var resolution_id: String = paused.resolution.resolution_id
	_expect(paused.revision == 1 and paused.players[0].turn_resources == {"recursos": 5, "ataque": 0, "mision": 0}
		and paused.authority.rng_state == initial.authority.rng_state
		and paused.authority.completed_sequences == initial.authority.completed_sequences,
		"ALT-03 se confirma el incremento inicial y la ventana sin cierre ni RNG")
	_expect(owner.resolution == {"resolution_id": resolution_id, "recipients": ["p1"], "kind": "eleccion",
		"pending_recipients": ["p1"], "step_id": "choose", "options": ["rama_a", "rama_b"], "min": 1, "max": 1}
		and other.resolution == {"resolution_id": resolution_id, "recipients": ["p1"],
			"kind": "eleccion", "pending_recipients": ["p1"]}, "ALT-01 oferta fija y privada")

	var answer: Dictionary = _answer(owner, "choose_branch", ["rama_a"])
	_reject(live, "p2", answer, "eleccion_invalida", "ALT-03 otra plaza no puede elegir")
	_reject(live, "p9", answer, "identidad_no_autorizada", "ALT-02 identidad desconocida")
	_reject(live, "p1", _changed(answer, ["expected_revision"], 0), "revision_obsoleta", "ALT-02 revisión obsoleta")
	for options: Array in [["unknown"], [], ["rama_a", "rama_a"], ["rama_a", "rama_b"]]:
		_reject(live, "p1", _answer(owner, "invalid_branch", options), "eleccion_invalida",
			"ALT-03 opciones inválidas: %s" % [options])
	for key: String in ["resolution_id", "step_id"]:
		_reject(live, "p1", _changed(answer, ["payload", key], "unrelated"), "eleccion_invalida",
			"ALT-03 identidad ajena de %s" % key)

	var receiver: EngineCore = _alternatives_engine(initial)
	for options: Array in [["rama_b", "rama_a"], ["rama_a", "unknown"]]:
		_reject_load(receiver, _changed(paused, ["resolution", "pending", "options"], options),
			"ALT-03 carga rechazada por oferta alterada: %s" % [options])
	_reject_load(_engine(initial), paused, "ALT-02 la pausa exige el registro del programa versionado")
	_reject_load(receiver, _changed(paused, ["catalog_id"], "test_catalog"), "ALT-02 la pausa exige el perfil versionado")
	_reject_load(receiver, _changed(paused, ["version_motor"], "incompatible"), "ALT-02 la pausa exige la versión del motor")
	for branch: String in ["rama_a", "rama_b"]:
		var expected: Dictionary = {"recursos": 3, "ataque": 0, "mision": 4} if branch == "rama_a" \
			else {"recursos": 4, "ataque": 0, "mision": 1}
		_test_alternative_success(initial, paused, owner, branch, expected)
	_test_alternative_rollback(start)


func _test_alternative_success(initial: Dictionary, paused: Dictionary, owner: Dictionary, branch: String, expected: Dictionary) -> void:
	var live: EngineCore = _alternatives_engine(initial)
	_expect(live.submit("p1", _intent("start_branches", "test_alternatives", 0)).ok
		and live.get_authority_snapshot() == paused, "ALT-03 cada rama empieza desde la misma frontera")
	var restored: EngineCore = _alternatives_engine(bytes_to_var(var_to_bytes(paused)))
	_expect(restored.get_authority_snapshot() == paused and restored.get_view("p1") == owner
		and restored.get_view("p2") == live.get_view("p2"), "ALT-03 restauración exacta de la ventana")
	var answer: Dictionary = _answer(owner, "choose_branch", [branch])
	var receipt: Dictionary = live.submit("p1", answer)
	var after: Dictionary = live.get_authority_snapshot()
	_expect(receipt == {"ok": true, "codigo": "aceptada", "action_id": "choose_branch", "revision": 2, "revision_aplicada": 2}
		and after.players[0].turn_resources == expected and after.players[1] == paused.players[1]
		and after.resolution == null and after.revision == paused.revision + 1,
		"ALT-03 %s confirma exclusivamente su rama y cierra la ventana" % branch)
	var resolution_id: String = paused.resolution.resolution_id
	_expect(after.authority.rng_state == paused.authority.rng_state and after.authority.rng_seed == paused.authority.rng_seed
		and after.authority.next_id == paused.authority.next_id
		and after.authority.completed_sequences == {resolution_id: _close("alternatives_v1", paused.turn.number, 2)}
		and after.authority.receipts.keys() == paused.authority.receipts.keys()
		and after.authority.receipts.p1.size() == 2
		and after.authority.receipts.p1.get("start_branches") == paused.authority.receipts.p1.start_branches
		and after.authority.receipts.p1.get("choose_branch", {}).get("revision_aplicada") == 2,
		"ALT-03 se añade un cierre y un recibo sin consumir RNG")
	_expect(restored.submit("p1", answer) == receipt and restored.get_authority_snapshot() == after,
		"ALT-03 ejecutar %s tras restaurar produce el mismo estado y recibo" % branch)
	_expect(live.submit("p1", answer) == receipt and live.get_authority_snapshot() == after,
		"ALT-03 el reenvío recupera el recibo sin cambios")
	var other_branch: String = "rama_b" if branch == "rama_a" else "rama_a"
	var consumed: Dictionary = _answer(owner, "late_choice", [other_branch])
	consumed.expected_revision = after.revision
	_reject(live, "p1", consumed, "accion_ilegal", "ALT-03 la ventana consumida rechaza otra respuesta vigente")


func _test_alternative_rollback(start: Dictionary) -> void:
	var live: EngineCore = _alternatives_engine(_alternatives_state(4, MAX_INT - 3))
	if not live.submit("p1", start).ok:
		_expect(false, "ALT-03 se abre la ventana antes del desborde de misión")
		return
	var paused: Dictionary = live.get_authority_snapshot()
	var owner: Dictionary = live.get_view("p1")
	_expect(paused.players[0].turn_resources == {"recursos": 5, "ataque": 0, "mision": MAX_INT - 3},
		"ALT-03 el primer intercambio cabe en la frontera antes del desborde")
	_reject(live, "p1", _answer(owner, "retry_branch", ["rama_a"]), "accion_ilegal",
		"ALT-03 el segundo intercambio desborda y revierte la rama completa")
	var receipt: Dictionary = live.submit("p1", _answer(owner, "retry_branch", ["rama_b"]))
	var after: Dictionary = live.get_authority_snapshot()
	_expect(receipt.ok and after.revision == paused.revision + 1 and after.resolution == null
		and after.players[0].turn_resources == {"recursos": 4, "ataque": 0, "mision": MAX_INT - 2},
		"ALT-03 se puede confirmar la otra rama desde la misma ventana e ID de acción")


func _test_move_from_hand() -> void:
	var initial: Dictionary = _movement_state()
	var expected: Dictionary = initial.duplicate(true)
	expected.zones.p1_mano.cards = ["b"]
	expected.zones.p1_descarte.cards = ["d", "c", "a"]

	var cycle: Cycle = Cycle.new(Fixtures.definitions(), initial.catalog_id, _registry)
	var candidate: Dictionary = initial.duplicate(true)
	_expect(cycle.discard_from_hand(candidate, "p1", ["c", "a"]) and candidate == expected,
		"MOV-01 conserva las instancias y solo modifica las dos listas en el orden indicado")
	for input: Array in [["p1", []], ["p1", "a"], [7, ["a"]], ["p3", ["a"]], ["p1", ["a", 7]],
			["p1", ["a", ""]], ["p1", ["a", "a"]], ["p1", ["a", "missing"]],
			["p1", ["a", "c2"]], ["p1", ["a", "other"]], ["p1", ["a", "in_play"]]]:
		candidate = initial.duplicate(true)
		_expect(not cycle.discard_from_hand(candidate, input[0], input[1]) and candidate == initial,
			"MOV-02 conserva todo el candidato al rechazar %s" % [input])

	var engine: EngineCore = _engine(initial)
	var intent: Dictionary = _intent("move", "test_move", 0)
	_reject(engine, "p2", intent, "accion_ilegal", "MOV-02 solo la plaza activa inicia el programa")
	_reject(engine, "p1", _intent("injected", "test_move", 0, {"instance_ids": ["b"]}),
		"formato_invalido", "MOV-02 la intención no elige las cartas")
	var receipt: Dictionary = engine.submit("p1", intent)
	var after: Dictionary = engine.get_authority_snapshot()
	var id: String = Registry.ID_PREFIX + str(initial.authority.next_id)
	_expect(receipt.ok and after.revision == 1 and after.resolution == null
		and after.authority.receipts.p1.size() == 1
		and after.authority.completed_sequences == {id: _close("move_v1", initial.turn.number, 1)},
		"MOV-03 una revisión, un recibo y un cierre")
	_expect(after.zones == expected.zones and after.instances == initial.instances
		and after.authority.rng_state == initial.authority.rng_state, "MOV-03 traslado confirmado con RNG intacto")
	_expect(engine.submit("p1", intent) == receipt and engine.get_authority_snapshot() == after,
		"MOV-03 reenvío conserva estado y recibo")

	var owner_view: Dictionary = engine.get_view("p1")
	var observer_view: Dictionary = engine.get_view("p2")
	var alternative: EngineCore = _engine(_movement_state("alternate"))
	_expect(alternative.submit("p1", intent).ok and alternative.get_view("p2") == observer_view
		and not observer_view.zones.p1_mano.has("cards") and not observer_view.zones.p1_descarte.has("cards"),
		"MOV-03 la vista de otra plaza solo refleja las cantidades")
	_expect(owner_view.zones.p1_mano.cards.map(_instance_id) == ["b"]
		and owner_view.zones.p1_descarte.cards.map(_instance_id) == ["d", "c", "a"]
		and alternative.get_view("p1").zones.p1_descarte.cards.map(_instance_id) == ["d", "c", "alternate"],
		"MOV-03 el titular recibe los IDs de sus propias zonas en orden")

	var rollback: Dictionary = _intent("rollback", "test_move_rollback", 0)
	_reject(_engine(initial), "p1", rollback, "accion_ilegal", "MOV-03 revierte saldo y RNG tras un ID ausente")
	var with_foreign_target: Dictionary = initial.duplicate(true)
	with_foreign_target.instances["invalid_target"] = Fixtures.instance("invalid_target", "test_action", "p2")
	with_foreign_target.zones.p2_mano.cards.append("invalid_target")
	_reject(_engine(with_foreign_target), "p1", rollback, "accion_ilegal",
		"MOV-03 revierte todo con el mismo error público para un ID ajeno")


func _movement_state(first_card: String = "a") -> Dictionary:
	var state: Dictionary = _prepared()
	state.instances.erase("c1")
	for id: String in [first_card, "b", "c", "d", "in_play"]:
		state.instances[id] = Fixtures.instance(id, "test_action", "p1")
	state.instances[first_card].state.flags["marked"] = true
	state.instances["other"] = Fixtures.instance("other", "test_action", "p2")
	state.zones.p1_mano.cards = [first_card, "b", "c"]
	state.zones.p1_descarte.cards = ["d"]
	state.zones.p1_juego.cards = ["in_play"]
	state.zones.p2_mano.cards = ["other"]
	return state


func _instance_id(card: Dictionary) -> String:
	return card.instance_id


func _hand_selection_state(count: int = 2, prefix: String = "pick") -> Dictionary:
	var state: Dictionary = _prepared()
	state.zones.p1_mano.cards = []
	state.zones.p1_descarte.cards = ["c1"]
	for index: int in count:
		var id: String = "%s_%d" % [prefix, index + 1]
		state.instances[id] = Fixtures.instance(id, "test_action", "p1")
		state.instances[id].state.flags["marked"] = index == 1
		state.zones.p1_mano.cards.append(id)
	return state


func _test_private_hand_selection() -> void:
	var initial: Dictionary = _hand_selection_state()
	var live: EngineCore = _engine(initial)
	var start: Dictionary = _intent("pick", "test_hand_select", 0)
	_reject(live, "p2", start, "accion_ilegal", "SEL-01 solo el activo inicia")
	_reject(live, "p1", _intent("inject", "test_hand_select", 0, {"options": ["pick_2"]}),
		"formato_invalido", "SEL-01 la intención no fija la oferta")
	var standalone: EngineCore = EngineCore.new(Fixtures.definitions(), initial.catalog_id)
	_expect(standalone.load_authority_snapshot(initial).ok, "SEL-01 estado base sin registro ficticio")
	_reject(standalone, "p1", start, "accion_no_soportada", "SEL-01 programa exclusivo de pruebas")
	if not live.submit("p1", start).ok:
		_expect(false, "SEL-01 inicia la elección privada")
		return
	var paused: Dictionary = live.get_authority_snapshot()
	var owner_view: Dictionary = live.get_view("p1")
	var other_view: Dictionary = live.get_view("p2")
	var resolution_id: String = paused.resolution.resolution_id
	var options: Array = owner_view.resolution.options
	var card_ids: Array = owner_view.zones.p1_mano.cards.map(_instance_id)
	_expect(paused.revision == 1 and paused.zones == initial.zones and paused.instances == initial.instances
		and paused.authority.rng_state == initial.authority.rng_state
		and paused.resolution.context.hand_binding == "hand_" + JSON.stringify(card_ids).sha256_text(),
		"SEL-01 la pausa conserva la mano y fija su huella en la autoridad")
	_expect(owner_view.resolution == {"resolution_id": resolution_id, "recipients": ["p1"], "kind": "eleccion",
		"pending_recipients": ["p1"], "step_id": "choose", "options": ["o00001", "o00002"], "min": 1, "max": 1}
		and card_ids == ["pick_1", "pick_2"], "SEL-01 dos copias se distinguen por el orden de la vista")
	_expect(other_view.resolution == {"resolution_id": resolution_id, "recipients": ["p1"],
		"kind": "eleccion", "pending_recipients": ["p1"]}
		and not other_view.zones.p1_mano.has("cards") and not other_view.zones.p1_descarte.has("cards"),
		"SEL-01 la otra plaza solo recibe bloqueo y cantidades")
	var chosen_index: int = card_ids.find("pick_2")
	if chosen_index < 0 or options.size() != card_ids.size():
		return
	var response: Dictionary = _answer(owner_view, "selected", [options[chosen_index]])
	_reject(live, "p2", response, "eleccion_invalida", "SEL-02 otra plaza no elige")
	for invalid: Array in [["o00003"], ["pick_2"], [], ["o00001", "o00001"], ["o00001", "o00002"]]:
		_reject(live, "p1", _answer(owner_view, "invalid", invalid), "eleccion_invalida",
			"SEL-02 opciones rechazadas sin modificar la pausa: %s" % [invalid])
	for key: String in ["resolution_id", "step_id"]:
		_reject(live, "p1", _changed(response, ["payload", key], "unrelated"), "eleccion_invalida",
			"SEL-02 identidad ajena de %s" % key)
	_test_hand_selection_restore_rejections(live, paused)

	var alternate: EngineCore = _engine(_hand_selection_state(2, "hidden"))
	_expect(alternate.submit("p1", start).ok and alternate.get_view("p2") == other_view
		and alternate.get_view("p1").zones.p1_mano.cards.map(_instance_id) == ["hidden_1", "hidden_2"],
		"SEL-03 pausa pública indistinguible entre manos privadas")
	var restored: EngineCore = _engine(bytes_to_var(var_to_bytes(paused)), Registry.new(Sequences.registration()))
	_expect(restored.get_view("p1") == owner_view, "SEL-03 la elección se reconstruye desde el snapshot pausado")
	var receipt: Dictionary = live.submit("p1", response)
	var after: Dictionary = live.get_authority_snapshot()
	var expected_zones: Dictionary = initial.zones.duplicate(true)
	expected_zones.p1_mano.cards = ["pick_1"]
	expected_zones.p1_descarte.cards = ["c1", "pick_2"]
	_expect(receipt == {"ok": true, "codigo": "aceptada", "action_id": "selected", "revision": 2, "revision_aplicada": 2}
		and after.resolution == null and after.revision == 2 and after.zones == expected_zones
		and after.instances == initial.instances and after.players == initial.players and after.turn == initial.turn,
		"SEL-03 mueve solo la segunda copia al final del descarte y conserva cada instancia")
	_expect(after.authority.rng_state == paused.authority.rng_state and after.authority.next_id == paused.authority.next_id
		and after.authority.completed_sequences == {resolution_id: _close("hand_select_v1", initial.turn.number, 2)}
		and after.authority.receipts.p1.size() == 2 and after.authority.receipts.p1.pick == paused.authority.receipts.p1.pick,
		"SEL-02 una revisión, un recibo y un cierre, sin consumo de RNG")
	_expect(restored.submit("p1", response) == receipt and restored.get_authority_snapshot() == after,
		"SEL-03 elegir tras restaurar produce el mismo recibo y snapshot completo")
	_expect(live.submit("p1", response) == receipt and live.get_authority_snapshot() == after,
		"SEL-03 el reenvío conserva el recibo")
	var stale: Dictionary = _changed(response, ["action_id"], "stale")
	_reject(live, "p1", stale, "revision_obsoleta", "SEL-03 una nueva intención con revisión obsoleta falla")
	_reject(live, "p1", _changed(stale, ["expected_revision"], after.revision), "accion_ilegal",
		"SEL-03 una nueva intención con la revisión actual tampoco consume una ventana cerrada")
	_expect(alternate.submit("p1", response).ok and alternate.get_view("p2") == live.get_view("p2")
		and live.get_view("p1").zones.p1_descarte.cards.map(_instance_id) == ["c1", "pick_2"]
		and alternate.get_view("p1").zones.p1_descarte.cards.map(_instance_id) == ["c1", "hidden_2"],
		"SEL-03 el traslado mantiene la privacidad entre plazas")


func _test_hand_selection_restore_rejections(engine: EngineCore, paused: Dictionary) -> void:
	var reordered: Dictionary = _changed(paused, ["zones", "p1_mano", "cards"], ["pick_2", "pick_1"])
	var replaced: Dictionary = _changed(paused, ["zones", "p1_mano", "cards"], ["pick_1", "c2"])
	replaced.zones.p1_mazo.cards = ["pick_2"]
	var altered_offer: Dictionary = _changed(paused, ["resolution", "pending", "options"], ["o00002", "o00001"])
	for changed: Dictionary in [reordered, replaced, altered_offer]:
		_reject_load(engine, changed, "SEL-03 oferta y mano inconsistentes rechazan restauración")
		var unpaused: Dictionary = _changed(changed, ["resolution"], null)
		var validation: Dictionary = Validator.new().validate(unpaused, Fixtures.definitions(), unpaused.catalog_id, _registry)
		_expect(validation.ok, "SEL-03 la corrupción probada afecta a la ventana y no a las zonas por sí solas")


func _test_hand_selection_limits() -> void:
	var start: Dictionary = _intent("choose", "test_hand_select", 0)
	for count: int in [0, 17]:
		_reject(_engine(_hand_selection_state(count)), "p1", start, "accion_ilegal",
			"SEL-03 tamaño de mano rechazado sin cambios: %d" % count)
	for count: int in [1, 16]:
		var engine: EngineCore = _engine(_hand_selection_state(count))
		if not engine.submit("p1", start).ok:
			_expect(false, "SEL-03 se ofrece ventana para %d cartas" % count)
			continue
		var view: Dictionary = engine.get_view("p1")
		var options: Array = view.resolution.options
		_expect(options.size() == count and view.resolution.min == 1 and view.resolution.max == 1,
			"SEL-03 el límite de %d cartas exige una respuesta" % count)
		if options.is_empty():
			continue
		var response: Dictionary = _answer(view, "upper", [options.back()])
		_expect(engine.submit("p1", response).ok
			and engine.get_authority_snapshot().zones.p1_descarte.cards == ["c1", "pick_%d" % count],
			"SEL-03 se puede elegir la última opción ofertada")


func _test_hand_selection_with_history() -> void:
	var previous: EngineCore = _engine(_hand_selection_state())
	_expect(previous.submit("p1", _intent("prior", "test_auto", 0)).ok, "SEL-02 prepara un cierre anterior")
	var later: Dictionary = previous.get_authority_snapshot()
	later.turn.number += 1
	var prior_id: String = Registry.ID_PREFIX + str(later.authority.next_id - 1)
	var prior_close: Dictionary = later.authority.completed_sequences[prior_id]
	later.zones["private_hand"] = later.zones.p1_mano
	later.zones.private_hand.zone_id = "private_hand"
	later.zones.erase("p1_mano")
	later.zones["private_discard"] = later.zones.p1_descarte
	later.zones.private_discard.zone_id = "private_discard"
	later.zones.erase("p1_descarte")
	var engine: EngineCore = _engine(later)
	if not engine.submit("p1", _intent("new_pick", "test_hand_select", later.revision)).ok:
		_expect(false, "SEL-02 abre la elección con zonas identificadas por titular y tipo")
		return
	var view: Dictionary = engine.get_view("p1")
	_expect(engine.submit("p1", _answer(view, "new_answer", ["o00001"])).ok,
		"SEL-02 el ciclo acepta estados con cierres en su registro")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.authority.completed_sequences.size() == 2
		and after.authority.completed_sequences[prior_id] == prior_close
		and after.zones.private_hand.cards == ["pick_2"] and after.zones.private_discard.cards == ["c1", "pick_1"],
		"SEL-02 conserva el historial y mueve la carta en las zonas renombradas")


func _test_hand_selection_rollback() -> void:
	_selection_failure_trace.clear()
	var registration: Dictionary = Sequences.registration()
	registration.operations.fixture_fail.execute = _observe_selection_failure
	var initial: Dictionary = _hand_selection_state()
	var engine: EngineCore = _engine(initial, Registry.new(registration))
	if not engine.submit("p1", _intent("start", "test_hand_select_rollback", 0)).ok:
		_expect(false, "SEL-03 la variante de fallo confirma la pausa")
		return
	var paused: Dictionary = engine.get_authority_snapshot()
	_expect(paused.revision == 1 and _resource(paused) == _resource(initial) + 2 and paused.zones == initial.zones,
		"SEL-03 el efecto previo a la ventana queda confirmado")
	var expected_rng: RandomNumberGenerator = _rng(paused)
	expected_rng.randi()
	_reject(engine, "p1", _answer(engine.get_view("p1"), "rollback", ["o00002"]), "accion_ilegal",
		"SEL-03 el fallo tras la selección conserva íntegro el snapshot pausado")
	_expect(_selection_failure_trace == [["pick_1"], ["c1", "pick_2"], _resource(paused) + 1, expected_rng.state],
		"SEL-03 el paso fallido llegó a ver el traslado y consumió RNG dentro del candidato")


static func _observe_selection_failure(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	var result: bool = Sequences._fail(state, context, params, rng, selected)
	_selection_failure_trace.assign([state.zones.p1_mano.cards.duplicate(), state.zones.p1_descarte.cards.duplicate(),
		state.players[0].turn_resources.recursos, rng.state])
	return result


func _test_pause_and_resume() -> void:
	var initial: Dictionary = _prepared()
	var live: EngineCore = _engine(initial)
	_expect(live.submit("p1", _intent("start", "test_pause", 0)).ok, "SEQ-02 arranque confirma pausa")
	var pause: Dictionary = live.get_authority_snapshot()
	var expected_rng: RandomNumberGenerator = _rng(initial)
	_expect(_resource(pause) == _resource(initial) + 2 + expected_rng.randi_range(0, 9)
		and pause.authority.rng_state == expected_rng.state and pause.resolution.cursor == 2, "SEQ-02 pasos previos se aplican antes de pausar")
	_expect(pause.authority.completed_sequences.is_empty() and pause.revision == 1 and pause.authority.receipts.p1.size() == 1, "SEQ-02 pausa confirma recibo sin cierre")
	var restored: EngineCore = _engine(bytes_to_var(var_to_bytes(pause)), Registry.new(Sequences.registration()))
	var response: Dictionary = _answer(live.get_view("p1"))
	var receipt: Dictionary = live.submit("p1", response)
	_expect(receipt.ok and restored.submit("p1", response) == receipt, "SEQ-02 reanuda motor equivalente desde Variant int64")
	var after: Dictionary = live.get_authority_snapshot()
	var expected_after: int = _resource(pause) + 1 + expected_rng.randi_range(0, 9)
	_expect(after == restored.get_authority_snapshot() and after.resolution == null and _resource(after) == expected_after
		and after.authority.rng_state == expected_rng.state and after.authority.next_id == pause.authority.next_id,
		"SEQ-02 ejecuta pasos restantes sin repetir IDs ni azar")
	_expect(after.authority.completed_sequences[pause.resolution.resolution_id].revision_aplicada == 2, "SEQ-02 cierre sellado al responder")


func _test_successive_windows() -> void:
	var engine: EngineCore = _engine(_prepared())
	_expect(engine.submit("p1", _intent("start", "test_twice", 0)).ok, "SEQ-03 primera ventana")
	var first: Dictionary = engine.get_view("p1")
	var first_response: Dictionary = _answer(first, "first", ["decline"])
	_reject(engine, "p1", _intent("spend", "test_spend", 1, {"amount": 1}), "accion_ilegal", "SEQ-03 acción ordinaria intercalada")
	_expect(engine.submit("p1", first_response).ok, "SEQ-03 respuesta abre segunda ventana")
	var second: Dictionary = engine.get_view("p2")
	_expect(second.resolution.kind == "reaccion" and second.resolution.step_id != first.resolution.step_id
		and second.resolution.resolution_id == first.resolution.resolution_id and second.turn == first.turn,
		"SEQ-03 misma resolución con segundo paso, otro destinatario y turno intacto")
	_reject(engine, "p2", _intent("old_step", "responder", 2, first_response.payload), "eleccion_invalida", "SEQ-03 paso consumido con ID nuevo")
	var response: Dictionary = _answer(second, "second")
	_reject(engine, "p1", response, "eleccion_invalida", "SEQ-03 dueño del turno ajeno a reacción")
	_expect(engine.submit("p2", response).ok and engine.get_authority_snapshot().resolution == null
		and _resource(engine.get_authority_snapshot(), 1) == 5, "SEQ-03 reacción de plaza autorizada aplica su efecto")


func _test_segment_rollback() -> void:
	var initial: Dictionary = _prepared()
	var engine: EngineCore = _engine(initial)
	_reject(engine, "p1", _intent("start", "test_before_failure", 0), "accion_ilegal", "SEQ-04 fallo previo revierte snapshot completo")
	_expect(engine.submit("p1", _intent("start", "test_after_failure", 0)).ok, "SEQ-04 mismo ID rechazado sigue disponible")
	var pause: Dictionary = engine.get_authority_snapshot()
	_expect(pause.authority.rng_state != initial.authority.rng_state and pause.authority.next_id == initial.authority.next_id + 1
		and pause.authority.receipts.p1.has("start"), "SEQ-04 primer segmento confirmado con RNG/ID/recibo")
	var response: Dictionary = _answer(engine.get_view("p1"))
	_reject(engine, "p1", response, "accion_ilegal", "SEQ-04 fallo posterior revierte sólo segmento actual")
	_reject(engine, "p1", response, "accion_ilegal", "SEQ-04 se puede reintentar misma ventana")
	_expect(engine.get_authority_snapshot() == pause, "SEQ-04 efectos previos siguen confirmados")


func _test_replay() -> void:
	var engine: EngineCore = _engine(_prepared())
	var start: Dictionary = _intent("start", "test_pause", 0)
	var start_receipt: Dictionary = engine.submit("p1", start)
	var answer: Dictionary = _answer(engine.get_view("p1"))
	var answer_receipt: Dictionary = engine.submit("p1", answer)
	var closed: Dictionary = engine.get_authority_snapshot()
	var restored: EngineCore = _engine(closed)
	for authority: EngineCore in [engine, restored]:
		_expect(start_receipt.ok and answer_receipt.ok and authority.submit("p1", start) == start_receipt
			and authority.submit("p1", answer) == answer_receipt and authority.get_authority_snapshot() == closed,
			"SEQ-05 recibos originales sobreviven al cierre")
		var changed: Dictionary = answer.duplicate(true)
		changed.payload.options = ["decline"]
		_reject(authority, "p1", changed, "id_reutilizado", "SEQ-05 mismo ID, intención distinta")
		_reject(authority, "p1", _intent("old_window", "responder", 2, answer.payload), "accion_ilegal", "SEQ-05 ventana cerrada no se reaplica")
		_reject(authority, "p1", _intent("again", "test_pause", 2), "accion_ilegal", "SEQ-05 misma ocurrencia con intención nueva")
		_reject(authority, "p1", _intent("alternate", "test_auto", 2), "accion_ilegal", "SEQ-05 alternar programa no inventa ocurrencia")


func _test_incompatibility() -> void:
	var initial: Dictionary = _prepared()
	var engine: EngineCore = _engine(initial)
	_reject(engine, "p1", _intent("unknown", "test_unknown", 0), "estado_invalido", "SEQ-06 programa desconocido al iniciar")
	_reject(engine, "p1", _intent("injected", "test_pause", 0, {"program_id": "automatic_v1", "steps": []}), "formato_invalido",
		"SEQ-06 programa y pasos proceden de autoridad")
	var legacy: Dictionary = initial.duplicate(true)
	legacy.version_esquema = 1
	legacy.version_motor = "p08-atium-1/godot-4.7.2"
	legacy.authority.erase("completed_sequences")
	_reject_load(engine, legacy, "SEQ-06 esquema v1 sin resolución no se migra")
	_expect(engine.submit("p1", _intent("start", "test_pause", 0)).ok, "SEQ-06 control de pausa válida")
	var pause: Dictionary = engine.get_authority_snapshot()
	for change: Array in [
		[["version_motor"], "unknown"],
		[["resolution", "program_id"], "unknown_v1"],
		[["resolution", "steps", 3], "unknown_step"],
		[["resolution", "cursor"], 4],
		[["resolution", "cursor"], 1],
		[["resolution", "pending"], null],
		[["resolution", "pending", "options"], ["arbitrary"]]
	]:
		_reject_load(engine, _changed(pause, change[0], change[1]), "SEQ-06 carga incompatible: %s" % str(change[0]))
	for alteration: String in ["unknown_operation", "wrong_type", "invalid_value", "executable_parameter", "wrong_signature",
		"wrong_execute_type", "wrong_rng_type", "wrong_offer_type", "wrong_validator_type", "wrong_scope_type",
		"typed_selection", "wrong_bound_type", "mutable_binding", "wrong_execute_return", "wrong_validator_return",
		"wrong_offer_return", "wrong_scope_return", "missing_context_schema"]:
		var registration: Dictionary = Sequences.registration()
		var program: Dictionary = registration.programs.pause_v1
		# La operación incompatible sólo se usaría después de la primera pausa.
		registration.operations["fixture_bad"] = registration.operations.fixture_roll.duplicate()
		program.steps[3].operation = "fixture_bad"
		match alteration:
			"unknown_operation":
				program.steps[3].operation = "unknown_operation"
			"wrong_type":
				program.steps[3] = Sequences.step("s4", "fixture_add", {"amount": true})
			"invalid_value":
				program.steps[3] = Sequences.step("s4", "fixture_add", {"amount": -1})
			"executable_parameter":
				program.steps[3] = Sequences.step("s4", "fixture_add", {"amount": _expect})
			"wrong_signature":
				registration.operations.fixture_bad.execute = _expect
			"wrong_execute_type":
				registration.operations.fixture_bad.execute = _wrong_execute_type
			"wrong_rng_type":
				registration.operations.fixture_bad.execute = _wrong_rng_type
			"wrong_offer_type":
				registration.operations.fixture_wait.offer = _wrong_offer_type
			"wrong_validator_type":
				registration.operations.fixture_bad.validate_params = _wrong_validator_type
			"wrong_scope_type":
				program.scope = _wrong_scope_type
			"typed_selection":
				registration.operations.fixture_bad.execute = _typed_selection
			"wrong_bound_type":
				registration.operations.fixture_wait.offer = _offer_options.bind("wrong")
			"mutable_binding":
				registration.operations.fixture_wait.offer = _offer_options.bind([])
			"wrong_execute_return":
				registration.operations.fixture_bad.execute = _wrong_execute_return
			"wrong_validator_return":
				registration.operations.fixture_bad.validate_params = _wrong_validator_return
			"wrong_offer_return":
				registration.operations.fixture_wait.offer = _wrong_offer_return
			"wrong_scope_return":
				program.scope = _wrong_scope_return
			"missing_context_schema":
				program.context.erase("owner_id")
		var invalid: EngineCore = EngineCore.new(Fixtures.definitions(), "test_catalog", {}, Registry.new(registration), Sequences.starters())
		_reject_load(invalid, initial, "SEQ-06 registro incompatible antes de iniciar: " + alteration)
		_reject(invalid, "p1", _intent("start", "test_pause", 0), "estado_invalido", "SEQ-06 nunca ejecuta prefijo inválido")
	var mutable: Dictionary = Sequences.registration()
	var frozen: Registry = Registry.new(mutable)
	var original: EngineCore = _engine(initial, frozen)
	mutable.programs.pause_v1.steps[3].operation = "unknown_operation"
	mutable.operations.clear()
	var copied_step: Dictionary = frozen.get_step("pause_v1", 3)
	copied_step.operation = "unknown_operation"
	_expect(original.submit("p1", _intent("start", "test_pause", 0)).ok and original.get_authority_snapshot() == pause
		and original.submit("p1", _answer(original.get_view("p1"))).ok, "SEQ-06 registro congelado y descriptores por copia")


func _test_response_validation() -> void:
	var engine: EngineCore = _engine(_prepared())
	_expect(engine.submit("p1", _intent("start", "test_pause", 0)).ok, "SEQ-07 pausa válida")
	var answer: Dictionary = _answer(engine.get_view("p1"))
	_reject(engine, "p2", answer, "eleccion_invalida", "SEQ-07 actor equivocado")
	_reject(engine, "p9", answer, "identidad_no_autorizada", "SEQ-07 actor desconocido")
	_reject(engine, "p1", _changed(answer, ["expected_revision"], 0), "revision_obsoleta", "SEQ-07 revisión obsoleta")
	_reject(engine, "p1", _changed(answer, ["actor_id"], "p2"), "formato_invalido", "SEQ-07 identidad separada")
	for change: Array in [
		[["resolution_id"], "wrong"], [["resolution_id"], 42],
		[["step_id"], "wrong"], [["step_id"], null],
		[["options"], "accept"], [["options"], []], [["options"], [true]], [["options"], ["stranger"]],
		[["options"], ["accept", "accept"]], [["options"], ["accept", "decline"]],
		[["options"], ["accept", "decline", "stranger"]], [["extra"], false]
	]:
		var altered: Dictionary = answer.duplicate(true)
		altered.payload = _changed(answer.payload, change[0], change[1])
		_reject(engine, "p1", altered, "eleccion_invalida", "SEQ-07 respuesta malformada: %s" % str(change))
	_expect(engine.submit("p1", answer).ok, "SEQ-07 rechazos no consumen opción ni ID")
	var optional: EngineCore = _engine(_prepared())
	_expect(optional.submit("p1", _intent("optional", "test_optional", 0)).ok, "SEQ-07 ventana con min=0")
	var view: Dictionary = optional.get_view("p1")
	_expect(view.resolution.min == 0 and optional.submit("p1", _answer(view, "empty", [])).ok
		and optional.get_authority_snapshot().resolution == null and _resource(optional.get_authority_snapshot()) == 4,
		"SEQ-07 selección vacía declina sólo con min=0")


func _test_privacy() -> void:
	var initial: Dictionary = _prepared("competitivo", 3)
	initial.instances["c3"] = Fixtures.instance("c3", "test_action", "p1")
	initial.zones.p1_mazo.cards.append("c3")
	var alternate: Dictionary = initial.duplicate(true)
	alternate.zones.p1_mazo.cards.reverse()
	alternate.authority.rng_state = -9007199254740997
	var a: EngineCore = _engine(initial)
	var b: EngineCore = _engine(alternate)
	_expect(a.submit("p1", _intent("start", "test_twice", 0)).ok and b.submit("p1", _intent("start", "test_private_alt", 0)).ok,
		"SEQ-08 programas distintos con la misma ventana pública")
	var a_pause: Dictionary = a.get_authority_snapshot()
	var b_pause: Dictionary = b.get_authority_snapshot()
	_expect(a_pause.resolution.context != b_pause.resolution.context and a_pause.resolution.program_id != b_pause.resolution.program_id
		and a_pause.zones.p1_mazo.cards != b_pause.zones.p1_mazo.cards, "SEQ-08 snapshots con datos privados distintos")
	var visible: Dictionary = a.get_view("p2")
	_expect(visible == b.get_view("p2") and a.get_view("p3") == b.get_view("p3"),
		"SEQ-08 vistas ajenas iguales con contexto, programa, mazo y RNG distintos")
	_expect(visible.resolution == {"resolution_id": a_pause.resolution.resolution_id, "recipients": ["p1", "p2", "p3"],
		"kind": "eleccion", "pending_recipients": ["p1"]} and not visible.has("authority"), "SEQ-08 lista permitida exacta de observador")
	var recipient: Dictionary = a.get_view("p1")
	_expect(recipient.resolution.size() == 8 and recipient.resolution.step_id == "s1" and recipient.resolution.options == ["accept", "decline"]
		and recipient.resolution.min == 1 and recipient.resolution.max == 1, "SEQ-08 destinatario recibe paso, opciones y límites")
	_expect(not JSON.stringify(recipient).contains("fixture_wait") and not JSON.stringify(recipient).contains(a_pause.resolution.context.occurrence_id),
		"SEQ-08 vista del destinatario oculta operación y ocurrencia")
	var attempt: Dictionary = _answer(recipient)
	var error_a: Dictionary = a.submit("p2", attempt)
	var error_b: Dictionary = b.submit("p2", attempt)
	_expect(error_a == error_b and error_a == {"ok": false, "codigo": "eleccion_invalida", "revision": 1},
		"SEQ-08 errores de actores ajenos sin detalles privados")
	_expect(a.submit("p1", attempt) == {"ok": true, "codigo": "aceptada", "action_id": "answer", "revision": 2, "revision_aplicada": 2},
		"SEQ-08 destinatario responde sólo con su vista y recibe acuse sin detalles")


func _test_authority() -> void:
	var initial: Dictionary = _prepared()
	var engine: EngineCore = _engine(initial)
	_expect(engine.submit("p1", _intent("start", "test_pause", 0)).ok, "SEQ-09 pausa válida para corromper")
	var pause: Dictionary = engine.get_authority_snapshot()
	var id: String = pause.resolution.resolution_id
	for change: Array in [
		[["resolution", "context", "owner_id"], "p2"],
		[["resolution", "context", "recipient_id"], "p9"],
		[["resolution", "context", "recipient_id"], "p2"],
		[["resolution", "context", "entry_phase"], "combate"],
		[["resolution", "context", "turn_number"], 2],
		[["resolution", "context", "occurrence_id"], "forged"],
		[["resolution", "context", "extra"], 0],
		[["resolution", "source_id"], "missing"],
		[["resolution", "recipients"], ["p1", "p1"]],
		[["resolution", "pending", "recipients"], ["p1", "p2"]],
		[["resolution", "pending", "recipients"], ["p2"]],
		[["lifecycle"], "finalizada"],
		[["players", 0, "eliminated"], true],
		[["players", 0, "health"], 0],
		[["authority", "next_id"], initial.authority.next_id],
		[["authority", "completed_sequences"], {id: _close("pause_v1", 3, 1)}],
		[["authority", "completed_sequences"], {"resolution_1": _close("pause_v1", 3, 1)}]
	]:
		_reject_load(engine, _changed(pause, change[0], change[1]), "SEQ-09 corrupción activa: %s" % str(change[0]))
	var switched: Dictionary = Sequences.registration()
	switched.programs.pause_v1.steps[2].params.kind = "reaccion"
	var substitute: EngineCore = _engine(initial, Registry.new(switched))
	_reject_load(substitute, pause, "SEQ-09 registro sustituto con ventana incompatible")
	var no_registry: EngineCore = EngineCore.new(Fixtures.definitions(), initial.catalog_id)
	_reject_load(no_registry, pause, "SEQ-09 programa ausente del registro")
	_expect(engine.submit("p1", _answer(engine.get_view("p1"))).ok, "SEQ-09 respuesta válida tras cargas rechazadas")
	var closed: Dictionary = engine.get_authority_snapshot()
	for change: Array in [
		[["revision_aplicada"], 3], [["revision_aplicada"], 0], [["turn_number"], 4], [["turn_number"], 0],
		[["owner_id"], "p9"], [["program_id"], "unknown_v1"], [["occurrence_id"], null]
	]:
		var corrupted: Dictionary = closed.duplicate(true)
		corrupted.authority.completed_sequences[id] = _changed(corrupted.authority.completed_sequences[id], change[0], change[1])
		_reject_load(engine, corrupted, "SEQ-09 cierre corrupto: %s" % str(change[0]))
	var duplicate: Dictionary = closed.duplicate(true)
	duplicate.authority.completed_sequences["resolution_1"] = duplicate.authority.completed_sequences[id].duplicate()
	_reject_load(engine, duplicate, "SEQ-09 ocurrencia completada duplicada")
	var exported: Dictionary = engine.get_authority_snapshot()
	exported.authority.completed_sequences[id].owner_id = "p2"
	exported.authority.receipts.p1.clear()
	_expect(engine.get_authority_snapshot() == closed, "SEQ-09 exportación privada es copia profunda")
	_test_protected_transitions(closed)


func _test_protected_transitions(closed: Dictionary) -> void:
	var handlers: Dictionary = Handlers.registry()
	for frozen: String in ["root", "authority", "receipts", "player_receipts", "ledger"]:
		handlers["freeze_" + frozen] = _freeze_commit.bind(frozen)
	for attack: String in ["erase", "rewrite", "forge", "typed"]:
		handlers["test_" + attack] = _alter_ledger.bind(attack)
	handlers["test_forge_pause"] = _forge_pause
	handlers["test_cycle"] = _discard_with_registry
	var engine: EngineCore = _engine(closed, _registry, handlers)
	for frozen: String in ["root", "authority", "receipts", "player_receipts", "ledger"]:
		_reject(engine, "p1", _intent("freeze_" + frozen, "freeze_" + frozen, closed.revision), "estado_invalido",
			"SEQ-09 contenedor de commit congelado: " + frozen)
	for attack: String in ["erase", "rewrite", "forge"]:
		var candidate: Dictionary = closed.duplicate(true)
		_alter_ledger(candidate, "p1", {}, _rng(candidate), attack)
		_expect(Validator.new().validate(candidate, Fixtures.definitions(), "test_catalog", _registry).ok,
			"SEQ-09 mutación %s es estructuralmente válida" % attack)
		_reject(engine, "p1", _intent(attack, "test_" + attack, closed.revision), "estado_invalido", "SEQ-09 P07 protege ledger ante " + attack)
	var pause_candidate: Dictionary = _prepared()
	pause_candidate.resolution = Sequences.reaction(pause_candidate)
	var pristine: EngineCore = _engine(_prepared(), _registry, handlers)
	_expect(Validator.new().validate(pause_candidate, Fixtures.definitions(), "test_catalog", _registry).ok,
		"SEQ-09 pausa forjada por manejador también es válida por forma")
	_reject(pristine, "p1", _intent("forge_pause", "test_forge_pause", 0), "estado_invalido", "SEQ-09 sólo el resolver introduce pausa")
	_reject(pristine, "p1", _intent("typed", "test_typed", 0), "estado_invalido", "SEQ-09 manejador no cambia tipo de ledger")
	var cycle: Dictionary = engine.submit("p1", _intent("cycle", "test_cycle", closed.revision))
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(cycle.ok and after.zones.p1_descarte.cards == ["c1"] and after.authority.completed_sequences == closed.authority.completed_sequences,
		"SEQ-09 acción de ciclo posterior conserva cierres")
	var cleanup: Cleanup = Cleanup.new(Fixtures.definitions(), "test_catalog", _registry)
	_expect(cleanup.finish_cleanup(after, "p1", _rng(after)).codigo == "accion_ilegal", "SEQ-09 cierre ficticio no habilita entrada a limpieza")
	# Sólo el fixture prepara una fase de limpieza preexistente con cartas suficientes.
	after.turn.phase = "limpieza"
	for card: String in ["c3", "c4", "c5", "c6"]:
		after.instances[card] = Fixtures.instance(card, "test_action", "p1")
		after.zones.p1_mazo.cards.append(card)
	_expect(cleanup.finish_cleanup(after, "p1", _rng(after)).ok and after.turn.phase == "inicio"
		and after.authority.completed_sequences == closed.authority.completed_sequences, "SEQ-09 limpieza preexistente acepta registro y conserva ledger")
	var starters: Dictionary = Sequences.starters()
	starters["test_isolated_start"] = _isolated_start
	var isolated: EngineCore = _engine(_prepared(), _registry, {}, starters)
	var control: EngineCore = _engine(_prepared())
	_expect(isolated.submit("p1", _intent("start", "test_isolated_start", 0)).ok and control.submit("p1", _intent("start", "test_auto", 0)).ok,
		"SEQ-09 adaptador de inicio con copia aislada")
	var isolated_result: Dictionary = isolated.get_authority_snapshot()
	var control_result: Dictionary = control.get_authority_snapshot()
	isolated_result.authority.receipts.clear()
	control_result.authority.receipts.clear()
	_expect(isolated_result == control_result, "SEQ-09 mutaciones del adaptador no afectan fase, RNG, IDs, recursos ni ledger")


func _alter_ledger(state: Dictionary, _actor: String, _payload: Dictionary, rng: RandomNumberGenerator, attack: String) -> String:
	var ledger: Dictionary = state.authority.completed_sequences
	match attack:
		"erase":
			ledger.clear()
		"rewrite":
			ledger.values()[0].revision_aplicada = 1
		"forge":
			var id: String = Registry.ID_PREFIX + str(state.authority.next_id)
			state.authority.next_id += 1
			ledger[id] = _close("pause_v1", 2, 1)
		"typed":
			var typed: Dictionary[String, String] = {}
			state.authority.completed_sequences = typed
	state.players[0].turn_resources.recursos += 1
	rng.randi()
	return ""


func _forge_pause(state: Dictionary, _actor: String, _payload: Dictionary, rng: RandomNumberGenerator) -> String:
	state.resolution = Sequences.reaction(state)
	rng.randi()
	return ""


func _discard_with_registry(state: Dictionary, actor: String, _payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	var cycle: Cycle = Cycle.new(Fixtures.definitions(), "test_catalog", _registry)
	return "" if cycle.discard(state, actor, ["c1"]).ok else "accion_ilegal"


func _isolated_start(state: Dictionary, actor: String, payload: Dictionary) -> Variant:
	var request: Variant = Sequences.start(state, actor, payload, "automatic_v1", 0)
	state.players[0].turn_resources.recursos = 999
	state.authority.rng_state = 0
	state.authority.next_id += 10
	state.turn.phase = "limpieza"
	state.authority.completed_sequences["resolution_1"] = _close("pause_v1", 2, 1)
	return request


func _test_limits_and_modes() -> void:
	for mode: String in ["competitivo", "cooperativo", "solitario"]:
		var sizes: Array = [1] if mode == "solitario" else [2, 3, 4]
		for count: int in sizes:
			var initial: Dictionary = _prepared(mode, count)
			var engine: EngineCore = _engine(initial)
			var description: String = "%s/%d" % [mode, count]
			_expect(engine.submit("p1", _intent("start", "test_pause", 0)).ok, "SEQ-10 pausa %s" % description)
			var pause: Dictionary = engine.get_authority_snapshot()
			var rebuilt: EngineCore = _engine(pause, Registry.new(Sequences.registration()))
			var response: Dictionary = _answer(rebuilt.get_view("p1"))
			_expect(rebuilt.submit("p1", response).ok and engine.submit("p1", response).ok
				and engine.get_authority_snapshot() == rebuilt.get_authority_snapshot(), "SEQ-10 reanuda %s" % description)
			var closed: Dictionary = rebuilt.get_authority_snapshot()
			_expect(closed.turn == initial.turn and closed.players.size() == count and closed.rival == initial.rival,
				"SEQ-10 secuencia preserva configuración %s" % description)
			var react: EngineCore = _engine(initial)
			var react_intent: Dictionary = _intent("react", "test_reaction", 0)
			if count == 1:
				_reject(react, "p1", react_intent, "accion_ilegal", "SEQ-10 solo no inventa otra plaza")
			else:
				_expect(react.submit("p1", react_intent).ok and react.submit("p2", _answer(react.get_view("p2"))).ok,
					"SEQ-10 reacción ajena en %s" % description)
	_test_step_and_option_limits()
	_test_numeric_and_storage_limits()


func _test_step_and_option_limits() -> void:
	var initial: Dictionary = _prepared()
	var registration: Dictionary = Sequences.registration()
	var steps: Array = []
	for index: int in Registry.MAX_STEPS:
		steps.append(Sequences.step("step_%d" % index, "fixture_add", {"amount": 1}))
	registration.programs.automatic_v1 = Sequences.program(steps)
	var sixty_four: EngineCore = _engine(initial, Registry.new(registration))
	_expect(sixty_four.submit("p1", _intent("start", "test_auto", 0)).ok
		and _resource(sixty_four.get_authority_snapshot()) == _resource(initial) + Registry.MAX_STEPS, "SEQ-10 64 pasos completos")
	steps.append(Sequences.step("too_many", "fixture_add", {"amount": 1}))
	var too_many: EngineCore = EngineCore.new(Fixtures.definitions(), "test_catalog", {}, Registry.new(registration))
	_reject_load(too_many, initial, "SEQ-10 65 pasos se rechazan íntegros")
	for count: int in [Registry.MAX_OPTIONS, Registry.MAX_OPTIONS + 1]:
		var offers: Dictionary = Sequences.registration()
		offers.operations.fixture_wait.offer = _offer_options.bind(count)
		var engine: EngineCore = _engine(initial, Registry.new(offers))
		var start: Dictionary = _intent("start", "test_pause", 0)
		if count == Registry.MAX_OPTIONS:
			_expect(engine.submit("p1", start).ok and engine.get_view("p1").resolution.options.size() == count
				and engine.submit("p1", _answer(engine.get_view("p1"), "answer", ["option_15"])).ok, "SEQ-10 16 opciones completas")
		else:
			_reject(engine, "p1", start, "estado_invalido", "SEQ-10 17 opciones revierten pasos previos y RNG")


static func _offer_options(_state: Dictionary, context: Dictionary, params: Dictionary, count: int) -> Dictionary:
	var options: Array = []
	for index: int in count:
		options.append("option_%d" % index)
	return {"kind": params.kind, "recipients": [context.owner_id], "options": options, "min": 1, "max": 1}


func _test_numeric_and_storage_limits() -> void:
	var initial: Dictionary = _prepared()
	for limit: Array in [
		[["authority", "next_id"], MAX_INT, "estado_invalido"],
		[["revision"], MAX_INT, "estado_invalido"],
		[["players", 0, "turn_resources", "recursos"], MAX_INT, "accion_ilegal"]
	]:
		var bounded: Dictionary = _changed(initial, limit[0], limit[1])
		var engine: EngineCore = _engine(bounded)
		_reject(engine, "p1", _intent("limit", "test_auto", bounded.revision), limit[2], "SEQ-10 desbordamiento: %s" % str(limit[0]))
	var typed: Dictionary[String, String] = {}
	var authority: EngineCore = _engine(initial)
	for path: Array in [["authority", "completed_sequences"], ["authority", "receipts"], ["authority", "receipts", "p1"]]:
		_reject_load(authority, _changed(initial, path, typed), "SEQ-10 diccionario tipado incompatible: %s" % str(path))
	for path: Array in [[], ["authority"], ["authority", "completed_sequences"], ["authority", "receipts"], ["authority", "receipts", "p1"]]:
		var frozen: Dictionary = initial.duplicate(true)
		frozen.authority.receipts["p1"] = {}
		var container: Dictionary = frozen
		for key: String in path:
			container = container[key]
		container.make_read_only()
		_reject_load(authority, frozen, "SEQ-10 contenedor de commit no mutable: %s" % str(path))
	var full: Dictionary = initial.duplicate(true)
	full.turn.number = 10000
	full.revision = 10000
	var remaining_nodes: int = Validator.MAX_NODES - _nodes(full)
	@warning_ignore("integer_division")
	var count: int = (remaining_nodes - 1) / _nodes(_close("automatic_v1", 1, 1))
	for number: int in range(1, count + 1):
		full.authority.completed_sequences[Registry.ID_PREFIX + str(number)] = _close("automatic_v1", number, number)
	full.authority.next_id = count + 1
	var at_capacity: EngineCore = _engine(full)
	_reject(at_capacity, "p1", _intent("limit_ledger", "test_auto", full.revision), "estado_invalido",
		"SEQ-10 límite global de estado con ledger conserva las entradas")


func _nodes(value: Variant) -> int:
	var total: int = 1
	if value is Dictionary:
		for item: Variant in value.values():
			total += _nodes(item)
	elif value is Array:
		for item: Variant in value:
			total += _nodes(item)
	return total


func _close(program: String, turn_number: int, revision: int) -> Dictionary:
	return {"program_id": program, "occurrence_id": Sequences.occurrence("test_match", turn_number, "p1"),
		"owner_id": "p1", "turn_number": turn_number, "revision_aplicada": revision}


func _changed(base: Dictionary, path: Array, value: Variant) -> Dictionary:
	var changed: Dictionary = base.duplicate(true)
	var parent: Variant = changed
	for index: int in path.size() - 1:
		parent = parent[path[index]]
	parent[path.back()] = value
	return changed


func _reject(engine: EngineCore, actor: String, intent: Dictionary, code: String, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, intent)
	var revision: int = before.get("revision", 0)
	_expect(result == {"ok": false, "codigo": code, "revision": revision} and engine.get_authority_snapshot() == before, label)


func _reject_load(engine: EngineCore, document: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var provided: Dictionary = document.duplicate(true)
	var result: Dictionary = engine.load_authority_snapshot(document)
	_expect(not result.ok and not result.errors.is_empty() and engine.get_authority_snapshot() == before and document == provided, label)


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


func _freeze_commit(state: Dictionary, _actor: String, _payload: Dictionary, rng: RandomNumberGenerator, target: String) -> String:
	rng.randi()
	var container: Dictionary = state
	match target:
		"authority": container = state.authority
		"receipts": container = state.authority.receipts
		"player_receipts": container = state.authority.receipts.p1
		"ledger": container = state.authority.completed_sequences
	container.make_read_only()
	return ""


static func _wrong_execute_type(_state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, _selection: Vector2) -> bool:
	return true


static func _wrong_rng_type(_state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: Node, _selection: Array) -> bool:
	return true


static func _typed_selection(_state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, _selection: Array[String]) -> bool:
	return true


static func _wrong_offer_type(_state: Dictionary, _context: Dictionary, _params: int) -> Dictionary:
	return {}


static func _wrong_validator_type(_params: String) -> bool:
	return true


static func _wrong_scope_type(_state: Dictionary, _context: String) -> Array:
	return []


static func _wrong_execute_return(_state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, _selection: Array) -> int:
	return 1


static func _wrong_validator_return(_params: Dictionary) -> void:
	pass


static func _wrong_offer_return(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Array:
	return []


static func _wrong_scope_return(_state: Dictionary, _context: Dictionary) -> Dictionary:
	return {}
