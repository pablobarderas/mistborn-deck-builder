extends SceneTree

const F = preload("res://tests/m2_fixtures.gd")
const Play = preload("res://scripts/game/m2_play.gd")
const Core = preload("res://scripts/game/game_engine.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Resolver = preload("res://scripts/game/sequence_resolver.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const M1 = preload("res://tests/m1_fixtures.gd")
const M8 = preload("res://tests/m8_fixtures.gd")
const Permanents = preload("res://tests/permanents_fixtures.gd")
static var fault_reached: bool = false
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_expect(F.engine().is_supported(), "perfil M2 cerrado")
	if _failures > 0:
		quit(1)
		return
	for count: int in [2, 3, 4]:
		print("M2_STAGE: arrivals/%d" % count)
		_arrivals(count)
		print("M2_STAGE: targets/%d" % count)
		_targets_and_privacy(count)
		print("M2_STAGE: starts/%d" % count)
		_summits_and_starts(count)
		print("M2_STAGE: terminal/%d" % count)
		_terminal(count)
		print("M2_STAGE: restore/%d" % count)
		_restoration(count)
		print("M2_STAGE: rollback/%d" % count)
		_rollback(count)
	print("M2_STAGE: budgets")
	_budgets()
	print("M2_STAGE: view")
	_view_budget()
	print("M2_STAGE: admission")
	_admission()
	if _failures == 0:
		print("P08_M2_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("M2_FAIL: " + label)


func _loaded(state: Dictionary) -> Play:
	var engine: Play = F.engine()
	var source = F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var result: Dictionary = engine.restore_match(state.match_id, source)
	_expect(result.ok, "carga fiable " + str(result.get("errors", [])))
	return engine


func _bad_load(state: Dictionary, label: String) -> void:
	var engine: Play = F.engine()
	var source = F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var before: Dictionary = state.duplicate(true)
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot().is_empty() and state == before, "carga rechazada sin mutar " + label)


func _reject(engine: Core, actor: String, action: Dictionary, code: String = "") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, action)
	_expect(not result.ok and (code.is_empty() or result.codigo == code), "rechazo " + code + " " + str(result))
	_expect(engine.get_authority_snapshot() == before, "rechazo conserva estado/recibos/ledger/ids/RNG")


func _arrivals(count: int) -> void:
	for position: int in [4, 7, 10]:
		for first: bool in [true, false]:
			for amount: int in [0, 1, 3]:
				var state: Dictionary = F.snapshot(count)
				F.allies(state, amount, "p2")
				if not first:
					F.at(state, position, "p2")
				F.at(state, position - 1)
				var engine: Play = _loaded(state)
				var action: Dictionary = F.advance(state)
				_expect(engine.submit("p1", action).ok, "M2-01 llegada %d/%d primera=%s N=%d" % [count, position, first, amount])
				var arrived: Dictionary = engine.get_authority_snapshot()
				_expect(arrived.missions.mission_2.progress.p1 == position and arrived.players[0].turn_resources.mision == state.players[0].turn_resources.mision - 1, "gasto y llegada únicos")
				_expect(arrived.players[0].turn_resources.ataque == state.players[0].turn_resources.ataque + [4, 7, 10].find(position) + 1 and arrived.players[0].turn_resources.recursos == state.players[0].turn_resources.recursos, "normal concede ataque conserva monedas")
				_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == arrived, "reenvío llegada")
				if first and amount > 0:
					var view: Dictionary = engine.get_view("p1")
					_expect(arrived.resolution.cursor == 1 and view.resolution.step_id == "s02" and view.resolution.min == 1 and view.resolution.max == 1, "normal confirmado y elección obligatoria incluso uno")
					_reject(engine, "p1", F.respond(view, [], "omit"), "eleccion_invalida")
					var chosen: Dictionary = view.resolution.option_allies[-1]
					var response: Dictionary = F.respond(view, [chosen.option_id])
					_expect(engine.submit("p1", response).ok, "M2-03 derrota directa")
					var closed: Dictionary = engine.get_authority_snapshot()
					_expect(closed.zones.p2_descarte.cards[-1] == chosen.instance_id and chosen.instance_id not in closed.zones.p2_juego.cards and closed.instances == state.instances, "traslado al propietario sin cambio identidad")
					_expect(closed.players == arrived.players and closed.authority.rng_state == state.authority.rng_state, "sin coste defensa daño ni RNG")
					_expect(engine.submit("p1", response).ok and engine.get_authority_snapshot() == closed, "reenvío respuesta")
					_reject(engine, "p1", F.respond(view, [chosen.option_id], "new_answer"), "revision_obsoleta")
				var final_state: Dictionary = engine.get_authority_snapshot()
				_expect(final_state.resolution == null and final_state.authority.completed_sequences.size() == state.authority.completed_sequences.size() + (1 if first else 0), "cierre ledger primera incluso vacío; posterior directa")
				_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == final_state, "reenvío llegada cerrada")
				var restored: Play = _loaded(final_state)
				_expect(restored.get_authority_snapshot() == final_state, "carga cierre automático sin reaplicar")


func _targets_and_privacy(count: int) -> void:
	var state: Dictionary = F.snapshot(count)
	F.at(state, 3)
	for owner: String in state.player_order:
		F.allies(state, 2, owner)
		F.allies(state, 1, owner, "mano")
		F.allies(state, 1, owner, "descarte")
		F.allies(state, 1, owner, "mazo")
	state.instances.c1.definition_id = "test_action"
	state.zones.p1_mano.cards.erase("c1")
	state.zones.p1_juego.cards.push_front("c1")
	# El orden de almacenamiento de plazas no gobierna la oferta.
	state.players.reverse()
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "oferta de todos los propietarios")
	var view: Dictionary = engine.get_view("p1")
	_expect(view.resolution.option_allies.size() == count * 2, "sólo aliados en juego")
	for index: int in count * 2:
		var option: Dictionary = view.resolution.option_allies[index]
		_expect(Registry.exact_keys(option, ["option_id", "instance_id", "definition_id", "owner_id", "zone_id"]) and option.owner_id == state.player_order[index / 2] and option.instance_id.ends_with("%05d" % (index % 2)), "oferta orden player_order y zona")
	var foreign: Dictionary = engine.get_view("p2")
	_expect(not foreign.resolution.has("options") and not foreign.resolution.has("option_allies") and not foreign.has("authority") and not foreign.has("instances"), "tercero sin opciones ni secretos")
	for selected: Array in [["bogus"], [view.resolution.options[0], view.resolution.options[0]], ["p1_juego_ally_00000"]]:
		_reject(engine, "p1", F.respond(view, selected, "invalid"), "eleccion_invalida")
	_reject(engine, "p2", F.respond(view, [view.resolution.options[0]], "foreign"), "eleccion_invalida")
	var extra: Dictionary = F.respond(view, [view.resolution.options[0]], "extra")
	extra.payload["owner_id"] = "p2"
	_reject(engine, "p1", extra, "eleccion_invalida")
	for field: String in ["step_id", "resolution_id"]:
		var wrong: Dictionary = F.respond(view, [view.resolution.options[0]], "wrong")
		wrong.payload[field] = "old"
		_reject(engine, "p1", wrong, "eleccion_invalida")
	var target: Dictionary = view.resolution.option_allies[-1]
	_expect(engine.submit("p1", F.respond(view, [target.option_id])).ok, "objetivo rival posterior")
	var after: Dictionary = engine.get_view("p1")
	var discard: Dictionary = after.zones[target.owner_id + "_descarte"]
	_expect(not discard.has("cards") and discard.count == 2 and after.resolution == null, "descarte rival sólo conteo al cerrar")
	state = F.snapshot(count)
	F.at(state, 3)
	F.allies(state, 1)
	engine = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "aliado propio objetivo")
	view = engine.get_view("p1")
	_expect(engine.submit("p1", F.respond(view, view.resolution.options)).ok and engine.get_authority_snapshot().zones.p1_descarte.cards == ["p1_juego_ally_00000"], "derrota propio al descarte propio")
	if count >= 3:
		state = F.snapshot(count)
		F.at(state, 3)
		F.allies(state, 2, "p2")
		state.players[1].health = 0
		state.players[1].eliminated = true
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok and engine.get_authority_snapshot().resolution == null and engine.get_authority_snapshot().zones.p2_juego.cards.size() == 2, "aliados de eliminada excluidos sin deuda")


func _summits_and_starts(count: int) -> void:
	for first: bool in [true, false]:
		var state: Dictionary = F.snapshot(count)
		if not first:
			F.at(state, 12, "p2")
		F.at(state, 11)
		var engine: Play = _loaded(state)
		var action: Dictionary = F.advance(state)
		_expect(engine.submit("p1", action).ok, "cima no terminal")
		var acquired: Dictionary = engine.get_authority_snapshot()
		_expect(acquired.resolution == null and acquired.players[0].turn_resources.ataque == state.players[0].turn_resources.ataque + (3 if first else 2) and acquired.players[0].turn_resources.recursos == state.players[0].turn_resources.recursos, "M2-04 permanente ataque inmediato y extra")
		_expect(acquired.authority.mission_permanents.mission_2.p1 == {"acquired_turn": state.turn.number, "last_applied_turn": state.turn.number}, "adquisición y marca juntas")
		_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == acquired, "cima reenvío no duplica")
		engine = _loaded(acquired)
		_reject(engine, "p1", F.intent(acquired, "inicio_4", "iniciar_turno", {"turn_number": 4}), "accion_no_soportada")
		# Fuente de autoridad fixture acredita entrega previa; no existe setter público.
		var later: Dictionary = acquired.duplicate(true)
		later.turn.number += count
		later.turn.phase = "inicio"
		later.revision += count
		later.players[0].turn_resources = {"recursos": 0, "ataque": 0, "mision": 0}
		engine = _loaded(later)
		var start: Dictionary = F.intent(later, "inicio_" + str(later.turn.number), "iniciar_turno", {"turn_number": later.turn.number})
		_expect(engine.start_turn("p1", start).ok, "inicio fiable atómico")
		var started: Dictionary = engine.get_authority_snapshot()
		_expect(started.turn.phase == "libre" and started.players[0].training == later.players[0].training + 1 and started.players[0].burn_limit == later.players[0].burn_limit + 1 and started.players[0].turn_resources.ataque == 2 and started.players[0].turn_resources.recursos == 0, "entrenamiento más ataque antes de libre")
		_expect(started.authority.mission_permanents.mission_2.p1.acquired_turn == acquired.turn.number and started.authority.mission_permanents.mission_2.p1.last_applied_turn == later.turn.number and started.authority.rng_state == later.authority.rng_state, "marca temporal conserva adquisición RNG")
		_expect(engine.start_turn("p1", start).ok and engine.get_authority_snapshot() == started, "recibo inicio")
		_reject(engine, "p1", start, "accion_no_soportada")
		_reject(engine, "p1", F.intent(started, "inicio_forjado", "avanzar_mision", {"mission_id": "mission_5"}), "accion_no_soportada")
		var again: Dictionary = F.intent(started, "inicio_again", "iniciar_turno", {"turn_number": later.turn.number})
		_expect(not engine.start_turn("p1", again).ok and engine.get_authority_snapshot() == started, "nuevo id no reaplica inicio")
		_expect(not engine.has_method("finish_cleanup"), "sin servicio limpieza")
		var restored: Play = _loaded(started)
		_expect(restored.get_authority_snapshot() == started, "restauración no cobra permanente")
		var following: Dictionary = started.duplicate(true)
		following.turn.number += count
		following.turn.phase = "inicio"
		following.revision += count
		following.players[0].turn_resources = {"recursos": 0, "ataque": 0, "mision": 0}
		restored = _loaded(following)
		var stale: Dictionary = F.intent(following, "inicio_stale_payload", "iniciar_turno", {"turn_number": later.turn.number})
		_expect(not restored.start_turn("p1", stale).ok and restored.get_authority_snapshot() == following, "payload antiguo al volver la plaza no cobra inicio")
		_expect(restored.start_turn("p1", start).ok and restored.get_authority_snapshot() == following, "recibo antiguo en turno posterior no ejecuta inicio")
		var next_start: Dictionary = F.intent(following, "inicio_" + str(following.turn.number), "iniciar_turno", {"turn_number": following.turn.number})
		_expect(restored.start_turn("p1", next_start).ok and restored.get_authority_snapshot().players[0].turn_resources.ataque == 2, "inicio propio posterior fiable concede sólo dos")
		var overflow: Dictionary = later.duplicate(true)
		overflow.players[0].turn_resources.ataque = Registry.MAX_INT - 1
		engine = _loaded(overflow)
		_expect(not engine.start_turn("p1", F.intent(overflow, "inicio_overflow", "iniciar_turno", {"turn_number": overflow.turn.number})).ok and engine.get_authority_snapshot() == overflow, "overflow revierte entrenamiento marca recursos y recibos")
		var other_turn: Dictionary = later.duplicate(true)
		other_turn.turn.active_id = "p2"
		if not first:
			other_turn.authority.mission_permanents.mission_2.p2.last_applied_turn = acquired.turn.number
		engine = _loaded(other_turn)
		var other_action: Dictionary = F.intent(other_turn, "inicio_other", "iniciar_turno", {"turn_number": other_turn.turn.number})
		_expect(engine.start_turn("p2", other_action).ok and engine.get_authority_snapshot().players[0].turn_resources.ataque == 0, "turno ajeno no cobra M2 propia")


func _terminal(count: int) -> void:
	for last: int in [2, 5, 7]:
		var state: Dictionary = F.snapshot(count)
		if last == 2:
			F.at(state, 11)
			F.complete_other(state, 5)
			F.complete_other(state, 7)
		else:
			F.at(state, 12)
			F.complete_other(state, 7 if last == 5 else 5)
			var mission: Dictionary = state.missions["mission_%d" % last]
			mission.progress.p1 = 11
			for position: int in range(1, 12):
				mission.first_arrivals["p%02d" % position] = "p1"
			for position: int in ([4, 8] if last == 5 else [6]):
				mission.rewards.p1.append("p%02d_normal" % position)
				mission.rewards.p1.append("p%02d_primero" % position)
		var engine: Play = _loaded(state)
		var action: Dictionary = F.advance(state, "winner", "mission_%d" % last)
		_expect(engine.submit("p1", action).ok, "M2-05 tercera cima %d" % last)
		var final_state: Dictionary = engine.get_authority_snapshot()
		_expect(final_state.lifecycle == "finalizada" and final_state.outcome.mission_id == "mission_%d" % last and final_state.players[0].turn_resources.ataque == state.players[0].turn_resources.ataque and final_state.authority.mission_permanents == state.authority.mission_permanents and final_state.missions["mission_%d" % last].rewards == state.missions["mission_%d" % last].rewards, "victoria anterior a premios y conserva permanentes previos")
		_expect(engine.submit("p1", action).ok and engine.get_authority_snapshot() == final_state, "duplicado ganador")
		_reject(engine, "p1", F.advance(final_state, "post_game", "mission_5"), "accion_ilegal")
		_expect(_loaded(final_state).get_authority_snapshot() == final_state, "carga final sin reaplicar")


func _restoration(count: int) -> void:
	var state: Dictionary = F.snapshot(count)
	F.at(state, 6)
	F.allies(state, 2, "p2")
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "prepara pausa restaurable")
	var paused: Dictionary = engine.get_authority_snapshot()
	var restored: Play = _loaded(paused)
	var view: Dictionary = restored.get_view("p1")
	var response: Dictionary = F.respond(view, [view.resolution.options[-1]])
	_expect(restored.submit("p1", response).ok and engine.submit("p1", response).ok and engine.get_authority_snapshot() == restored.get_authority_snapshot(), "M2-06 restaurar equivale a continuidad")
	for patch: Array in [["cursor", 0], ["cursor", 2], ["source_id", "mision_m5"], ["program_id", "m8_first_v1"], ["recipients", ["p2"]]]:
		var bad: Dictionary = paused.duplicate(true)
		bad.resolution[patch[0]] = patch[1]
		_bad_load(bad, "programa/frontera " + str(patch[0]))
	for patch: Array in [["owner_id", "p2"], ["mission_id", "mission_5"], ["position", 12], ["occurrence_id", "fake"], ["entry_phase", "inicio"], ["turn_number", 2]]:
		var bad: Dictionary = paused.duplicate(true)
		bad.resolution.context[patch[0]] = patch[1]
		_bad_load(bad, "contexto " + str(patch[0]))
	for variant: int in 7:
		var bad: Dictionary = paused.duplicate(true)
		match variant:
			0: bad.missions.mission_2.rewards.p1.erase("p07_normal")
			1: bad.missions.mission_2.rewards.p1.append("p07_primero")
			2: bad.missions.mission_5.rewards.p2.append("p04_normal")
			3: bad.authority.completed_sequences.erase(bad.authority.completed_sequences.keys()[0])
			4: bad.resolution.pending.options.reverse()
			5: bad.resolution.pending.recipients = ["p2"]
			6:
				bad.instances.p2_juego_ally_00001.definition_id = "test_action"
		_bad_load(bad, "grupos/ledger/oferta " + str(variant))
	state = F.snapshot(count)
	F.at(state, 12)
	for variant: int in 6:
		var bad: Dictionary = state.duplicate(true)
		match variant:
			0: bad.authority.mission_permanents.clear()
			1: bad.authority.mission_permanents.mission_2.p1.acquired_turn = 0
			2: bad.authority.mission_permanents.mission_2.p1.last_applied_turn = state.turn.number + 1
			3: bad.authority.mission_permanents.mission_2.p1.last_applied_turn = state.turn.number - 1
			4: bad.missions.mission_2.rewards.p1.erase("p12_permanente")
			5: bad.authority.mission_permanents.mission_2["p2"] = bad.authority.mission_permanents.mission_2.p1.duplicate(true)
		_bad_load(bad, "marca perdida/huérfana/futura " + str(variant))
	var old: Dictionary = F.snapshot(count)
	old.version_esquema = 6
	old.version_motor = "p08-m1-refresh-1/godot-4.7.2"
	_bad_load(old, "snapshot6 sin migración")
	if count >= 3:
		var eliminated: Dictionary = F.snapshot(count)
		F.at(eliminated, 12, "p2")
		eliminated.players[1].health = 0
		eliminated.players[1].eliminated = true
		_expect(_loaded(eliminated).get_authority_snapshot() == eliminated, "permanente de plaza eliminada conserva correspondencia")
		eliminated.authority.mission_permanents.clear()
		_bad_load(eliminated, "marca de plaza eliminada sigue obligatoria")


static func _bad_direct(candidate: Dictionary, actor: String, _payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	fault_reached = true
	F.Advance._player(candidate, actor).turn_resources.recursos += 1
	return ""


static func _rng_direct(candidate: Dictionary, actor: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	var service: RefCounted = F.engine()._advance
	var result: Dictionary = service.advance(candidate, actor, payload.mission_id)
	if not result.ok:
		return result.codigo
	candidate.merge(result.candidate, true)
	rng.randi()
	fault_reached = true
	return ""


static func _fail_after_move(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	fault_reached = Play._defeat(state, context, params, rng, selected, "test_ally")
	return false


static func _rng_after_move(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	fault_reached = Play._defeat(state, context, params, rng, selected, "test_ally")
	rng.randi()
	return fault_reached


static func _fail_after_arrival(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	fault_reached = Play._arrive(state, context, params, rng, selected)
	return false


static func _rng_after_arrival(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	fault_reached = Play._arrive(state, context, params, rng, selected)
	rng.randi()
	return fault_reached


func _rollback(count: int) -> void:
	var state: Dictionary = F.snapshot(count)
	var engine: Play = _loaded(state)
	for handler: Callable in [_bad_direct, _rng_direct]:
		engine._handlers.avanzar_mision = handler
		fault_reached = false
		_reject(engine, "p1", F.advance(state, "fault", "mission_5"), "estado_invalido")
		_expect(fault_reached, "handler adverso real ejecutado")
	state = F.snapshot(count)
	F.at(state, 3)
	F.allies(state, 1, "p2")
	for handler: Callable in [_fail_after_arrival, _rng_after_arrival]:
		engine = _loaded(state)
		var registration: Dictionary = Play.registration("test_ally")
		registration.operations.m2_arrive.execute = handler
		engine._resolver = Resolver.new(Registry.new(registration), engine._advance._definitions)
		fault_reached = false
		_reject(engine, "p1", F.advance(state, "fault_arrival"))
		_expect(fault_reached and engine.get_authority_snapshot() == state, "fallo/RNG tras gasto llegada normal revierte primera frontera")
	engine = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "pausa rollback")
	var paused: Dictionary = engine.get_authority_snapshot()
	for handler: Callable in [_fail_after_move, _rng_after_move]:
		# Registro de producción permanece sellado; se altera únicamente el runner
		# de prueba para alcanzar el callback después de validar la oferta real.
		var registration: Dictionary = Play.registration("test_ally")
		registration.operations.m2_defeat.execute = handler
		engine._resolver = Resolver.new(Registry.new(registration), engine._advance._definitions)
		fault_reached = false
		_reject(engine, "p1", F.respond(engine.get_view("p1"), ["o00001"], "fault_response"))
		_expect(fault_reached and engine.get_authority_snapshot() == paused, "fallo tras traslado conserva sólo normal confirmado")
	state = F.snapshot(count)
	F.at(state, 3)
	state.players[0].turn_resources.ataque = Registry.MAX_INT
	engine = _loaded(state)
	_reject(engine, "p1", F.advance(state), "estado_invalido")
	state = F.snapshot(count)
	F.at(state, 11)
	state.players[0].turn_resources.ataque = Registry.MAX_INT - 2
	engine = _loaded(state)
	_reject(engine, "p1", F.advance(state), "estado_invalido")


func _budgets() -> void:
	for amount: int in [16, 17, 100]:
		var state: Dictionary = F.snapshot(4)
		F.at(state, 3)
		F.allies(state, amount, "p2")
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "M2-07 oferta sin truncar %d" % amount)
		var view: Dictionary = engine.get_view("p1")
		_expect(view.resolution.options.size() == amount and view.resolution.option_allies.size() == amount and engine._m2_registry.option_limit(Play.FIRST) == 10000 and Registry.new().option_limit("unknown") == 16, "techo propio conserva defecto previo")
		var restored: Play = _loaded(engine.get_authority_snapshot())
		_expect(restored.submit("p1", F.respond(view, [view.resolution.options[-1]])).ok, "última opción puede cerrar")
	for mode: String in ["revision", "next_id", "receipts", "destination_not_first"]:
		var state: Dictionary = F.snapshot()
		F.at(state, 3)
		F.allies(state, 1)
		F.allies(state, 1, "p2")
		if mode == "revision":
			state.revision = Registry.MAX_INT - 1
		elif mode == "next_id":
			state.authority.next_id = Registry.MAX_INT
		elif mode == "receipts":
			state.revision = 1
			for index: int in 9999:
				state.authority.receipts.get_or_add("p1", {})["r%d" % index] = {"canonical": "x", "revision_aplicada": 1}
		else:
			# Diez mil instancias únicas exceden50k nodos: esta entrada se
			# rechaza estructuralmente. No representa una partida restaurable
			# ni prueba por sí sola la cota multirrama de M2.
			F.allies(state, 10000, "p2", "descarte")
		var engine: Play = F.engine()
		var source = F.Missions.LatestSource.new()
		source.confirm(engine.profile_identity(), state)
		var loaded: Dictionary = engine.restore_match(state.match_id, source)
		if loaded.ok:
			_reject(engine, "p1", F.advance(state), "estado_invalido")
		else:
			_expect(engine.get_authority_snapshot().is_empty(), "presupuesto carga rechaza íntegro " + mode)
	# Revisión exacta suficiente para dos segmentos; cierre sólo requiere uno.
	var state: Dictionary = F.snapshot()
	F.at(state, 3)
	F.allies(state, 1, "p2")
	state.revision = Registry.MAX_INT - 2
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "frontera revisión dos commits")
	var view: Dictionary = engine.get_view("p1")
	_expect(_loaded(engine.get_authority_snapshot()).submit("p1", F.respond(view, view.resolution.options)).ok, "último commit disponible")
	# Techo por programa, independiente de que el snapshot alcance antes su
	# límite de nodos. El techo por defecto de otros registros sigue siendo16.
	var pending: Dictionary = {"kind": "eleccion", "recipients": ["p1"], "options": [], "min": 1, "max": 1}
	for index: int in 10000:
		pending.options.append("o%05d" % index)
	var registry: Registry = Registry.new(Play.registration("test_ally"))
	_expect(registry.valid_pending(pending, ["p1"], Play.FIRST), "techo10000 completo")
	pending.options.append("overflow")
	_expect(not registry.valid_pending(pending, ["p1"], Play.FIRST), "techo10001 rechazado sin truncar")
	# Guarda aislada del destino lleno: ningún snapshot con10000 instancias
	# únicas cabe en50k nodos, por eso no atribuir este fixture a partida válida.
	var full: Dictionary = F.snapshot()
	F.allies(full, 1)
	F.allies(full, 1, "p2")
	full.zones.p2_descarte.cards.resize(10000)
	var before: Dictionary = full.duplicate(true)
	_expect(not Play.Targets.defeat(full, F.engine()._advance._definitions, "o00002") and full == before, "destino de opción NO primera lleno no traslada")
	# Recibos en la frontera exacta, tanto ruta directa como dos segmentos.
	for amount: int in [0, 1]:
		state = F.snapshot()
		F.at(state, 3)
		F.allies(state, amount, "p2")
		state.revision = 1
		state.authority.receipts["p1"] = {}
		for index: int in 10000 - (amount + 1):
			state.authority.receipts.p1["old_%d" % index] = {"canonical": "x", "revision_aplicada": 1}
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state)).ok, "reserva recibos exacta N%d" % amount)
		if amount > 0:
			view = engine.get_view("p1")
			_expect(engine.submit("p1", F.respond(view, view.resolution.options)).ok, "último recibo cierra")
		_expect(engine.get_authority_snapshot().authority.receipts.p1.size() == 10000, "historial10000 sin borrar")


static func _node_count(value: Variant) -> int:
	var total: int = 1
	if value is Dictionary:
		for item: Variant in value.values():
			total += _node_count(item)
	elif value is Array:
		for item: Variant in value:
			total += _node_count(item)
	return total


static func _clear_allies(state: Dictionary) -> void:
	for id: String in state.instances.keys():
		if state.instances[id].definition_id == "test_ally":
			for zone: Dictionary in state.zones.values():
				zone.cards.erase(id)
			state.instances.erase(id)


func _view_budget() -> void:
	var state: Dictionary = F.snapshot()
	F.at(state, 3)
	F.allies(state, 1, "p2")
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state)).ok, "origen real pausa para frontera vista")
	var boundary: Dictionary = engine.get_authority_snapshot()
	_clear_allies(boundary)
	boundary.resolution.pending = Play._offer(boundary, boundary.resolution.context, {}, "test_ally")
	var definitions: Dictionary = engine._advance._definitions
	var constant: int = _node_count(Core.ViewBuilder.new().project(boundary, "p1", definitions))
	F.allies(boundary, 1, "p2")
	boundary.resolution.pending = Play._offer(boundary, boundary.resolution.context, {}, "test_ally")
	var per_candidate: int = _node_count(Core.ViewBuilder.new().project(boundary, "p1", definitions)) - constant
	_clear_allies(boundary)
	var count: int = int(float(50001 - constant) / per_candidate)
	F.allies(boundary, count, "p2")
	boundary.resolution.pending = Play._offer(boundary, boundary.resolution.context, {}, "test_ally")
	var padding: int = 50001 - _node_count(Core.ViewBuilder.new().project(boundary, "p1", definitions))
	var metal: Dictionary = {"token_id": "budget_available", "metal": "hierro", "exhausted": false, "used_this_turn": false}
	if padding >= _node_count(metal):
		boundary.players[0].metals.append(metal)
		padding -= _node_count(metal)
	for name: String in ["hierro", "acero", "peltre", "estano", "bronce", "zinc", "laton", "atium"]:
		if padding == 0:
			break
		boundary.players[0].burned[name] = 0
		padding -= 1
	_expect(padding == 0 and _node_count(Core.ViewBuilder.new().project(boundary, "p1", definitions)) == 50001, "vista actual exactamente50001")
	_expect(engine._advance.state_error(boundary).is_empty() and not engine._fits(boundary), "snapshot válido con vista demasiado grande")
	var next: Dictionary = boundary.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = next.authority.rng_seed
	rng.state = next.authority.rng_state
	var result: Resolver.Result = Resolver.new(engine._m2_registry, definitions).resume(next, [next.resolution.pending.options[-1]], rng)
	_expect(engine._frontier(next, result, rng, boundary.authority.rng_state), "cierre sí cabe no legitima vista actual")
	_bad_load(boundary, "vista actual50001 aunque cierre cabe")
	# El mismo conjunto legal antes de gasto cabe sin oferta; intentar llegar
	# debe rechazar sin normal, coste, primer puesto, recibo ni consumo de ID.
	var initial: Dictionary = boundary.duplicate(true)
	initial.resolution = null
	initial.missions.mission_2.progress.p1 = 3
	initial.missions.mission_2.first_arrivals.p04 = null
	initial.missions.mission_2.rewards.p1.erase("p04_normal")
	initial.players[0].turn_resources.ataque -= 1
	initial.players[0].turn_resources.mision += 1
	initial.authority.next_id -= 1
	initial.authority.receipts.clear()
	initial.revision -= 1
	engine = _loaded(initial)
	_reject(engine, "p1", F.advance(initial, "budget_arrival"), "estado_invalido")


func _admission() -> void:
	for fixture: RefCounted in [M1.engine(), M8.engine(), Permanents.engine(), F.Missions.engine()]:
		var source = F.Missions.LatestSource.new()
		var state: Dictionary = F.snapshot()
		source.confirm(fixture.profile_identity(), state)
		_expect(not fixture.restore_match(state.match_id, source).ok and fixture.get_authority_snapshot().is_empty(), "perfiles previos no admiten M2")
	for fixture_state: Dictionary in [M1.snapshot(), M8.snapshot(), Permanents.snapshot(), F.Missions.snapshot(F.engine().catalog_identity())]:
		_bad_load(fixture_state, "M2 no combina perfiles")
	for kind: String in ["defender", "cloud", "ability", "funding", "mission"]:
		var catalog: Dictionary = F.Missions.catalog()
		for card: Dictionary in catalog.cartas:
			if card.id == "test_ally":
				if kind in ["defender", "cloud"]:
					card.rasgos[kind] = true
				elif kind == "ability":
					card.habilidades[0].efectos = [{"op": "ganar", "recurso": "ataque", "cantidad": 1, "objetivo": "propio"}]
				elif kind == "funding":
					card.tipo = "funding"
			if kind == "mission" and card.id == "mision_m2":
				card.rasgos.recorridos[0].casillas[3].efectos[0].cantidad = 2
		_expect(not F.engine(catalog).is_supported(), "M2-08 rechazo de admisión " + kind)
	var state: Dictionary = F.snapshot()
	state.turn.phase = "limpieza"
	_bad_load(state, "sin entrada limpieza")
	state = F.snapshot(3)
	state.mode = "cooperativo"
	_bad_load(state, "sin rival cooperativo ficticio")
	var engine: Play = _loaded(F.snapshot())
	for kind: String in ["jugar_carta", "quemar", "atacar", "cerrar_limpieza", "cobrar_permanente"]:
		_reject(engine, "p1", F.intent(engine.get_authority_snapshot(), "unsupported", kind, {}), "accion_no_soportada")
