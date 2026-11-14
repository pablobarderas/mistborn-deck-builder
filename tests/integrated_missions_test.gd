extends SceneTree

const F = preload("res://tests/integrated_missions_fixtures.gd")
const Play = preload("res://scripts/game/integrated_missions_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Resolver = preload("res://scripts/game/sequence_resolver.gd")
const M1F = preload("res://tests/m1_fixtures.gd")
const M2F = preload("res://tests/m2_fixtures.gd")
const M8F = preload("res://tests/m8_fixtures.gd")
const PF = preload("res://tests/permanents_fixtures.gd")
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	print("INT_STAGE: admission")
	_admission()
	for count: int in [2, 3, 4]:
		print("INT_STAGE: cells/%d" % count)
		_cells(count)
		_terminal(count)
		_choices(count)
		_permanents(count)
	_draw_and_cleanup()
	_adversaries()
	_budgets()
	_view_budget()
	if _failures == 0:
		print("P08_INTEGRATED_MISSIONS_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("INT_FAIL: " + label)


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
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot().is_empty() and before == state, "carga atomica: " + label)


func _reject(engine: Play, action: Dictionary, code: String = "", actor: String = "p1") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, action)
	_expect(not result.ok and (code.is_empty() or result.codigo == code), "rechazo " + code + ": " + str(result))
	_expect(before == engine.get_authority_snapshot(), "rechazo conserva snapshot y RNG")


func _admission() -> void:
	_expect(F.engine().is_supported(), "INT-01 servicio combinado soportado")
	_expect(Validator.SCHEMA_VERSION == 8 and Validator.ENGINE_VERSION == "p08-integrated-missions-1/godot-4.7.2", "INT-01 version exacta sin migracion")
	for count: int in [2, 3, 4]:
		var combinations: int = 0
		for a: int in range(1, 7):
			for b: int in range(a + 1, 8):
				for c: int in range(b + 1, 9):
					var state: Dictionary = F.snapshot([c, a, b], count)
					# IDs de instancia ajenos al número y diccionario en orden arbitrario.
					var mission: Dictionary = state.missions["mission_%d" % c]
					state.missions.erase("mission_%d" % c)
					state.missions["arbitrary_instance"] = mission
					var engine: Play = _loaded(state)
					_expect(engine.get_authority_snapshot() == state, "INT-01 subconjunto %d/%d/%d/%d" % [count, a, b, c])
					combinations += 1
		_expect(combinations == 56, "INT-01 56 combinaciones por numero de plazas")
	for kind: String in ["two", "four", "duplicate", "unknown", "schema", "engine", "cooperative", "mission_text"]:
		var state: Dictionary = F.snapshot()
		match kind:
			"two": state.missions.erase("mission_8")
			"four": state.missions["fourth"] = state.missions.mission_8.duplicate(true)
			"duplicate": state.missions.mission_8.definition_id = "mision_m1"
			"unknown": state.missions.mission_8.definition_id = "mision_m9"
			"schema": state.version_esquema = 7
			"engine": state.version_motor = "p08-m2-defeat-1/godot-4.7.2"
			"cooperative": state.mode = "cooperativo"
			"mission_text": state.catalog_id = "modified_catalog"
		_bad_load(state, "INT-01 " + kind)
	var engine: Play = F.engine()
	var state: Dictionary = F.snapshot()
	var source = F.Missions.LatestSource.new()
	source.confirm("other_profile", state)
	_expect(not engine.restore_match(state.match_id, source).ok and not engine.load_authority_snapshot(state).ok, "INT-01 perfil ajeno y entrada publica rechazados")
	for old: RefCounted in [M1F.engine(), M2F.engine(), M8F.engine(), PF.engine(), F.Missions.engine()]:
		source = F.Missions.LatestSource.new()
		source.confirm(old.profile_identity(), state)
		_expect(not old.restore_match(state.match_id, source).ok, "INT-01 pilotos conservan conjuntos exactos")
	for mutation: String in ["defender", "cloud", "ability", "mission", "text", "track"]:
		var catalog: Dictionary = F.Missions.catalog()
		for card: Dictionary in catalog.cartas:
			if card.id == "test_ally":
				if mutation in ["defender", "cloud"]:
					card.rasgos[mutation] = true
				elif mutation == "ability":
					card.habilidades[0].efectos = [{"op": "ganar", "recurso": "ataque", "cantidad": 1, "objetivo": "propio"}]
			if card.id == "mision_m2" and mutation == "mission":
				card.rasgos.recorridos[0].casillas[3].efectos[0].cantidad = 2
		var descriptors: Dictionary = F.Missions.descriptors(catalog, true)
		if mutation == "text":
			descriptors.mision_m3.nombre += " altered"
		var training: Dictionary = F.Missions.training_profile(catalog)
		if mutation == "track":
			training.marks = training.marks.duplicate(true)
			training.marks[0] = ""
		engine = Play.new(catalog, F.Missions.descriptors(catalog, false), training, descriptors)
		_expect(not engine.is_supported(), "INT-01 contenido incompatible incluso no seleccionado " + mutation)


func _triple(number: int) -> Array:
	var numbers: Array = [number]
	for other: int in [1, 2, 3, 4, 5, 6, 7, 8]:
		if other not in numbers and numbers.size() < 3:
			numbers.append(other)
	return numbers


func _settle(engine: Play, prefix: String, skip_optional: bool = true) -> void:
	for segment: int in 3:
		var view: Dictionary = engine.get_view("p1")
		if view.resolution == null:
			return
		var options: Array = []
		if view.resolution.min > 0 or not skip_optional:
			options.append(view.resolution.options[0])
		_expect(engine.submit("p1", F.respond(view, options, prefix + str(segment))).ok, "continuacion " + prefix)
	_expect(engine.get_authority_snapshot().resolution == null, "cierre finito " + prefix)


func _cells(count: int) -> void:
	for number: int in range(1, 9):
		for first: bool in [true, false]:
			var initial: Dictionary = F.snapshot(_triple(number), count)
			if not first:
				F.at(initial, number, 12, "p2")
			M1F.metals(initial, 4)
			F.cards(initial, 20, "p1_mazo")
			initial.players[0].health = 10
			var engine: Play = _loaded(initial)
			for position: int in range(1, 13):
				var state: Dictionary = engine.get_authority_snapshot()
				var player: Dictionary = state.players[0]
				_expect(engine.submit("p1", F.advance(state, number, "advance_%d" % position)).ok, "INT-02 llegada %d/%d/%d/%s" % [count, number, position, first])
				_settle(engine, "settle_%d_" % position)
				var after: Dictionary = engine.get_authority_snapshot()
				if after.is_empty():
					continue
				var result: Dictionary = after.players[0]
				_expect(after.missions["mission_%d" % number].progress.p1 == position and result.turn_resources.mision == player.turn_resources.mision - 1, "INT-02 un punto por paso")
				_assert_cell(state, after, number, position, first)


func _assert_cell(before: Dictionary, after: Dictionary, number: int, position: int, first: bool) -> void:
	# Oráculo de efectos explícito, independiente del generador de candidatos.
	var coins: int = 0
	var attack: int = 0
	var heal: int = 0
	var draw: int = 0
	var train: int = 0
	var atium: int = 0
	match number:
		2:
			attack = {4: 1, 7: 2, 10: 3, 12: 3 if first else 2}.get(position, 0)
		3:
			coins = (2 if first else 1) if position in [4, 6, 8, 10] else ((5 if first else 2) if position == 12 else 0)
		4:
			draw = (2 if first else 1) if position in [4, 8] else (2 if first and position == 12 else 0)
		5:
			coins = (2 if first else 1) if position == 4 else 0
			attack = 2 if position == 8 else 0
			heal = 2 if first and position == 8 else 0
			atium = (2 if first else 1) if position == 12 else 0
		6:
			train = (2 if first else 1) if position in [6, 12] else 0
		7:
			heal = ((4 if position == 6 else 6) + (2 if first else 0)) if position in [6, 12] else 0
	var a: Dictionary = after.players[0]
	var b: Dictionary = before.players[0]
	_expect(a.turn_resources.recursos == b.turn_resources.recursos + coins and a.turn_resources.ataque == b.turn_resources.ataque + attack, "INT-02 monedas/ataque M%d p%d" % [number, position])
	_expect(a.health == mini(40, b.health + heal) and a.training == b.training + train and a.persistent.atium == b.persistent.atium + atium, "INT-02 salud/entrenamiento/Atium M%d p%d" % [number, position])
	_expect(after.zones.p1_mano.cards.size() == before.zones.p1_mano.cards.size() + draw, "INT-02 robo M%d p%d" % [number, position])
	var refreshed: int = 0
	var exhausted_before: int = 0
	for token: Dictionary in b.metals:
		if token.metal == "cobre" and token.exhausted:
			exhausted_before += 1
	for token: Dictionary in a.metals:
		if token.metal == "cobre" and not token.exhausted:
			refreshed += 1
	var expected_refresh: int = mini(exhausted_before, 2 if first else 1) if number == 1 and position in [5, 9] else (exhausted_before if number == 1 and position == 12 and first else 0)
	_expect(refreshed == 4 - exhausted_before + expected_refresh, "INT-02 refrescos selectivos y cima M1")
	var burn_gain: int = 1 if number == 1 and position == 12 else 0
	for threshold: int in [3, 9, 15]:
		if b.training < threshold and b.training + train >= threshold:
			burn_gain += 1
	_expect(a.burn_limit == b.burn_limit + burn_gain, "INT-02 capacidad entrenamiento/permanente")
	_expect(after.authority.rng_state == before.authority.rng_state, "INT-02 sin reciclado RNG intacto")


func _terminal(count: int) -> void:
	for number: int in range(1, 9):
		var state: Dictionary = F.snapshot(_triple(number), count)
		for other: int in _triple(number):
			F.at(state, other, 11 if other == number else 12)
		M1F.metals(state, 4)
		F.cards(state, 4)
		var before: Dictionary = state.players[0].duplicate(true)
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state, number)).ok, "INT-02 tercera cima por M%d" % number)
		var after: Dictionary = engine.get_authority_snapshot()
		before.turn_resources.mision -= 1
		_expect(after.lifecycle == "finalizada" and after.turn.phase == "finalizada" and after.outcome.mission_id == "mission_%d" % number and after.resolution == null, "INT-02 victoria inmediata")
		_expect(after.players[0] == before and after.instances == state.instances and after.zones == state.zones and after.authority.completed_sequences == state.authority.completed_sequences and after.authority.mission_permanents == state.authority.mission_permanents and after.authority.rng_state == state.authority.rng_state, "INT-02 sin premios/grupos/ledger/RNG de ultima cima")
		_expect(after.missions["mission_%d" % number].rewards.p1 == state.missions["mission_%d" % number].rewards.p1, "INT-02 sin grupo ultima cima")
		_reject(engine, F.advance(after, number, "after_terminal"), "accion_ilegal")


func _choices(count: int) -> void:
	var state: Dictionary = F.snapshot([8, 1, 2], count)
	for entry: Array in [[1, 4], [2, 3], [8, 8]]:
		F.at(state, entry[0], entry[1])
	M1F.metals(state, 3)
	M2F.allies(state, 2, "p1")
	M2F.allies(state, 3, "p2")
	F.cards(state, 3, "p1_descarte")
	var engine: Play = _loaded(state)
	for number: int in [1, 2, 8]:
		var action: Dictionary = F.advance(engine.get_authority_snapshot(), number, "mission_%d" % number)
		_expect(engine.submit("p1", action).ok, "INT-03 familias coexistentes llegada")
		var segments: int = 0
		while engine.get_authority_snapshot().resolution != null and segments < 3:
			var confirmed: Dictionary = engine.get_authority_snapshot()
			var view: Dictionary = engine.get_view("p1")
			var foreign: Dictionary = engine.get_view("p2")
			var mapping: String = {1: "option_metals", 2: "option_allies", 8: "option_cards"}[number]
			_expect(view.resolution.has(mapping) and not foreign.resolution.has("options") and not foreign.resolution.has(mapping), "INT-07 oferta solo destinatario")
			for key: String in ["program_id", "source_id", "context", "cursor", "steps", "authority", "rng_state", "receipts", "completed_sequences"]:
				_expect(not view.resolution.has(key) and not foreign.resolution.has(key), "INT-07 secreto no proyectado " + key)
			for other: String in ["option_metals", "option_allies", "option_cards"]:
				_expect(other == mapping or not view.resolution.has(other), "INT-07 sin correspondencia cruzada")
			_expect(not view.zones.p2_mano.has("cards") and not view.zones.p2_descarte.has("cards") and not view.has("authority"), "INT-07 zonas ajenas y autoridad ocultas")
			_reject(engine, F.respond(view, ["forged"], "invalid"), "eleccion_invalida")
			_reject(engine, F.respond(view, [view.resolution.options[0]], "wrong_actor"), "eleccion_invalida", "p2")
			_reject(engine, F.advance(confirmed, 2, "blocked"), "accion_ilegal")
			var forged: Dictionary = confirmed.duplicate(true)
			forged.resolution.context.mission_id = "mission_%d" % (2 if number != 2 else 1)
			_bad_load(forged, "INT-03 cursor/deuda de otra mision")
			forged = confirmed.duplicate(true)
			forged.missions["mission_%d" % (8 if number != 8 else 1)].rewards.p1.erase("p05_normal")
			_bad_load(forged, "INT-03 pausa no excusa deuda valida de otra familia")
			forged = confirmed.duplicate(true)
			forged.resolution.source_id = "mision_m2" if number != 2 else "mision_m1"
			_bad_load(forged, "INT-03 fuente cruzada")
			forged = confirmed.duplicate(true)
			forged.resolution.program_id = "m2_first_v1" if number != 2 else "m1_first_v1"
			_bad_load(forged, "INT-03 programa cruzado")
			engine = _loaded(confirmed)
			_expect(engine.get_view("p1") == view, "INT-03 restauracion exacta de cursor")
			var selected: Array = [view.resolution.options[-1]] if view.resolution.min > 0 else []
			var answer: Dictionary = F.respond(view, selected, "answer_%d_%d" % [number, segments])
			_expect(engine.submit("p1", answer).ok, "INT-03 respuesta aceptada")
			var accepted: Dictionary = engine.get_authority_snapshot()
			_expect(engine.submit("p1", answer).ok and engine.get_authority_snapshot() == accepted, "INT-03 reenvio sin repetir segmento")
			segments += 1
		_expect(segments == (1 if number == 2 else 2), "INT-03 numero ventanas por familia")
	var complete: Dictionary = engine.get_authority_snapshot()
	_expect(complete.authority.completed_sequences.size() == 4, "INT-03 tres familias y ledger historico coexistentes")
	_expect(complete.zones.p2_juego.cards.size() == 2 and complete.zones.p2_descarte.cards.size() == 1 and complete.zones.eliminadas.cards.is_empty(), "INT-03 derrota al descarte del propietario y M8 omision")
	engine = _loaded(complete)
	var forged: Dictionary = complete.duplicate(true)
	forged.authority.completed_sequences.values()[0].program_id = "m2_first_v1"
	_bad_load(forged, "INT-03 programa de cierre cruzado")
	# Las tres familias liquidadas sin objetivos no abren elección.
	for number: int in [1, 2, 8]:
		state = F.snapshot()
		F.at(state, number, 3 if number == 2 else 4)
		for zone: Dictionary in state.zones.values():
			zone.cards.clear()
		state.instances.clear()
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state, number)).ok and engine.get_authority_snapshot().resolution == null, "INT-03 auto_empty M%d" % number)
	# Una misma carta derrotada por M2 entra en oferta M8 desde el descarte propio.
	state = F.snapshot([2, 8, 3], count)
	F.at(state, 2, 3)
	F.at(state, 8, 4)
	M2F.allies(state, 1, "p1")
	M2F.allies(state, 1, "p2")
	engine = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 2)).ok, "INT-03 objetivo propio y rival admitidos juntos")
	var view: Dictionary = engine.get_view("p1")
	var own_id: String = ""
	var selected: String = ""
	for target: Dictionary in view.resolution.option_allies:
		if target.owner_id == "p1":
			own_id = target.instance_id
			selected = target.option_id
	_expect(engine.submit("p1", F.respond(view, [selected], "defeat_own")).ok, "INT-03 derrota objetivo propio")
	complete = engine.get_authority_snapshot()
	_expect(own_id in complete.zones.p1_descarte.cards and complete.zones.p2_juego.cards.size() == 1, "INT-03 descarte propio sin derrotar rival")
	_expect(engine.submit("p1", F.advance(complete, 8, "remove_defeated")).ok, "INT-03 M8 reconstruye oferta tras derrota")
	view = engine.get_view("p1")
	for target: Dictionary in view.resolution.option_cards:
		if target.instance_id == own_id:
			selected = target.option_id
	_expect(engine.submit("p1", F.respond(view, [selected], "remove_own")).ok, "INT-03 M8 elimina aliado desde descarte")
	_settle(engine, "skip_extra")
	complete = engine.get_authority_snapshot()
	_expect(own_id in complete.zones.eliminadas.cards and own_id not in complete.zones.p1_descarte.cards, "INT-03 M2 descarte y M8 eliminadas son destinos distintos")


func _permanents(count: int) -> void:
	var state: Dictionary = F.snapshot([2, 3, 6], count)
	F.at(state, 2, 12)
	F.at(state, 3, 12)
	state.turn.number += 2
	state.turn.phase = "inicio"
	var engine: Play = _loaded(state)
	var action: Dictionary = F.intent(state, "inicio_combined", "iniciar_turno", {"turn_number": state.turn.number})
	_reject(engine, action, "accion_no_soportada")
	_expect(engine.start_turn("p1", action).ok, "INT-04 inicio M2+M3 atomico")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.players[0].turn_resources.ataque == state.players[0].turn_resources.ataque + 2 and after.players[0].turn_resources.recursos == state.players[0].turn_resources.recursos + 2 and after.players[0].training == 3, "INT-04 ambos recursos y entrenamiento")
	for marks: Dictionary in after.authority.mission_permanents.values():
		_expect(marks.p1.last_applied_turn == state.turn.number and marks.p1.acquired_turn == state.turn.number - 2, "INT-04 marcas simultaneas")
	_expect(engine.start_turn("p1", action).ok and engine.get_authority_snapshot() == after, "INT-05 reenvio inicio")
	_reject(engine, action, "accion_no_soportada")
	var newer: Dictionary = F.intent(after, "inicio_new", "iniciar_turno", {"turn_number": after.turn.number})
	_expect(not engine.start_turn("p1", newer).ok and engine.get_authority_snapshot() == after, "INT-05 ocurrencia consumida ID nuevo")
	for fault: String in ["absent", "orphan", "future", "reapplied", "burn"]:
		var bad: Dictionary = state.duplicate(true)
		match fault:
			"absent": bad.authority.mission_permanents.erase("mission_3")
			"orphan": bad.authority.mission_permanents["missing"] = bad.authority.mission_permanents.mission_3.duplicate(true)
			"future": bad.authority.mission_permanents.mission_3.p1.acquired_turn = bad.turn.number + 1
			"reapplied": bad.authority.mission_permanents.mission_3.p1.last_applied_turn = bad.turn.number
			"burn": bad.players[0].burn_limit += 1
		_bad_load(bad, "INT-05 marca/capacidad " + fault)
	state.players[0].turn_resources.recursos = Registry.MAX_INT
	engine = _loaded(state)
	_expect(not engine.start_turn("p1", action).ok and engine.get_authority_snapshot() == state, "INT-05 overflow M3 revierte ataque M2 y entrenamiento")


func _draw_and_cleanup() -> void:
	var state: Dictionary = F.snapshot([1, 6, 4])
	F.at(state, 1, 12)
	F.at(state, 6, 5)
	F.at(state, 4, 3)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 6)).ok, "INT-04 M6 tras permanente M1")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after.players[0].training == 4 and after.players[0].burn_limit == 3 and after.zones == state.zones, "INT-04 M6 conserva bonus M1 y no roba")
	state = after.duplicate(true)
	state.turn.number += 2
	state.turn.phase = "inicio"
	engine = _loaded(state)
	_expect(engine.start_turn("p1", F.intent(state, "inicio_capacity", "iniciar_turno", {"turn_number": state.turn.number})).ok, "INT-04 inicio conserva bonus M1")
	_expect(engine.get_authority_snapshot().players[0].burn_limit == 3, "INT-04 bonus no duplicado")
	for first: bool in [true, false]:
		state = F.snapshot([1, 4, 6])
		if not first:
			F.at(state, 1, 12, "p2")
		F.at(state, 1, 11)
		M1F.metals(state, 4)
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state, 1)).ok, "INT-02 cima directa M1")
		after = engine.get_authority_snapshot()
		_expect(Play.M1.option_metals(after, "p1").size() == (0 if first else 4) and after.players[0].burn_limit == 2 and after.resolution == null, "INT-02 refresco total primero sin secuencia ficticia")
	# Una sola candidata también exige selección, después extra auto_empty.
	state = F.snapshot()
	F.at(state, 1, 4)
	M1F.metals(state, 1)
	engine = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 1)).ok and engine.get_view("p1").resolution.options.size() == 1, "INT-03 candidata única obligatoria")
	_settle(engine, "single")
	_expect(engine.get_authority_snapshot().resolution == null, "INT-03 extra sin candidatas liquida")
	# Robo M4 con reciclado reproducible; el extra de cima sí roba, el permanente no.
	for position: int in [4, 8, 12]:
		for first: bool in [true, false]:
			state = F.snapshot([4, 8, 7])
			if not first:
				F.at(state, 4, position, "p2")
			F.at(state, 4, position - 1)
			_clear_cards(state)
			F.cards(state, 10)
			engine = _loaded(state)
			var same: Play = _loaded(state)
			var action: Dictionary = F.advance(state, 4)
			_expect(engine.submit("p1", action).ok and same.submit("p1", action).ok, "INT-04 robo M4 con reciclado")
			after = engine.get_authority_snapshot()
			var amount: int = (2 if first else 1) if position != 12 else (2 if first else 0)
			_expect(after.zones.p1_mano.cards.size() == amount and after == same.get_authority_snapshot(), "INT-04 tamaño M4 y RNG reproducible")
			_expect((after.authority.rng_state != state.authority.rng_state) == (amount > 0), "INT-04 RNG solo cuando se recicla")
	# Capacidad M1 y mano M4 simultáneas en cierre interno.
	for permanent: bool in [true, false]:
		state = F.snapshot([1, 4, 8])
		F.at(state, 1, 12)
		if permanent:
			F.at(state, 4, 12)
		_clear_cards(state)
		F.cards(state, 9)
		state.turn.phase = "limpieza"
		engine = _loaded(state)
		var action: Dictionary = F.intent(state, "limpieza_combined", "cerrar_limpieza", {"turn_number": state.turn.number})
		_reject(engine, action, "accion_no_soportada")
		_expect(engine.finish_cleanup("p1", action).ok, "INT-04 cierre interno M1+M4")
		after = engine.get_authority_snapshot()
		_expect(after.zones.p1_mano.cards.size() == (6 if permanent else 5) and after.players[0].burn_limit == 2 and after.turn.phase == "inicio" and after.turn.active_id == "p2", "INT-04 mano 5/6 capacidad y siguiente vivo")
		_expect(engine.finish_cleanup("p1", action).ok and engine.get_authority_snapshot() == after, "INT-05 reenvio cierre")
		_reject(engine, action, "accion_no_soportada")
		_expect(not engine.finish_cleanup("p1", F.intent(after, "limpieza_new", "cerrar_limpieza", {"turn_number": state.turn.number})).ok and engine.get_authority_snapshot() == after, "INT-05 cierre consumido ID nuevo")
	# M8 elimina dos de tres; M4 roba corto sin deuda tras agotamiento.
	state = F.snapshot([4, 8, 7])
	F.at(state, 4, 12)
	F.at(state, 8, 4)
	_clear_cards(state)
	F.cards(state, 3)
	engine = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 8)).ok, "INT-04 M4+M8 eliminación")
	_settle(engine, "remove", false)
	after = engine.get_authority_snapshot()
	_expect(after.zones.eliminadas.cards.size() == 2, "INT-04 dos eliminadas a pila común")
	after.turn.phase = "limpieza"
	engine = _loaded(after)
	_expect(engine.finish_cleanup("p1", F.intent(after, "limpieza_short", "cerrar_limpieza", {"turn_number": after.turn.number})).ok, "INT-04 cierre agotado aceptado")
	_expect(engine.get_authority_snapshot().zones.p1_mano.cards.size() == 1, "INT-04 robo corto una carta sin deuda")
	# El robo de limpieza llega a consumir RNG provisional, pero no hay margen
	# para el recibo: toda la transacción de autoridad debe conservarse.
	state = F.snapshot([1, 4, 8])
	state.turn.phase = "limpieza"
	_clear_cards(state)
	F.cards(state, 9)
	state.revision = 10000
	state.authority.receipts["p1"] = {}
	for index: int in 10000:
		state.authority.receipts.p1["old_%d" % index] = {"canonical": "x", "revision_aplicada": 1}
	engine = _loaded(state)
	var payload: Dictionary = {"turn_number": state.turn.number}
	var staged: Dictionary = state.duplicate(true)
	var provisional: RandomNumberGenerator = Play._rng_for(state)
	_expect(engine._cleanup(staged, "p1", payload, provisional) == "estado_invalido" and provisional.state != state.authority.rng_state and staged.zones != state.zones, "INT-05 falla posterior a robo/reciclado provisional")
	_expect(not engine.finish_cleanup("p1", F.intent(state, "limpieza_no_receipt", "cerrar_limpieza", payload)).ok and engine.get_authority_snapshot() == state, "INT-05/06 fallo recibo revierte robo y RNG vivo")


static func _clear_cards(state: Dictionary) -> void:
	for zone: Dictionary in state.zones.values():
		zone.cards.clear()
	state.instances.clear()


static func _rng_fault(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator, advance: Advance) -> String:
	var result: Dictionary = advance.advance(candidate, owner, payload.mission_id, rng)
	if not result.ok:
		return result.codigo
	candidate.merge(result.candidate, true)
	rng.randi()
	return ""


static func _delta_fault(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator, advance: Advance) -> String:
	var code: String = _rng_fault(candidate, owner, payload, rng, advance)
	if code.is_empty():
		candidate.players[0].turn_resources.recursos += 1
	return code


static func _refresh_rng_fault(state: Dictionary, context: Dictionary, params: Dictionary, rng: RandomNumberGenerator, selected: Array) -> bool:
	var ok: bool = Play.M1._refresh(state, context, params, rng, selected)
	rng.randi()
	return ok


func _adversaries() -> void:
	for number: int in [3, 4]:
		for callback: Callable in [_rng_fault, _delta_fault]:
			var state: Dictionary = F.snapshot([3, 4, 8])
			F.at(state, number, 3)
			_clear_cards(state)
			F.cards(state, 8)
			var engine: Play = _loaded(state)
			engine._handlers[Play.ACTION_ID] = callback.bind(engine._advance)
			_reject(engine, F.advance(state, number), "estado_invalido")
	# Delta inválido con RNG legítimo idéntico al candidato fiable de M4.
	var random_state: Dictionary = F.snapshot([3, 4, 8])
	F.at(random_state, 4, 3)
	_clear_cards(random_state)
	F.cards(random_state, 8)
	var random_engine: Play = _loaded(random_state)
	random_engine._handlers[Play.ACTION_ID] = _delta_only.bind(random_engine._advance)
	_reject(random_engine, F.advance(random_state, 4), "estado_invalido")
	var state: Dictionary = F.snapshot()
	F.at(state, 1, 4)
	M1F.metals(state, 3)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 1)).ok, "INT-07 pausa para callback adverso")
	var registration: Dictionary = Play.registration("test_ally")
	registration.operations.m1_refresh.execute = _refresh_rng_fault
	engine._resolver = Resolver.new(Registry.new(registration), engine._content)
	var view: Dictionary = engine.get_view("p1")
	_reject(engine, F.respond(view, [view.resolution.options[0]]), "estado_invalido")
	engine = _loaded(state)
	engine._combined_registry._operations.m1_refresh.execute = _refresh_rng_fault
	_reject(engine, F.advance(state, 1), "estado_invalido")
	# Una mutación estructuralmente válida también debe fallar sin azar.
	state = F.snapshot([3, 4, 8])
	F.at(state, 3, 3)
	engine = _loaded(state)
	engine._handlers[Play.ACTION_ID] = _delta_only.bind(engine._advance)
	_reject(engine, F.advance(state, 3), "estado_invalido")


static func _delta_only(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator, advance: Advance) -> String:
	var result: Dictionary = advance.advance(candidate, owner, payload.mission_id, rng)
	if not result.ok:
		return result.codigo
	candidate.merge(result.candidate, true)
	candidate.players[0].turn_resources.recursos += 1
	return ""


func _budgets() -> void:
	for number: int in [1, 2, 8]:
		var state: Dictionary = F.snapshot()
		F.at(state, number, 3 if number == 2 else 4)
		M1F.metals(state, 23)
		M2F.allies(state, 23, "p2")
		F.cards(state, 23, "p1_descarte")
		var needed: int = 2 if number == 2 else 3
		state.revision = Registry.MAX_INT - needed
		var engine: Play = _loaded(state)
		_expect(engine.submit("p1", F.advance(state, number)).ok, "INT-06 frontera suficiente de revisiones M%d" % number)
		var view: Dictionary = engine.get_view("p1")
		_expect(view.resolution.options.size() >= 23, "INT-06 más de16 candidatas completas M%d" % number)
		var pause: Dictionary = engine.get_authority_snapshot()
		engine = _loaded(pause)
		_settle(engine, "boundary")
		_expect(engine.get_authority_snapshot().resolution == null, "INT-06 cierre en límite")
		state.revision += 1
		engine = _loaded(state)
		_reject(engine, F.advance(state, number), "estado_invalido")
		# Carga de una pausa sin margen no publica estado parcial.
		pause.revision = Registry.MAX_INT
		_bad_load(pause, "INT-06 carga sin revisiones restantes")
	# M1 presupuesto completo para ambas ventanas, también límite de recibos.
	var state: Dictionary = F.snapshot()
	F.at(state, 1, 4)
	M1F.metals(state, 3)
	state.revision = 10000
	state.authority.receipts["p1"] = {}
	for index: int in 9998:
		state.authority.receipts.p1["receipt_%d" % index] = {"canonical": "x", "revision_aplicada": 1}
	var engine: Play = _loaded(state)
	_reject(engine, F.advance(state, 1), "estado_invalido")
	# auto_empty precisa una sola revisión en M1 y M2.
	for number: int in [1, 2]:
		state = F.snapshot()
		F.at(state, number, 3 if number == 2 else 4)
		state.revision = Registry.MAX_INT - 1
		engine = _loaded(state)
		_expect(engine.submit("p1", F.advance(state, number)).ok and engine.get_authority_snapshot().revision == Registry.MAX_INT, "INT-06 auto_empty una revisión")
	# M8 cima: los subconjuntos legales mueven hasta cuatro y luego uno.
	state = F.snapshot()
	F.at(state, 8, 11)
	_clear_cards(state)
	F.cards(state, 23)
	engine = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 8)).ok, "INT-06 cima M8 oferta completa")
	var view: Dictionary = engine.get_view("p1")
	_expect(view.resolution.options.size() == 23 and view.resolution.max == 4, "INT-06 cima admite cuatro sin truncado")
	_expect(engine.submit("p1", F.respond(view, view.resolution.options.slice(0, 4), "four")).ok, "INT-06 subconjunto cuatro")
	view = engine.get_view("p1")
	_expect(view.resolution.options.size() == 19 and view.resolution.max == 1, "INT-06 nueva oferta reconstruida")
	_expect(engine.submit("p1", F.respond(view, [view.resolution.options[-1]], "fifth")).ok and engine.get_authority_snapshot().zones.eliminadas.cards.size() == 5, "INT-06 extra quinto a destino común")


static func _nodes(value: Variant) -> int:
	var count: int = 1
	if value is Dictionary:
		for item: Variant in value.values():
			count += _nodes(item)
	elif value is Array:
		for item: Variant in value:
			count += _nodes(item)
	return count


static func _clear_allies(state: Dictionary) -> void:
	for id: String in state.instances.keys():
		if state.instances[id].definition_id == "test_ally":
			for zone: Dictionary in state.zones.values():
				zone.cards.erase(id)
			state.instances.erase(id)


func _view_budget() -> void:
	# Snapshot por debajo de 50k cuya proyección M2 supera exactamente el límite.
	# Mantiene ledger M1/M8 y marcas M3 presentes en pruebas de estado separadas.
	var state: Dictionary = F.snapshot()
	F.at(state, 1, 5)
	F.at(state, 8, 5)
	F.at(state, 2, 3)
	M2F.allies(state, 1, "p2")
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.advance(state, 2)).ok, "INT-06 frontera de vista origen")
	var boundary: Dictionary = engine.get_authority_snapshot()
	_clear_allies(boundary)
	boundary.resolution.pending = Play.M2._offer(boundary, boundary.resolution.context, {}, "test_ally")
	var constant: int = _nodes(Play.ViewBuilder.new().project(boundary, "p1", engine._content))
	M2F.allies(boundary, 1, "p2")
	boundary.resolution.pending = Play.M2._offer(boundary, boundary.resolution.context, {}, "test_ally")
	var per: int = _nodes(Play.ViewBuilder.new().project(boundary, "p1", engine._content)) - constant
	_clear_allies(boundary)
	M2F.allies(boundary, int(float(50001 - constant) / per), "p2")
	boundary.resolution.pending = Play.M2._offer(boundary, boundary.resolution.context, {}, "test_ally")
	var padding: int = 50001 - _nodes(Play.ViewBuilder.new().project(boundary, "p1", engine._content))
	if padding >= 5:
		boundary.players[0].metals.append({"token_id": "budget_available", "metal": "hierro", "exhausted": false, "used_this_turn": false})
		padding -= 5
	for name: String in ["hierro", "acero", "peltre", "estano", "bronce", "zinc", "laton", "atium"]:
		if padding <= 0:
			break
		boundary.players[0].burned[name] = 0
		padding -= 1
	_expect(padding == 0 and _nodes(Play.ViewBuilder.new().project(boundary, "p1", engine._content)) == 50001, "INT-06 vista exacta50001")
	_expect(engine._advance.state_error(boundary).is_empty() and not engine._fits(boundary), "INT-06 snapshot cabe pero vista actual no")
	_bad_load(boundary, "INT-06 vista actual no cabe aunque cierre reduzca oferta")
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
	_reject(engine, F.advance(initial, 2), "estado_invalido")
