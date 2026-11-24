extends SceneTree
## Variante explícita de ensayo: II se omite sólo en memoria, mercado/misiones
## son ficticios y los checkpoints de niveles no representan turnos jugados.

const Play = preload("res://scripts/game/initial_competitive_play.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const Bindings = preload("res://scripts/catalog/initial_competitive_bindings.gd")
const Base = preload("res://tests/funding_fixtures.gd")
const Seats = preload("res://tests/competitive_start_fixtures.gd")
var checks: int = 0
var failures: int = 0
var document: Dictionary
var manifest: Dictionary
var _prepared_seed: Dictionary = {}


class Source extends Play.SnapshotSource:
	var entry: Dictionary
	func _init(value: Dictionary) -> void:
		entry = value.duplicate(true)
	func latest(_match_id: String, _profile_id: String) -> Dictionary:
		return entry.duplicate(true)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	create_timer(60.0).timeout.connect(func() -> void:
		push_error("E1_PLAY_FAIL: tiempo máximo excedido.")
		quit(1))
	document = _catalog()
	manifest = _manifest()
	var validation: Dictionary = Play.Catalog.new().validate(document)
	if not validation.ok or not _engine().is_supported():
		push_error("E1_PLAY_FAIL: admisión inicial: " + str(validation.errors))
		quit(1)
		return
	_preparation_cases()
	_start_mark_cases()
	_primary_cases()
	_signature_cases()
	_atium_cases()
	_card_fuel_cases()
	_rejection_cases()
	_restore_cases()
	var disk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/inicio_competitivo.json"))
	for card: Dictionary in disk.cartas:
		_expect(card.revision.estado == "borrador", "La promoción existe exclusivamente en memoria: " + card.id)
		if card.tipo == "personaje":
			_expect(card.habilidades.size() == 3 and card.habilidades[1].id == "nivel_ii", "II permanece pendiente en autoría.")
	if failures == 0:
		print("P08_INITIAL_COMPETITIVE_PLAY_OK: ", checks, " comprobaciones; ensayo compuesto, sin producto ni nivel II.")
	quit(0 if failures == 0 else 1)


func _catalog() -> Dictionary:
	var result: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/inicio_competitivo.json"))
	result.id_catalogo = "initial_competitive_explicit_fixture_without_ii"
	for card: Dictionary in result.cartas:
		card.revision = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
		if card.tipo == "personaje":
			card.habilidades.remove_at(1)
		if card.tipo == "pista_entrenamiento":
			for cell: Dictionary in card.rasgos.recorridos[0].casillas:
				cell.efectos = [{"op": "sin_efecto"}]
	var template: Dictionary = Base.catalog()
	var source: Dictionary = template.fuentes[0].duplicate(true)
	source.tipo = "carta_fisica"
	source.sha256 = FileAccess.get_sha256(source.ruta)
	result.fuentes.append(source)
	var definitions: Dictionary = Base.definitions(template)
	for id: String in ["test_action", "test_ally"]:
		var inert: Dictionary = definitions[id].duplicate(true)
		if id == "test_action":
			inert.metales = ["peltre", "estano"]
		result.cartas.append(inert)
	for index: int in 8:
		var mission: Dictionary = definitions.test_mission.duplicate(true)
		mission.id = "fixture_mission_" + str(index)
		mission.habilidades = []
		mission.rasgos = {"recorridos": [{"id": "principal", "casillas": []}]}
		for position: int in 12:
			var cell: Dictionary = {"id": "p%02d" % (position + 1), "efectos": [], "primero": []}
			if position == 11:
				cell.efectos = [{"op": "ganar", "recurso": "ataque", "cantidad": 1, "objetivo": "propio"}]
				cell.permanente = null
			mission.rasgos.recorridos[0].casillas.append(cell)
		result.cartas.append(mission)
	return result


func _manifest() -> Dictionary:
	var result: Dictionary = {"characters": [], "funding_id": "financiacion", "training_track_id": "pista_entrenamiento",
		"market_cards": [], "missions": [], "rival": null}
	for owner: String in Bindings.STARTERS:
		result.characters.append({"character_id": owner, "starters": Bindings.STARTERS[owner].duplicate()})
	for index: int in 82:
		result.market_cards.append("test_action" if index < 41 else "test_ally")
	for index: int in 8:
		result.missions.append("fixture_mission_" + str(index))
	return result


func _engine() -> RefCounted:
	return Play.new(document, manifest)


func _preparation_cases() -> void:
	for count: int in [2, 3, 4]:
		var engine: RefCounted = _engine()
		_expect(engine.is_supported(), "Perfil compuesto cerrado admitido para ensayo.")
		var prepared: Dictionary = engine.prepare_match("e1_match", Seats.seats(count), "p1", 823)
		_expect(prepared.ok, "Preparación conectada para %d plazas." % count)
		if not prepared.ok:
			continue
		var state: Dictionary = engine.get_authority_snapshot()
		if count == 4:
			_prepared_seed = state.duplicate(true)
		_expect(state.players.size() == count and state.turn.phase == "inicio", "Preparación no salta el inicio.")
		for player: Dictionary in state.players:
			var cards: Array = Funding._zone(state, "mano", player.player_id).cards + Funding._zone(state, "mazo", player.player_id).cards
			var own: Array = []
			var coins: int = 0
			for id: String in cards:
				var definition: String = state.instances[id].definition_id
				if definition == "financiacion":
					coins += 1
				else:
					own.append(definition)
			own.sort()
			var expected: Array = Bindings.STARTERS[player.character_id].duplicate()
			expected.sort()
			_expect(own == expected and coins == 6 and Funding._zone(state, "mano", player.player_id).cards.size() == 5, "Mazo exacto y mano de cinco.")
		var intent: Dictionary = _intent(state, "inicio_unico", Play.START_TURN_ACTION, {"turn_number": 1})
		_expect(engine.start_turn("p1", intent).ok, "El primer turno avanza entrenamiento.")
		var started: Dictionary = engine.get_authority_snapshot()
		_expect(Funding._funding_player(started, "p1").training == 1 and started.turn.phase == "libre", "Inicio usa TrainingAdvance y abre libre.")
		_expect(engine.start_turn("p1", intent).ok and engine.get_authority_snapshot() == started, "Reenvío de inicio sin duplicación.")
		_assert_atomic(engine, "p1", _intent(started, "inicio_otra_vez", Play.START_TURN_ACTION, {"turn_number": 1}), true)
		var hand: Array = Funding._zone(started, "mano", "p1").cards
		var view: Dictionary = engine.get_view("p2")
		_expect(not JSON.stringify(view).contains(JSON.stringify(hand[0])), "La vista ajena no revela instancias de mano.")
	var wrong: Dictionary = manifest.duplicate(true)
	wrong.characters[0].starters[0] = wrong.characters[1].starters[0]
	var invalid: RefCounted = Play.new(document, wrong)
	_expect(not invalid.is_supported() and not invalid.prepare_match("e1_match", Seats.seats(2), "p1", 1).ok, "Guard de vínculos antes de GameSetup.")
	var changed: Dictionary = document.duplicate(true)
	changed.cartas[0].habilidades[0].efectos[0].cantidad += 1
	_expect(not Play.new(changed, manifest).is_supported(), "No se ejecuta un programa de efectos modificado.")


func _checkpoint(owner_character: String, training: int = 5, atium: bool = false) -> Dictionary:
	if _prepared_seed.is_empty():
		return {}
	var snapshot: Dictionary = _prepared_seed.duplicate(true)
	var player: Dictionary = {}
	for item: Dictionary in snapshot.players:
		if item.character_id == owner_character:
			player = item
	snapshot.turn.phase = "libre"
	snapshot.turn.number = 5
	snapshot.turn.active_id = player.player_id
	player.training = training
	player.burn_limit = 1 + (1 if training >= 3 else 0) + (1 if training >= 9 else 0) + (1 if training >= 15 else 0)
	player.health = 39
	if atium:
		player.persistent.atium = 1
		player.metals.append({"token_id": "fixture_atium", "metal": "atium", "exhausted": false, "used_this_turn": false})
	var hand: Array = []
	var deck: Array = []
	for card: Dictionary in snapshot.instances.values():
		if card.owner_id == player.player_id:
			if card.definition_id != "financiacion" or hand.size() == 0:
				hand.append(card.instance_id)
			else:
				deck.append(card.instance_id)
	# Exactamente cuatro Training y una Funding en mano; cinco Funding en mazo.
	if hand.size() == 4:
		hand.append(deck.pop_back())
	Funding._zone(snapshot, "mano", player.player_id).cards = hand
	Funding._zone(snapshot, "mazo", player.player_id).cards = deck
	return snapshot


func _from_checkpoint(snapshot: Dictionary) -> RefCounted:
	var engine: RefCounted = _engine()
	var entry: Dictionary = {"profile_id": engine.profile_identity(), "checkpoint": snapshot, "commands": [], "snapshot": snapshot}
	_expect(engine.restore_match("e1_match", Source.new(entry)).ok, "Checkpoint explícito de autoridad admitido para la prueba.")
	return engine


func _card(state: Dictionary, owner: String, definition: String) -> String:
	for id: String in Funding._zone(state, "mano", owner).cards:
		if state.instances[id].definition_id == definition:
			return id
	return ""


func _primary(state: Dictionary, definition: String, apply: bool = true, token: String = "") -> Dictionary:
	var metal: String = definition.get_slice("_", 1).replace("cinc", "zinc")
	return {"instance_id": _card(state, state.turn.active_id, definition), "aplicar": apply, "metal": metal if apply else null,
		"origen": {"tipo": "ficha", "id": "token_" + metal if token.is_empty() else token} if apply else {}}


func _start_mark_cases() -> void:
	for position: int in [2, 4, 10, 19, 20]:
		var checkpoint: Dictionary = _checkpoint("marsh", position)
		checkpoint.turn.phase = "inicio"
		var engine: RefCounted = _from_checkpoint(checkpoint)
		var actor: String = checkpoint.turn.active_id
		_expect(engine.start_turn(actor, _intent(checkpoint, "inicio_marca", Play.START_TURN_ACTION, {"turn_number": 5})).ok, "Inicio conecta marca de pista desde %d." % position)
		var after: Dictionary = engine.get_authority_snapshot()
		var player: Dictionary = Funding._funding_player(after, actor)
		_expect(player.training == mini(position + 1, 20) and after.turn.phase == "libre", "Posición de pista y apertura exactas.")
		_expect(player.persistent.atium == (1 if position in [10, 20] else 0), "Premio Atium de casilla o continuo sin duplicación.")


func _primary_cases() -> void:
	for character: String in Bindings.STARTERS:
		for definition: String in Bindings.STARTERS[character]:
			var engine: RefCounted = _from_checkpoint(_checkpoint(character))
			var state: Dictionary = engine.get_authority_snapshot()
			var actor: String = state.turn.active_id
			var payload: Dictionary = _primary(state, definition)
			var intent: Dictionary = _intent(state, "primaria", Play.PLAY, payload)
			_expect(engine.submit(actor, intent).ok, "Primaria alcanzable: " + definition)
			var after: Dictionary = engine.get_authority_snapshot()
			var player: Dictionary = Funding._funding_player(after, actor)
			var suffix: String = definition.get_slice("_", 1)
			var expected: Dictionary = {"recursos": 0, "ataque": 0, "mision": 2} if suffix in ["estano", "bronce"] else {"recursos": 1, "ataque": 0, "mision": 1} if suffix in ["cinc", "laton"] else {"recursos": 1, "ataque": 2, "mision": 0}
			_expect(player.turn_resources == expected and payload.instance_id in Funding._zone(after, "juego", actor).cards, "Efectos exactos y movimiento de " + definition)
			_expect(player.burned == {payload.metal: 1}, "La primaria registra el metal ordinario.")
			for token: Dictionary in player.metals:
				if token.token_id == payload.origen.id:
					_expect(token.used_this_turn and not token.exhausted, "Quema ordinaria conserva agotamiento persistente.")
			_expect(engine.submit(actor, intent).ok and engine.get_authority_snapshot() == after, "Reenvío de primaria idempotente.")
			_assert_atomic(engine, actor, _intent(after, "repetir_carta", Play.PLAY, payload))
	var omitted: RefCounted = _from_checkpoint(_checkpoint("kelsier"))
	var before: Dictionary = omitted.get_authority_snapshot()
	_expect(omitted.submit(before.turn.active_id, _intent(before, "omitir", Play.PLAY, _primary(before, "kelsier_estano", false))).ok, "Omisión mueve Training sin metal.")
	var player: Dictionary = Funding._funding_player(omitted.get_authority_snapshot(), before.turn.active_id)
	_expect(player.burned.is_empty() and player.turn_resources == {"recursos": 0, "ataque": 0, "mision": 0}, "Omitir conserva fichas y reservas.")
	for apply: bool in [true, false]:
		var engine: RefCounted = _from_checkpoint(_checkpoint("marsh"))
		var state: Dictionary = engine.get_authority_snapshot()
		var actor: String = state.turn.active_id
		var payload: Dictionary = {"instance_id": _card(state, actor, "financiacion"), "aplicar": apply}
		_expect(engine.submit(actor, _intent(state, "funding", Funding.ACTION_ID, payload)).ok, "Funding aplica/omite en el mismo perfil.")
		_expect(Funding._funding_player(engine.get_authority_snapshot(), actor).turn_resources.recursos == (1 if apply else 0), "Funding concede exactamente su moneda.")


func _signature_cases() -> void:
	for character: String in Bindings.STARTERS:
		var engine: RefCounted = _from_checkpoint(_checkpoint(character, 5))
		var state: Dictionary = engine.get_authority_snapshot()
		var actor: String = state.turn.active_id
		var definition: String = character + "_" + Play.SIGNATURES[character].replace("zinc", "cinc")
		_expect(engine.submit(actor, _intent(state, "metal_firma", Play.PLAY, _primary(state, definition))).ok, "Quema el metal de firma: " + character)
		var before: Dictionary = engine.get_authority_snapshot()
		_expect(engine.submit(actor, _intent(before, "firma_i", Play.CHARACTER, {"nivel": 1, "aplicar": true})).ok, "Firma I alcanzable: " + character)
		var after: Dictionary = engine.get_authority_snapshot()
		var old_player: Dictionary = Funding._funding_player(before, actor)
		var player: Dictionary = Funding._funding_player(after, actor)
		var gains: Dictionary = {"kelsier": [0, 2, 0], "marsh": [0, 0, 1], "shan": [2, 0, 0], "vin": [1, 1, 0]}
		_expect(player.turn_resources.recursos - old_player.turn_resources.recursos == gains[character][0]
			and player.turn_resources.ataque - old_player.turn_resources.ataque == gains[character][1]
			and player.turn_resources.mision - old_player.turn_resources.mision == gains[character][2], "Firma I aplica su vector exacto.")
		_expect(player.health == (40 if character == "vin" else 39), "Vin cura hasta el máximo.")
		_assert_atomic(engine, actor, _intent(after, "firma_repetida", Play.CHARACTER, {"nivel": 1, "aplicar": true}))
	var vin: Dictionary = _checkpoint("vin", 5)
	Funding._funding_player(vin, vin.turn.active_id).health = 40
	var engine: RefCounted = _from_checkpoint(vin)
	_expect(engine.submit(vin.turn.active_id, _intent(vin, "metal_vin", Play.PLAY, _primary(vin, "vin_peltre"))).ok, "Vin quema Peltre a salud máxima.")
	var state: Dictionary = engine.get_authority_snapshot()
	_expect(engine.submit(state.turn.active_id, _intent(state, "firma_vin", Play.CHARACTER, {"nivel": 1, "aplicar": true})).ok
		and Funding._funding_player(engine.get_authority_snapshot(), state.turn.active_id).health == 40, "Vin nunca supera 40.")
	for training: int in [0, 4]:
		var blocked: RefCounted = _from_checkpoint(_checkpoint("marsh", training))
		var before: Dictionary = blocked.get_authority_snapshot()
		_expect(blocked.submit(before.turn.active_id, _intent(before, "metal_bloqueado", Play.PLAY, _primary(before, "marsh_bronce"))).ok, "Quema previa con nivel I bloqueado.")
		before = blocked.get_authority_snapshot()
		_assert_atomic(blocked, before.turn.active_id, _intent(before, "nivel_bloqueado", Play.CHARACTER, {"nivel": 1, "aplicar": true}))


func _atium_cases() -> void:
	for character: String in Bindings.STARTERS:
		var engine: RefCounted = _from_checkpoint(_checkpoint(character, 13, true))
		var state: Dictionary = engine.get_authority_snapshot()
		var actor: String = state.turn.active_id
		var definition: String = Bindings.STARTERS[character][0]
		_expect(engine.submit(actor, _intent(state, "quemar_atium", Play.PLAY, _primary(state, definition, true, "fixture_atium"))).ok, "Atium sustituye la primaria de " + character)
		var before: Dictionary = engine.get_authority_snapshot()
		_expect(engine.submit(actor, _intent(before, "firma_iii", Play.CHARACTER, {"nivel": 3, "aplicar": true})).ok, "Nivel III se activa tras Atium sustituto.")
		var after: Dictionary = engine.get_authority_snapshot()
		var old_player: Dictionary = Funding._funding_player(before, actor)
		var player: Dictionary = Funding._funding_player(after, actor)
		_expect(player.turn_resources.ataque == old_player.turn_resources.ataque + 3 and player.turn_resources.mision == old_player.turn_resources.mision + 3, "III reserva tres de combate y misión.")
		_expect(player.burned.atium == 1 and player.persistent.atium == 1, "Atium usado se conserva hasta limpieza pendiente.")
		_assert_atomic(engine, actor, _intent(after, "repetir_iii", Play.CHARACTER, {"nivel": 3, "aplicar": true}))
		_assert_atomic(engine, actor, _intent(after, "atium_reutilizado", Play.PLAY, _primary(after, Bindings.STARTERS[character][1], true, "fixture_atium")))
	var capacity: RefCounted = _from_checkpoint(_checkpoint("kelsier", 1, true))
	var state: Dictionary = capacity.get_authority_snapshot()
	var actor: String = state.turn.active_id
	_expect(capacity.submit(actor, _intent(state, "llenar_capacidad", Play.PLAY, _primary(state, "kelsier_estano"))).ok, "Una ficha llena capacidad inicial.")
	var after: Dictionary = capacity.get_authority_snapshot()
	_assert_atomic(capacity, actor, _intent(after, "atium_excede", Play.PLAY, _primary(after, "kelsier_cobre", true, "fixture_atium")))
	_assert_atomic(capacity, actor, _intent(after, "iii_bloqueado", Play.CHARACTER, {"nivel": 3, "aplicar": true}))
	var blocked: RefCounted = _from_checkpoint(_checkpoint("marsh", 12, true))
	state = blocked.get_authority_snapshot()
	_expect(blocked.submit(state.turn.active_id, _intent(state, "atium_sin_iii", Play.PLAY, _primary(state, "marsh_bronce", true, "fixture_atium"))).ok, "Atium se quema antes del umbral III.")
	after = blocked.get_authority_snapshot()
	_assert_atomic(blocked, after.turn.active_id, _intent(after, "iii_umbral", Play.CHARACTER, {"nivel": 3, "aplicar": true}))


func _fuel_checkpoint(foreign: bool = false) -> Dictionary:
	var state: Dictionary = _checkpoint("kelsier", 13)
	var owner: String = state.turn.active_id
	if foreign:
		owner = "p1" if owner != "p1" else "p2"
	for id: String in state.zones.mazo_mercado.cards:
		if state.instances[id].definition_id == "test_action":
			state.instances[id].owner_id = owner
			state.zones.mazo_mercado.cards.erase(id)
			Funding._zone(state, "mano", owner).cards.append(id)
			break
	return state


func _card_fuel_cases() -> void:
	var checkpoint: Dictionary = _fuel_checkpoint()
	var engine: RefCounted = _from_checkpoint(checkpoint)
	var actor: String = checkpoint.turn.active_id
	var fuel: String = _card(checkpoint, actor, "test_action")
	var payload: Dictionary = _primary(checkpoint, "kelsier_estano")
	payload.origen = {"tipo": "carta", "id": fuel}
	_expect(engine.submit(actor, _intent(checkpoint, "combustible_carta", Play.PLAY, payload)).ok, "Una Acción ficticia propia alimenta la primaria compatible.")
	var after: Dictionary = engine.get_authority_snapshot()
	var player: Dictionary = Funding._funding_player(after, actor)
	_expect(Funding._zone(after, "juego", actor).cards.size() == 2 and after.instances[fuel].state.flags == {"e1_metal_estano": true}, "Combustible y Training pasan a juego por rutas distintas.")
	_expect(player.turn_resources == {"recursos": 0, "ataque": 0, "mision": 2} and player.burned == {"estano": 1}, "Combustible no ejecuta primaria y cuenta como metal quemado.")
	for token: Dictionary in player.metals:
		_expect(not token.used_this_turn, "Usar carta como metal no consume una ficha.")
	var restored: RefCounted = _engine()
	_expect(restored.restore_match("e1_match", Source.new(engine.export_authority_entry())).ok and restored.get_authority_snapshot() == after, "Ruta de combustible se restaura con el mismo estado.")
	var wrong: RefCounted = _from_checkpoint(checkpoint)
	var incompatible: Dictionary = _primary(checkpoint, "kelsier_cobre")
	incompatible.origen = {"tipo": "carta", "id": fuel}
	_assert_atomic(wrong, actor, _intent(checkpoint, "carta_incompatible", Play.PLAY, incompatible))
	var foreign: Dictionary = _fuel_checkpoint(true)
	var foreign_engine: RefCounted = _from_checkpoint(foreign)
	var foreign_owner: String = "p1" if actor != "p1" else "p2"
	var foreign_payload: Dictionary = _primary(foreign, "kelsier_estano")
	foreign_payload.origen = {"tipo": "carta", "id": _card(foreign, foreign_owner, "test_action")}
	_assert_atomic(foreign_engine, actor, _intent(foreign, "carta_ajena", Play.PLAY, foreign_payload))


func _rejection_cases() -> void:
	var engine: RefCounted = _from_checkpoint(_checkpoint("kelsier", 13, true))
	var state: Dictionary = engine.get_authority_snapshot()
	var actor: String = state.turn.active_id
	var valid: Dictionary = _primary(state, "kelsier_estano")
	for invalid: Dictionary in [
		{"instance_id": valid.instance_id, "aplicar": true, "metal": "estano", "origen": {"tipo": "ficha", "id": "token_cobre"}},
		{"instance_id": valid.instance_id, "aplicar": true, "metal": "atium", "origen": {"tipo": "ficha", "id": "fixture_atium"}},
		{"instance_id": valid.instance_id, "aplicar": false, "metal": "estano", "origen": {}},
		{"instance_id": valid.instance_id, "aplicar": true, "metal": "estano", "origen": {"tipo": "carta", "id": valid.instance_id}},
		{"instance_id": valid.instance_id, "aplicar": true, "metal": "estano", "origen": {"tipo": "carta", "id": "ausente"}},
	]:
		_assert_atomic(engine, actor, _intent(state, "invalida", Play.PLAY, invalid))
	_assert_atomic(engine, actor, _intent(state, "sin_quema", Play.CHARACTER, {"nivel": 1, "aplicar": true}))
	_assert_atomic(engine, actor, _intent(state, "ii_no_contratado", Play.CHARACTER, {"nivel": 2, "aplicar": true}))
	_assert_atomic(engine, actor, _intent(state, "comprar", "comprar_carta", {}))
	_assert_atomic(engine, actor, _intent(state, "limpieza_no_contratada", "cerrar_limpieza", {}))
	_assert_atomic(engine, "p1" if actor != "p1" else "p2", _intent(state, "fuera_de_turno", Play.PLAY, valid))
	var original: Dictionary = engine.get_authority_snapshot()
	engine._state._snapshot.players[0].turn_resources.recursos = Play.Registry.MAX_INT
	var excessive: Dictionary = engine.get_authority_snapshot()
	var other: String = excessive.players[0].player_id
	if other != actor:
		engine._state._snapshot.turn.active_id = other
		excessive = engine.get_authority_snapshot()
	var funding: String = _card(excessive, other, "financiacion")
	_assert_atomic(engine, other, _intent(excessive, "desbordar", Funding.ACTION_ID, {"instance_id": funding, "aplicar": true}))
	engine._state._snapshot = original
	engine._handlers[Play.PLAY] = func(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
		var error: String = engine._training(candidate, owner, payload, rng)
		rng.randi()
		return error
	_assert_atomic(engine, actor, _intent(state, "rng_ajeno", Play.PLAY, valid))
	engine._handlers[Play.PLAY] = engine._training
	engine._content.financiacion.texto_original = "Cambio posterior al perfil"
	_assert_atomic(engine, actor, _intent(state, "perfil_mutado", Play.PLAY, valid))


func _restore_cases() -> void:
	var engine: RefCounted = _from_checkpoint(_checkpoint("marsh", 13, true))
	var state: Dictionary = engine.get_authority_snapshot()
	var actor: String = state.turn.active_id
	var command: Dictionary = _intent(state, "persistir", Play.PLAY, _primary(state, "marsh_bronce", true, "fixture_atium"))
	_expect(engine.submit(actor, command).ok, "Acción confirmada antes de restaurar.")
	var next: Dictionary = engine.get_authority_snapshot()
	_expect(engine.submit(actor, _intent(next, "firma_persistida", Play.CHARACTER, {"nivel": 3, "aplicar": true})).ok, "Firma confirmada antes de restaurar.")
	var entry: Dictionary = engine.export_authority_entry()
	var restored: RefCounted = _engine()
	_expect(restored.restore_match("e1_match", Source.new(entry)).ok and restored.get_authority_snapshot() == entry.snapshot, "Restauración reproduce acciones, recibos, RNG y límites.")
	_expect(restored.submit(actor, command).ok and restored.get_authority_snapshot() == entry.snapshot, "Reenvío tras restaurar conserva snapshot.")
	var changed: Dictionary = command.duplicate(true)
	changed.payload.aplicar = false
	_assert_atomic(restored, actor, changed)
	for field: String in ["resources", "burned", "mark", "used", "limit", "receipt", "profile", "checkpoint", "turn"]:
		var bad: Dictionary = entry.duplicate(true)
		var player: Dictionary = Funding._funding_player(bad.snapshot, actor)
		match field:
			"resources": player.turn_resources.mision += 1
			"burned": player.burned.atium = 0
			"mark": player.ability_uses.e1_nivel_3 += 1
			"used": player.metals.back().used_this_turn = false
			"limit": player.burn_limit += 1
			"receipt": bad.snapshot.authority.receipts[actor].persistir.revision_aplicada += 1
			"profile": bad.profile_id = "ajeno"
			"checkpoint": Funding._funding_player(bad.checkpoint, actor).metals.back().exhausted = true
			"turn": bad.checkpoint.turn.number = 0
		var rejected: RefCounted = _engine()
		_expect(not rejected.restore_match("e1_match", Source.new(bad)).ok and rejected.get_authority_snapshot().is_empty(), "Restauración atómica rechaza alteración: " + field)
	var duplicate: Dictionary = entry.duplicate(true)
	duplicate.commands.append(duplicate.commands[0])
	_expect(not _engine().restore_match("e1_match", Source.new(duplicate)).ok, "Registro duplicado no produce otra aplicación.")
	_expect(not _engine().load_authority_snapshot(entry.snapshot).ok, "No hay carga pública directa de snapshots.")


func _intent(state: Dictionary, id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision, "tipo": kind, "payload": payload}


func _assert_atomic(engine: RefCounted, actor: String, intent: Dictionary, starting: bool = false) -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	var result: Dictionary = engine.start_turn(actor, intent) if starting else engine.submit(actor, intent)
	_expect(not result.ok, "Entrada inválida rechazada: " + intent.action_id)
	_expect(engine.get_authority_snapshot() == before, "Rechazo conserva estado, RNG y recibos: " + intent.action_id)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("E1_PLAY_FAIL: " + message)
