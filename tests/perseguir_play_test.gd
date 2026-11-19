extends SceneTree

const F = preload("res://tests/perseguir_fixtures.gd")
const Play = preload("res://scripts/game/perseguir_play.gd")
const Rules = preload("res://scripts/game/perseguir_rules.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	print("PER_STAGE: admission")
	_admission()
	for count: int in [2, 3, 4]:
		print("PER_STAGE: routes/%d" % count)
		_routes(count)
	print("PER_STAGE: rejections")
	_rejections()
	print("PER_STAGE: restoration")
	_restoration()
	print("PER_STAGE: missions")
	_m1_after_ordinary_burn()
	_missions()
	if _failures == 0:
		print("P08_PERSEGUIR_PLAY_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("PER_FAIL: " + label)


func _loaded(state: Dictionary) -> Play:
	var engine: Play = F.engine()
	var source = F.F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var result: Dictionary = engine.restore_match(state.match_id, source)
	_expect(result.ok, "carga fiable: " + str(result.get("errors", [])))
	return engine


func _bad_load(state: Dictionary, label: String) -> void:
	var engine: Play = F.engine()
	var source = F.F.Missions.LatestSource.new()
	source.confirm(engine.profile_identity(), state)
	var before: Dictionary = state.duplicate(true)
	_expect(not engine.restore_match(state.match_id, source).ok and engine.get_authority_snapshot().is_empty() and state == before, "carga rechazada: " + label)


func _reject(engine: Play, action: Dictionary, label: String, actor: String = "p1") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.submit(actor, action)
	_expect(not result.ok and before == engine.get_authority_snapshot(), "rechazo atomico: " + label + " " + str(result))


func _admission() -> void:
	_expect(F.engine().is_supported(), "PER-01 perfil soportado")
	var actual: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/perseguir.json"))
	_expect(not Play.new(actual, {}, {}, {}).is_supported(), "borrador/fuera de perfil no se promueve")
	var catalog: Dictionary = F.catalog()
	_expect(not F.F.engine(catalog).is_supported(), "perfil integrado anterior rechaza Perseguir")
	for kind: String in ["draft", "version", "source", "other_source", "primary", "savant", "sense", "quantity", "metals", "copy", "observer"]:
		var document: Dictionary = F.catalog()
		var card: Dictionary = document.cartas[-1]
		match kind:
			"draft": card.revision.estado = "borrador"
			"version": document.version_esquema = 3
			"source": document.fuentes[-1].sha256 = "0".repeat(64)
			"other_source":
				document.fuentes[-1].ruta = "res://tests/perseguir_fixtures.gd"
				document.fuentes[-1].sha256 = FileAccess.get_sha256(document.fuentes[-1].ruta)
			"primary": card.habilidades[0].condicion = {"op": "metales_quemados", "metales": ["bronce"]}
			"savant": card.habilidades[1].condicion = {"op": "siempre"}
			"sense": card.habilidades[0].efectos[0].cantidad = 3
			"quantity": card.cantidad = 2
			"metals": card.metales = ["bronce"]
			"copy": card.vinculos = ["test_action"]
			"observer": document.cartas[8].habilidades[0].efectos = [{"op": "ganar", "recurso": "mision", "cantidad": 1, "objetivo": "propio"}]
		_expect(not F.engine(document).is_supported(), "PER-01 perfil rechaza " + kind)
	var engine: Play = F.engine()
	var state: Dictionary = F.snapshot()
	_expect(not engine.load_authority_snapshot(state).ok and not engine.restore_match(state.match_id, state).ok, "PER-06 sólo SnapshotSource tipada")
	var source = F.F.Missions.LatestSource.new()
	source.confirm("foreign", state)
	_expect(not engine.restore_match(state.match_id, source).ok, "perfil fuente exacto")


func _routes(count: int) -> void:
	for mode: String in ["bronce_p1", "atium_1", "c2", "omit", "cobre", "bronce", "savant_omit"]:
		var state: Dictionary = F.snapshot(count)
		var payload: Dictionary = F.payload()
		if mode in ["atium_1", "c2"]:
			payload = F.payload("primaria", true, mode)
		elif mode == "omit":
			payload = F.payload("primaria", false, "", null)
		elif mode in ["cobre", "bronce", "savant_omit"]:
			payload = F.payload("metal", mode != "savant_omit", "", "cobre" if mode == "savant_omit" else mode)
		var engine: Play = _loaded(state)
		var action: Dictionary = F.intent(state, payload)
		var result: Dictionary = engine.submit("p1", action)
		_expect(result.ok, "PER-02/03 ruta %s/%d: %s" % [mode, count, str(result)])
		var after: Dictionary = engine.get_authority_snapshot()
		if not result.ok:
			continue
		var mission: int = 0 if mode in ["omit", "savant_omit"] else (1 if mode in ["cobre", "bronce"] else 2)
		_expect(after.players[0].turn_resources.mision == mission and after.players[0].turn_resources.recursos == (2 if mode in ["bronce_p1", "atium_1", "c2"] else 0) and after.players[0].persistent.boxings == state.players[0].persistent.boxings, "ganancias exactas sin Boxings")
		_expect(after.missions == state.missions and after.authority.rng_state == state.authority.rng_state and after.authority.completed_sequences == state.authority.completed_sequences, "reserva no avanza ni concede premio/azar")
		_expect("c1" not in after.zones.p1_mano.cards and after.zones.p1_juego.cards.count("c1") == 1 and after.instances.c1.state.ability_uses == {Rules.MARK: 1}, "movimiento y cierre único")
		var used: int = 0
		for token: Dictionary in after.players[0].metals:
			if token.used_this_turn:
				used += 1
				_expect(not token.exhausted, "quema ordinaria y Atium conservan la ficha sin agotar")
		_expect(used == (1 if mode in ["bronce_p1", "atium_1"] else 0), "carta y omisiones no consumen cupo")
		_expect(("c2" in after.zones.p1_juego.cards) == (mode == "c2"), "combustible se mueve sólo cuando alimenta")
		_expect(engine.submit("p1", action) == result and after == engine.get_authority_snapshot(), "PER-05 reenvío idempotente")
		_reject(engine, F.intent(after, payload, "new_id"), "instancia consumida")
		var restored: Play = _loaded(after)
		_expect(restored.get_authority_snapshot() == after and restored.submit("p1", action) == result, "PER-06 restauración sin reaplicar")
		var view: Dictionary = engine.get_view("p2")
		var text_view: String = JSON.stringify(view)
		_expect(not text_view.contains("perseguir_revision") and not text_view.contains("canonical") and not text_view.contains("rng_state") and not text_view.contains("ability_uses"), "PER-07 marcas/recibos/RNG privados")
		_expect(mode == "c2" or not text_view.contains('"c2"'), "tercero no recibe combustible oculto en mano")
		_expect(not JSON.stringify(engine.get_view("p1")).contains("perseguir_revision"), "propietario no recibe marcas")


func _rejections() -> void:
	for kind: String in ["extra", "partial", "receptor", "flaring", "old_burn", "spent", "exhausted", "limit", "self", "foreign", "zone", "resource", "mission", "revision", "phase", "dead"]:
		var state: Dictionary = F.snapshot()
		var payload: Dictionary = F.payload()
		match kind:
			"extra": payload["ganancia"] = 2
			"partial": payload.aplicar = "mision"
			"receptor": payload = F.payload("metal"); payload["receptora"] = "c2"
			"flaring": payload.origen["flaring"] = true
			"old_burn": payload.origen.id = "cobre_1"
			"spent", "limit":
				if kind == "spent":
					state.players[0].metals[-1].used_this_turn = true
					state.players[0].burned["bronce"] = 1
				else:
					state.players[0].metals[0].used_this_turn = true
					state.players[0].burned["cobre"] = 1
			"exhausted": state.players[0].metals[-1].exhausted = true
			"self": payload.origen = {"tipo": "carta", "id": "c1"}
			"foreign": payload.instance_id = "absent"
			"zone": state.zones.p1_mano.cards.erase("c1"); state.zones.p1_mazo.cards.append("c1")
			"resource": state.players[0].turn_resources.recursos = Registry.MAX_INT - 1
			"mission": state.players[0].turn_resources.mision = Registry.MAX_INT - 1
			"revision": state.revision = Registry.MAX_INT
			"phase": state.turn.phase = "inicio"
			"dead": state.players[1].health = 0; state.players[1].eliminated = true
		if kind == "dead":
			_bad_load(state, "menos de dos vivos")
			continue
		var engine: Play = _loaded(state)
		_reject(engine, F.intent(state, payload), kind)
	var state: Dictionary = F.snapshot()
	var engine: Play = _loaded(state)
	_reject(engine, F.intent(state, F.payload()), "plaza ajena", "p2")
	# El combustible no utiliza cupo aunque ya esté lleno.
	state.players[0].metals[0].used_this_turn = true
	state.players[0].burned["cobre"] = 1
	engine = _loaded(state)
	_expect(engine.submit("p1", F.intent(state, F.payload("primaria", true, "c2"))).ok, "carta combustible con cupo de fichas lleno")
	# Un manejador sustituido no puede ganar recursos ni mover cartas adicionales.
	engine = _loaded(F.snapshot())
	engine._handlers[Rules.ACTION] = _forged_handler
	_reject(engine, F.intent(engine.get_authority_snapshot(), F.payload()), "manejador alterado")


func _forged_handler(candidate: Dictionary, _actor: String, _payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	candidate.players[0].turn_resources.mision += 99
	return ""


func _restoration() -> void:
	var engine: Play = _loaded(F.snapshot())
	_expect(engine.submit("p1", F.intent(engine.get_authority_snapshot(), F.payload())).ok, "semilla restauración")
	var confirmed: Dictionary = engine.get_authority_snapshot()
	for kind: String in ["mark", "receipt", "canonical", "revision", "hand", "used", "exhausted", "burned", "unknown", "second", "ledger"]:
		var state: Dictionary = confirmed.duplicate(true)
		match kind:
			"mark": state.instances.c1.state.ability_uses.clear()
			"receipt": state.authority.receipts.clear()
			"canonical": state.authority.receipts.p1.perseguir.canonical = "invalid"
			"revision": state.instances.c1.state.ability_uses[Rules.MARK] = 0
			"hand": state.zones.p1_juego.cards.erase("c1"); state.zones.p1_mano.cards.append("c1")
			"used": state.players[0].metals[-1].used_this_turn = false; state.players[0].burned.clear()
			"exhausted": state.players[0].metals[-1].exhausted = true
			"burned": state.players[0].burned.bronce = 2
			"unknown": state.instances.c2.state.flags["sense"] = true
			"second": state.instances.c2.definition_id = "perseguir"
			"ledger": state.authority.completed_sequences["fake"] = {}
		_bad_load(state, kind)
	# Fuente y descriptores se vuelven a comprobar en la autoridad.
	engine._catalog.fuentes[-1].sha256 = "0".repeat(64)
	_reject(engine, F.intent(confirmed, F.payload(), "source_changed"), "fuente cambiada")


func _missions() -> void:
	var state: Dictionary = F.snapshot()
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.intent(state, F.payload())).ok, "ganancia previa a gasto")
	for number: int in [1, 5]:
		state = engine.get_authority_snapshot()
		_expect(engine.submit("p1", F.F.advance(state, number, "spend_%d" % number)).ok, "PER-04 gasto uno en misión distinta")
	_expect(engine.get_authority_snapshot().players[0].turn_resources.mision == 0, "reserva gastada exactamente")
	state = F.snapshot()
	F.F.at(state, 8, 4)
	engine = _loaded(state)
	_expect(engine.submit("p1", F.intent(state, F.payload("metal"))).ok, "Savant antes de M8")
	state = engine.get_authority_snapshot()
	_expect(engine.submit("p1", F.F.advance(state, 8, "m8")).ok, "M8 abre elección tras ganar")
	var owner_view: Dictionary = engine.get_view("p1")
	_expect(owner_view.resolution != null and not engine.get_view("p2").resolution.has("options"), "elección M8 privada")
	_reject(engine, F.intent(engine.get_authority_snapshot(), F.payload(), "blocked"), "resolución incompatible")
	# Selecciona la instancia ya jugada por su correspondencia privada autorizada.
	var selected: String = ""
	for option: Dictionary in owner_view.resolution.option_cards:
		if option.instance_id == "c1": selected = option.option_id
	_expect(not selected.is_empty(), "M8 ofrece Perseguir en juego")
	if not selected.is_empty():
		_expect(engine.submit("p1", F.F.respond(owner_view, [selected], "eliminate")).ok, "M8 elimina carta jugada")
		owner_view = engine.get_view("p1")
		if owner_view.resolution != null:
			_expect(engine.submit("p1", F.F.respond(owner_view, [], "omit_extra")).ok, "omitir extra M8")
		state = engine.get_authority_snapshot()
		_expect("c1" in state.zones.eliminadas.cards, "Perseguir eliminada mantiene cierre")
		_loaded(state)
	state = F.snapshot()
	F.F.at(state, 1, 12)
	F.F.at(state, 5, 12)
	F.F.at(state, 8, 11)
	engine = _loaded(state)
	_expect(engine.submit("p1", F.intent(state, F.payload())).ok, "primaria antes de tercera cima")
	state = engine.get_authority_snapshot()
	_expect(engine.submit("p1", F.F.advance(state, 8, "third_summit")).ok, "PER-04 tercera cima")
	state = engine.get_authority_snapshot()
	_expect(state.lifecycle == "finalizada" and state.outcome.winner_id == "p1" and state.resolution == null and "p12_normal" not in state.missions.mission_8.rewards.p1 and "p12_primero" not in state.missions.mission_8.rewards.p1, "victoria antes de premios finales")


func _m1_after_ordinary_burn() -> void:
	var state: Dictionary = F.snapshot()
	F.F.at(state, 1, 4)
	var engine: Play = _loaded(state)
	_expect(engine.submit("p1", F.intent(state, F.payload())).ok, "quema bronce antes de premio M1")
	state = engine.get_authority_snapshot()
	var token: Dictionary = state.players[0].metals[-1]
	_expect(token.used_this_turn and not token.exhausted, "bronce usado no genera agotamiento persistente")
	_expect(engine.submit("p1", F.F.advance(state, 1, "m1_after_burn")).ok, "M1 p5 tras quema ordinaria")
	state = engine.get_authority_snapshot()
	_expect(state.resolution == null and state.missions.mission_1.progress.p1 == 5, "M1 cierra sin oferta de refresco espuria")
	token = state.players[0].metals[-1]
	_expect(token.used_this_turn and not token.exhausted, "M1 no habilita reutilizar bronce ya usado")
	_loaded(state)
