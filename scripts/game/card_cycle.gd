extends RefCounted
## Primitivas internas de autoridad; el manejador decide cuándo y cuánto robar.
## No registra acciones de cliente, ejecuta efectos ni completa el turno.

const Validator = preload("res://scripts/game/state_validator.gd")
var _definitions: Dictionary
var _catalog_id: String


func _init(definitions: Dictionary, catalog_id: String) -> void:
	_definitions = definitions.duplicate(true)
	_catalog_id = catalog_id


func draw(snapshot: Variant, player_id: Variant, count: Variant, rng: Variant) -> Dictionary:
	var code: String = _check(snapshot, player_id)
	if not code.is_empty():
		return _result(code)
	if typeof(count) != TYPE_INT or count < 0 or not rng is RandomNumberGenerator:
		return _result("formato_invalido")
	var zones: Dictionary = _personal_zones(snapshot, player_id)
	if count > zones.mazo.cards.size() + zones.descarte.cards.size():
		# Guardia técnica DUD-006: no decide un resultado reglamentario.
		return _result("regla_pendiente")
	var candidate: Dictionary = snapshot.duplicate(true)
	zones = _personal_zones(candidate, player_id)
	var staged_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	staged_rng.seed = rng.seed
	staged_rng.state = rng.state
	for unused: int in count:
		if zones.mazo.cards.is_empty():
			zones.mazo.cards.assign(zones.descarte.cards)
			zones.descarte.cards.clear()
			_shuffle(zones.mazo.cards, staged_rng)
		zones.mano.cards.append(zones.mazo.cards.pop_back())
	if not _valid(candidate):
		return _result("estado_invalido")
	# El RNG pertenece a la transacción; GameEngine guarda su estado al commit.
	snapshot.merge(candidate, true)
	rng.state = staged_rng.state
	return _result("")


func discard(snapshot: Variant, player_id: Variant, instance_ids: Variant) -> Dictionary:
	var code: String = _check(snapshot, player_id)
	if not code.is_empty():
		return _result(code)
	if not instance_ids is Array:
		return _result("formato_invalido")
	var zones: Dictionary = _personal_zones(snapshot, player_id)
	var seen: Dictionary = {}
	for id: Variant in instance_ids:
		if not id is String or seen.has(id):
			return _result("formato_invalido")
		seen[id] = true
		if not id in zones.mano.cards and not id in zones.juego.cards:
			return _result("accion_ilegal")
	var candidate: Dictionary = snapshot.duplicate(true)
	zones = _personal_zones(candidate, player_id)
	for id: String in instance_ids:
		zones.mano.cards.erase(id)
		zones.juego.cards.erase(id)
		zones.descarte.cards.append(id)
	return _commit(snapshot, candidate)


func cleanup_cards(snapshot: Variant, player_id: Variant) -> Dictionary:
	var code: String = _check(snapshot, player_id)
	if not code.is_empty():
		return _result(code)
	var zones: Dictionary = _personal_zones(snapshot, player_id)
	var selected: Array = zones.mano.cards.duplicate()
	for id: String in zones.juego.cards:
		var definition_id: String = snapshot.instances[id].definition_id
		if _definitions[definition_id].tipo != "aliado":
			selected.append(id)
	return discard(snapshot, player_id, selected)


func _check(snapshot: Variant, player_id: Variant) -> String:
	if not _valid(snapshot):
		return "estado_invalido"
	if not player_id is String:
		return "formato_invalido"
	for player: Dictionary in snapshot.players:
		if player.player_id == player_id:
			return ""
	return "accion_ilegal"


func _valid(snapshot: Variant) -> bool:
	return Validator.new().validate(snapshot, _definitions, _catalog_id).ok


func _personal_zones(snapshot: Dictionary, player_id: String) -> Dictionary:
	var result: Dictionary = {}
	for zone: Dictionary in snapshot.zones.values():
		if zone.holder_id == player_id:
			result[zone.kind] = zone
	return result


func _commit(snapshot: Dictionary, candidate: Dictionary) -> Dictionary:
	if not _valid(candidate):
		return _result("estado_invalido")
	snapshot.merge(candidate, true)
	return _result("")


func _shuffle(cards: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(cards.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var saved: Variant = cards[index]
		cards[index] = cards[other]
		cards[other] = saved


func _result(code: String) -> Dictionary:
	return {"ok": code.is_empty(), "codigo": "aceptada" if code.is_empty() else code}
