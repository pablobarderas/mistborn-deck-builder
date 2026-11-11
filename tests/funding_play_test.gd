extends SceneTree

const Funding = preload("res://scripts/game/funding_play.gd")
const EngineCore = preload("res://scripts/game/game_engine.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Fixtures = preload("res://tests/funding_fixtures.gd")
const Base = preload("res://tests/game_state_fixtures.gd")
const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_play()
	_test_multiple_and_replay()
	_test_illegal()
	_test_profiles()
	_test_dynamic_admission()
	_test_limits()
	_test_privacy()
	_test_cleanup()
	if _failures == 0:
		print("P08_FUNDING_OK: %d comprobaciones." % _checks)
	else:
		push_error("P08 Funding: %d fallos en %d comprobaciones." % [_failures, _checks])
	quit(0 if _failures == 0 else 1)


func _engine(state: Dictionary) -> Funding:
	var doc: Dictionary = Fixtures.catalog()
	var engine: Funding = Funding.new(doc, "test_funding", Fixtures.inerts(doc))
	_expect(engine.is_supported() and engine.load_authority_snapshot(state).ok, "Fixture/perfil válidos")
	return engine


func _intent(id: String = "play", revision: int = 0, card: String = "c1", apply: bool = true) -> Dictionary:
	return {"version_accion": 1, "match_id": "test_match", "action_id": id, "expected_revision": revision,
		"tipo": "jugar_funding", "payload": {"instance_id": card, "aplicar": apply}}


func _test_play() -> void:
	for count: int in [2, 3, 4]:
		for apply: bool in [true, false]:
			for balance: int in [0, 7]:
				var initial: Dictionary = Fixtures.snapshot("competitivo", count)
				initial.players[0].turn_resources.recursos = balance
				if count >= 3:
					initial.target_id = "p2"
				var engine: Funding = _engine(initial)
				var receipt: Dictionary = engine.submit("p1", _intent("play", 0, "c1", apply))
				_expect(receipt == {"ok": true, "codigo": "aceptada", "action_id": "play", "revision": 1, "revision_aplicada": 1}, "FUND01 acuse exacto")
				var after: Dictionary = engine.get_authority_snapshot()
				var expected: Dictionary = initial.duplicate(true)
				expected.players[0].turn_resources.recursos += 1 if apply else 0
				_zone(expected, "mano").cards.erase("c1")
				_zone(expected, "juego").cards.append("c1")
				expected.revision = after.revision
				expected.authority.next_id = after.authority.next_id
				expected.authority.receipts = after.authority.receipts.duplicate(true)
				expected.authority.completed_sequences = after.authority.completed_sequences.duplicate(true)
				_expect(after == expected and after.resolution == null, "FUND01/08 sólo cambia movimiento/saldo y commit P07")
				_expect(after.authority.next_id == initial.authority.next_id + 1 and after.authority.receipts.p1.size() == 1
					and after.authority.completed_sequences == {"resolution_3": _close(3, 3, 1)}, "FUND01 cierre, ocurrencia y contador exactos")
				_reject(engine, "p1", _intent("again", 1), "accion_ilegal", "FUND01 omitir/aplicar consume juego de esa instancia")


func _test_multiple_and_replay() -> void:
	var engine: Funding = _engine(Fixtures.snapshot())
	var first: Dictionary = _intent()
	var first_receipt: Dictionary = engine.submit("p1", first)
	_expect(first_receipt.ok and engine.submit("p1", _intent("second", 1, "funding_b")).ok, "FUND02 dos instancias, sin límite artificial")
	var closed: Dictionary = engine.get_authority_snapshot()
	_expect(closed.players[0].turn_resources.recursos == 6 and closed.authority.completed_sequences.size() == 2
		and closed.authority.completed_sequences.resolution_4 == _close(4, 3, 2), "FUND02 +2 y dos ocurrencias")
	var restored: Funding = _engine(bytes_to_var(var_to_bytes(closed)))
	for authority: Funding in [engine, restored]:
		_expect(authority.submit("p1", first) == first_receipt and authority.get_authority_snapshot() == closed, "FUND05 duplicado exacto antes/después de carga")
		var reused: Dictionary = first.duplicate(true)
		reused.payload.aplicar = false
		_reject(authority, "p1", reused, "id_reutilizado", "FUND05 ID con otra elección")
		_reject(authority, "p1", _intent("new", 2), "accion_ilegal", "FUND05 nuevo ID no devuelve carta a mano")
	var doc: Dictionary = Fixtures.catalog()
	var empty: EngineCore = EngineCore.new(Fixtures.definitions(doc), engine.catalog_identity())
	_expect(not empty.load_authority_snapshot(closed).ok, "FUND05 registro vacío no borra cierres")
	var reordered: Dictionary = _reverse_keys(doc)
	var compatible: Funding = Funding.new(reordered, "test_funding", _reverse_keys(Fixtures.inerts(doc)))
	_expect(compatible.catalog_identity() == engine.catalog_identity() and compatible.load_authority_snapshot(closed).ok
		and compatible.submit("p1", first) == first_receipt, "FUND05 identidad canónica independiente de orden de claves")
	var decoded: Dictionary = JSON.parse_string(JSON.stringify(doc))
	var from_json: Funding = Funding.new(decoded, "test_funding", Fixtures.inerts(doc))
	var from_variant: Funding = Funding.new(doc, "test_funding", Fixtures.inerts(decoded))
	_expect(from_json.catalog_identity() == engine.catalog_identity() and from_json.load_authority_snapshot(closed).ok
		and from_variant.catalog_identity() == engine.catalog_identity() and from_variant.load_authority_snapshot(closed).ok,
		"FUND05 el catálogo y los descriptores JSON/Variant son compatibles en ambas direcciones")
	var bad_ledger: Dictionary = closed.duplicate(true)
	bad_ledger.authority.completed_sequences.resolution_4.occurrence_id = "funding_play_5"
	var generic: EngineCore = EngineCore.new(Fixtures.definitions(doc), engine.catalog_identity(), {}, Registry.new(Funding._registration("test_funding")))
	_expect(generic.load_authority_snapshot(bad_ledger).ok, "FUND05 P07 valida la estructura del cierre sin aplicar la convención de Funding")
	_expect(not engine.load_authority_snapshot(bad_ledger).ok and engine.get_authority_snapshot() == closed,
		"FUND05 la ocurrencia histórica debe corresponder al ID de resolución")
	doc.cartas[2].cantidad += 1
	var changed: Funding = Funding.new(doc, "test_funding", Fixtures.inerts(doc))
	_expect(changed.is_supported() and changed.catalog_identity() != engine.catalog_identity() and not changed.load_authority_snapshot(closed).ok,
		"FUND05 mismo ID editorial con cambio mecánico no carga cierres")
	var previous: Dictionary = closed.duplicate(true)
	previous.version_motor = "p08-sequence-1/godot-4.7.2"
	_expect(not engine.load_authority_snapshot(previous).ok and engine.get_authority_snapshot() == closed, "FUND05 sin migración heurística")


func _test_illegal() -> void:
	for change: Array in [["phase", "inicio"], ["phase", "combate"], ["phase", "limpieza"], ["phase", "rival"], ["phase", "finalizada"],
		["number", 0], ["active_id", "p2"]]:
		var state: Dictionary = Fixtures.snapshot()
		state.turn[change[0]] = change[1]
		_reject(_engine(state), "p1", _intent(), "accion_ilegal", "FUND03 fase/turno/actor")
	for mode: String in ["cooperativo", "solitario"]:
		_reject(_engine(Fixtures.snapshot(mode, 1 if mode == "solitario" else 2)), "p1", _intent(), "accion_ilegal", "FUND03 modo no implementado")
	for change: Array in [["lifecycle", "finalizada"], ["eliminated", true], ["health", 0]]:
		var state: Dictionary = Fixtures.snapshot()
		if change[0] == "lifecycle":
			state.lifecycle = change[1]
		else:
			state.players[0][change[0]] = change[1]
		_reject(_engine(state), "p1", _intent(), "accion_ilegal", "FUND03 finalizada/eliminado/sin salud")
	for kind: String in ["mazo", "descarte", "juego", "eliminadas"]:
		var state: Dictionary = Fixtures.snapshot()
		_zone(state, "mano").cards.erase("c1")
		_zone(state, kind, null if kind == "eliminadas" else "p1").cards.append("c1")
		_reject(_engine(state), "p1", _intent(), "accion_ilegal", "FUND03 ubicación ilegal")
	var authority: Funding = _engine(Fixtures.snapshot())
	for card: String in ["foreign", "absent", "remaining"]:
		_reject(authority, "p1", _intent("invalid", 0, card), "accion_ilegal", "FUND04 ajena/ausente/no Funding")
	_reject(authority, "p2", _intent(), "accion_ilegal", "FUND03 actor no activo")
	for payload: Dictionary in [{"instance_id": "c1"}, {"instance_id": "c1", "aplicar": 1}, {"instance_id": "c1", "aplicar": null},
		{"instance_id": "c1", "aplicar": true, "cantidad": 1}, {"instance_id": "c1", "aplicar": true, "programa": "funding_play_v1"},
		{"instance_id": "c1", "aplicar": true, "fase": "libre"}, {"instance_id": 42, "aplicar": true}]:
		var intent: Dictionary = _intent()
		intent.payload = payload
		_reject(authority, "p1", intent, "formato_invalido", "FUND04 payload exacto")
	# P07 bloquea cualquier nueva acción durante una resolución existente de otro registro.
	const Sequences = preload("res://tests/sequence_fixtures.gd")
	var pending: Dictionary = Fixtures.snapshot()
	pending.resolution = Sequences.reaction(pending)
	var doc: Dictionary = Fixtures.catalog()
	var blocked: EngineCore = EngineCore.new(Fixtures.definitions(doc), pending.catalog_id, {}, Registry.new(Sequences.registration()), {"jugar_funding": Sequences.start.bind("automatic_v1", 0)})
	_expect(blocked.load_authority_snapshot(pending).ok, "FUND03 fixture con reacción pendiente")
	_reject(blocked, "p1", _intent(), "accion_ilegal", "FUND03 resolución pendiente bloquea acción")


func _test_profiles() -> void:
	var cases: Array = [
		[["cartas", 0, "revision", "estado"], "borrador"], [["cartas", 0, "revision", "dudas"], ["pendiente"]],
		[["cartas", 0, "habilidades", 0, "condicion"], {"op": "metales_quemados", "metales": ["cobre"]}],
		[["cartas", 0, "habilidades", 0, "efectos"], [{"op": "ganar", "recurso": "boxings", "cantidad": 1, "objetivo": "propio"}]],
		[["cartas", 0, "metales"], ["cobre"]], [["cartas", 0, "rasgos"], {"salud": 1}],
		[["cartas", 0, "habilidades", 0, "limite_por_turno"], 1],
		[["cartas", 3, "habilidades", 0, "momento"], "continuo"],
		[["cartas", 2, "habilidades", 0, "efectos"], [{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"}]],
		[["cartas", 5, "rasgos", "recorridos", 0, "casillas", 0, "efectos"], [{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"}]],
		[["cartas", 0, "vinculos"], ["test_action"]], [["cartas", 0, "coste_compra"], 1],
		[["cartas", 0, "fuentes", 0, "id"], "NO_EXISTE"]]
	for change: Array in cases:
		var doc: Dictionary = Fixtures.catalog()
		var target: Variant = doc
		for key: Variant in change[0].slice(0, change[0].size() - 1):
			target = target[key]
		target[change[0][-1]] = change[1]
		var engine: Funding = Funding.new(doc, "test_funding", Fixtures.inerts(doc))
		_expect(not engine.is_supported() and not engine.load_authority_snapshot(Fixtures.snapshot()).ok, "FUND04 perfil completo rechaza mecánica/revisión/estructura no soportada")
	var extra: Dictionary = Fixtures.catalog()
	extra.cartas[0].habilidades.append(extra.cartas[0].habilidades[0].duplicate(true))
	extra.cartas[0].habilidades[1].id = "additional"
	_expect(not Funding.new(extra, "test_funding", Fixtures.inerts(extra)).is_supported(), "FUND04 habilidad adicional aunque resumen=1")
	var doc: Dictionary = Fixtures.catalog()
	var inerts: Dictionary = Fixtures.inerts(doc)
	inerts.erase("test_character")
	_expect(not Funding.new(doc, "test_funding", inerts).is_supported(), "FUND04 no basta una whitelist parcial")
	inerts = Fixtures.inerts(doc)
	inerts.test_character = {}
	_expect(not Funding.new(doc, "test_funding", inerts).is_supported(), "FUND04 no basta una etiqueta vacía")
	inerts = Fixtures.inerts(doc)
	inerts.test_ally.coste_compra = 0.5
	_expect(not Funding.new(doc, "test_funding", inerts).is_supported(), "FUND04 no se truncan fracciones de los descriptores")
	var copy: Funding = Funding.new(doc, "test_funding", Fixtures.inerts(doc))
	var state: Dictionary = Fixtures.snapshot()
	_expect(copy.load_authority_snapshot(state).ok, "FUND04 carga con perfil copiado")
	doc.cartas[0].habilidades[0].efectos[0].cantidad = 500
	_expect(copy.submit("p1", _intent()).ok and copy.get_authority_snapshot().players[0].turn_resources.recursos == 5, "FUND04 entradas externas mutables no cambian programa")


func _test_dynamic_admission() -> void:
	var clean: Dictionary = Fixtures.snapshot()
	var authority: Funding = _engine(clean)
	var expected_error: Dictionary = {"ok": false, "errors": PackedStringArray(["Estado incompatible con el perfil Funding."])}
	for path: Array in [["turn", "counters"], ["players", 1, "ability_uses"], ["instances", "remaining", "state", "ability_uses"],
		["instances", "remaining", "state", "flags"], ["missions", "mission_1", "rewards", "p2"]]:
		var candidate: Dictionary = clean.duplicate(true)
		var current: Variant = candidate
		for key: Variant in path.slice(0, path.size() - 1):
			current = current[key]
		current[path[-1]] = ["unknown"] if path[-1] == "p2" else {"unknown": true if path[-1] == "flags" else 1}
		_expect(authority.load_authority_snapshot(candidate) == expected_error and authority.get_authority_snapshot() == clean,
			"FUND04 marca desconocida impide cargar sin alterar el estado anterior")
	var hidden: Dictionary = clean.duplicate(true)
	hidden.instances.foreign.state.flags["unknown"] = true
	var catalog: Dictionary = Fixtures.catalog()
	var structural: EngineCore = EngineCore.new(Fixtures.definitions(catalog), clean.catalog_id)
	_expect(structural.load_authority_snapshot(hidden).ok and structural.get_view("p1") == authority.get_view("p1"),
		"FUND07 el estado estructuralmente válido oculta la marca de la mano ajena")
	var fresh: Funding = Funding.new(catalog, "test_funding", Fixtures.inerts(catalog))
	_expect(fresh.load_authority_snapshot(hidden) == expected_error and fresh.get_authority_snapshot().is_empty(),
		"FUND07 la marca privada incompatible no llega a publicarse en la primera carga")
	_expect(authority.load_authority_snapshot(hidden) == expected_error and authority.get_authority_snapshot() == clean,
		"FUND07 la marca privada incompatible tampoco reemplaza el estado confirmado")
	var control: Funding = _engine(clean)
	var intent: Dictionary = _intent()
	var receipt: Dictionary = authority.submit("p1", intent)
	_expect(receipt.ok and receipt == control.submit("p1", intent) and authority.get_authority_snapshot() == control.get_authority_snapshot(),
		"FUND07 intentar cargar la marca oculta no altera el resultado de jugar Funding")


func _test_limits() -> void:
	for field: String in ["revision", "next_id", "recursos"]:
		var state: Dictionary = Fixtures.snapshot()
		if field == "revision":
			state.revision = Registry.MAX_INT
		elif field == "next_id":
			state.authority.next_id = Registry.MAX_INT
		else:
			state.players[0].turn_resources.recursos = Registry.MAX_INT
		_reject(_engine(state), "p1", _intent("limit", state.revision), "estado_invalido", "FUND06 overflow atómico")
	var maximum: Dictionary = Fixtures.snapshot()
	maximum.players[0].turn_resources.recursos = Registry.MAX_INT
	var omitted: Funding = _engine(maximum)
	_expect(omitted.submit("p1", _intent("omit", 0, "c1", false)).ok
		and omitted.get_authority_snapshot().players[0].turn_resources.recursos == Registry.MAX_INT, "FUND06 omitir con saldo máximo")
	var constrained: Dictionary = Fixtures.snapshot()
	var typed_play: Array[int] = []
	_zone(constrained, "descarte").cards.append_array(_zone(constrained, "juego").cards)
	_zone(constrained, "juego").cards = typed_play
	_reject(_engine(constrained), "p1", _intent(), "estado_invalido", "FUND06 zona de juego con tipo incompatible no admite mutación")
	var full: Dictionary = Fixtures.snapshot()
	full.turn.number = 10000
	full.revision = 10000
	@warning_ignore("integer_division")
	var count: int = (Validator.MAX_NODES - _nodes(full) - 1) / _nodes(_close(1, 1, 1))
	for id: int in range(1, count + 1):
		full.authority.completed_sequences["resolution_" + str(id)] = _close(id, id, id)
	full.authority.next_id = count + 1
	_reject(_engine(full), "p1", _intent("full", full.revision), "estado_invalido", "FUND06 ledger sin espacio rechaza candidato completo")
	var valid: Funding = _engine(Fixtures.snapshot())
	var before: Dictionary = valid.get_authority_snapshot()
	var malformed: Dictionary = before.duplicate(true)
	malformed.instances.c1.owner_id = "p2"
	_expect(not valid.load_authority_snapshot(malformed).ok and valid.get_authority_snapshot() == before, "FUND06 carga inválida conserva autoridad")


func _test_privacy() -> void:
	for apply: bool in [true, false]:
		var a: Dictionary = Fixtures.snapshot("competitivo", 4)
		var b: Dictionary = a.duplicate(true)
		b.instances.remaining.definition_id = "test_ally"
		b.instances.c2.definition_id = "test_ally"
		var one: Funding = _engine(a)
		var two: Funding = _engine(b)
		_expect(one.submit("p1", _intent("play", 0, "c1", apply)).ok and two.submit("p1", _intent("play", 0, "c1", apply)).ok, "FUND07 aplicar/omitir para comparar secretos")
		for recipient: String in ["p1", "p2", "p3", "p4"]:
			var view: Dictionary = one.get_view(recipient)
			var hand: Dictionary = _zone(view, "mano")
			var play: Dictionary = _zone(view, "juego")
			_expect(view.players[0].turn_resources.recursos == 4 + (1 if apply else 0) and hand.count == 2
				and play.cards[-1].instance_id == "c1" and play.cards[-1].definition_id == "test_funding" and view.resolution == null,
				"FUND07 la vista muestra Funding, recursos y cantidad de mano")
			if recipient == "p1":
				_expect(view != two.get_view(recipient) and hand.cards[0].instance_id == "remaining", "FUND07 propietario distingue mano propia")
			else:
				_expect(view == two.get_view(recipient) and not hand.has("cards"), "FUND07 vistas ajenas idénticas con mano/mazo secretos distintos")
			var text: String = str(view)
			_expect(not text.contains("c2") and not text.contains("rng_state")
				and not text.contains("completed_sequences") and not text.contains("occurrence_id") and not text.contains("canonical"), "FUND07 sin secretos de mano/mazo/autoridad")
		var invalid: Dictionary = _intent("foreign", 1, "foreign")
		_expect(one.submit("p1", invalid) == two.submit("p1", invalid), "FUND07 errores públicos independientes de secretos")


func _test_cleanup() -> void:
	var engine: Funding = _engine(Fixtures.snapshot())
	_expect(engine.submit("p1", _intent()).ok, "FUND08 Funding jugada")
	_reject(engine, "p1", {"version_accion": 1, "match_id": "test_match", "action_id": "cleanup", "expected_revision": 1,
		"tipo": "limpieza", "payload": {}}, "accion_no_soportada", "FUND08 cierre Funding no abre limpieza")
	var doc: Dictionary = Fixtures.catalog()
	var state: Dictionary = engine.get_authority_snapshot()
	var cleanup: Cleanup = Cleanup.new(Fixtures.definitions(doc), engine.catalog_identity(), Registry.new(Funding._registration("test_funding")))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = state.authority.rng_seed
	rng.state = state.authority.rng_state
	var before: Dictionary = state.duplicate(true)
	_expect(not cleanup.finish_cleanup(state, "p1", rng).ok and state == before, "FUND08 no reutilizar cierre como permiso de fase")
	# Segmento interno de fixture: no hay transición libre -> limpieza en producto.
	state.turn.phase = "limpieza"
	for index: int in range(3):
		var id: String = "draw_%d" % index
		state.instances[id] = Base.instance(id, "test_action", "p1")
		_zone(state, "mazo").cards.append(id)
	_expect(cleanup.finish_cleanup(state, "p1", rng).ok and state.players[0].turn_resources.recursos == 0
		and state.turn.phase == "inicio", "FUND08 composición interna descarta Funding y reinicia recursos")
	_expect(not "c1" in _zone(state, "juego").cards and "played" in _zone(state, "juego").cards, "FUND08 Funding sale de juego; aliado permanece")


func _reject(engine: EngineCore, actor: String, intent: Dictionary, code: String, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, intent)
	_expect(result == {"ok": false, "codigo": code, "revision": before.revision} and engine.get_authority_snapshot() == before, label)


func _zone(state: Dictionary, kind: String, holder: Variant = "p1") -> Dictionary:
	for zone: Dictionary in state.zones.values():
		if zone.kind == kind and zone.holder_id == holder:
			return zone
	return {}


func _close(id: int, turn: int, revision: int) -> Dictionary:
	return {"program_id": "funding_play_v1", "occurrence_id": "funding_play_" + str(id), "owner_id": "p1", "turn_number": turn, "revision_aplicada": revision}


func _nodes(value: Variant) -> int:
	var total: int = 1
	if value is Dictionary:
		for item: Variant in value.values():
			total += _nodes(item)
	elif value is Array:
		for item: Variant in value:
			total += _nodes(item)
	return total


func _reverse_keys(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		var keys: Array = value.keys()
		keys.reverse()
		for key: String in keys:
			result[key] = _reverse_keys(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_reverse_keys(item))
		return result
	return value


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)
