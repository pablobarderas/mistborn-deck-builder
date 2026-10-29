extends SceneTree
## CAS-REG-009/010/025, SPEC-008 AC-07–10. Contenido técnico ficticio.

const Cycle = preload("res://scripts/game/card_cycle.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const GameCore = preload("res://scripts/game/game_engine.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for mode: String in ["competitivo", "cooperativo", "solitario"]:
		var counts: Array = [1] if mode == "solitario" else [2, 3, 4]
		for count: int in counts:
			_test_cycle(mode, count)
	_test_rejections()
	_test_order()
	_test_engine()
	if failures == 0:
		print("P08_CYCLE_OK: %d comprobaciones." % checks)
	else:
		push_error("P08 ciclo: %d fallos en %d comprobaciones." % [failures, checks])
	quit(0 if failures == 0 else 1)


func _definitions() -> Dictionary:
	var definitions: Dictionary = Fixtures.definitions()
	definitions["test_ally"] = {"id": "test_ally", "tipo": "aliado", "efecto": "NO EJECUTAR"}
	return definitions


func _snapshot(mode: String = "competitivo", count: int = 2) -> Dictionary:
	var state: Dictionary = Fixtures.snapshot(mode, count)
	# No depender de IDs derivados de plaza ni de claves canónicas.
	for kind: String in Validator.PLAYER_ZONES:
		var old_id: String = "p1_" + kind
		var new_id: String = "custom_" + kind
		state.zones[new_id] = state.zones[old_id]
		state.zones[new_id].zone_id = new_id
		state.zones.erase(old_id)
	for id: String in ["d1", "d2", "d3", "played", "ally", "held_ally"]:
		var definition: String = "test_ally" if id in ["ally", "held_ally"] else "test_action"
		state.instances[id] = Fixtures.instance(id, definition, "p1")
	state.zones.custom_descarte.cards = ["d1", "d2", "d3"]
	state.zones.custom_juego.cards = ["played", "ally"]
	state.zones.custom_mano.cards.append("held_ally")
	state.instances["market_card"] = Fixtures.instance("market_card", "test_action", null)
	state.zones.mercado.cards.append("market_card")
	if count > 1:
		state.instances["other_card"] = Fixtures.instance("other_card", "test_action", "p2")
		state.zones.p2_mano.cards.append("other_card")
	return state


func _rng(state: Dictionary) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = state.authority.rng_seed
	rng.state = state.authority.rng_state
	return rng


func _test_cycle(mode: String, count: int) -> void:
	var cycle: RefCounted = Cycle.new(_definitions(), "test_catalog")
	var state: Dictionary = _snapshot(mode, count)
	var original: Dictionary = state.duplicate(true)
	var rng: RandomNumberGenerator = _rng(state)
	var initial_rng: int = rng.state
	_expect(Validator.new().validate(state, _definitions(), "test_catalog").ok, "Fixture siete configuraciones válido")
	_expect(cycle.draw(state, "p1", 0, rng).ok and state == original and rng.state == initial_rng, "AC07 N=0 vacío")
	_expect(cycle.draw(state, "p1", 1, rng).ok, "AC07 roba última carta")
	_expect(state.zones.custom_mano.cards == ["c1", "held_ally", "c2"], "AC07 superior al extremo final, orden e identidad")
	_expect(state.zones.custom_mazo.cards.is_empty() and state.zones.custom_descarte.cards == ["d1", "d2", "d3"] and rng.state == initial_rng, "AC07 última carta no recicla ni consume RNG")
	var at_recycle: Dictionary = state.duplicate(true)
	var expected_rng: RandomNumberGenerator = _rng(original)
	var shuffled: Array = ["d1", "d2", "d3"]
	for index: int in range(2, 0, -1):
		var other: int = expected_rng.randi_range(0, index)
		var saved: String = shuffled[index]
		shuffled[index] = shuffled[other]
		shuffled[other] = saved
	var expected_top: String = shuffled.back()
	_expect(cycle.draw(state, "p1", 1, rng).ok, "AC07 recicla al necesitar otra carta")
	shuffled.pop_back()
	_expect(state.zones.custom_mano.cards.back() == expected_top and state.zones.custom_mazo.cards == shuffled and state.zones.custom_descarte.cards.is_empty(), "AC07 reciclado Fisher-Yates reproducible")
	_expect(rng.state == expected_rng.state and rng.state != initial_rng, "AC10 RNG local consumido exactamente por reciclado")
	var replay_rng: RandomNumberGenerator = _rng(original)
	_expect(cycle.draw(at_recycle, "p1", 1, replay_rng).ok and at_recycle == state and replay_rng.state == rng.state, "AC10 snapshot y RNG deterministas")
	_expect(cycle.draw(state, "p1", 2, rng).ok and state.zones.custom_mazo.cards.is_empty(), "AC09 robo exacto de todas las disponibles")
	var before_failure: Dictionary = state.duplicate(true)
	var before_rng: int = rng.state
	var failed: Dictionary = cycle.draw(state, "p1", 1, rng)
	_expect(not failed.ok and failed.codigo == "regla_pendiente" and state == before_failure and rng.state == before_rng, "AC09 agotamiento bloquea sin inventar resultado")
	_expect(cycle.cleanup_cards(state, "p1").ok, "AC08 limpieza solo cartas")
	_expect(state.zones.custom_mano.cards.is_empty() and state.zones.custom_juego.cards == ["ally"], "AC08 aliado en juego permanece; aliado en mano se descarta")
	_expect(state.zones.custom_descarte.cards.size() == 7 and "held_ally" in state.zones.custom_descarte.cards, "AC08 conserva cantidad al limpiar")
	_expect(state.players == original.players and state.instances == original.instances and state.turn == original.turn and state.resolution == original.resolution and state.authority == original.authority, "AC08 sin recursos/metales/habilidades/fases ni efectos")
	for id: String in original.zones:
		if original.zones[id].holder_id != "p1":
			_expect(state.zones[id] == original.zones[id], "AC10 conserva zona ajena/mercado/rival")
	_expect(state.rival == original.rival and state.missions == original.missions, "AC10 rival y misiones intactos")
	_expect(Validator.new().validate(state, _definitions(), "test_catalog").ok, "AC10 salida válida P07")
	_expect(cycle.discard(state, "p1", ["ally"]).ok and state.zones.custom_juego.cards.is_empty(), "AC08 descarte explícito admite aliado")
	var noop: Dictionary = state.duplicate(true)
	_expect(cycle.cleanup_cards(state, "p1").ok and cycle.discard(state, "p1", []).ok and state == noop, "Limpieza repetida y selección vacía no cambian estado")


func _test_rejections() -> void:
	var cycle: RefCounted = Cycle.new(_definitions(), "test_catalog")
	var state: Dictionary = _snapshot()
	var before: Dictionary = state.duplicate(true)
	var rng: RandomNumberGenerator = _rng(state)
	var before_rng: int = rng.state
	for bad: Variant in [-1, 1.0, "1", null, true]:
		_expect(not cycle.draw(state, "p1", bad, rng).ok and state == before and rng.state == before_rng, "AC09 cantidad inválida rechazada atómicamente")
	for request: Array in [["p9", 1, rng], [null, 1, rng], ["p1", 1, null], ["p1", 9223372036854775807, rng]]:
		_expect(not cycle.draw(state, request[0], request[1], request[2]).ok and state == before and rng.state == before_rng, "AC09 identidad/RNG/robo excesivo inválidos")
	for ids: Variant in [["c1", "c1"], ["c1", "missing"], ["c1", "c2"], ["c1", "other_card"], ["market_card"], [1], "c1", null]:
		_expect(not cycle.discard(state, "p1", ids).ok and state == before, "AC08 selección duplicada/ajena/no mano ni juego rechazada sin movimiento parcial")
	_expect(not cycle.cleanup_cards(state, "p9").ok and state == before, "Limpieza plaza inexistente sin cambios")
	# Falta una carta para N: no hay robo parcial ni barajado previo al rechazo.
	var result: Dictionary = cycle.draw(state, "p1", 5, rng)
	_expect(result == {"ok": false, "codigo": "regla_pendiente"} and state == before and rng.state == before_rng, "AC09 preflight mazo+descarte antes de consumir RNG")
	for invalid: Variant in [null, [], {}, {"zones": {}}]:
		_expect(cycle.draw(invalid, "p1", 1, rng).codigo == "estado_invalido", "Entrada P07 inválida robo")
		_expect(cycle.discard(invalid, "p1", []).codigo == "estado_invalido", "Entrada P07 inválida descarte")
		_expect(cycle.cleanup_cards(invalid, "p1").codigo == "estado_invalido", "Entrada P07 inválida limpieza")
	var malformed: Dictionary = before.duplicate(true)
	malformed.zones.custom_mazo.cards.append("c1")
	_expect(cycle.draw(malformed, "p1", 0, rng).codigo == "estado_invalido", "N=0 también valida entrada completa")
	_expect(cycle.discard(state, "p1", ["played", "c1"]).ok and state.zones.custom_descarte.cards == ["d1", "d2", "d3", "played", "c1"], "Descarte mezcla juego/mano y respeta orden explícito")


func _test_order() -> void:
	var cycle: RefCounted = Cycle.new(_definitions(), "test_catalog")
	var state: Dictionary = _snapshot()
	state.zones.custom_mazo.cards = ["d1", "d2", "c2"]
	state.zones.custom_descarte.cards = ["d3"]
	var rng: RandomNumberGenerator = _rng(state)
	var before_rng: int = rng.state
	_expect(cycle.draw(state, "p1", 2, rng).ok and state.zones.custom_mano.cards == ["c1", "held_ally", "c2", "d2"] and state.zones.custom_mazo.cards == ["d1"], "AC07 dos robos conservan orden desde extremo final")
	_expect(rng.state == before_rng and state.zones.custom_descarte.cards == ["d3"], "AC07 descarte intacto mientras queda mazo")


func _test_engine() -> void:
	var initial: Dictionary = _snapshot("cooperativo")
	initial.lifecycle = "en_curso"
	initial.turn.active_id = "p1"
	initial.turn.phase = "inicio"
	var cycle: RefCounted = Cycle.new(_definitions(), "test_catalog")
	# Registro exclusivo del test: cantidad fijada por autoridad, nunca payload.
	var handler: Callable = func(state: Dictionary, actor: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
		if not payload.is_empty():
			return "formato_invalido"
		var result: Dictionary = cycle.draw(state, actor, 2, rng)
		return "" if result.ok else ("accion_ilegal" if result.codigo == "regla_pendiente" else result.codigo)
	var reject_after: Callable = func(state: Dictionary, actor: String, _payload: Dictionary, rng: RandomNumberGenerator) -> String:
		cycle.cleanup_cards(state, actor)
		cycle.draw(state, actor, 2, rng)
		return "accion_ilegal"
	var registry: Dictionary = {"test_cycle": handler, "test_fail_cycle": reject_after}
	var a: RefCounted = GameCore.new(_definitions(), "test_catalog", registry)
	var b: RefCounted = GameCore.new(_definitions(), "test_catalog", registry)
	_expect(a.load_authority_snapshot(initial).ok and b.load_authority_snapshot(initial).ok, "AC10 integración P07 fixtures")
	var failed: Dictionary = a.submit("p1", _action("failed", "test_fail_cycle", 0))
	_expect(not failed.ok and a.get_authority_snapshot() == initial, "AC10 rechazo posterior al ciclo revierte zonas, RNG y recibos")
	var intent: Dictionary = _action("draw_fixed", "test_cycle", 0)
	var receipt: Dictionary = a.submit("p1", intent)
	_expect(receipt.ok and receipt.revision_aplicada == 1, "AC10 recibo transacción")
	_expect(b.submit("p1", intent) == receipt and a.get_authority_snapshot() == b.get_authority_snapshot(), "AC10 rechazo previo no altera determinismo")
	var after: Dictionary = a.get_authority_snapshot()
	_expect(a.submit("p1", intent) == receipt and a.get_authority_snapshot() == after, "AC10 reintento no roba dos veces")
	_expect(after.turn == initial.turn and after.resolution == null and after.players == initial.players, "AC10 primitiva no salta inicio ni declara turno finalizado")
	var resumed: RefCounted = GameCore.new(_definitions(), "test_catalog", registry)
	_expect(resumed.load_authority_snapshot(after).ok and resumed.submit("p1", intent) == receipt, "AC10 recibo restaura desde snapshot")
	var own: Dictionary = a.get_view("p1")
	var other: Dictionary = a.get_view("p2")
	_expect(own.zones.custom_mano.cards.size() == 4 and not other.zones.custom_mano.has("cards") and other.zones.custom_mano.count == 4, "AC10 privacidad tras robo/reciclado")
	_expect(not own.zones.custom_mazo.has("cards") and not other.zones.custom_descarte.has("cards") and not other.has("authority"), "AC10 mazo, descarte ajeno y RNG ocultos")
	var second: Dictionary = a.submit("p1", _action("exact", "test_cycle", 1))
	_expect(second.ok, "AC10 robo exacto restante mediante transacción")
	var exhausted: Dictionary = a.get_authority_snapshot()
	var blocked: Dictionary = a.submit("p1", _action("blocked", "test_cycle", 2))
	_expect(blocked.codigo == "accion_ilegal" and a.get_authority_snapshot() == exhausted and not exhausted.authority.receipts.p1.has("blocked"), "AC10 regla pendiente se mapea sin recibo ni datos privados")
	_expect(a.submit("p2", _action("out_of_turn", "test_cycle", 2)).codigo == "accion_ilegal", "Motor mantiene puerta de actor activo")
	var injected: Dictionary = _action("injected", "test_cycle", 2)
	injected.payload["count"] = 999
	_expect(a.submit("p1", injected).codigo == "formato_invalido", "Cantidad nunca decidida por cliente")


func _action(id: String, kind: String, revision: int) -> Dictionary:
	return {"version_accion": 1, "match_id": "test_match", "action_id": id,
		"expected_revision": revision, "tipo": kind, "payload": {}}


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
