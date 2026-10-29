extends SceneTree
## SPEC-008 AC-11–18; reglas de limpieza/turno, con contenido ficticio.

const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
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
			_test_success(mode, count)
			_test_atium(mode, count)
	_test_guards()
	_test_order()
	_test_exhaustion()
	_test_engine()
	if failures == 0:
		print("P08_CLEANUP_OK: %d comprobaciones." % checks)
	else:
		push_error("P08 limpieza: %d fallos en %d comprobaciones." % [failures, checks])
	quit(0 if failures == 0 else 1)


func _definitions() -> Dictionary:
	var definitions: Dictionary = Fixtures.definitions()
	definitions["test_ally"] = {"id": "test_ally", "tipo": "aliado", "efecto": "NO EJECUTAR"}
	return definitions


func _snapshot(mode: String = "competitivo", count: int = 2) -> Dictionary:
	var state: Dictionary = Fixtures.snapshot(mode, count)
	state.lifecycle = "en_curso"
	state.turn = {"number": 4, "active_id": "p1", "phase": "limpieza", "counters": {}}
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
	for instance: Dictionary in state.instances.values():
		if instance.owner_id == "p1":
			instance.state.ability_uses = {"used": 2}
	state.players[0].metals[0].exhausted = true
	state.instances["market_card"] = Fixtures.instance("market_card", "test_action", null)
	state.instances.market_card.state.flags = {"unknown": true}
	state.zones.mercado.cards = ["market_card"]
	if count > 1:
		state.instances["other_card"] = Fixtures.instance("other_card", "test_action", "p2")
		state.instances.other_card.state.ability_uses = {"other": 3}
		state.instances.other_card.state.flags = {"other": false}
		state.zones.p2_mano.cards = ["other_card"]
	if mode != "competitivo":
		# La prueba positiva no presupone resuelto un adversario frente al activo.
		state.zones.adversarios.cards.clear()
		state.rival.adversaries.clear()
		state.instances.erase("enemy_1")
	return state


func _rng(state: Dictionary) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = state.authority.rng_seed
	rng.state = state.authority.rng_state
	return rng


func _test_success(mode: String, count: int) -> void:
	var service: RefCounted = Cleanup.new(_definitions(), "test_catalog")
	var state: Dictionary = _snapshot(mode, count)
	var original: Dictionary = state.duplicate(true)
	var rng: RandomNumberGenerator = _rng(state)
	var validation: Dictionary = Validator.new().validate(state, _definitions(), "test_catalog")
	_expect(validation.ok, "AC11 fixture válido de siete configuraciones: " + str(validation.errors))
	if not validation.ok:
		return
	_expect(service.finish_cleanup(state, "p1", rng) == {"ok": true, "codigo": "aceptada"}, "AC12 éxito sin identidades privadas en respuesta")
	_expect(state.zones.custom_mano.cards.size() == 5 and state.zones.custom_mano.cards[0] == "c2", "AC12 robo cinco, empieza por superior anterior")
	_expect(state.zones.custom_juego.cards == ["ally"] and state.zones.custom_mazo.cards.size() == 2 and state.zones.custom_descarte.cards.is_empty(), "AC12 limpia mano/no aliados antes de reciclar y conserva aliado")
	var expected_player: Dictionary = original.players[0].duplicate(true)
	expected_player.turn_resources = {"recursos": 0, "ataque": 0}
	expected_player.burned = {}
	expected_player.ability_uses = {}
	expected_player.metals[0].used_this_turn = false
	_expect(state.players[0] == expected_player, "AC12 resetea sólo temporales; conserva exhausted, Atium, saldo, salud, entrenamiento y burn_limit")
	for index: int in range(1, count):
		_expect(state.players[index] == original.players[index], "AC12 jugadores ajenos sin cambios")
	for id: String in original.instances:
		var expected: Dictionary = original.instances[id].duplicate(true)
		if expected.owner_id == "p1":
			expected.state.ability_uses = {}
		_expect(state.instances[id] == expected, "AC12 usos propios incluso fuera juego; flags/instancias ajenas intactos")
	for id: String in original.zones:
		if original.zones[id].holder_id != "p1":
			_expect(state.zones[id] == original.zones[id], "AC12 conservación zonas ajenas/compartidas/rival")
	for key: String in ["rival", "missions", "target_id", "authority", "revision", "resolution", "lifecycle"]:
		_expect(state[key] == original[key], "AC12 persistentes de partida conservados")
	if mode == "competitivo":
		_expect(state.turn == {"number": 5, "active_id": "p2", "phase": "inicio", "counters": {}}, "AC13 siguiente vivo inicia sin entrenar ni abrir libre")
	else:
		_expect(state.turn == {"number": 4, "active_id": "p1", "phase": "rival", "counters": {}}, "AC13 coop/solo entrega rival sin ejecutarlo")
	_expect(Validator.new().validate(state, _definitions(), "test_catalog").ok, "AC14 salida conserva invariantes P07")
	var replay: Dictionary = original.duplicate(true)
	var replay_rng: RandomNumberGenerator = _rng(original)
	_expect(service.finish_cleanup(replay, "p1", replay_rng).ok and replay == state and replay_rng.state == rng.state and rng.state != original.authority.rng_state, "AC14 determinismo de snapshot/RNG con reciclado")
	_reject(state, "p1", "accion_ilegal", "AC13 no repite limpieza ni sale de inicio/rival")


func _set_atium(state: Dictionary, used: Array) -> void:
	var player: Dictionary = state.players[0]
	player.metals = [player.metals[0]]
	for index: int in range(used.size()):
		player.metals.append({"token_id": "atium_%d" % (index + 1), "metal": "atium", "exhausted": false, "used_this_turn": used[index]})
	player.persistent.atium = used.size()


func _test_atium(mode: String, count: int) -> void:
	for used: Array in [[], [false, false], [true, true], [true, false, true, false]]:
		var state: Dictionary = _snapshot(mode, count)
		_set_atium(state, used)
		# Metal ordinario entre las fichas: el filtrado conserva el orden completo.
		state.players[0].metals.insert(1, {"token_id": "acero_1", "metal": "acero", "exhausted": false, "used_this_turn": true})
		var original: Dictionary = state.duplicate(true)
		var expected_metals: Array = []
		var expected_total: int = 0
		for token: Dictionary in original.players[0].metals:
			if token.metal == "atium":
				if token.used_this_turn:
					continue
				expected_total += 1
			var retained: Dictionary = token.duplicate(true)
			if retained.metal != "atium":
				retained.used_this_turn = false
			expected_metals.append(retained)
		var rng: RandomNumberGenerator = _rng(state)
		var result: Dictionary = Cleanup.new(_definitions(), "test_catalog").finish_cleanup(state, "p1", rng)
		_expect(result == {"ok": true, "codigo": "aceptada"}, "AC16 devolución sin identidades privadas, siete configuraciones")
		_expect(state.players[0].metals == expected_metals and state.players[0].persistent.atium == expected_total, "AC16 mezcla/todas/ninguna/cero: retira sólo usadas y conserva orden/IDs/estado")
		_expect(state.players[0].persistent.boxings == original.players[0].persistent.boxings, "AC16 Boxings no se altera")
		for index: int in range(1, count):
			_expect(state.players[index] == original.players[index], "AC16 fichas y saldo ajenos intactos")
		_expect(Validator.new().validate(state, _definitions(), "test_catalog").ok, "AC17 devolución conserva igualdad exacta P07")
		var after: Dictionary = state.duplicate(true)
		var after_rng: int = rng.state
		_expect(not Cleanup.new(_definitions(), "test_catalog").finish_cleanup(state, "p1", rng).ok and state == after and rng.state == after_rng, "AC17 segundo cierre no devuelve ni consume otra vez")


func _reject(state: Dictionary, actor: Variant, code: String, message: String) -> void:
	var before: Dictionary = state.duplicate(true)
	var rng: RandomNumberGenerator = _rng(state)
	var before_rng: int = rng.state
	var result: Dictionary = Cleanup.new(_definitions(), "test_catalog").finish_cleanup(state, actor, rng)
	_expect(result == {"ok": false, "codigo": code} and state == before and rng.state == before_rng, message)


func _test_guards() -> void:
	var service: RefCounted = Cleanup.new(_definitions(), "test_catalog")
	var base: Dictionary = _snapshot()
	for invalid: Variant in [null, [], {}, {"turn": {}}]:
		_expect(service.finish_cleanup(invalid, "p1", _rng(base)).codigo == "estado_invalido", "AC11 entrada malformada")
	_reject(base, null, "formato_invalido", "AC11 actor malformado")
	_reject(base, "p9", "accion_ilegal", "AC11 actor inexistente")
	_reject(base, "p2", "accion_ilegal", "AC11 fuera turno")
	var before: Dictionary = base.duplicate(true)
	_expect(service.finish_cleanup(base, "p1", null).codigo == "formato_invalido" and base == before, "AC11 RNG inválido sin mutación")
	for phase: String in ["sin_iniciar", "inicio", "libre", "combate", "rival", "finalizada"]:
		var state: Dictionary = base.duplicate(true)
		state.turn.phase = phase
		_reject(state, "p1", "accion_ilegal", "AC11 puerta de fase " + phase)
	for lifecycle: String in ["sin_preparar", "finalizada"]:
		var state: Dictionary = base.duplicate(true)
		state.lifecycle = lifecycle
		_reject(state, "p1", "accion_ilegal", "AC11 lifecycle " + lifecycle)
	var state: Dictionary = base.duplicate(true)
	state.turn.number = 0
	_reject(state, "p1", "accion_ilegal", "AC11 turno positivo obligatorio")
	state = base.duplicate(true)
	state.turn.number = 9223372036854775807
	_reject(state, "p1", "regla_pendiente", "AC13 desbordamiento no crea turno negativo")
	state = base.duplicate(true)
	state.turn.active_id = null
	_reject(state, "p1", "accion_ilegal", "AC11 activo ausente")
	state = base.duplicate(true)
	state.resolution = Fixtures.resolution()
	_reject(state, "p1", "accion_ilegal", "AC11 resolución pendiente no se salta")
	for counter: int in [0, 1]:
		state = base.duplicate(true)
		state.turn.counters = {"unknown": counter}
		_reject(state, "p1", "regla_pendiente", "AC11 counter no vacío bloquea incluso cero")
	for flag: bool in [false, true]:
		state = base.duplicate(true)
		state.instances.d1.state.flags = {"unknown": flag}
		_reject(state, "p1", "regla_pendiente", "AC11 flag propio fuera juego bloquea incluso false")
	state = base.duplicate(true)
	state.players[0].persistent.atium = 0
	_reject(state, "p1", "estado_invalido", "AC15 saldo incoherente no se repara durante limpieza")
	state = base.duplicate(true)
	state.players[0].metals[1].exhausted = true
	_reject(state, "p1", "estado_invalido", "AC15 Atium agotado rechazado sin refrescarlo")
	state = base.duplicate(true)
	state.players[1].persistent.atium = 2
	_reject(state, "p1", "estado_invalido", "AC15 igualdad exacta también en plazas ajenas")
	state = base.duplicate(true)
	state.players[1].metals[1].exhausted = true
	_reject(state, "p1", "estado_invalido", "AC15 Atium agotado ajeno también invalida snapshot")
	for eliminated: bool in [false, true]:
		state = base.duplicate(true)
		state.players[0].health = 0
		state.players[0].eliminated = eliminated
		_reject(state, "p1", "accion_ilegal", "AC11 activo sin salud nunca avanza")
	state = base.duplicate(true)
	state.players[0].eliminated = true
	_reject(state, "p1", "accion_ilegal", "AC11 activo eliminado nunca avanza")
	for mode: String in ["competitivo", "cooperativo"]:
		for eliminated: bool in [false, true]:
			state = _snapshot(mode)
			state.players[1].health = 8 if eliminated else 0
			state.players[1].eliminated = eliminated
			_reject(state, "p1", "regla_pendiente", "AC13 muerte incoherente de otro jugador bloquea sin decidir final")
	state = base.duplicate(true)
	state.players[1].health = 0
	state.players[1].eliminated = true
	_reject(state, "p1", "regla_pendiente", "AC13 último superviviente no inventa victoria")
	for mode: String in ["cooperativo", "solitario"]:
		state = _snapshot(mode, 1 if mode == "solitario" else 2)
		state.rival.health = 0
		_reject(state, "p1", "regla_pendiente", "AC13 rival muerto no inventa victoria")
		state = _snapshot(mode, 1 if mode == "solitario" else 2)
		_add_enemy(state, "p1")
		_reject(state, "p1", "regla_pendiente", "AC11 adversario frente activo pendiente de resolver")
	state = _snapshot("cooperativo")
	_add_enemy(state, "p2")
	var rival_before: Dictionary = state.rival.duplicate(true)
	_expect(service.finish_cleanup(state, "p1", _rng(state)).ok and state.rival == rival_before, "AC11 adversarios sólo frente a otro no bloquean ni se ejecutan")
	state = base.duplicate(true)
	state.zones.custom_mazo.cards.append("c1")
	_reject(state, "p1", "estado_invalido", "AC11 snapshot inválido no se repara silenciosamente")


func _add_enemy(state: Dictionary, facing: String) -> void:
	state.instances["enemy_1"] = Fixtures.instance("enemy_1", "test_enemy", null)
	state.zones.adversarios.cards = ["enemy_1"]
	state.rival.adversaries["enemy_1"] = {"facing_id": facing, "destroyed_shields": [0, 1]}


func _test_order() -> void:
	var service: RefCounted = Cleanup.new(_definitions(), "test_catalog")
	var state: Dictionary = _snapshot("competitivo", 4)
	state.player_order = ["p1", "p3", "p4", "p2"]
	state.players[2].health = 0
	state.players[2].eliminated = true
	_expect(service.finish_cleanup(state, "p1", _rng(state)).ok and state.turn.active_id == "p4", "AC13 sigue player_order y salta eliminado")
	state = _snapshot("competitivo", 3)
	state.player_order = ["p2", "p3", "p1"]
	state.players[1].health = 0
	state.players[1].eliminated = true
	state.target_id = "p3"
	_expect(service.finish_cleanup(state, "p1", _rng(state)).ok and state.turn.active_id == "p3" and state.turn.number == 5 and state.target_id == "p3", "AC13 vuelta de orden no reinicia número ni modifica Target")


func _test_exhaustion() -> void:
	var state: Dictionary = _snapshot()
	state.players[0].metals[1].used_this_turn = true
	for id: String in ["d1", "d2", "d3", "held_ally"]:
		state.instances.erase(id)
	state.zones.custom_mano.cards = ["c1"]
	state.zones.custom_descarte.cards = []
	_reject(state, "p1", "regla_pendiente", "AC17 agotamiento revierte también devolución/saldo Atium, contadores, fase y RNG")
	# Cinco disponibles exactas tras limpiar: se acepta sin reciclar al terminar.
	state = _snapshot()
	for id: String in ["d1", "d2"]:
		state.instances.erase(id)
	state.zones.custom_descarte.cards = ["d3"]
	var rng: RandomNumberGenerator = _rng(state)
	_expect(Cleanup.new(_definitions(), "test_catalog").finish_cleanup(state, "p1", rng).ok and state.zones.custom_mano.cards.size() == 5 and state.zones.custom_mazo.cards.is_empty(), "AC14 robo exacto no se considera agotamiento pendiente")
	state = _snapshot()
	state.zones.custom_mazo.cards = ["d1", "d2", "d3", "played", "c2"]
	state.zones.custom_descarte.cards = []
	state.zones.custom_juego.cards = ["ally"]
	rng = _rng(state)
	var before_rng: int = rng.state
	_expect(Cleanup.new(_definitions(), "test_catalog").finish_cleanup(state, "p1", rng).ok and rng.state == before_rng, "AC14 sin reciclado no consume RNG")
	_expect(state.zones.custom_mano.cards == ["c2", "played", "d3", "d2", "d1"] and state.zones.custom_descarte.cards == ["c1", "held_ally"], "AC12 robo conserva orden de mazo y no recicla anticipadamente")
	_expect(state.players[0].persistent.atium == 1 and not state.players[0].metals[1].exhausted, "AC16 Atium sin usar conserva ficha y saldo total")


func _test_engine() -> void:
	var service: RefCounted = Cleanup.new(_definitions(), "test_catalog")
	# Manejadores ficticios exclusivos de la prueba; no API de producto.
	var handler: Callable = func(state: Dictionary, actor: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
		if not payload.is_empty():
			return "formato_invalido"
		var result: Dictionary = service.finish_cleanup(state, actor, rng)
		return "" if result.ok else ("accion_ilegal" if result.codigo == "regla_pendiente" else result.codigo)
	var reject_after: Callable = func(state: Dictionary, actor: String, _payload: Dictionary, rng: RandomNumberGenerator) -> String:
		var result: Dictionary = service.finish_cleanup(state, actor, rng)
		return "accion_ilegal" if result.ok else "estado_invalido"
	var registry: Dictionary = {"test_cleanup": handler, "test_fail_cleanup": reject_after}
	var initial: Dictionary = _snapshot("cooperativo")
	_set_atium(initial, [true, false, true])
	var a: RefCounted = GameCore.new(_definitions(), "test_catalog", registry)
	var b: RefCounted = GameCore.new(_definitions(), "test_catalog", registry)
	_expect(a.load_authority_snapshot(initial).ok and b.load_authority_snapshot(initial).ok, "AC14 P07 acepta fixtures")
	_expect(a.submit("p1", _action("failed", "test_fail_cleanup", 0)).codigo == "accion_ilegal" and a.get_authority_snapshot() == initial, "AC14 rechazo posterior al éxito revierte fase/cartas/recibos y RNG consumido")
	var injected: Dictionary = _action("injected", "test_cleanup", 0)
	injected.payload = {"phase": "libre", "count": 0}
	_expect(a.submit("p1", injected).codigo == "formato_invalido" and a.get_authority_snapshot() == initial, "AC14 cliente no decide fase ni cantidad")
	_expect(a.submit("p2", _action("other", "test_cleanup", 0)).codigo == "accion_ilegal", "AC11 P07 rechaza actor fuera turno")
	var intent: Dictionary = _action("cleanup", "test_cleanup", 0)
	var receipt: Dictionary = a.submit("p1", intent)
	_expect(receipt.ok and receipt.revision_aplicada == 1, "AC14 recibo P07 al completar limpieza")
	_expect(b.submit("p1", intent) == receipt and b.get_authority_snapshot() == a.get_authority_snapshot(), "AC14 replay determinista tras rechazo anterior")
	var after: Dictionary = a.get_authority_snapshot()
	_expect(after.authority.rng_state != initial.authority.rng_state and after.turn.phase == "rival", "AC14 P07 persiste RNG y fase juntos")
	_expect(after.players[0].persistent.atium == 1 and after.players[0].metals.size() == 2 and after.players[0].metals[1].token_id == "atium_2", "AC17 P07 confirma devolución y decremento juntos")
	_expect(a.submit("p1", intent) == receipt and a.get_authority_snapshot() == after, "AC14 reintento no limpia/roba dos veces")
	var resumed: RefCounted = GameCore.new(_definitions(), "test_catalog", registry)
	_expect(resumed.load_authority_snapshot(after).ok and resumed.submit("p1", intent) == receipt and resumed.get_authority_snapshot() == after, "AC14 recibo sobrevive reanudación")
	_expect(a.submit("p1", _action("again", "test_cleanup", 1)).codigo == "accion_ilegal" and a.get_authority_snapshot() == after, "AC13 nueva intención no sale de rival")
	var own: Dictionary = a.get_view("p1")
	var other: Dictionary = a.get_view("p2")
	_expect(own.players[0].persistent.atium == 1 and other.players[0].persistent.atium == 1 and own.players[0].metals == after.players[0].metals and other.players[0].metals == after.players[0].metals, "AC17 proyecciones y snapshot coinciden en saldo/fichas públicos")
	_expect(own.zones.custom_mano.cards.size() == 5 and other.zones.custom_mano.count == 5 and not other.zones.custom_mano.has("cards"), "AC14 mano privada tras limpieza")
	_expect(not own.has("authority") and not other.has("authority") and not own.zones.custom_mazo.has("cards") and not other.zones.custom_mazo.has("cards"), "AC14 no filtra RNG, recibos ni orden mazo")
	initial = _snapshot()
	initial.players[0].metals[1].used_this_turn = true
	initial.turn.counters = {"unknown": 1}
	_expect(a.load_authority_snapshot(initial).ok, "AC14 estado con regla pendiente es estructuralmente válido")
	_expect(a.submit("p1", intent).codigo == "accion_ilegal" and a.get_authority_snapshot() == initial and not a.get_authority_snapshot().authority.receipts.has("p1"), "AC14 adaptador mapea regla_pendiente sin recibos ni filtraciones")


func _action(id: String, kind: String, revision: int) -> Dictionary:
	return {"version_accion": 1, "match_id": "test_match", "action_id": id,
		"expected_revision": revision, "tipo": kind, "payload": {}}


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
