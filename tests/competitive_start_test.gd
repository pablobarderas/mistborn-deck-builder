extends SceneTree

const Start = preload("res://scripts/game/competitive_start.gd")
const Fixtures = preload("res://tests/competitive_start_fixtures.gd")
const FundingFixtures = preload("res://tests/funding_fixtures.gd")
const Base = preload("res://tests/game_state_fixtures.gd")
const Sequences = preload("res://tests/sequence_fixtures.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const CatalogValidator = preload("res://scripts/catalog/catalog_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const MATCH_ID: String = Fixtures.MATCH_ID

var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_test_opening()
	_test_receipts()
	_test_obligations()
	_test_endings()
	_test_rejections_and_recovery()
	if _failures == 0:
		print("P08_START_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _test_opening() -> void:
	# INI-01 / REG-028: el primer turno de cada plaza, sin robar otra mano.
	for count: int in [2, 3, 4]:
		var engine: Start = _engine()
		if not _prepare(engine, count):
			continue
		var order: Array = engine.get_authority_snapshot().player_order
		_expect(order.front() == "p2" and order.size() == count, "INI-01 orden preparado para %d" % count)
		for number: int in range(1, count + 1):
			var actor: String = order[number - 1]
			var state: Dictionary = engine.get_authority_snapshot()
			if number > 1:
				# Simular una entrega de autoridad, con todos los commits previos.
				state = _delivered(state, actor)
				engine = _engine()
				if not _restore(engine, state, "INI-01 entrega de fixture"):
					break
			var player: Dictionary = _player(state, actor)
			_expect(player.training == 0 and player.burn_limit == 1 and state.turn.number == number,
				"INI-01 la plaza conserva su entrenamiento inicial")
			_expect(state.zones[actor + "_mano"].cards.size() == 5, "INI-01 mano preparada de cinco")
			for mission: Dictionary in state.missions.values():
				_expect(mission.progress[actor] == 0, "INI-01 progreso inicial de misión cero")
			_open_and_compare(engine, actor, 1, 1, false, "INI-01 primera apertura de " + actor)
	var json_catalog: Dictionary = JSON.parse_string(JSON.stringify(Fixtures.catalog()))
	_prepare(_engine(json_catalog), 2)

	var engine: Start = _engine()
	var state: Dictionary = Fixtures.compact_snapshot(engine.catalog_identity())
	if _restore(engine, state, "INI-01 entrada con siguiente casilla de quema"):
		_open_and_compare(engine, "p1", 3, 3, false, "INI-01 aumento de capacidad de quema")
		var before: Dictionary = engine.get_authority_snapshot()
		var funding: Dictionary = engine.submit("p1", _funding(before))
		_expect(funding.ok, "INI-01 Funding puede actuar en libre")
		var after: Dictionary = engine.get_authority_snapshot()
		_expect(after.players[0].turn_resources.recursos == before.players[0].turn_resources.recursos + 1
			and after.zones.p1_juego.cards == ["c1"] and after.turn == before.turn,
			"INI-01 Funding mueve la instancia y aplica el recurso sin cambiar el turno")
		var later: Start = _engine()
		state = _delivered(after, "p2")
		state.players[1].training = 10
		if _restore(later, state, "INI-01 entrada con cierre previo de Funding"):
			_open_and_compare(later, "p2", 11, 2, true, "INI-01 Atium y cierre Funding preservado")


func _test_receipts() -> void:
	# INI-02: comprobar repetición antes de revisión, turno y fase.
	var engine: Start = _engine()
	var first: Dictionary = Fixtures.compact_snapshot(engine.catalog_identity())
	if not _restore(engine, first, "INI-02 inicio pendiente"):
		return
	var intent: Dictionary = _intent(first, "inicio_original")
	var queued: Dictionary = _intent(first, "inicio_encolado")
	_reject_public(engine, "p1", intent, "INI-02 tipo y namespace reservados antes de aplicar")
	var public_type: Dictionary = _intent(first, "publico")
	_reject_public(engine, "p1", public_type, "INI-02 tipo reservado con ID público")
	var public_id: Dictionary = _funding(first, "inicio_reservado")
	_reject_public(engine, "p1", public_id, "INI-02 ID reservado con tipo público")
	_reject_start(engine, "p1", _funding(first), "INI-02 entrada interna rechaza tipo público")
	_reject_start(engine, "p1", public_type, "INI-02 entrada interna exige namespace reservado")
	_reject_public(engine, "p1", _funding(first), "INI-02 Funding bloqueado hasta abrir libre")
	var receipt: Dictionary = engine.start_turn("p1", intent)
	_expect(receipt.ok and receipt.get("revision_aplicada") == 1, "INI-02 commit del primer elemento encolado")
	_expect(_reject_start(engine, "p1", queued, "INI-02 segundo elemento encolado").get("codigo") == "revision_obsoleta",
		"INI-02 revisión común sólo admite un commit")
	_repeat(engine, "p1", intent, receipt, "INI-02 repetición exacta")
	_reject_public(engine, "p1", intent, "INI-02 el cliente no puede recuperar el recibo interno")
	var changed: Dictionary = intent.duplicate(true)
	changed.payload.turn_number += 1
	_expect(_reject_start(engine, "p1", changed, "INI-02 mismo ID con número distinto").get("codigo") == "id_reutilizado",
		"INI-02 huella distinta precede a las guardas de revisión y turno")
	var opened: Dictionary = engine.get_authority_snapshot()
	_reject_start(engine, "p1", _intent(opened, "inicio_consumido"), "INI-02 la fase libre consume la ocurrencia")
	_expect(engine.submit("p1", _funding(opened)).ok, "INI-02 commit posterior de Funding")
	var latest: Dictionary = engine.get_authority_snapshot()
	_expect(latest.revision == 2, "INI-02 acción posterior incrementa revisión")
	_repeat(engine, "p1", intent, receipt, "INI-02 repetición tras otra acción")
	var restored: Start = _engine()
	if not _restore(restored, latest, "INI-02 carga del último commit"):
		return
	_repeat(restored, "p1", intent, receipt, "INI-02 repetición tras restauración")
	_reject_public(restored, "p1", intent, "INI-02 repetición pública tras restaurar")
	var next: Start = _engine()
	var delivered: Dictionary = _delivered(latest, "p2")
	if not _restore(next, delivered, "INI-02 entrega a otra plaza"):
		return
	_open_and_compare(next, "p2", 3, 3, false, "INI-02 inicio intermedio de p2")
	var returning: Dictionary = _delivered(next.get_authority_snapshot(), "p1")
	var again: Start = _engine()
	if _restore(again, returning, "INI-02 vuelve a actuar p1"):
		var stale_turn: Dictionary = _intent(returning, "inicio_turno_anterior")
		stale_turn.payload.turn_number = first.turn.number
		_reject_start(again, "p1", stale_turn, "INI-02 turno anterior con revisión vigente y la misma plaza")
		_open_and_compare(again, "p1", 4, 3, false, "INI-02 el nuevo turno de p1 admite el avance")


func _test_obligations() -> void:
	# INI-03 / SRC-002: el pendiente sobrevive a derrotar a Keeper.
	var catalog: Dictionary = Fixtures.catalog()
	var keeper: Dictionary = FundingFixtures.definitions(catalog).test_ally
	keeper.id = "test_keeper"
	keeper.nombre = "Keeper de prueba"
	keeper.habilidades[0].momento = "continuo"
	catalog.cartas.append(keeper)
	_expect(CatalogValidator.new().validate(catalog).ok, "INI-03 Keeper ficticio es estructuralmente válido para P06")
	var incompatible: Start = _engine(catalog)
	_expect(not incompatible.is_supported(), "INI-03 un descriptor de Keeper fuera de juego invalida el perfil")
	var state: Dictionary = Fixtures.compact_snapshot(incompatible.catalog_identity())
	state.instances["keeper"] = Base.instance("keeper", keeper.id, "p1")
	state.zones.eliminadas.cards.append("keeper")
	state.zones.p1_mazo.cards.erase("c2")
	state.zones.eliminadas.cards.append("c2")
	state.instances.c2.state.flags["apartada_por_keeper"] = true
	_reject_restore(incompatible, state, "INI-03 Keeper derrotado y carta apartada conservan su obligación")

	var admitted: Start = _engine()
	var known: Dictionary = Fixtures.compact_snapshot(admitted.catalog_identity())
	var unknown: Dictionary = known.duplicate(true)
	unknown.instances.c2.state.flags["pendiente_inicio"] = true
	_reject_restore(admitted, unknown, "INI-03 marca desconocida con perfil conocido, incluso en mazo")
	if _restore(admitted, known, "INI-03 recuperar estado admitido"):
		_reject_restore(admitted, unknown, "INI-03 la sustitución no altera el estado admitido")


func _test_endings() -> void:
	# INI-04 / REG-032/033/035/044: comprobar continuidad antes del paso.
	var engine: Start = _engine()
	var state: Dictionary = Fixtures.compact_snapshot(engine.catalog_identity())
	state.players[1].health = 0
	state.players[1].eliminated = true
	if _restore(engine, state, "INI-04 estado con único superviviente"):
		_expect(_reject_start(engine, "p1", _intent(state), "INI-04 un único superviviente conserva inicio").codigo == "regla_pendiente",
			"INI-04 la autoridad deriva el final por supervivencia")
	engine = _engine()
	state = Fixtures.compact_snapshot(engine.catalog_identity())
	for mission: Dictionary in state.missions.values():
		mission.progress.p2 = 1
		mission.arrival_order.append("p2")
	if _restore(engine, state, "INI-04 tres misiones completas para la plaza inactiva"):
		_expect(_reject_start(engine, "p1", _intent(state), "INI-04 el final por misiones de otra plaza bloquea inicio").codigo == "regla_pendiente",
			"INI-04 la autoridad deriva el final por misiones")
	engine = _engine()
	for mission: Dictionary in state.missions.values():
		mission.arrival_order.clear()
	var source: Fixtures.LatestSource = _source(engine, state)
	var admission: Dictionary = engine.restore_match(MATCH_ID, source)
	if admission.ok:
		_reject_start(engine, "p1", _intent(state), "INI-04 arrival_order vacío no permite ignorar la cima")
	else:
		_expect(engine.get_authority_snapshot().is_empty(), "INI-04 datos de llegada incompatibles se rechazan atómicamente")

	engine = _engine()
	state = Fixtures.compact_snapshot(engine.catalog_identity())
	if _restore(engine, state, "INI-04 inicio previo a una finalización de fixture"):
		var intent: Dictionary = _intent(state, "inicio_antes_final")
		var receipt: Dictionary = engine.start_turn("p1", intent)
		_expect(receipt.ok, "INI-04 el inicio anterior a la finalización conserva su recibo")
		state = engine.get_authority_snapshot()
		state.lifecycle = "finalizada"
		state.turn.phase = "finalizada"
		state.revision += 1
		engine = _engine()
		if _restore(engine, state, "INI-04 snapshot finalizado"):
			_reject_start(engine, "p1", _intent(state), "INI-04 partida finalizada conserva snapshot")
			_repeat(engine, "p1", intent, receipt, "INI-04 el recibo válido sigue accesible tras finalizar")
	var catalog: Dictionary = Fixtures.catalog()
	for definition: Dictionary in catalog.cartas:
		if definition.id == "test_character":
			definition.habilidades.append({"id": "confrontation", "momento": "continuo", "condicion": {"op": "siempre"},
				"limite_por_turno": null, "efectos": [{"op": "sin_efecto"}]})
	var confrontation: Start = _engine(catalog)
	_expect(CatalogValidator.new().validate(catalog).ok and not confrontation.is_supported(),
		"INI-04 se excluye un origen que permite Confrontation sin certificar su evento")
	_reject_restore(confrontation, Fixtures.compact_snapshot(confrontation.catalog_identity()),
		"INI-04 el estado de origen Confrontation no se admite")
	engine = _engine()
	state = Fixtures.compact_snapshot(engine.catalog_identity())
	state.players[0].training = 10
	for index: int in [2, 3]:
		state.players[0].metals.append({"token_id": "fixture_atium_%d" % index, "metal": "atium", "exhausted": false, "used_this_turn": false})
	state.players[0].persistent.atium = 3
	if _restore(engine, state, "INI-04 inicio con tres fichas de Atium"):
		_open_and_compare(engine, "p1", 11, 2, true, "INI-04 la cuarta ficha sin activación permite abrir libre")
		_expect(engine.get_authority_snapshot().players[0].persistent.atium == 4, "INI-04 saldo de cuatro fichas")


func _test_rejections_and_recovery() -> void:
	# INI-05: comprobaciones de admisión, solicitud, candidato y commit.
	var engine: Start = _engine()
	var initial: Dictionary = Fixtures.compact_snapshot(engine.catalog_identity())
	var latest: Fixtures.LatestSource = _source(engine, initial)
	var reentrant: Callable = func(match_id: String, profile_id: String) -> Dictionary:
		_reject_start(engine, "p1", _intent(initial), "INI-02 inicio reentrante")
		_reject_public(engine, "p1", _funding(initial), "INI-02 acción de jugador reentrante")
		_reject_restore(engine, initial, "INI-02 restauración reentrante")
		var prepared: Dictionary = engine.prepare_match(match_id, Fixtures.seats(2), "p1", Fixtures.manifest(), 12345)
		_expect(not prepared.ok and engine.get_authority_snapshot().is_empty(), "INI-02 preparación reentrante")
		return latest.latest(match_id, profile_id)
	var loaded: Dictionary = engine.restore_match(MATCH_ID, Fixtures.ScriptedSource.new(reentrant))
	_expect(loaded.ok and engine.get_authority_snapshot() == initial, "INI-02 sólo confirma la operación exterior")
	if not loaded.ok:
		return
	_reject_start(engine, "p2", _intent(initial), "INI-05 actor distinto de la plaza activa")
	_reject_start(engine, "unknown", _intent(initial), "INI-05 actor desconocido")
	var malformed: Dictionary = _intent(initial)
	malformed.payload["training"] = 5
	_reject_start(engine, "p1", malformed, "INI-05 payload no puede decidir entrenamiento")
	malformed = _intent(initial)
	malformed.payload.turn_number = str(initial.turn.number)
	_reject_start(engine, "p1", malformed, "INI-05 número de turno debe ser entero")
	malformed = _intent(initial)
	malformed.match_id = "otro_match"
	_reject_start(engine, "p1", malformed, "INI-05 partida incorrecta")
	_open_and_compare(engine, "p1", 3, 3, false, "INI-05 reintento válido tras rechazos")
	var committed: Dictionary = engine.get_authority_snapshot()
	latest.confirm(engine.profile_identity(), committed)
	latest.confirm(engine.profile_identity(), initial)
	_expect(not engine.load_authority_snapshot(initial).ok and engine.get_authority_snapshot() == committed,
		"INI-05 carga cruda precommit de la misma versión se rechaza sobre motor cargado")
	_reject_restore(engine, initial, "INI-05 fuente tampoco reemplaza motor cargado")
	var fresh: Start = _engine()
	_expect(not fresh.load_authority_snapshot(initial).ok and fresh.get_authority_snapshot().is_empty(),
		"INI-05 carga cruda también bloqueada sobre motor vacío")
	var old: Fixtures.ScriptedSource = Fixtures.ScriptedSource.new(latest.select.bind(initial.revision))
	_expect(not fresh.restore_match(MATCH_ID, old).ok and fresh.get_authority_snapshot().is_empty(),
		"INI-05 fuente fiable rechaza selección de revisión precommit")
	var different_profile: Callable = func(_match_id: String, _profile_id: String) -> Dictionary:
		return {"profile_id": "perfil_distinto", "snapshot": committed}
	_expect(not fresh.restore_match(MATCH_ID, Fixtures.ScriptedSource.new(different_profile)).ok
		and fresh.get_authority_snapshot().is_empty(),
		"INI-05 mismo catálogo y snapshot con procedencia de otro perfil se rechazan")
	var invalid_callable: Callable = func(_match: int, _profile: int) -> Dictionary:
		return {}
	_expect(not fresh.restore_match(MATCH_ID, invalid_callable).ok and fresh.get_authority_snapshot().is_empty(),
		"INI-05 fuente exige el contrato tipado y rechaza un callable incompatible")
	var outdated: Dictionary = committed.duplicate(true)
	outdated.version_motor = "p08-funding-1/godot-4.7.2"
	_reject_restore(fresh, outdated, "INI-05 motor anterior sin migración")
	_expect(fresh.restore_match(MATCH_ID, latest).ok and fresh.get_authority_snapshot() == committed,
		"INI-05 la última revisión se puede restaurar tras rechazos")
	var view: Dictionary = fresh.get_view("p2")
	_expect(view.get("turn") == {"number": committed.turn.number, "active_id": "p1", "phase": "libre"}
		and _player(view, "p1").get("training") == 3, "INI-05 fase y avance visibles para otra plaza")
	var encoded: String = JSON.stringify(view)
	for private_text: String in ["authority", "receipts", "completed_sequences", "rng_seed", "rng_state", "profile_id",
		"inicio_prueba", "ability_uses", "flags", "counters"]:
		_expect(not encoded.contains(private_text), "INI-05 vista ajena excluye " + private_text)
	_expect(not view.get("zones", {}).get("p1_mano", {}).has("cards"), "INI-05 mano ajena permanece privada")

	var unsupported: Start = _engine()
	for mode: String in ["cooperativo", "solitario"]:
		var count: int = 2 if mode == "cooperativo" else 1
		_reject_restore(unsupported, Fixtures.compact_snapshot(unsupported.catalog_identity(), mode, count),
			"INI-05 modo fuera del perfil: " + mode)
	var pending: Dictionary = initial.duplicate(true)
	pending.resolution = Sequences.reaction(pending)
	var definitions: Dictionary = CatalogValidator.new().validate(Fixtures.catalog()).cards
	var other_registry: Registry = Registry.new(Sequences.registration())
	_expect(Validator.new().validate(pending, definitions, pending.catalog_id, other_registry).ok,
		"INI-05 resolución pendiente estructuralmente válida con otro registro")
	_reject_restore(unsupported, pending, "INI-05 resolución pendiente fuera del registro")
	var cleaning: Dictionary = initial.duplicate(true)
	cleaning.turn.phase = "limpieza"
	_reject_restore(unsupported, cleaning, "INI-05 fase fuera de la admisión")
	var exhausted: Dictionary = initial.duplicate(true)
	exhausted.revision = Registry.MAX_INT
	if _restore(unsupported, exhausted, "INI-05 revisión al máximo todavía admisible"):
		_reject_start(unsupported, "p1", _intent(exhausted), "INI-05 desbordamiento de revisión")
	var blocked: Start = _engine()
	var overflow: Dictionary = initial.duplicate(true)
	overflow.players[0].burn_limit = Registry.MAX_INT
	if _restore(blocked, overflow, "INI-05 límite de quema inicial admisible"):
		_reject_start(blocked, "p1", _intent(overflow), "INI-05 falla el paso por desbordamiento de quema")
	_test_candidate_limit(initial)
	_test_receipt_limit(initial)


func _test_candidate_limit(initial: Dictionary) -> void:
	var state: Dictionary = initial.duplicate(true)
	state.players[0].training = 10
	var metals: Array = state.players[0].metals
	for index: int in range(metals.size(), Validator.MAX_ITEMS):
		metals.append({"token_id": "cobre_%d" % index, "metal": "cobre", "exhausted": false, "used_this_turn": false})
	var definitions: Dictionary = CatalogValidator.new().validate(Fixtures.catalog()).cards
	var validator: Validator = Validator.new()
	var low: int = 2
	var high: int = metals.size()
	while low + 1 < high:
		var middle: int = (low + high) >> 1
		state.players[0].metals = metals.slice(0, middle)
		if validator.validate(state, definitions, state.catalog_id).ok:
			low = middle
		else:
			high = middle
	state.players[0].metals = metals.slice(0, low)
	var candidate: Dictionary = state.duplicate(true)
	_grant_atium(candidate, "p1")
	_expect(not validator.validate(candidate, definitions, state.catalog_id).ok, "INI-05 el candidato supera el presupuesto técnico")
	var engine: Start = _engine()
	if _restore(engine, state, "INI-05 snapshot de entrada al límite técnico válido"):
		_reject_start(engine, "p1", _intent(state), "INI-05 candidato inválido conserva RNG, recompensa, recibos y cierre")


func _test_receipt_limit(initial: Dictionary) -> void:
	var state: Dictionary = initial.duplicate(true)
	state.players[0].training = 0
	state.players[0].burn_limit = 1
	state.revision = Validator.MAX_ITEMS
	var receipts: Dictionary = {}
	for index: int in range(1, Validator.MAX_ITEMS + 1):
		receipts["fixture_%d" % index] = {"canonical": "fixture_%d" % index, "revision_aplicada": index}
	state.authority.receipts["p1"] = receipts
	# El avance sin premio cabe en el snapshot. Sólo el recibo nuevo rebasa el límite.
	var before_receipt: Dictionary = state.duplicate(true)
	before_receipt.players[0].training = 1
	before_receipt.turn.phase = "libre"
	var definitions: Dictionary = CatalogValidator.new().validate(Fixtures.catalog()).cards
	_expect(Validator.new().validate(before_receipt, definitions, state.catalog_id).ok,
		"INI-05 el candidato de avance es válido antes de añadir recibo")
	var engine: Start = _engine()
	if _restore(engine, state, "INI-05 recibos existentes al límite admitido"):
		_expect(_reject_start(engine, "p1", _intent(state), "INI-05 fallo de validación del commit P07").codigo == "estado_invalido",
			"INI-05 el nuevo recibo rebasa el límite sin confirmar el avance")


func _engine(document: Dictionary = {}) -> Start:
	if document.is_empty():
		document = Fixtures.catalog()
	return Start.new(document, Fixtures.FUNDING_ID, FundingFixtures.inerts(document), Fixtures.training_profile(document))


func _prepare(engine: Start, count: int) -> bool:
	var result: Dictionary = engine.prepare_match(MATCH_ID, Fixtures.seats(count), "p2", Fixtures.manifest(), 12345)
	_expect(result.ok, "INI-01 preparar %d plazas: %s" % [count, result.get("errors", [])])
	return result.ok


func _source(engine: Start, state: Dictionary) -> Fixtures.LatestSource:
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	return source


func _restore(engine: Start, state: Dictionary, label: String) -> bool:
	var source: Fixtures.LatestSource = _source(engine, state)
	var result: Dictionary = engine.restore_match(MATCH_ID, source)
	_expect(result.ok and engine.get_authority_snapshot() == state, label + ": " + str(result.get("errors", [])))
	return result.ok


func _reject_restore(engine: Start, state: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var source: Fixtures.LatestSource = _source(engine, state)
	var result: Dictionary = engine.restore_match(MATCH_ID, source)
	_expect(not result.ok and engine.get_authority_snapshot() == before, label)


func _intent(state: Dictionary, id: String = "inicio_prueba") -> Dictionary:
	return {"version_accion": 1, "match_id": MATCH_ID, "action_id": id, "expected_revision": state.revision,
		"tipo": "iniciar_turno", "payload": {"turn_number": state.turn.number}}


func _funding(state: Dictionary, id: String = "jugar_prueba") -> Dictionary:
	return {"version_accion": 1, "match_id": MATCH_ID, "action_id": id, "expected_revision": state.revision,
		"tipo": "jugar_funding", "payload": {"instance_id": "c1", "aplicar": true}}


func _delivered(previous: Dictionary, actor: String) -> Dictionary:
	var state: Dictionary = previous.duplicate(true)
	state.turn.number += 1
	state.turn.active_id = actor
	state.turn.phase = "inicio"
	state.revision += 1
	return state


func _player(state: Dictionary, actor: String) -> Dictionary:
	for player: Dictionary in state.get("players", []):
		if player.player_id == actor:
			return player
	return {}


func _grant_atium(state: Dictionary, actor: String) -> void:
	var player: Dictionary = _player(state, actor)
	player.metals.append({"token_id": "token_atium_" + str(state.authority.next_id), "metal": "atium",
		"exhausted": false, "used_this_turn": false})
	player.persistent.atium += 1
	state.authority.next_id += 1


func _open_and_compare(engine: Start, actor: String, training: int, burn_limit: int, atium: bool, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var expected: Dictionary = before.duplicate(true)
	var player: Dictionary = _player(expected, actor)
	player.training = training
	player.burn_limit = burn_limit
	if atium:
		_grant_atium(expected, actor)
	expected.turn.phase = "libre"
	expected.revision += 1
	var id: String = "inicio_%d" % before.turn.number
	var result: Dictionary = engine.start_turn(actor, _intent(before, id))
	_expect(result.ok and result.get("revision_aplicada") == expected.revision, label + " confirma una revisión: " + str(result))
	if not result.ok:
		return
	var actual: Dictionary = engine.get_authority_snapshot()
	var receipts: Dictionary = actual.authority.receipts.get(actor, {})
	var added: Dictionary = receipts.get(id, {})
	_expect(added.get("revision_aplicada") == expected.revision and not added.get("canonical", "").is_empty(),
		label + " confirma el recibo por plaza e ID")
	receipts.erase(id)
	if receipts.is_empty() and not expected.authority.receipts.has(actor):
		actual.authority.receipts.erase(actor)
	_expect(actual == expected, label + " sólo modifica avance, recompensa, fase y commit P07")


func _repeat(engine: Start, actor: String, intent: Dictionary, receipt: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	_expect(receipt.ok and engine.start_turn(actor, intent) == receipt and engine.get_authority_snapshot() == before, label)


func _reject_start(engine: Start, actor: String, intent: Dictionary, label: String) -> Dictionary:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.start_turn(actor, intent)
	_expect(not result.ok and not result.has("revision_aplicada") and engine.get_authority_snapshot() == before, label)
	return result


func _reject_public(engine: Start, actor: String, intent: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, intent)
	_expect(not result.ok and not result.has("revision_aplicada") and engine.get_authority_snapshot() == before, label)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(label)
