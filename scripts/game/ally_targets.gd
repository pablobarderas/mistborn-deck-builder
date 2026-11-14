extends RefCounted
## Selección cerrada de aliados inertes. No interpreta Defender ni reacciones.


static func options(state: Dictionary, definitions: Dictionary) -> Array:
	var result: Array = []
	for owner: String in state.player_order:
		var alive: bool = false
		for player: Dictionary in state.players:
			if player.player_id == owner:
				alive = not player.eliminated and player.health > 0
		if not alive:
			continue
		for zone_id: String in state.zones:
			var zone: Dictionary = state.zones[zone_id]
			if zone.kind != "juego" or zone.holder_id != owner:
				continue
			for id: String in zone.cards:
				var card: Dictionary = state.instances[id]
				if card.owner_id == owner and definitions.get(card.definition_id, {}).get("tipo") == "aliado":
					result.append({"option_id": "o%05d" % (result.size() + 1), "instance_id": id,
						"definition_id": card.definition_id, "owner_id": owner, "zone_id": zone_id})
	return result


static func discard_zone(state: Dictionary, owner: String) -> Dictionary:
	for zone: Dictionary in state.zones.values():
		if zone.kind == "descarte" and zone.holder_id == owner:
			return zone
	return {}


static func defeat(state: Dictionary, definitions: Dictionary, option_id: String) -> bool:
	for option: Dictionary in options(state, definitions):
		if option.option_id != option_id:
			continue
		var destination: Dictionary = discard_zone(state, option.owner_id)
		if destination.is_empty() or destination.cards.size() >= 10000:
			return false
		state.zones[option.zone_id].cards.erase(option.instance_id)
		destination.cards.append(option.instance_id)
		return true
	return false
