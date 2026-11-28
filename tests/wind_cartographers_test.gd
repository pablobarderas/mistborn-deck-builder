extends SceneTree

const WindGame = preload("res://scripts/game/wind_cartographers.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_catalog()
	_test_rejections_and_copies()
	_test_payments_and_limits()
	_test_supply_exhaustion()
	_test_score_and_ties()
	_test_recycling()
	for count: int in [2, 3, 4]:
		_test_complete_game(count)
	if failures == 0:
		print("WIND_CARTOGRAPHERS_OK: %d comprobaciones." % checks)
	else:
		push_error("Cartógrafos del Viento: %d fallos en %d comprobaciones." % [failures, checks])
	quit(0 if failures == 0 else 1)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func _snapshot(game: RefCounted) -> Array:
	return [game.view(), game._players.duplicate(true), game._rng.state, game._turns_completed]


func _test_catalog() -> void:
	var parsed: JSON = JSON.new()
	_check(parsed.parse(FileAccess.get_file_as_string(WindGame.CATALOG_PATH)) == OK, "JSON válido")
	var data: Dictionary = parsed.data
	_check(WindGame.validate_catalog(data), "Catálogo original válido")
	for invalid: Variant in [null, [], {}, {"version": 1, "cards": [], "routes": []}]:
		_check(not WindGame.validate_catalog(invalid), "Rechaza catálogo incompleto")
	var duplicate: Dictionary = data.duplicate(true)
	duplicate.cards[1].id = duplicate.cards[0].id
	_check(not WindGame.validate_catalog(duplicate), "Rechaza IDs repetidos")
	for key: String in ["cost", "credits", "compasses", "start_count", "supply"]:
		var bad: Dictionary = data.duplicate(true)
		bad.cards[0][key] = -1
		_check(not WindGame.validate_catalog(bad), "Rechaza valor negativo " + key)
	var fractional: Dictionary = data.duplicate(true)
	fractional.cards[0].credits = 1.5
	_check(not WindGame.validate_catalog(fractional), "Rechaza cantidad fraccionaria")
	var route: Dictionary = data.duplicate(true)
	route.routes[0].costs = [1, 2]
	_check(not WindGame.validate_catalog(route), "Rechaza ruta incompleta")
	var empty_name: Dictionary = data.duplicate(true)
	empty_name.cards[0].name = " "
	_check(not WindGame.validate_catalog(empty_name), "Rechaza nombre vacío")


func _test_rejections_and_copies() -> void:
	var game: RefCounted = WindGame.new()
	_check(not game.play(0, 0), "Sin partida no se juega")
	_check(game.start(3, 401), "Inicia tres plazas")
	var before: Array = _snapshot(game)
	for count: int in [-1, 0, 1, 5]:
		_check(not game.start(count, 7), "Tamaño inválido")
		_check(before == _snapshot(game), "Inicio inválido atómico")
	var seat: int = game.view().active_seat
	var other: int = (seat + 1) % 3
	_check(game.hand(other).is_empty(), "Mano ajena privada")
	_check(game.hand(-1).is_empty(), "Plaza negativa privada")
	_check(not game.play(other, 0), "Rechazo de plaza ajena")
	_check(not game.buy(other, "planeador"), "Rechazo compra ajena")
	_check(not game.chart(other, 0), "Rechazo trazado ajeno")
	_check(not game.end_turn(other), "Rechazo relevo ajeno")
	_check(not game.play(seat, -1), "Índice negativo")
	_check(not game.play(seat, 99), "Índice fuera de mano")
	_check(not game.buy(seat, "inexistente"), "ID desconocido")
	_check(not game.chart(seat, -1), "Ruta negativa")
	_check(not game.chart(seat, 3), "Ruta fuera de rango")
	_check(before == _snapshot(game), "Todas las acciones inválidas conservan estado y RNG")
	var public_view: Dictionary = game.view()
	public_view.players[seat].routes[0] = 90
	public_view.routes[0].costs[0] = 90
	public_view.supply[0].remaining = 90
	var cards: Array = game.hand(seat)
	cards[0].credits = 90
	_check(before == _snapshot(game), "Vistas y manos son copias profundas")
	var same: RefCounted = WindGame.new()
	_check(same.start(3, 401), "Inicio reproducible")
	_check(_snapshot(same) == before, "Semilla reproduce preparación completa")


func _test_payments_and_limits() -> void:
	var game: RefCounted = WindGame.new()
	_check(game.start(2, 11), "Prepara pagos")
	var seat: int = game.view().active_seat
	_check(not game.buy(seat, "planeador"), "Compra sin recursos")
	_check(not game.chart(seat, 0), "Trazado sin recursos")
	game._players[seat].hand = ["sextante", "encargo", "observatorio", "taller"]
	_check(game.play(seat, 0), "Juega sextante")
	_check(game.view().credits == 2 and game.view().compasses == 2, "Dos recursos acumulados")
	_check(game.buy(seat, "planeador"), "Compra intercalada")
	_check(game.view().credits == 0 and game.view().supply[0].remaining == 5, "Compra paga y reduce oferta")
	_check(game._players[seat].discard == ["planeador"], "Compra al descarte")
	_check(game.chart(seat, 0), "Traza intercalado")
	_check(game.view().compasses == 0 and game.view().players[seat].routes == [1, 0, 0], "Trazado paga y progresa")
	_check(game.play(seat, 0), "Segunda carta tras compra y trazado")
	var before: Array = _snapshot(game)
	_check(not game.play(seat, 0), "Máximo de dos cartas")
	_check(not game.buy(seat, "planeador"), "Máximo de una compra")
	_check(not game.chart(seat, 0), "Máximo de un trazado")
	_check(before == _snapshot(game), "Límites atómicos")
	game._bought = false
	game._credits = 10
	game._supply.planeador = 0
	before = _snapshot(game)
	_check(not game.buy(seat, "planeador"), "Oferta agotada")
	_check(before == _snapshot(game), "Oferta agotada conserva recursos")
	game._charted = false
	game._compasses = 10
	game._players[seat].routes = [3, 0, 0]
	before = _snapshot(game)
	_check(not game.chart(seat, 0), "Ruta completa rechazada")
	_check(before == _snapshot(game), "Ruta completa conserva recursos")


func _test_supply_exhaustion() -> void:
	var game: RefCounted = WindGame.new()
	_check(game.start(4, 915), "Prepara agotamiento real de la oferta")
	var bought: int = 0
	var rejected: bool = false
	while not game.view().finished and not rejected:
		var seat: int = game.view().active_seat
		var cards: Array[Dictionary] = game.hand(seat)
		for index: int in cards.size():
			if cards[index].credits >= 2:
				_check(game.play(seat, index), "Genera créditos para comprar una copia")
				break
		if game.view().credits >= 2:
			if bought < 6:
				_check(game.buy(seat, "planeador"), "Compra una copia disponible")
				bought += 1
				_check(game.view().supply[0].remaining == 6 - bought, "Oferta exacta tras la compra")
			else:
				var before: Array = _snapshot(game)
				rejected = not game.buy(seat, "planeador")
				_check(before == _snapshot(game), "La séptima copia no cambia cartas, recursos ni RNG")
		_check(game.end_turn(seat), "Relevo antes de comprar otra copia")
	_check(bought == 6 and rejected, "Se compran seis copias y se rechaza la séptima")


func _test_score_and_ties() -> void:
	var game: RefCounted = WindGame.new()
	_check(game.start(2, 31), "Prepara puntuaciones")
	game._players[0].routes = [3, 2, 1]
	_check(game.view().players[0].score == 17, "Suma etapas y bonus de tres rutas")
	game._players[0].routes = [3, 2, 0]
	_check(game.view().players[0].score == 11, "Sin bonus para dos rutas")
	game._players[0].routes = [0, 0, 0]
	for index: int in range(12):
		_check(game.end_turn(game.view().active_seat), "Final por seis rondas")
	_check(game.view().winners == [0, 1], "Empate incluye ambas plazas")
	_check(game.view().round == 6, "Final permanece en ronda seis")
	_check(game.hand(game.view().active_seat).is_empty(), "Sin mano al terminar")
	var before: Array = _snapshot(game)
	_check(not game.end_turn(game.view().active_seat), "Final no admite relevo")
	_check(not game.play(game.view().active_seat, 0), "Final no admite carta")
	_check(not game.buy(game.view().active_seat, "taller"), "Final no admite compra")
	_check(not game.chart(game.view().active_seat, 0), "Final no admite trazado")
	_check(before == _snapshot(game), "Final inmutable")
	game._players[1].routes = [0, 0, 1]
	_check(game.view().winners == [1], "Ganador único por puntos")


func _test_recycling() -> void:
	var game: RefCounted = WindGame.new()
	_check(game.start(2, 73), "Prepara reciclado")
	var target: int = (game.view().active_seat + 1) % 2
	game._players[target].deck = ["encargo"]
	game._players[target].discard = ["observatorio", "taller", "planeador"]
	_check(game.end_turn(game.view().active_seat), "Releva para robo con reciclado")
	_check(game.hand(target).size() == 4, "Roba cuatro al reciclar a mitad")
	_check(game._players[target].deck.is_empty() and game._players[target].discard.is_empty(), "Reciclado consume solo cartas disponibles")
	var ids: Array = []
	for card: Dictionary in game.hand(target):
		ids.append(card.id)
	ids.sort()
	_check(ids == ["encargo", "observatorio", "planeador", "taller"], "Reciclado conserva identidades")


func _test_complete_game(count: int) -> void:
	var game: RefCounted = WindGame.new()
	_check(game.start(count, 982 + count), "Partida completa %d" % count)
	var first: int = game.view().active_seat
	var turns: Array[int] = []
	turns.resize(count)
	turns.fill(0)
	var purchases: int = 0
	while not game.view().finished:
		var state: Dictionary = game.view()
		var seat: int = state.active_seat
		_check(seat == (first + purchases_turns(turns)) % count, "Orden circular")
		_check(state.round == turns[seat] + 1, "Rondas equilibradas")
		_check(game.hand(seat).size() == 4, "Cuatro cartas por turno")
		turns[seat] += 1
		for index: int in range(2):
			_check(game.play(seat, 0), "Juega cartas en partida")
		for card: Dictionary in game.view().supply:
			if card.remaining > 0 and game.view().credits >= card.cost:
				_check(game.buy(seat, card.id), "Compra en partida")
				purchases += 1
				break
		for route_index: int in range(3):
			var progress: int = game.view().players[seat].routes[route_index]
			if progress < 3 and game.view().compasses >= game.view().routes[route_index].costs[progress]:
				_check(game.chart(seat, route_index), "Traza en partida")
				break
		_check(game.end_turn(seat), "Termina turno de partida")
		var total: int = 0
		for player: Dictionary in game._players:
			total += player.deck.size() + player.discard.size() + player.hand.size() + player.played.size()
		_check(total == count * 8 + purchases, "Conservación de todas las zonas")
		var available: int = 0
		for card: Dictionary in game.view().supply:
			available += card.remaining
		_check(available + purchases == 24, "Oferta conserva todas las compras")
	for played_turns: int in turns:
		_check(played_turns == 6, "Seis turnos por plaza")
	_check(not game.view().winners.is_empty(), "Partida tiene resultado")
	_check(game.start(count, 982 + count), "Reinicio tras resultado")
	_check(game.view().round == 1 and not game.view().finished, "Reinicio limpia final")


func purchases_turns(turns: Array[int]) -> int:
	var result: int = 0
	for value: int in turns:
		result += value
	return result
