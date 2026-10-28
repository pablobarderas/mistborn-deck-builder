extends SceneTree

const Setup = preload("res://scripts/game/game_setup.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var definitions: Dictionary = _definitions()
	var manifest: Dictionary = _manifest()
	for mode: String in ["competitivo", "cooperativo", "solitario"]:
		var counts: Array = [1] if mode == "solitario" else [2, 3, 4]
		for count: int in counts:
			_test_mode(definitions, manifest, mode, count)
	_test_errors(definitions, manifest)
	if failures == 0:
		print("P08_SETUP_OK: %d comprobaciones." % checks)
	else:
		push_error("P08 preparación: %d fallos en %d comprobaciones." % [failures, checks])
	quit(0 if failures == 0 else 1)


func _test_mode(definitions: Dictionary, manifest: Dictionary, mode: String, count: int) -> void:
	var local_manifest: Dictionary = manifest.duplicate(true)
	if mode == "competitivo":
		local_manifest.rival = null
	var seats: Array = _seats(count)
	var first: Variant = "p2" if mode == "competitivo" else null
	var setup: RefCounted = Setup.new(definitions, "test_catalog")
	var original: Dictionary = local_manifest.duplicate(true)
	var result: Dictionary = setup.create("match_1", mode, seats, first, local_manifest, 12345)
	_expect(result.ok, "%s %d: preparación aceptada" % [mode, count])
	if not result.ok:
		return
	var state: Dictionary = result.snapshot
	_expect(Validator.new().validate(state, definitions, "test_catalog").ok, "Snapshot válido")
	_expect(state == setup.create("match_1", mode, seats, first, local_manifest, 12345).snapshot, "Misma semilla reproduce snapshot")
	_expect(local_manifest == original and definitions == _definitions(), "Entradas sin mutar")
	_expect(state.players.size() == count and state.instances.size() == 82 + 10 * count + (0 if mode == "competitivo" else 36), "Instancias físicas correctas")
	_expect(state.zones.mercado.cards.size() == 6 and state.zones.mazo_mercado.cards.size() == 76, "Mercado seis de 82")
	_expect(state.missions.size() == 3 and _mission_defs(state).size() == 3, "Tres misiones distintas")
	_expect(state.turn.phase == "inicio" and state.turn.number == 1 and state.turn.active_id == state.player_order[0], "Entrenamiento inicial aún pendiente")
	_expect(state.authority.rng_state != state.authority.rng_seed and state.authority.next_id == state.instances.size() + 1, "RNG e IDs guardados")
	for player: Dictionary in state.players:
		var id: String = player.player_id
		_expect(player.metals.size() == 8 and player.training == 0 and player.burn_limit == 1, "Metales y entrenamiento iniciales")
		_expect(state.zones[id + "_mano"].cards.size() == 5 and state.zones[id + "_mazo"].cards.size() == 5, "Mano inicial de cinco")
		var rank: int = state.player_order.find(id)
		var expected_health: int = 36
		if mode == "competitivo":
			if rank == 1:
				expected_health = 38
			elif rank >= 2:
				expected_health = 40
		_expect(player.health == expected_health and player.persistent.boxings == (1 if mode == "competitivo" and rank == 3 else 0), "Bonificación por puesto/mode")
	if mode == "competitivo":
		_expect(state.player_order[0] == "p2" and state.target_id == (state.player_order.back() if count >= 3 else null) and state.rival == null, "Primer jugador elegido y Target condicional")
	else:
		_expect(state.player_order[0] in ["p1", "p2", "p3", "p4"] and state.target_id == null, "Primer jugador sorteado sin Target")
		_expect(state.rival.health == 48 and state.rival.domination.visible_value == 1 and state.zones.mazo_rival.cards.size() == 36, "Rival inicial completo")


func _test_errors(definitions: Dictionary, manifest: Dictionary) -> void:
	var setup: RefCounted = Setup.new(definitions, "test_catalog")
	var seats: Array = _seats(2)
	var competitive: Dictionary = manifest.duplicate(true)
	competitive.rival = null
	for request: Array in [["competitivo", null], ["cooperativo", "p1"], ["solitario", null], ["desconocido", "p1"]]:
		var result: Dictionary = setup.create("match_1", request[0], seats, request[1], competitive, 3)
		_expect(not result.ok and not result.has("snapshot"), "Modo/primer jugador inválido no crea estado")
	var bad_seats: Array = _seats(2)
	bad_seats[1].player_id = "p1"
	_expect(not setup.create("match_1", "competitivo", bad_seats, "p1", competitive, 3).ok, "Plaza duplicada rechazada")
	_expect(not setup.create("bad-id", "competitivo", seats, "p1", competitive, 3).ok, "ID de partida inválido")
	_expect(not setup.create("match_1", "competitivo", seats, "p1", competitive, "3").ok, "Semilla no entera rechazada")
	var bad: Dictionary = competitive.duplicate(true)
	bad.market_cards.pop_back()
	_expect(_incomplete(setup, bad), "Mercado incompleto rechazado")
	bad = competitive.duplicate(true)
	bad.characters[0].starters[0] = "missing"
	_expect(_incomplete(setup, bad), "Carta inicial ausente rechazada")
	bad = competitive.duplicate(true)
	bad.missions[1] = bad.missions[0]
	_expect(_incomplete(setup, bad), "Misión duplicada rechazada")
	bad = competitive.duplicate(true)
	bad.training_track_id = "funding"
	_expect(_incomplete(setup, bad), "Pista del tipo incorrecto rechazada")
	var unreviewed: Dictionary = definitions.duplicate(true)
	unreviewed.market.revision.estado = "muestra"
	_expect(_incomplete(Setup.new(unreviewed, "test_catalog"), competitive), "Definición no verificada rechazada")
	var short_stock: Dictionary = definitions.duplicate(true)
	short_stock.market.cantidad = 81
	_expect(_incomplete(Setup.new(short_stock, "test_catalog"), competitive), "Copias por encima del inventario rechazadas")
	short_stock = definitions.duplicate(true)
	short_stock.track.cantidad = 1
	_expect(_incomplete(Setup.new(short_stock, "test_catalog"), competitive), "Pistas insuficientes rechazadas")
	bad = competitive.duplicate(true)
	bad.rival = manifest.rival
	_expect(_incomplete(setup, bad), "Rival en competitivo rechazado")
	bad = manifest.duplicate(true)
	bad.rival.cards.pop_back()
	_expect(not setup.create("match_1", "cooperativo", seats, null, bad, 3).ok, "Mazo rival incompleto rechazado")


func _incomplete(setup: RefCounted, manifest: Dictionary) -> bool:
	var result: Dictionary = setup.create("match_1", "competitivo", _seats(2), "p1", manifest, 3)
	return not result.ok and result.codigo == "contenido_incompleto" and not result.has("snapshot")


func _definitions() -> Dictionary:
	var result: Dictionary = {}
	for pair: Array in [["funding", "funding"], ["track", "pista_entrenamiento"],
		["market", "accion"], ["rival", "rival"], ["domination", "dominacion"],
		["edict", "edicto"]]:
		var quantity: int = 1
		if pair[0] == "funding":
			quantity = 24
		elif pair[0] == "market":
			quantity = 82
		elif pair[0] == "edict":
			quantity = 36
		elif pair[0] == "track":
			quantity = 4
		result[pair[0]] = {"id": pair[0], "tipo": pair[1], "cantidad": quantity, "revision": {"estado": "verificada"}}
	for index: int in 4:
		result["character_%d" % index] = {"id": "character_%d" % index, "tipo": "personaje", "cantidad": 1, "revision": {"estado": "verificada"}}
		result["starter_%d" % index] = {"id": "starter_%d" % index, "tipo": "entrenamiento", "cantidad": 4, "revision": {"estado": "verificada"}}
	for index: int in 8:
		result["mission_%d" % index] = {"id": "mission_%d" % index, "tipo": "mision", "cantidad": 1, "revision": {"estado": "verificada"}}
	return result


func _manifest() -> Dictionary:
	var characters: Array = []
	for index: int in 4:
		characters.append({"character_id": "character_%d" % index, "starters": ["starter_%d" % index, "starter_%d" % index, "starter_%d" % index, "starter_%d" % index]})
	var missions: Array = []
	for index: int in 8:
		missions.append("mission_%d" % index)
	var market: Array = []
	for unused: int in 82:
		market.append("market")
	var rivals: Array = []
	for unused: int in 36:
		rivals.append("edict")
	return {"characters": characters, "funding_id": "funding", "training_track_id": "track",
		"market_cards": market, "missions": missions,
		"rival": {"definition_id": "rival", "domination_id": "domination", "cards": rivals}}


func _seats(count: int) -> Array:
	var result: Array = []
	for index: int in count:
		result.append({"player_id": "p%d" % (index + 1), "name": "Prueba %d" % (index + 1)})
	return result


func _mission_defs(state: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for mission: Dictionary in state.missions.values():
		result[mission.definition_id] = true
	return result


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
