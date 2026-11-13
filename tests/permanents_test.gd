extends SceneTree

const Fixtures = preload("res://tests/permanents_fixtures.gd")
const Missions = preload("res://tests/mission_advance_fixtures.gd")
const Play = preload("res://scripts/game/permanents_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Validator = preload("res://scripts/game/state_validator.gd")


class RejectAfterDraw extends Play:
	var injected: bool = true
	var reached: bool = false
	var changed_rng: bool = false

	func _init(catalog: Dictionary, inerts: Dictionary, training: Dictionary, missions: Dictionary) -> void:
		super(catalog, inerts, training, missions)

	func _advance_action(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
		var before_rng: int = rng.state
		var error: String = super._advance_action(candidate, actor_id, payload, rng)
		if error.is_empty():
			reached = true
			changed_rng = rng.state != before_rng
			return "estado_invalido" if injected else ""
		return error

	func _cleanup(candidate: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
		var before_rng: int = rng.state
		var error: String = super._cleanup(candidate, actor_id, payload, rng)
		if error.is_empty():
			reached = true
			changed_rng = rng.state != before_rng
			return "estado_invalido" if injected else ""
		return error


var _checks: int = 0
var _failures: int = 0
var _advance: Advance


func _initialize() -> void:
	var catalog: Dictionary = Missions.catalog()
	_advance = Advance.new(Missions.descriptors(catalog, true).merged(Missions.descriptors(catalog, false)), Play.identity_for(catalog), Missions.training_profile(catalog), true)
	var initial_error: String = _advance.state_error(Fixtures.snapshot())
	if not initial_error.is_empty():
		push_error("Fixture inicial incompatible: " + initial_error)
		quit(1)
		return
	for count: int in [2, 3, 4]:
		_arrivals(count)
		_starts(count)
		_cleanup(count)
		_terminals(count)
	_failures_and_origin()
	_postdraw_rollback()
	_privacy()
	if _failures == 0:
		print("P08_PERMANENTS_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _arrivals(count: int) -> void:
	var state: Dictionary = Fixtures.snapshot(count)
	var start: Dictionary = state.duplicate(true)
	state = _progress(state, "mission_3", 11)
	_expect(state.players[0].turn_resources.recursos == start.players[0].turn_resources.recursos + 8, "PERM-01 M3 intermedios normal antes extra")
	var engine: Play = _loaded(state)
	var request: Dictionary = _mission(state, "mission_3", "top3")
	_expect(engine.submit("p1", request).ok, "PERM-01 M3 cima primera")
	state = engine.get_authority_snapshot()
	_expect(state.players[0].turn_resources.recursos == start.players[0].turn_resources.recursos + 13, "PERM-01 cima suma5 sobre reserva")
	_expect(state.players[0].persistent.boxings == 3 and state.authority.mission_permanents == {"mission_3": {"p1": {"acquired_turn": 3, "last_applied_turn": 3}}}, "PERM-01 marca atómica y Boxings")
	_expect(engine.submit("p1", request).ok and engine.get_authority_snapshot() == state, "PERM-01 reenvío llegada")
	state.turn.number += 1
	state.turn.active_id = "p2"
	state = _progress(state, "mission_3", 12, "p2")
	_expect(state.players[1].turn_resources.recursos == 10 and state.missions.mission_3.arrival_order == ["p1", "p2"], "PERM-01 segunda llegada M3 sólo2 e intermedios4")
	state = Fixtures.snapshot(count)
	Fixtures.cards(state, 12, "p1_descarte")
	var rng_before: int = state.authority.rng_state
	state = _progress(state, "mission_4", 12)
	_expect(state.zones.p1_mano.cards.size() == 6 and state.authority.rng_state != rng_before, "PERM-01 M4 intermedios4 cima2 con reciclado")
	_expect(state.missions.mission_4.rewards.p1 == ["p04_normal", "p04_primero", "p08_normal", "p08_primero", "p12_permanente", "p12_primero"] and state.authority.mission_permanents.is_empty(), "PERM-01 instalación no roba ni marca M4")
	state.turn.number += 1
	state.turn.active_id = "p2"
	state = _progress(state, "mission_4", 12, "p2")
	_expect(state.missions.mission_4.rewards.p2 == ["p04_normal", "p08_normal", "p12_permanente"] and state.zones.p2_mano.cards.is_empty(), "PERM-01 segundo instala sin extra; robo corto")


func _starts(count: int) -> void:
	for owned: bool in [false, true]:
		var state: Dictionary = Fixtures.snapshot(count)
		if owned:
			state = _progress(state, "mission_3", 12)
		state.turn.number += count
		state.turn.phase = "inicio"
		var before: Dictionary = state.duplicate(true)
		var engine: Play = _loaded(state)
		var request: Dictionary = _internal(state, "inicio_unico", "iniciar_turno")
		_expect(engine.start_turn("p1", request).ok, "PERM-02 inicio atómico")
		state = engine.get_authority_snapshot()
		_expect(state.turn.phase == "libre" and state.players[0].training == before.players[0].training + 1 and state.players[0].burn_limit == 2, "PERM-02 exactamente un entrenamiento")
		_expect(state.players[0].turn_resources.recursos == before.players[0].turn_resources.recursos + (2 if owned else 0), "PERM-02 +2 antes de libre")
		_expect(state.players.slice(1) == before.players.slice(1), "PERM-02 plazas ajenas intactas")
		if owned:
			_expect(state.authority.mission_permanents.mission_3.p1 == {"acquired_turn": 3, "last_applied_turn": 3 + count}, "PERM-02 preserva adquisición y marca inicio")
		_expect(engine.start_turn("p1", request).ok and engine.get_authority_snapshot() == state, "PERM-02 reenvío sin duplicar")
		var restored: Play = _loaded(state)
		_expect(restored.start_turn("p1", request).ok and restored.get_authority_snapshot() == state, "PERM-02 recibo restaurado")
		_reject(restored, _internal(state, "inicio_otro", "iniciar_turno"), "start", "PERM-02 nuevo ID no repite")
		state.turn.number += count
		state.turn.phase = "inicio"
		engine = _loaded(state)
		_reject(engine, _internal(before, "inicio_antiguo", "iniciar_turno"), "start", "PERM-02 petición antigua al volver plaza")
		_expect(engine.start_turn("p1", _internal(state, "inicio_vuelta", "iniciar_turno")).ok, "PERM-02 regreso posterior")
		var after: Dictionary = engine.get_authority_snapshot()
		_expect(after.players[0].training == state.players[0].training + 1 and after.players[0].turn_resources.recursos == state.players[0].turn_resources.recursos + (2 if owned else 0), "PERM-02 vuelta un paso y beneficio")


func _cleanup(count: int) -> void:
	for owned: bool in [false, true]:
		for total: int in [0, 3, 5, 6, 10]:
			for zone: String in ["p1_mazo", "p1_descarte"]:
				var state: Dictionary = Fixtures.snapshot(count)
				if owned:
					state = _progress(state, "mission_4", 12)
				state = _progress(state, "mission_3", 12)
				Fixtures.cards(state, total, zone)
				state.turn.phase = "limpieza"
				state.players[0].metals[1].used_this_turn = true
				state.players[0].metals[0].exhausted = true
				var before: Dictionary = state.duplicate(true)
				var engine: Play = _loaded(state)
				var request: Dictionary = _internal(state, "limpieza_unica", "cerrar_limpieza")
				_expect(engine.finish_cleanup("p1", request).ok, "PERM-03 cierre5/6")
				state = engine.get_authority_snapshot()
				_expect(state.zones.p1_mano.cards.size() == mini(total, 6 if owned else 5), "PERM-03 una solicitud exacta sin deuda")
				_expect((state.authority.rng_state != before.authority.rng_state) == (zone == "p1_descarte" and total > 1), "PERM-03 RNG sólo baraja")
				_expect(state.turn == {"number": 4, "active_id": "p2", "phase": "inicio", "counters": {}} and state.players[0].turn_resources == {"recursos": 0, "ataque": 0, "mision": 0}, "PERM-03 entrega sin reponer monedas")
				_expect(state.authority.mission_permanents == before.authority.mission_permanents and state.players[0].persistent == {"atium": 0, "boxings": 3}, "PERM-03 ledger intacto devolución Atium única")
				_expect(engine.finish_cleanup("p1", request).ok and engine.get_authority_snapshot() == state, "PERM-03 reenvío cierre")
				var restored: Play = _loaded(state)
				_expect(restored.finish_cleanup("p1", request).ok and restored.get_authority_snapshot() == state, "PERM-03 cierre restaurado")
				_reject(restored, _internal(state, "limpieza_nueva", "cerrar_limpieza"), "cleanup", "PERM-03 ocurrencia consumida")
	# Eliminado conserva su marca y se salta en la entrega.
	if count > 2:
		var state: Dictionary = Fixtures.snapshot(count)
		state.turn.active_id = "p2"
		state = _progress(state, "mission_3", 12, "p2")
		state.players[1].health = 0
		state.players[1].eliminated = true
		state.turn.active_id = "p1"
		state.turn.phase = "limpieza"
		var engine: Play = _loaded(state)
		_expect(engine.finish_cleanup("p1", _internal(state, "limpieza_skip", "cerrar_limpieza")).ok, "PERM-05 cierre salta eliminado")
		var after: Dictionary = engine.get_authority_snapshot()
		_expect(after.turn.active_id == "p3" and after.authority.mission_permanents == state.authority.mission_permanents, "PERM-05 conserva ledger eliminado")


func _terminals(count: int) -> void:
	for last: String in ["mission_3", "mission_4"]:
		var state: Dictionary = Fixtures.snapshot(count)
		for mission: String in ["mission_3", "mission_4", "mission_7"]:
			state = _progress(state, mission, 11 if mission == last else 12)
		Fixtures.cards(state, 10, "p1_descarte")
		var before: Dictionary = state.duplicate(true)
		var engine: Play = _loaded(state)
		var request: Dictionary = _mission(state, last, "winning")
		_expect(engine.submit("p1", request).ok, "PERM-05 tercera cima terminal")
		state = engine.get_authority_snapshot()
		_expect(state.lifecycle == "finalizada" and state.outcome.mission_id == last and state.missions[last].arrival_order == ["p1"], "PERM-05 llegada y outcome primero")
		_expect(state.authority.mission_permanents == before.authority.mission_permanents and state.authority.rng_state == before.authority.rng_state and state.zones == before.zones, "PERM-05 sin marca ni robo final")
		_expect(state.players[0].turn_resources.recursos == before.players[0].turn_resources.recursos and not "p12_permanente" in state.missions[last].rewards.p1, "PERM-05 sin instalación ni monedas final")
		_expect(engine.submit("p1", request).ok and engine.get_authority_snapshot() == state, "PERM-05 reintento ganador")
		_reject(engine, _internal(state, "inicio_final", "iniciar_turno"), "start", "PERM-05 no inicio final")
		_reject(engine, _internal(state, "limpieza_final", "cerrar_limpieza"), "cleanup", "PERM-05 no limpieza final")


func _failures_and_origin() -> void:
	for reserve: int in [Registry.MAX_INT - 1, Registry.MAX_INT - 3]:
		var state: Dictionary = _progress(Fixtures.snapshot(), "mission_3", 11)
		state.players[0].turn_resources.recursos = reserve
		_reject(_loaded(state), _mission(state, "mission_3", "overflow_top"), "submit", "PERM-04 rollback +2 o +3")
	var state: Dictionary = _progress(Fixtures.snapshot(), "mission_3", 12)
	state.turn.number += 2
	state.turn.phase = "inicio"
	state.players[0].turn_resources.recursos = Registry.MAX_INT
	_reject(_loaded(state), _internal(state, "inicio_overflow", "iniciar_turno"), "start", "PERM-04 rollback tras entrenamiento")
	state.players[0].turn_resources.recursos = 0
	state.players[0].training = 10
	state.players[0].burn_limit = 3
	state.players[0].metals[1].token_id = "token_atium_%d" % state.authority.next_id
	_reject(_loaded(state), _internal(state, "inicio_collision", "iniciar_turno"), "start", "PERM-04 fallo recompensa entrenamiento")
	for phase: String in ["inicio", "limpieza", "libre"]:
		state = Fixtures.snapshot()
		state.turn.phase = phase
		state.revision = Registry.MAX_INT
		var request: Dictionary = _mission(state, "mission_4", "max_revision") if phase == "libre" else _internal(state, "inicio_max" if phase == "inicio" else "limpieza_max", "iniciar_turno" if phase == "inicio" else "cerrar_limpieza")
		_reject(_loaded(state), request, "submit" if phase == "libre" else ("start" if phase == "inicio" else "cleanup"), "PERM-04 revisión agotada")
	state = _progress(Fixtures.snapshot(), "mission_3", 12)
	for mutation: String in ["missing", "future", "extra", "orphan", "m4", "partial", "version", "flags", "single"]:
		var bad: Dictionary = state.duplicate(true)
		match mutation:
			"missing": bad.authority.mission_permanents.clear()
			"future": bad.authority.mission_permanents.mission_3.p1.last_applied_turn += 1
			"extra": bad.authority.mission_permanents.mission_3.p1.extra = 1
			"orphan": bad.authority.mission_permanents.mission_3.p2 = {"acquired_turn": 1, "last_applied_turn": 2}
			"m4": bad.authority.mission_permanents.mission_4 = bad.authority.mission_permanents.mission_3.duplicate(true)
			"partial": bad.turn.phase = "inicio"
			"version": bad.version_esquema = 3
			"flags": bad.instances.c1.state.flags = {"unknown": true}
			"single":
				bad.players[1].health = 0
				bad.players[1].eliminated = true
		_reject_restore(bad, "PERM-04 origen/marca " + mutation)
	var engine: Play = _loaded(state)
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot() == state, "PERM-04 motor ocupado no reemplazable")
	_expect(not engine.load_authority_snapshot(state).ok, "PERM-04 no carga libre")
	var wrong: Play = Fixtures.engine()
	source = Fixtures.LatestSource.new()
	source.confirm("wrong_profile", state)
	_expect(not wrong.restore_match(state.match_id, source).ok, "PERM-04 perfil distinto")
	state = Fixtures.snapshot()
	engine = _loaded(state)
	for kind: String in ["iniciar_turno", "cerrar_limpieza", "cobrar_permanente"]:
		_reject(engine, _internal(state, "inicio_publico" if kind == "iniciar_turno" else "limpieza_publica", kind), "submit", "PERM-06 entrada pública reservada")
	var request: Dictionary = _mission(state, "mission_3", "extra_payload")
	request.payload.last_applied_turn = 3
	_reject(engine, request, "submit", "PERM-06 cliente no aporta marca")
	state.turn.phase = "inicio"
	engine = _loaded(state)
	request = _internal(state, "inicio_race_a", "iniciar_turno")
	var second: Dictionary = _internal(state, "inicio_race_b", "iniciar_turno")
	_expect(engine.start_turn("p1", request).ok, "PERM-06 primera solicitud serializada")
	_reject(engine, second, "start", "PERM-06 segunda igual revisión no aplica")
	request.payload.turn_number += 1
	_reject(engine, request, "start", "PERM-06 ID reutilizado distinto contenido")
	# El catálogo completo se inspecciona, aunque la carta peligrosa esté eliminada.
	var catalog: Dictionary = Missions.catalog()
	for card: Dictionary in catalog.cartas:
		if card.id == "test_action":
			card.habilidades = [{"id": "danger", "efectos": [{"op": "robar", "cantidad": 1, "objetivo": "propio"}]}]
	_expect(not Fixtures.engine(catalog).is_supported(), "PERM-04 catálogo con obligaciones no admitido")


func _postdraw_rollback() -> void:
	for count: int in [2, 3, 4]:
		for closing: bool in [false, true]:
			var state: Dictionary = _progress(Fixtures.snapshot(count), "mission_4", 12 if closing else 11)
			Fixtures.cards(state, 10, "p1_descarte")
			if closing:
				state.turn.phase = "limpieza"
				state.players[0].metals[1].used_this_turn = true
				state.players[0].metals[0].exhausted = true
			var catalog: Dictionary = Missions.catalog()
			var engine: RejectAfterDraw = RejectAfterDraw.new(catalog, Missions.descriptors(catalog, false), Missions.training_profile(catalog), Missions.descriptors(catalog, true))
			var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
			source.confirm(engine.profile_identity(), state)
			_expect(engine.restore_match(state.match_id, source).ok, "PERM-04 fuente del doble de fallo")
			var request: Dictionary = _internal(state, "limpieza_postdraw", "cerrar_limpieza") if closing else _mission(state, "mission_4", "postdraw")
			_reject(engine, request, "cleanup" if closing else "submit", "PERM-04 rollback total después de robo/reciclado real")
			_expect(engine.reached and engine.changed_rng, "PERM-04 fallo ocurre después de cambiar RNG")
			engine.injected = false
			var accepted: Dictionary = engine.finish_cleanup("p1", request) if closing else engine.submit("p1", request)
			_expect(accepted.ok and engine.get_authority_snapshot().revision == state.revision + 1, "PERM-04 mismo ID tras rechazo confirma una vez")
			var committed: Dictionary = engine.get_authority_snapshot()
			source.confirm(engine.profile_identity(), committed)
			source.confirm(engine.profile_identity(), state)
			var restored: Play = Fixtures.engine()
			_expect(restored.restore_match(state.match_id, source).ok and restored.get_authority_snapshot() == committed, "PERM-04 fuente no sustituye último por precommit")
			if closing:
				_reject(restored, request, "submit", "PERM-06 cierre público rechaza antes de recibo")
			else:
				_expect(restored.submit("p1", request).ok and restored.get_authority_snapshot() == committed, "PERM-04 recibo después de rollback y restauración")


func _privacy() -> void:
	var state: Dictionary = Fixtures.snapshot(3)
	Fixtures.cards(state, 12, "p1_descarte")
	state = _progress(state, "mission_3", 12)
	state = _progress(state, "mission_4", 11)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", _mission(state, "mission_4", "private_draw")).ok, "PERM-06 robo de autoridad")
	state = engine.get_authority_snapshot()
	for current: Play in [engine, _loaded(state)]:
		var own: Dictionary = current.get_view("p1")
		var other: Dictionary = current.get_view("p2")
		_expect(not own.has("authority") and not other.has("authority") and not other.has("instances"), "PERM-06 ledger/recibos/RNG privados")
		_expect(own.zones.p1_mano.has("cards") and not other.zones.p1_mano.has("cards") and not own.zones.p1_mazo.has("cards"), "PERM-06 cartas privadas sólo propietario")
		_expect(other.missions.mission_3.rewards.p1.has("p12_permanente"), "PERM-06 progreso y premios públicos")
	state.turn.phase = "limpieza"
	engine = _loaded(state)
	_reject(engine, _mission(state, "mission_7", "no_skip"), "submit", "PERM-06 no avance fuera libre")


func _progress(state: Dictionary, mission: String, target: int, actor: String = "p1") -> Dictionary:
	while state.missions[mission].progress[actor] < target:
		var result: Dictionary = _advance.advance(state, actor, mission)
		_expect(result.ok, "Fixture progreso " + mission)
		if not result.ok:
			return state
		state = result.candidate
	return state


func _loaded(state: Dictionary) -> Play:
	var engine: Play = Fixtures.engine()
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var restored: Dictionary = engine.restore_match(state.match_id, source)
	if not restored.ok:
		var validation: Dictionary = Validator.new().validate(state, _advance._definitions, _advance._catalog_id)
		push_error("Diagnóstico fixture: " + str(validation.errors) + "; perfil=" + engine._advance.state_error(state))
	_expect(restored.ok, "Fixture fuente confirmada")
	return engine


func _reject_restore(state: Dictionary, label: String) -> void:
	var engine: Play = Fixtures.engine()
	var source: Fixtures.LatestSource = Fixtures.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot().is_empty(), label)


func _mission(state: Dictionary, mission: String, action_id: String) -> Dictionary:
	return Fixtures.intent(state, action_id, "avanzar_mision", {"mission_id": mission})


func _internal(state: Dictionary, action_id: String, kind: String) -> Dictionary:
	return Fixtures.intent(state, action_id, kind, {"turn_number": state.turn.number})


func _reject(engine: Play, request: Dictionary, path: String, label: String) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary
	match path:
		"start": result = engine.start_turn("p1", request)
		"cleanup": result = engine.finish_cleanup("p1", request)
		_: result = engine.submit("p1", request)
	_expect(not result.ok and engine.get_authority_snapshot() == before, label)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(label)
