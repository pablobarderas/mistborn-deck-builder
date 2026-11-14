extends RefCounted
## Lista permitida para clientes. Nunca copia el snapshot privado completo.


func project(state: Dictionary, recipient_id: String, definitions: Dictionary = {}) -> Dictionary:
	if state.is_empty() or not _known_player(state.players, recipient_id):
		return {}
	var players: Array = []
	for player: Dictionary in state.players:
		players.append({"player_id": player.player_id, "name": player.name, "eliminated": player.eliminated,
			"health": player.health, "character_id": player.character_id,
			"training_track_id": player.training_track_id,
			"persistent": player.persistent.duplicate(true), "turn_resources": player.turn_resources.duplicate(true),
			"training": player.training, "metals": player.metals.duplicate(true), "burned": player.burned.duplicate(true),
			"burn_limit": player.burn_limit})
	var zones: Dictionary = {}
	for zone_id: String in state.zones:
		var zone: Dictionary = state.zones[zone_id]
		var visible: Dictionary = {"kind": zone.kind, "holder_id": zone.holder_id, "count": zone.cards.size()}
		if zone.kind in ["mercado", "eliminadas", "juego", "adversarios"] or (zone.holder_id == recipient_id and zone.kind in ["mano", "descarte"]):
			var cards: Array = []
			for instance_id: String in zone.cards:
				var card: Dictionary = state.instances[instance_id]
				cards.append({"instance_id": card.instance_id, "definition_id": card.definition_id, "owner_id": card.owner_id})
			visible["cards"] = cards
		zones[zone_id] = visible
	var missions: Dictionary = {}
	for mission_id: String in state.missions:
		var mission: Dictionary = state.missions[mission_id]
		missions[mission_id] = {"definition_id": mission.definition_id, "progress": mission.progress.duplicate(true),
			"rewards": mission.rewards.duplicate(true), "arrival_order": mission.arrival_order.duplicate(true),
			"first_arrivals": mission.first_arrivals.duplicate(true)}
	var outcome: Variant = null
	if state.outcome != null:
		outcome = {"winner_id": state.outcome.winner_id, "reason": state.outcome.reason,
			"mission_id": state.outcome.mission_id, "turn_number": state.outcome.turn_number}
	var rival: Variant = null
	if state.rival != null:
		rival = {"definition_id": state.rival.definition_id, "health": state.rival.health,
			"domination": state.rival.domination.duplicate(true), "adversaries": state.rival.adversaries.duplicate(true)}
	var resolution: Variant = null
	if state.resolution != null:
		var active: Dictionary = state.resolution
		var pending: Dictionary = active.pending
		resolution = {"resolution_id": active.resolution_id, "recipients": active.recipients.duplicate(),
			"kind": pending.kind, "pending_recipients": pending.recipients.duplicate()}
		if recipient_id in pending.recipients:
			resolution["step_id"] = active.steps[active.cursor]
			resolution["options"] = pending.options.duplicate()
			resolution["min"] = pending.min
			resolution["max"] = pending.max
			if active.program_id in ["m8_normal_v1", "m8_first_v1"]:
				resolution["option_cards"] = _option_cards(state, recipient_id)
			if active.program_id in ["m1_normal_v1", "m1_first_v1"]:
				resolution["option_metals"] = _option_metals(state, recipient_id)
			if active.program_id == "m2_first_v1":
				resolution["option_allies"] = preload("res://scripts/game/ally_targets.gd").options(state, definitions)
	return {"version_motor": state.version_motor, "catalog_id": state.catalog_id, "match_id": state.match_id, "mode": state.mode,
		"revision": state.revision, "lifecycle": state.lifecycle, "player_order": state.player_order.duplicate(true),
		"players": players, "zones": zones, "turn": {"number": state.turn.number,
			"active_id": state.turn.active_id, "phase": state.turn.phase}, "missions": missions,
		"target_id": state.target_id, "rival": rival, "resolution": resolution, "outcome": outcome}


func _known_player(players: Array, recipient_id: String) -> bool:
	for player: Dictionary in players:
		if player.player_id == recipient_id:
			return true
	return false


static func _option_cards(state: Dictionary, owner: String) -> Array:
	var result: Array = []
	for kind: String in ["mano", "descarte", "juego"]:
		for zone_id: String in state.zones:
			var zone: Dictionary = state.zones[zone_id]
			if zone.kind == kind and zone.holder_id == owner:
				for id: String in zone.cards:
					var card: Dictionary = state.instances[id]
					if card.owner_id == owner:
						result.append({"option_id": "o%05d" % (result.size() + 1), "instance_id": id, "definition_id": card.definition_id, "zone_id": zone_id})
	return result


static func _option_metals(state: Dictionary, owner: String) -> Array:
	return preload("res://scripts/game/metal_refresh.gd").options(state, owner)
