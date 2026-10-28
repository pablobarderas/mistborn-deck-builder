extends RefCounted
## Lista permitida para clientes. Nunca copia el snapshot privado completo.


func project(state: Dictionary, recipient_id: String) -> Dictionary:
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
			"rewards": mission.rewards.duplicate(true), "arrival_order": mission.arrival_order.duplicate(true)}
	var rival: Variant = null
	if state.rival != null:
		rival = {"definition_id": state.rival.definition_id, "health": state.rival.health,
			"domination": state.rival.domination.duplicate(true), "adversaries": state.rival.adversaries.duplicate(true)}
	var resolution: Variant = null
	if state.resolution != null:
		resolution = {"resolution_id": state.resolution.resolution_id, "cursor": state.resolution.cursor,
			"recipients": state.resolution.recipients.duplicate(true)}
		if state.resolution.pending != null:
			var pending: Dictionary = state.resolution.pending
			resolution["kind"] = pending.kind
			resolution["pending_recipients"] = pending.recipients.duplicate(true)
			if recipient_id in pending.recipients:
				resolution["options"] = pending.options.duplicate(true)
				resolution["min"] = pending.min
				resolution["max"] = pending.max
	return {"version_motor": state.version_motor, "catalog_id": state.catalog_id, "match_id": state.match_id, "mode": state.mode,
		"revision": state.revision, "lifecycle": state.lifecycle, "player_order": state.player_order.duplicate(true),
		"players": players, "zones": zones, "turn": {"number": state.turn.number,
			"active_id": state.turn.active_id, "phase": state.turn.phase}, "missions": missions,
		"target_id": state.target_id, "rival": rival, "resolution": resolution}


func _known_player(players: Array, recipient_id: String) -> bool:
	for player: Dictionary in players:
		if player.player_id == recipient_id:
			return true
	return false
