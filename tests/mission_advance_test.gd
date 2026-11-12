extends SceneTree

const Fixtures = preload("res://tests/mission_advance_fixtures.gd")
const Play = preload("res://scripts/game/mission_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
var _checks: int = 0
var _failures: int = 0
var _catalog: Dictionary
var _advance: Advance


func _initialize() -> void:
	_catalog = Fixtures.catalog()
	_advance = Advance.new(Fixtures.descriptors(_catalog, true).merged(Fixtures.descriptors(_catalog, false)), Play.identity_for(_catalog), Fixtures.training_profile(_catalog))
	_test_exact_delta()
	_test_progress_and_rewards()
	_test_first_arrivals()
	_test_training()
	_test_terminals()
	_test_atomicity()
	_test_rejections()
	_test_catalog_and_restore()
	_test_privacy()
	if _failures == 0:
		print("P08_MISSION_ADVANCE_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _test_exact_delta() -> void:
	var state: Dictionary = _progress(_initial(), "p1", "mission_5", 3)
	var engine: Play = _loaded(state)
	var request: Dictionary = Fixtures.intent(state, "mission_5", "delta")
	_expect(engine.submit("p1", request).ok, "MIS-03 delta premiado aceptado")
	var actual: Dictionary = engine.get_authority_snapshot()
	var expected: Dictionary = state.duplicate(true)
	expected.revision += 1
	expected.players[0].turn_resources.mision -= 1
	expected.players[0].turn_resources.recursos += 2
	expected.missions.mission_5.progress.p1 = 4
	expected.missions.mission_5.first_arrivals.p04 = "p1"
	expected.missions.mission_5.rewards.p1 = ["p04_normal", "p04_primero"]
	# La codificación del recibo la verifica P07; aquí se comprueba su único alta.
	_expect(actual.authority.receipts.keys() == ["p1"] and actual.authority.receipts.p1.keys() == ["delta"], "MIS-03 sólo recibo de la intención")
	expected.authority.receipts = actual.authority.receipts.duplicate(true)
	_expect(actual == expected, "MIS-03 snapshot completo: no cambia ningún campo ajeno")


func _test_progress_and_rewards() -> void:
	for count: int in [2, 3, 4]:
		var state: Dictionary = _initial(count)
		var engine: Play = _loaded(state)
		_expect(engine.is_supported(), "MIS-01 perfil completo %d" % count)
		var original: Dictionary = state.duplicate(true)
		for position: int in range(1, 13):
			var before: Dictionary = engine.get_authority_snapshot()
			var intent: Dictionary = Fixtures.intent(before, "mission_5", "m5_%d" % position)
			var accepted: Dictionary = engine.submit("p1", intent)
			_expect(accepted.ok, "MIS-01 M5 paso %d" % position)
			state = engine.get_authority_snapshot()
			if not accepted.ok:
				break
			_expect(state.missions.mission_5.progress.p1 == position and state.players[0].turn_resources.mision == 36 - position, "MIS-01 pago exacto")
			_expect(state.missions.mission_5.first_arrivals["p%02d" % position] == "p1", "MIS-02 reservar primero")
			_expect(state.authority.rng_state == before.authority.rng_state, "MIS-03 sin RNG")
			_expect(engine.submit("p1", intent).ok and engine.get_authority_snapshot() == state, "MIS-03 duplicado exacto")
		_expect(state.players[0].turn_resources.recursos == original.players[0].turn_resources.recursos + 2, "M5 moneda normal y extra")
		_expect(state.players[0].turn_resources.ataque == original.players[0].turn_resources.ataque + 2, "M5 combate")
		_expect(state.players[0].health == 32, "M5 curación primero")
		_expect(state.players[0].persistent.atium == 3 and state.players[0].metals.size() == 4, "M5 dos fichas Atium")
		_expect(state.missions.mission_5.arrival_order == ["p1"] and state.lifecycle == "en_curso", "Una misión no gana")
		_reject_action(engine, "p1", Fixtures.intent(state, "mission_5", "finished"), "Desde cima no gastar")
		var split: Dictionary = _initial(count)
		split = _progress(split, "p1", "mission_5", 1)
		split = _progress(split, "p1", "mission_7", 1)
		_expect(split.players[0].turn_resources.mision == 34 and split.missions.mission_5.progress.p1 == 1 and split.missions.mission_7.progress.p1 == 1, "MIS-01 repartir puntos")


func _test_first_arrivals() -> void:
	var state: Dictionary = _initial(3)
	state = _progress(state, "p1", "mission_5", 4)
	var owner_gain: int = state.players[0].turn_resources.recursos
	state.turn.active_id = "p2"
	state = _progress(state, "p2", "mission_5", 12)
	_expect(state.players[1].turn_resources.recursos == 5, "MIS-02 segundo sólo moneda normal")
	_expect(state.missions.mission_5.first_arrivals.p04 == "p1" and state.missions.mission_5.first_arrivals.p12 == "p2", "MIS-02 primero intermedio distinto de cima")
	state.turn.active_id = "p3"
	state.players[0].health = 0
	state.players[0].eliminated = true
	state = _progress(state, "p3", "mission_5", 4)
	_expect(state.players[2].turn_resources.recursos == 5 and state.missions.mission_5.first_arrivals.p04 == "p1", "MIS-02 eliminado conserva primero")
	_expect(state.players[0].turn_resources.recursos == owner_gain and state.missions.mission_5.rewards.p1 == ["p04_normal", "p04_primero"], "MIS-02 conserva premios eliminado")
	var forged: Dictionary = state.duplicate(true)
	forged.missions.mission_5.first_arrivals.p04 = "p3"
	_expect(not _advance.state_error(forged).is_empty(), "MIS-02 no reasignar extra liquidado")


func _test_training() -> void:
	var state: Dictionary = _initial()
	state.players[0].training = 19
	state.players[0].burn_limit = 4
	state = _progress(state, "p1", "mission_6", 6)
	_expect(state.players[0].training == 20 and state.players[0].persistent.atium == 2, "M6 normal llega20 extra gana Atium")
	_expect(state.turn.phase == "libre" and state.turn.number == 3, "M6 no falsea inicio ni abre turno")
	state = _progress(state, "p1", "mission_6", 12)
	_expect(state.players[0].persistent.atium == 4 and state.lifecycle == "en_curso", "M6 dos avances de extremo; cuatro Atium no gana")
	_expect(state.missions.mission_6.rewards.p1 == ["p06_normal", "p06_primero", "p12_normal", "p12_primero"], "M6 grupos únicos")
	state = _initial()
	state = _progress(state, "p1", "mission_6", 6)
	_expect(state.players[0].training == 4 and state.players[0].burn_limit == 2, "M6 conserva recompensa quema")
	state = _initial()
	state.players[0].health = 39
	state = _progress(state, "p1", "mission_7", 12)
	_expect(state.players[0].health == 40, "M7 curación saturada y extra sin overflow")


func _test_terminals() -> void:
	for count: int in [2, 3, 4]:
		for last: int in [5, 6, 7]:
			var state: Dictionary = _initial(count)
			# Otra plaza puede llegar antes a una misión: no impide ganar las tres.
			state.turn.active_id = "p2"
			state = _progress(state, "p2", "mission_5", 12)
			state.turn.active_id = "p1"
			for number: int in [5, 6, 7]:
				if number != last:
					state = _progress(state, "p1", "mission_%d" % number, 12)
			state = _progress(state, "p1", "mission_%d" % last, 11)
			state.players[0].health = 10
			var before: Dictionary = state.duplicate(true)
			var engine: Play = _loaded(state)
			var intent: Dictionary = Fixtures.intent(state, "mission_%d" % last, "win")
			_expect(engine.submit("p1", intent).ok, "MIS-05 aceptar llegada terminal")
			state = engine.get_authority_snapshot()
			_expect(state.lifecycle == "finalizada" and state.turn.phase == "finalizada" and state.outcome == {"winner_id": "p1", "reason": "tres_misiones", "mission_id": "mission_%d" % last, "turn_number": 3}, "MIS-05 resultado exacto")
			_expect(state.players[0].health == 10 and state.players[0].training == before.players[0].training and state.players[0].metals == before.players[0].metals and state.authority.next_id == before.authority.next_id, "MIS-05 sin premio última cima")
			_expect(state.players[0].turn_resources.mision == 0 and state.resolution == null, "MIS-05 pago sin obligación futura")
			_expect(not "p12_normal" in state.missions["mission_%d" % last].rewards.p1, "MIS-05 no liquidar premio terminal")
			_expect(engine.submit("p1", intent).ok and engine.get_authority_snapshot() == state, "MIS-05 recibo terminal")
			var restored: Play = _loaded(state)
			_expect(restored.submit("p1", intent).ok and restored.get_authority_snapshot() == state, "MIS-05 restaurar recibo terminal")
			_reject_action(restored, "p1", Fixtures.intent(state, "mission_5", "after_win"), "MIS-05 nueva acción tras final")
			var false_result: Dictionary = state.duplicate(true)
			false_result.outcome.mission_id = "mission_6" if last != 6 else "mission_5"
			_expect(not _advance.state_error(false_result).is_empty(), "MIS-05 no omitir premios de otra cima")
			false_result = state.duplicate(true)
			false_result.outcome.winner_id = "p2"
			_expect(not _advance.state_error(false_result).is_empty(), "MIS-05 resultado falsificado")


func _test_atomicity() -> void:
	var state: Dictionary = _progress(_initial(), "p1", "mission_5", 3)
	state.players[0].turn_resources.recursos = Registry.MAX_INT - 1
	# Normal puede sumar, extra falla: ambos vuelven atrás junto al gasto.
	var engine: Play = _loaded(state)
	_reject_action(engine, "p1", Fixtures.intent(state, "mission_5", "overflow_extra"), "MIS-03 rollback después de premio normal")
	state = _progress(_initial(), "p1", "mission_5", 11)
	state.players[0].metals[1].token_id = "token_atium_%d" % (state.authority.next_id + 1)
	engine = _loaded(state)
	_reject_action(engine, "p1", Fixtures.intent(state, "mission_5", "collision"), "MIS-03 rollback segunda ficha")
	state.players[0].metals[1].token_id = "old_atium"
	state.authority.next_id = Registry.MAX_INT - 1
	engine = _loaded(state)
	_reject_action(engine, "p1", Fixtures.intent(state, "mission_5", "counter"), "MIS-03 overflow segundo ID")
	state = _initial()
	state.players[0].training = 19
	state.players[0].burn_limit = 4
	state = _progress(state, "p1", "mission_6", 5)
	state.players[0].metals[1].token_id = "token_atium_%d" % state.authority.next_id
	engine = _loaded(state)
	_reject_action(engine, "p1", Fixtures.intent(state, "mission_6", "training_fail"), "MIS-03 rollback Training normal cuando extra falla")
	var frozen: Dictionary = _initial()
	frozen.players[0].turn_resources.make_read_only()
	_expect(not _advance.advance(frozen, "p1", "mission_5").ok, "MIS-03 contenedor readonly sin error de script")
	var typed: Array[String] = []
	state = _initial()
	state.missions.mission_5.rewards.p1 = typed
	_expect(not _advance.advance(state, "p1", "mission_5").ok, "MIS-03 contenedor tipado rechazado antes de mutar")


func _test_rejections() -> void:
	var state: Dictionary = _initial()
	var engine: Play = _loaded(state)
	var intent: Dictionary = Fixtures.intent(state, "mission_5", "valid")
	var bad: Dictionary = intent.duplicate(true)
	bad.payload.position = 12
	_reject_action(engine, "p1", bad, "MIS-01 no aceptar posición cliente")
	bad = intent.duplicate(true)
	bad.payload.mission_id = "mision_m2"
	_reject_action(engine, "p1", bad, "MIS-01 misión ajena/no seleccionada")
	_reject_action(engine, "p2", intent, "MIS-01 fuera de turno")
	bad = intent.duplicate(true)
	bad.expected_revision += 1
	_reject_action(engine, "p1", bad, "MIS-03 revisión incorrecta")
	_expect(engine.submit("p1", intent).ok, "MIS-03 primer envío")
	state = engine.get_authority_snapshot()
	bad = intent.duplicate(true)
	bad.payload.mission_id = "mission_7"
	_reject_action(engine, "p1", bad, "MIS-03 ID reutilizado")
	_expect(engine.submit("p1", Fixtures.intent(state, "mission_5", "next")).ok, "MIS-03 ID nuevo permite paso siguiente")
	state = _initial()
	state.players[0].turn_resources.mision = 0
	engine = _loaded(state)
	_reject_action(engine, "p1", Fixtures.intent(state, "mission_5", "empty"), "MIS-01 reserva insuficiente")
	for mutation: Array in [["version_esquema", 2], ["mode", "cooperativo"], ["outcome", {}]]:
		state = _initial()
		state[mutation[0]] = mutation[1]
		_reject_restore(state, "MIS-06 esquema/modo/resultado")
	state = _initial()
	state.turn.phase = "inicio"
	_reject_restore(state, "MIS-01 fase incompatible")
	state = _initial()
	state.players[0].ability_uses = {"sense": 1}
	_reject_restore(state, "MIS-06 modificador desconocido")
	state = _initial()
	state.instances.c1.state.flags = {"keeper": true}
	_reject_restore(state, "MIS-06 obligación desconocida")
	state = _initial()
	state.missions.mission_5.rewards.p1 = ["p04_normal"]
	_reject_restore(state, "MIS-01 premio inventado")
	state = _initial()
	state.missions.mission_5.first_arrivals.p04 = "p2"
	_reject_restore(state, "MIS-01 primera llegada sin entrar")
	state = _initial()
	state.players[1].health = 0
	state.players[1].eliminated = true
	_reject_restore(state, "MIS-05 único superviviente fuera del perfil")


func _test_catalog_and_restore() -> void:
	var catalog: Dictionary = _catalog.duplicate(true)
	var missions: Dictionary = Fixtures.descriptors(catalog, true)
	missions.mision_m5.rasgos.recorridos[0].casillas[3].efectos[0].cantidad = 99
	var engine: Play = Play.new(catalog, Fixtures.descriptors(catalog, false), Fixtures.training_profile(catalog), missions)
	_expect(not engine.is_supported(), "MIS-06 descriptor cambiado")
	catalog = _catalog.duplicate(true)
	for card: Dictionary in catalog.cartas:
		if card.id == "mision_m5":
			card.rasgos.recorridos[0].casillas[3].efectos[0].cantidad = 99
	engine = Fixtures.engine(catalog)
	_expect(not engine.is_supported(), "MIS-06 efecto no soportado aunque descriptor coincida")
	catalog = _catalog.duplicate(true)
	for card: Dictionary in catalog.cartas:
		if card.id == "test_action":
			card.nombre += " distinta"
	engine = Fixtures.engine(catalog)
	_expect(engine.is_supported() and engine.catalog_identity() != Play.identity_for(_catalog), "MIS-06 identidad completa")
	_reject_restore(_initial(), "MIS-06 catálogo cambiado bajo mismo ID", engine)
	var json_catalog: Dictionary = JSON.parse_string(JSON.stringify(_catalog))
	_expect(Fixtures.engine(json_catalog).catalog_identity() == Play.identity_for(_catalog), "MIS-06 números JSON integrales")
	engine = Fixtures.engine(_catalog)
	var state: Dictionary = _initial()
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	_expect(not engine.load_authority_snapshot(state).ok and not engine.restore_match(state.match_id, {}).ok, "MIS-06 no carga libre/cliente")
	_expect(engine.restore_match(state.match_id, source).ok, "MIS-06 fuente tipada")
	var intent: Dictionary = Fixtures.intent(state, "mission_5", "confirm")
	_expect(engine.submit("p1", intent).ok, "MIS-06 confirmar avance")
	state = engine.get_authority_snapshot()
	source.confirm(engine.profile_identity(), state)
	_expect(source.select(state.match_id, engine.profile_identity(), 0).is_empty(), "MIS-06 fuente rechaza copia antigua")
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot() == state, "MIS-06 no reemplazar motor cargado")
	var fresh: Play = Fixtures.engine(_catalog)
	_expect(fresh.restore_match(state.match_id, source).ok and fresh.get_authority_snapshot() == state, "MIS-06 restaurar último confirmado")
	_expect(fresh.submit("p1", intent).ok and fresh.get_authority_snapshot() == state, "MIS-03 recibo restaurado")


func _test_privacy() -> void:
	var state: Dictionary = _initial()
	var engine: Play = _loaded(state)
	var view: Dictionary = engine.get_view("p2")
	_expect(not view.has("authority") and not view.has("instances") and view.has("outcome"), "MIS-06 proyección whitelist")
	_expect(not view.zones.p1_mano.has("cards") and not view.zones.p1_mazo.has("cards"), "MIS-06 mano/mazo privados")
	var different: Dictionary = state.duplicate(true)
	different.instances.c2.definition_id = "test_ally"
	different.authority.rng_state += 1
	var other: Play = _loaded(different)
	_expect(other.get_view("p2") == view, "MIS-06 secretos distintos misma vista ajena")
	view.missions.mission_5.first_arrivals.p01 = "p2"
	_expect(engine.get_authority_snapshot() == state, "MIS-06 vista no muta autoridad")


func _initial(count: int = 2) -> Dictionary:
	return Fixtures.snapshot(Play.identity_for(_catalog), count)


func _progress(state: Dictionary, actor_id: String, mission_id: String, target: int) -> Dictionary:
	while state.missions[mission_id].progress[actor_id] < target:
		var result: Dictionary = _advance.advance(state, actor_id, mission_id)
		_expect(result.ok, "Fixture avance automático " + mission_id)
		if not result.ok:
			return state
		state = result.candidate
	return state


func _loaded(state: Dictionary) -> Play:
	var engine: Play = Fixtures.engine(_catalog)
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	_expect(engine.restore_match(state.match_id, source).ok, "MIS-06 admitir estado de fixture coherente")
	return engine


func _reject_action(engine: Play, actor_id: String, intent: Dictionary, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	_expect(not engine.submit(actor_id, intent).ok and engine.get_authority_snapshot() == before, label)


func _reject_restore(state: Dictionary, label: String, engine: Play = null) -> void:
	if engine == null:
		engine = Fixtures.engine(_catalog)
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot().is_empty(), label)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(label)
