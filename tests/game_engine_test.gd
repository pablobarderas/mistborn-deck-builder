extends SceneTree

const GameCore = preload("res://scripts/game/game_engine.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const Handlers = preload("res://tests/game_engine_handlers.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_validation_and_atomicity()
	_test_receipts_and_replay()
	_test_rng()
	_test_resolution()
	_test_projection()
	if failures == 0:
		print("P07_ENGINE_OK: %d comprobaciones." % checks)
	else:
		push_error("P07 motor: %d fallos en %d comprobaciones." % [failures, checks])
	quit(0 if failures == 0 else 1)


func _prepared(mode: String = "competitivo") -> Dictionary:
	var state: Dictionary = Fixtures.snapshot(mode)
	state.lifecycle = "en_curso"
	state.turn.active_id = "p1"
	state.turn.phase = "libre"
	return state


func _engine(state: Dictionary, handlers: Dictionary = {}) -> RefCounted:
	var registry: Dictionary = Handlers.registry() if handlers.is_empty() else handlers
	var engine: RefCounted = GameCore.new(Fixtures.definitions(), "test_catalog", registry)
	_expect(engine.load_authority_snapshot(state).ok, "Fixture aceptado")
	return engine


func _action(id: String, type: String, revision: int, payload: Dictionary = {}) -> Dictionary:
	return {"version_accion": 1, "match_id": "test_match", "action_id": id,
		"expected_revision": revision, "tipo": type, "payload": payload}


func _test_validation_and_atomicity() -> void:
	var engine: RefCounted = _engine(_prepared())
	var start: Dictionary = engine.get_authority_snapshot()
	for invalid: Variant in [null, [], true, {}, {"version_accion": 1}]:
		_expect(not engine.submit("p1", invalid).ok and engine.get_authority_snapshot() == start, "Formato inválido no muta")
	var wrong: Dictionary = _action("bad_1", "test_spend", 0, {"amount": 1})
	wrong.version_accion = 2
	_reject(engine, "p1", wrong, "version_incompatible")
	wrong = _action("bad_2", "test_spend", 0, {"amount": 1})
	wrong.match_id = "other_match"
	_reject(engine, "p1", wrong, "partida_incorrecta")
	wrong = _action("bad_3", "test_spend", 1, {"amount": 1})
	_reject(engine, "p1", wrong, "revision_obsoleta")
	wrong = _action("bad_4", "test_spend", 0, {"amount": 1})
	wrong["actor_id"] = "p1"
	_reject(engine, "p1", wrong, "formato_invalido")
	_reject(engine, "p9", _action("bad_5", "test_spend", 0, {"amount": 1}), "identidad_no_autorizada")
	_reject(engine, "p1", _action("bad_6", "unhandled", 0), "accion_no_soportada")
	_reject(engine, "p2", _action("bad_7", "test_spend", 0, {"amount": 1}), "accion_ilegal")
	_reject(engine, "p1", _action("bad_8", "test_spend", 0, {"amount": 100}), "accion_ilegal")
	_reject(engine, "p1", _action("bad_9", "test_move", 0, {"instance_id": "c2", "to_zone": "p1_descarte"}), "accion_ilegal")
	_reject(engine, "p1", _action("bad_10", "test_fail", 0), "accion_ilegal")
	for field: String in ["version_accion", "match_id", "action_id", "expected_revision", "tipo", "payload"]:
		for malformed: Variant in [null, true, [], {}]:
			var broken: Dictionary = _action("malformed", "test_spend", 0, {"amount": 1})
			broken[field] = malformed
			var code: String = "version_incompatible" if field == "version_accion" else "formato_invalido"
			_reject(engine, "p1", broken, code)
	_reject(engine, "p1", _action("bad_11", "test_corrupt", 0), "estado_invalido")
	_reject(engine, "p1", _action("bad_12", "test_erase", 0), "estado_invalido")
	_reject(engine, "p1", _action("bad_13", "test_rewind", 0), "estado_invalido")
	_expect(engine.get_authority_snapshot() == start, "Todos los rechazos preservan cartas, recursos, RNG, IDs y revisión")
	var spend: Dictionary = engine.submit("p1", _action("spend_1", "test_spend", 0, {"amount": 2}))
	_expect(spend.ok and spend.revision == 1, "Acción aceptada incrementa revisión una vez")
	_expect(engine.get_authority_snapshot().players[0].turn_resources.recursos == 2, "Recurso disminuye tras commit")
	var moved: Dictionary = engine.submit("p1", _action("move_1", "test_move", 1, {"instance_id": "c1", "to_zone": "p1_descarte"}))
	_expect(moved.ok and moved.revision == 2, "Movimiento ficticio aceptado")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.zones.p1_mano.cards.is_empty() and after.zones.p1_descarte.cards == ["c1"] and after.instances.c1.owner_id == "p1", "Movimiento conserva identidad y propietario")
	var no_rules: RefCounted = GameCore.new(Fixtures.definitions(), "test_catalog")
	_expect(no_rules.load_authority_snapshot(_prepared()).ok, "Sin registro de acciones")
	_reject(no_rules, "p1", _action("x", "test_move", 0, {"instance_id": "c1", "to_zone": "p1_descarte"}), "accion_no_soportada")
	var object_action: Dictionary = _action("obj", "test_spend", 0, {"amount": 1})
	object_action.payload["code"] = RefCounted.new()
	_reject(no_rules, "p1", object_action, "formato_invalido")


func _test_receipts_and_replay() -> void:
	var engine: RefCounted = _engine(_prepared())
	var original: Dictionary = _action("same", "test_spend", 0, {"amount": 1})
	var first: Dictionary = engine.submit("p1", original)
	_expect(first.ok and first.revision_aplicada == 1, "Primer recibo")
	var reordered: Dictionary = {"payload": {"amount": 1}, "tipo": "test_spend", "expected_revision": 0,
		"action_id": "same", "match_id": "test_match", "version_accion": 1}
	_expect(engine.submit("p1", reordered) == first, "Orden de claves no cambia identidad del reintento")
	_expect(engine.submit("p1", _action("other", "test_spend", 1, {"amount": 1})).ok, "Interviene otra acción")
	var before: Dictionary = engine.get_authority_snapshot()
	_reject(engine, "p1", _action("forget", "test_forget", 2), "estado_invalido")
	_expect(engine.submit("p1", original) == first and engine.get_authority_snapshot() == before, "Reintento tardío devuelve acuse original sin mutar")
	_reject(engine, "p1", _action("same", "test_spend", 0, {"amount": 2}), "id_reutilizado")
	_reject(engine, "p2", original, "revision_obsoleta")
	var resumed: RefCounted = _engine(before)
	_expect(resumed.submit("p1", original) == first and resumed.get_authority_snapshot() == before, "Recibo persiste tras reconstruir autoridad desde snapshot")
	var fresh: Dictionary = _action("retry_reject", "test_spend", 2, {"amount": 100})
	_reject(engine, "p1", fresh, "accion_ilegal")
	_expect(not engine.get_authority_snapshot().authority.receipts.p1.has("retry_reject"), "Rechazo no reserva ID")
	fresh.payload.amount = 1
	_expect(engine.submit("p1", fresh).ok, "ID rechazado puede corregirse y usarse")


func _test_rng() -> void:
	var fixture: Dictionary = _prepared()
	for id: String in ["c3", "c4", "c5", "c6"]:
		fixture.instances[id] = Fixtures.instance(id, "test_action", "p1")
		fixture.zones.p1_mazo.cards.append(id)
	var a: RefCounted = _engine(fixture)
	var b: RefCounted = _engine(fixture)
	var shuffle: Dictionary = _action("shuffle_1", "test_shuffle", 0, {"zone_id": "p1_mazo"})
	_reject(a, "p1", _action("failed", "test_fail", 0), "accion_ilegal")
	_expect(a.submit("p1", shuffle).ok and b.submit("p1", shuffle).ok, "Ambos barajan")
	_expect(a.get_authority_snapshot().zones.p1_mazo.cards == b.get_authority_snapshot().zones.p1_mazo.cards, "Misma semilla/acciones dan mismo orden")
	_expect(a.get_authority_snapshot().authority.rng_state == b.get_authority_snapshot().authority.rng_state, "Rechazo no consume RNG")
	var c: RefCounted = _engine(a.get_authority_snapshot())
	var next: Dictionary = _action("shuffle_2", "test_shuffle", 1, {"zone_id": "p1_mazo"})
	_expect(a.submit("p1", next).ok and c.submit("p1", next).ok and a.get_authority_snapshot() == c.get_authority_snapshot(), "Snapshot restaura secuencia RNG")
	var before: Dictionary = a.get_authority_snapshot()
	_reject(a, "p1", _action("corrupt", "test_corrupt", 2), "estado_invalido")
	_expect(a.get_authority_snapshot() == before, "Error tras RNG conserva secuencia y estado completo")


func _test_resolution() -> void:
	var fixture: Dictionary = _prepared()
	fixture.resolution = Fixtures.resolution()
	var engine: RefCounted = _engine(fixture)
	var response: Dictionary = _action("answer", "responder", 0, {"resolution_id": "r1", "step_id": "choose", "options": ["accept"]})
	_reject(engine, "p1", response, "eleccion_invalida")
	_reject(engine, "p2", _action("blocked", "test_spend", 0, {"amount": 1}), "accion_ilegal")
	for payload: Dictionary in [
		{"resolution_id": "wrong", "step_id": "choose", "options": ["accept"]},
		{"resolution_id": "r1", "step_id": "wrong", "options": ["accept"]},
		{"resolution_id": "r1", "step_id": "choose", "options": ["unknown"]},
		{"resolution_id": "r1", "step_id": "choose", "options": ["accept", "accept"]},
		{"resolution_id": true, "step_id": "choose", "options": []},
		{"resolution_id": "r1", "step_id": 1, "options": []},
		{"resolution_id": "r1", "step_id": "choose", "options": [] , "state": {}}
	]:
		_reject(engine, "p2", _action("invalid", "responder", 0, payload), "eleccion_invalida")
	var before: Dictionary = engine.get_authority_snapshot()
	var accepted: Dictionary = engine.submit("p2", response)
	_expect(accepted.ok and accepted.revision == 1, "Respuesta fuera del turno activo admitida")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.resolution.cursor == 2 and after.resolution.pending == null and after.players[1].health == before.players[1].health + 1, "Continuación ficticia conserva paso y efecto del handler")
	_reject(engine, "p2", _action("late", "responder", 1, response.payload), "eleccion_invalida")
	var restored: RefCounted = _engine(before)
	_expect(restored.submit("p2", response) == accepted and restored.get_authority_snapshot() == after, "Resolución pausada reanudable tras snapshot")


func _test_projection() -> void:
	var fixture: Dictionary = _prepared("cooperativo")
	fixture.resolution = Fixtures.resolution()
	fixture.zones.p1_mazo.cards.clear()
	fixture.zones.p1_descarte.cards.append("c2")
	var definitions: Dictionary = Fixtures.definitions()
	definitions["test_action_alt"] = {"id": "test_action_alt", "tipo": "accion"}
	var engine: RefCounted = GameCore.new(definitions, "test_catalog", Handlers.registry())
	_expect(engine.load_authority_snapshot(fixture).ok, "Proyección con descarte y rival")
	var own: Dictionary = engine.get_view("p1")
	var other: Dictionary = engine.get_view("p2")
	_expect(own.zones.p1_mano.cards[0].definition_id == "test_action" and own.zones.p1_descarte.cards[0].instance_id == "c2", "Mano/descarte propios visibles")
	_expect(not other.zones.p1_mano.has("cards") and not other.zones.p1_descarte.has("cards") and other.zones.p1_mano.count == 1, "Mano/descarte ajenos solo cantidades")
	_expect(not own.zones.mazo_mercado.has("cards") and not own.zones.mazo_rival.has("cards"), "Mazos no revelados")
	_expect(own.zones.adversarios.cards[0].definition_id == "test_enemy" and other.zones.eliminadas.cards.is_empty(), "Zonas públicas disponibles")
	_expect(not own.resolution.has("options") and other.resolution.options == ["accept", "decline"], "Opciones solo para destinatario")
	_expect(not own.has("authority") and not other.has("instances") and not own.has("rng_seed") and not own.has("receipts"), "Campos secretos ausentes")
	var other_serialized: String = JSON.stringify(other)
	_expect(not other_serialized.contains('"c1"') and not other_serialized.contains('"c2"') and not other_serialized.contains("rng_state"), "Vista ajena no contiene IDs de mano/descarte ni RNG")
	_expect(engine.get_view("p9").is_empty(), "Destinatario desconocido sin vista")
	var changed: Dictionary = fixture.duplicate(true)
	changed.instances.c1.definition_id = "test_action_alt"
	var secret_engine: RefCounted = GameCore.new(definitions, "test_catalog", Handlers.registry())
	_expect(secret_engine.load_authority_snapshot(changed).ok, "Variante de secreto válida")
	_expect(secret_engine.get_view("p2") == other and secret_engine.get_view("p1") != own, "Cambiar carta oculta no altera vista ajena")
	var attempted: Dictionary = engine.get_view("p1")
	attempted.players[0].health = 999
	attempted.zones.p1_mano.cards.clear()
	_expect(engine.get_view("p1") == own, "Modificar proyección no cambia autoridad")
	var rejected_a: Dictionary = engine.submit("p1", _action("x", "test_spend", 0, {"amount": 1}))
	var rejected_b: Dictionary = secret_engine.submit("p1", _action("x", "test_spend", 0, {"amount": 1}))
	_expect(rejected_a == rejected_b and rejected_a.codigo == "accion_ilegal", "Error no revela secreto alternativo")


func _reject(engine: RefCounted, actor: String, action: Variant, code: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, action)
	_expect(not result.ok and result.codigo == code and engine.get_authority_snapshot() == before,
		"Rechazo %s conserva estado" % code)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
