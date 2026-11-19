extends "res://scripts/game/mission_advance.gd"
## Las marcas de la carta se validan antes de reutilizar las reglas M1–M8.

const Rules = preload("res://scripts/game/perseguir_rules.gd")


func state_error(state: Variant) -> String:
	if not Validator.new().validate(state, _definitions, _catalog_id, _registry).ok or not Rules.closures_valid(state, _definitions):
		return "estado_invalido"
	var plain: Dictionary = state.duplicate(true)
	for instance: Dictionary in plain.instances.values():
		instance.state.ability_uses.clear()
	for player: Dictionary in plain.players:
		var used: Dictionary = {}
		var total: int = 0
		for token: Dictionary in player.metals:
			if token.used_this_turn:
				used[token.metal] = used.get(token.metal, 0) + 1
				total += 1
		for metal: String in player.burned:
			if player.burned[metal] != used.get(metal, 0):
				return "estado_invalido"
		for metal: String in used:
			if player.burned.get(metal) != used[metal]:
				return "estado_invalido"
		if total > player.burn_limit:
			return "estado_invalido"
	return super.state_error(plain)
