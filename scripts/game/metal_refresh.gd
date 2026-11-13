extends RefCounted
## Candidatas de autoridad compartidas por premios y vista; no quema ni activa.


static func options(state: Dictionary, owner: String) -> Array:
	var result: Array = []
	for player: Dictionary in state.players:
		if player.player_id != owner:
			continue
		for token: Dictionary in player.metals:
			if token.metal != "atium" and token.exhausted:
				result.append({"option_id": "o%05d" % (result.size() + 1), "token_id": token.token_id,
					"metal": token.metal, "exhausted": token.exhausted, "used_this_turn": token.used_this_turn})
	return result


static func apply(state: Dictionary, owner: String, token_ids: Array) -> bool:
	var candidates: Dictionary = {}
	for token: Dictionary in options(state, owner):
		candidates[token.token_id] = true
	var seen: Dictionary = {}
	for id: Variant in token_ids:
		if not id is String or not candidates.has(id) or seen.has(id):
			return false
		seen[id] = true
	for player: Dictionary in state.players:
		if player.player_id == owner:
			for token: Dictionary in player.metals:
				if seen.has(token.token_id):
					token.exhausted = false
	return true


static func all(state: Dictionary, owner: String) -> bool:
	var ids: Array = []
	for token: Dictionary in options(state, owner):
		ids.append(token.token_id)
	return apply(state, owner, ids)
