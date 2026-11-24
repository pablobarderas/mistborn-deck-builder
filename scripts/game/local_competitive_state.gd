extends "res://scripts/game/game_state.gd"
## Extensión exclusiva E2: el validador publicado no conoce el final por combate.

func validate_candidate(document: Variant) -> Dictionary:
	if document is Dictionary and document.get("outcome") is Dictionary and document.outcome.get("reason") == "ultimo_superviviente":
		var outcome: Dictionary = document.outcome
		if not Registry.exact_keys(outcome, ["winner_id", "reason", "mission_id", "turn_number"]) or outcome.mission_id != null:
			return {"ok": false, "errors": PackedStringArray(["Final de combate incompatible."])}
		var ordinary: Dictionary = document.duplicate(true)
		ordinary.outcome = null
		var result: Dictionary = super.validate_candidate(ordinary)
		if not result.ok:
			return result
		var alive: Array = []
		for player: Dictionary in document.players:
			if player.eliminated != (player.health == 0):
				return {"ok": false, "errors": PackedStringArray(["Salud y eliminación incompatibles."])}
			if not player.eliminated:
				alive.append(player.player_id)
		if alive != [outcome.winner_id] or document.lifecycle != "finalizada" or document.turn.phase != "finalizada" \
			or document.turn.active_id != outcome.winner_id or outcome.turn_number != document.turn.number or document.target_id != null:
			return {"ok": false, "errors": PackedStringArray(["Superviviente incompatible."])}
		return result
	return super.validate_candidate(document)
