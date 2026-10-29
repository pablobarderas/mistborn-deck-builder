extends RefCounted
## Cierre interno de limpieza. No registra acciones ni resuelve efectos o finales.

const Validator = preload("res://scripts/game/state_validator.gd")
const CardCycle = preload("res://scripts/game/card_cycle.gd")
var _definitions: Dictionary
var _catalog_id: String


func _init(definitions: Dictionary, catalog_id: String) -> void:
	_definitions = definitions.duplicate(true)
	_catalog_id = catalog_id


func finish_cleanup(snapshot: Variant, player_id: Variant, rng: Variant) -> Dictionary:
	if not _valid(snapshot):
		return _result("estado_invalido")
	if not player_id is String or not rng is RandomNumberGenerator:
		return _result("formato_invalido")
	if snapshot.lifecycle != "en_curso" or snapshot.turn.phase != "limpieza" \
		or snapshot.turn.active_id != player_id or snapshot.turn.number < 1 \
		or snapshot.resolution != null:
		return _result("accion_ilegal")
	var active: Dictionary = _player(snapshot, player_id)
	if active.is_empty() or active.eliminated or active.health <= 0:
		return _result("accion_ilegal")
	var code: String = _pending_rule(snapshot, player_id)
	if not code.is_empty():
		return _result(code)
	var candidate: Dictionary = snapshot.duplicate(true)
	var staged_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	staged_rng.seed = rng.seed
	staged_rng.state = rng.state
	var cycle: RefCounted = CardCycle.new(_definitions, _catalog_id)
	var result: Dictionary = cycle.cleanup_cards(candidate, player_id)
	if not result.ok:
		return result
	active = _player(candidate, player_id)
	active.turn_resources.recursos = 0
	active.turn_resources.ataque = 0
	active.burned.clear()
	active.ability_uses.clear()
	for token: Dictionary in active.metals:
		if token.metal != "atium":
			token.used_this_turn = false
	for instance: Dictionary in candidate.instances.values():
		if instance.owner_id == player_id:
			instance.state.ability_uses.clear()
	result = cycle.draw(candidate, player_id, 5, staged_rng)
	if not result.ok:
		return result
	if candidate.mode == "competitivo":
		var order: Array = candidate.player_order
		var index: int = order.find(player_id)
		for offset: int in range(1, order.size()):
			var next_id: String = order[(index + offset) % order.size()]
			if not _player(candidate, next_id).eliminated:
				candidate.turn.active_id = next_id
				break
		candidate.turn.number += 1
		candidate.turn.phase = "inicio"
	else:
		candidate.turn.phase = "rival"
	if not _valid(candidate):
		return _result("estado_invalido")
	# El commit P07 persiste authority.rng_state. Aquí solo se publica el RNG recibido.
	snapshot.merge(candidate, true)
	rng.state = staged_rng.state
	return _result("")


func _pending_rule(snapshot: Dictionary, player_id: String) -> String:
	if not snapshot.turn.counters.is_empty():
		return "regla_pendiente"
	for instance: Dictionary in snapshot.instances.values():
		if instance.owner_id == player_id and not instance.state.flags.is_empty():
			return "regla_pendiente"
	for token: Dictionary in _player(snapshot, player_id).metals:
		if token.metal == "atium" and token.used_this_turn:
			return "regla_pendiente"
	var alive: int = 0
	for player: Dictionary in snapshot.players:
		if player.eliminated != (player.health <= 0):
			return "regla_pendiente"
		if not player.eliminated:
			alive += 1
	if snapshot.mode == "competitivo":
		if alive < 2 or snapshot.turn.number == 9223372036854775807:
			return "regla_pendiente"
	else:
		# Guardia de final pendiente; esta API no decide victoria ni derrota.
		if snapshot.rival.health <= 0:
			return "regla_pendiente"
		for enemy: Dictionary in snapshot.rival.adversaries.values():
			if enemy.facing_id == player_id:
				return "regla_pendiente"
	return ""


func _player(snapshot: Dictionary, player_id: String) -> Dictionary:
	for player: Dictionary in snapshot.players:
		if player.player_id == player_id:
			return player
	return {}


func _valid(snapshot: Variant) -> bool:
	return Validator.new().validate(snapshot, _definitions, _catalog_id).ok


func _result(code: String) -> Dictionary:
	return {"ok": code.is_empty(), "codigo": "aceptada" if code.is_empty() else code}
