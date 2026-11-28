extends RefCounted

const CATALOG_PATH: String = "res://data/cartografos_del_viento.json"
const ROUND_LIMIT: int = 6
const HAND_SIZE: int = 4
const PLAY_LIMIT: int = 2

var last_error: String = ""
var _catalog: Dictionary = {}
var _cards: Dictionary = {}
var _players: Array[Dictionary] = []
var _supply: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _active_seat: int = -1
var _first_seat: int = -1
var _round: int = 0
var _turns_completed: int = 0
var _finished: bool = false
var _credits: int = 0
var _compasses: int = 0
var _played_count: int = 0
var _bought: bool = false
var _charted: bool = false


static func validate_catalog(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 1:
		return false
	if not data.get("cards") is Array or not data.get("routes") is Array:
		return false
	if data.cards.size() != 6 or data.routes.size() != 3:
		return false
	var ids: Dictionary = {}
	var starter_count: int = 0
	var market_count: int = 0
	for entry: Variant in data.cards:
		if not entry is Dictionary or not _valid_identity(entry, ids):
			return false
		for key: String in ["cost", "credits", "compasses", "start_count", "supply"]:
			if not _whole_nonnegative(entry.get(key)):
				return false
		if entry.start_count == 4 and entry.supply == 0 and entry.cost == 0:
			starter_count += 1
		elif entry.start_count == 0 and entry.supply == 6 and entry.cost > 0:
			market_count += 1
		else:
			return false
		if entry.credits + entry.compasses <= 0:
			return false
	if starter_count != 2 or market_count != 4:
		return false
	for entry: Variant in data.routes:
		if not entry is Dictionary or not _valid_identity(entry, ids):
			return false
		for key: String in ["costs", "points"]:
			if not entry.get(key) is Array or entry[key].size() != 3:
				return false
			for amount: Variant in entry[key]:
				if not _whole_nonnegative(amount) or amount <= 0:
					return false
	return true


static func _valid_identity(entry: Dictionary, ids: Dictionary) -> bool:
	if not entry.get("id") is String or not entry.get("name") is String:
		return false
	if entry.id.is_empty() or entry.name.strip_edges().is_empty() or ids.has(entry.id):
		return false
	ids[entry.id] = true
	return true


static func _whole_nonnegative(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= 0 and value == floor(float(value)) and value <= 100


func start(player_count: int, seed_value: int) -> bool:
	if player_count < 2 or player_count > 4:
		return _reject("Elige entre dos y cuatro plazas.")
	var file: FileAccess = FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el catálogo de Cartógrafos del Viento.")
		return _reject("No se pudo abrir el catálogo.")
	var parsed: JSON = JSON.new()
	if parsed.parse(file.get_as_text()) != OK or not validate_catalog(parsed.data):
		push_error("Catálogo inválido de Cartógrafos del Viento.")
		return _reject("El catálogo tiene datos inválidos.")
	_catalog = parsed.data.duplicate(true)
	_cards.clear()
	_players.clear()
	_supply.clear()
	_rng.seed = seed_value
	for card: Dictionary in _catalog.cards:
		_cards[card.id] = card
		if card.supply > 0:
			_supply[card.id] = int(card.supply)
	for seat: int in range(player_count):
		var deck: Array = []
		for card: Dictionary in _catalog.cards:
			for copy_index: int in range(int(card.start_count)):
				deck.append(card.id)
		_shuffle(deck)
		_players.append({"seat": seat, "name": "Plaza %d" % (seat + 1), "deck": deck, "discard": [], "hand": [], "played": [], "routes": [0, 0, 0]})
	_first_seat = _rng.randi_range(0, player_count - 1)
	_active_seat = _first_seat
	_turns_completed = 0
	_round = 1
	_finished = false
	_begin_turn()
	return _accept()


func view() -> Dictionary:
	var players: Array[Dictionary] = []
	var winners: Array[int] = []
	var best_score: int = -1
	for player: Dictionary in _players:
		var score: int = _score(player)
		players.append({"seat": player.seat, "name": player.name, "routes": player.routes.duplicate(), "score": score, "deck_count": player.deck.size(), "discard_count": player.discard.size(), "hand_count": player.hand.size(), "played_count": player.played.size()})
		if _finished:
			if score > best_score:
				best_score = score
				winners.clear()
			if score == best_score:
				winners.append(int(player.seat))
	var supply: Array[Dictionary] = []
	for id: String in _supply:
		var card: Dictionary = _public_card(id)
		card["cost"] = int(_cards[id].cost)
		card["remaining"] = int(_supply[id])
		supply.append(card)
	return {"round": _round, "active_seat": _active_seat, "first_seat": _first_seat, "player_count": _players.size(), "finished": _finished, "players": players, "winners": winners, "supply": supply, "routes": _catalog.get("routes", []).duplicate(true), "credits": _credits, "compasses": _compasses, "played_count": _played_count, "bought": _bought, "charted": _charted}


func hand(seat: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _can_act(seat):
		return result
	for id: String in _players[seat].hand:
		result.append(_public_card(id))
	return result


func play(seat: int, index: int) -> bool:
	if not _can_act(seat) or _played_count >= PLAY_LIMIT:
		return _reject("Puedes jugar hasta dos cartas en tu turno.")
	var cards: Array = _players[seat].hand
	if index < 0 or index >= cards.size():
		return _reject("La carta elegida no está en tu mano.")
	var id: String = cards[index]
	cards.remove_at(index)
	_players[seat].played.append(id)
	_credits += int(_cards[id].credits)
	_compasses += int(_cards[id].compasses)
	_played_count += 1
	return _accept()


func buy(seat: int, card_id: String) -> bool:
	if not _can_act(seat) or _bought or not _supply.has(card_id):
		return _reject("Puedes comprar un instrumento por turno.")
	var cost: int = int(_cards[card_id].cost)
	if _supply[card_id] <= 0 or _credits < cost:
		return _reject("Faltan créditos o se ha agotado el instrumento.")
	_credits -= cost
	_supply[card_id] -= 1
	_players[seat].discard.append(card_id)
	_bought = true
	return _accept()


func chart(seat: int, route_index: int) -> bool:
	if not _can_act(seat) or _charted or route_index < 0 or route_index >= _catalog.routes.size():
		return _reject("Puedes trazar una etapa por turno.")
	var progress: int = int(_players[seat].routes[route_index])
	var route: Dictionary = _catalog.routes[route_index]
	if progress >= route.costs.size():
		return _reject("Esta ruta ya está completa.")
	var cost: int = int(route.costs[progress])
	if _compasses < cost:
		return _reject("Faltan brújulas para esa etapa.")
	_compasses -= cost
	_players[seat].routes[route_index] = progress + 1
	_charted = true
	return _accept()


func end_turn(seat: int) -> bool:
	if not _can_act(seat):
		return _reject("Esa plaza no tiene un turno activo.")
	var player: Dictionary = _players[seat]
	player.discard.append_array(player.played)
	player.discard.append_array(player.hand)
	player.played.clear()
	player.hand.clear()
	_turns_completed += 1
	if _turns_completed == ROUND_LIMIT * _players.size():
		_finished = true
		_credits = 0
		_compasses = 0
		return _accept()
	_active_seat = (_active_seat + 1) % _players.size()
	_round = 1 + _turns_completed / _players.size()
	_begin_turn()
	return _accept()


func _begin_turn() -> void:
	_credits = 0
	_compasses = 0
	_played_count = 0
	_bought = false
	_charted = false
	var player: Dictionary = _players[_active_seat]
	for draw_index: int in range(HAND_SIZE):
		if player.deck.is_empty():
			player.deck.append_array(player.discard)
			player.discard.clear()
			_shuffle(player.deck)
		if not player.deck.is_empty():
			player.hand.append(player.deck.pop_back())


func _shuffle(cards: Array) -> void:
	for index: int in range(cards.size() - 1, 0, -1):
		var other: int = _rng.randi_range(0, index)
		var previous: Variant = cards[index]
		cards[index] = cards[other]
		cards[other] = previous


func _score(player: Dictionary) -> int:
	var score: int = 0
	var all_started: bool = true
	for index: int in range(player.routes.size()):
		var progress: int = int(player.routes[index])
		all_started = all_started and progress > 0
		for stage: int in range(progress):
			score += int(_catalog.routes[index].points[stage])
	return score + (3 if all_started else 0)


func _can_act(seat: int) -> bool:
	return not _finished and seat >= 0 and seat == _active_seat and seat < _players.size()


func _public_card(id: String) -> Dictionary:
	var card: Dictionary = _cards[id]
	return {"id": id, "name": card.name, "credits": int(card.credits), "compasses": int(card.compasses)}


func _reject(message: String) -> bool:
	last_error = message
	return false


func _accept() -> bool:
	last_error = ""
	return true
