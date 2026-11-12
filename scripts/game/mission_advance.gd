extends RefCounted
## Candidato automático del perfil M5/M6/M7. Sin acceso a transporte ni commit.

const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Training = preload("res://scripts/game/training_advance.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const ACTIVE_DEFINITIONS: Array[String] = ["mision_m5", "mision_m6", "mision_m7"]
var _definitions: Dictionary
var _catalog_id: String
var _training: Training
var _registry: Registry = Registry.new()


func _init(definitions: Dictionary, catalog_id: String, training_profile: Dictionary) -> void:
	_definitions = definitions.duplicate(true)
	_catalog_id = catalog_id
	_training = Training.new(_definitions, _catalog_id, training_profile, _registry)


func supported() -> bool:
	for id: String in ACTIVE_DEFINITIONS:
		if not _definitions.has(id) or not supported_mission(_definitions[id]):
			return false
	return true


static func supported_mission(card: Dictionary) -> bool:
	if not card.get("id") in ACTIVE_DEFINITIONS or card.get("tipo") != "mision":
		return false
	var tracks: Array = card.get("rasgos", {}).get("recorridos", [])
	if tracks.size() != 1 or tracks[0].id != "principal" or tracks[0].casillas.size() != 12:
		return false
	var expected: Array = []
	for position: int in range(1, 13):
		var cell: Dictionary = {"id": "p%02d" % position, "efectos": [], "primero": []}
		if position == 12:
			cell.permanente = null
		if card.id == "mision_m5":
			if position == 4:
				cell.efectos = [_gain("recursos", 1)]
				cell.primero = [_gain("recursos", 1)]
			elif position == 8:
				cell.efectos = [_gain("ataque", 2)]
				cell.primero = [_effect("curar", 2)]
			elif position == 12:
				cell.efectos = [_gain("atium", 1)]
				cell.primero = [_gain("atium", 1)]
		elif card.id == "mision_m6" and position in [6, 12]:
			cell.efectos = [{"op": "avanzar", "pista": "entrenamiento", "cantidad": 1, "objetivo": "propio"}]
			cell.primero = cell.efectos.duplicate(true)
		elif card.id == "mision_m7" and position in [6, 12]:
			cell.efectos = [_effect("curar", 4 if position == 6 else 6)]
			cell.primero = [_effect("curar", 2)]
		expected.append(cell)
	return Funding._same_descriptor(tracks[0].casillas, expected)


static func _gain(resource: String, amount: int) -> Dictionary:
	return {"op": "ganar", "recurso": resource, "cantidad": amount, "objetivo": "propio"}


static func _effect(operation: String, amount: int) -> Dictionary:
	return {"op": operation, "cantidad": amount, "objetivo": "propio"}


func state_error(state: Variant) -> String:
	if not Validator.new().validate(state, _definitions, _catalog_id, _registry).ok or not _writable_tree(state):
		return "estado_invalido"
	if not supported() or state.mode != "competitivo" or state.turn.number < 1 or state.resolution != null 		or not state.turn.counters.is_empty() or not state.authority.completed_sequences.is_empty():
		return "estado_invalido"
	if state.lifecycle not in ["en_curso", "finalizada"] 		or state.turn.phase != ("libre" if state.lifecycle == "en_curso" else "finalizada"):
		return "estado_invalido"
	var alive: int = 0
	var completed: Dictionary = {}
	for player: Dictionary in state.players:
		if player.eliminated != (player.health == 0) or player.health > 40 or not player.ability_uses.is_empty() 			or not _training.supports_track(player.training_track_id) or player.training > Training.LAST_POSITION:
			return "estado_invalido"
		var burn_limit: int = 0
		for index: int in range(player.training + 1):
			if Training.PANEL[index] == "quema":
				burn_limit += 1
		if player.burn_limit != burn_limit:
			return "estado_invalido"
		if not player.eliminated:
			alive += 1
		completed[player.player_id] = 0
	if alive < 2 or _player(state, state.turn.active_id).get("eliminated", true):
		return "estado_invalido"
	for card: Dictionary in state.instances.values():
		if not card.state.flags.is_empty() or not card.state.ability_uses.is_empty():
			return "estado_invalido"
	if state.missions.size() != 3:
		return "estado_invalido"
	var seen: Array = []
	for mission_id: String in state.missions:
		var mission: Dictionary = state.missions[mission_id]
		if not mission.definition_id in ACTIVE_DEFINITIONS or mission.definition_id in seen:
			return "estado_invalido"
		seen.append(mission.definition_id)
		var cells: Array = _definitions[mission.definition_id].rasgos.recorridos[0].casillas
		if not Registry.exact_keys(mission.first_arrivals, _cell_ids(cells)):
			return "estado_invalido"
		var reached: Array = []
		for player_id: String in completed:
			var position: int = mission.progress[player_id]
			if position > 12:
				return "estado_invalido"
			if position == 12:
				reached.append(player_id)
				completed[player_id] += 1
			var expected: Array = []
			for index: int in range(position):
				var cell: Dictionary = cells[index]
				var terminal_cell: bool = state.outcome != null and state.outcome.mission_id == mission_id 					and state.outcome.winner_id == player_id and index == 11
				if terminal_cell:
					continue
				if not cell.efectos.is_empty():
					expected.append(cell.id + "_normal")
				if not cell.primero.is_empty() and mission.first_arrivals[cell.id] == player_id:
					expected.append(cell.id + "_primero")
			var actual: Array = mission.rewards[player_id].duplicate()
			actual.sort()
			expected.sort()
			if actual != expected:
				return "estado_invalido"
		for index: int in 12:
			var cell_id: String = cells[index].id
			var first: Variant = mission.first_arrivals[cell_id]
			var any_reached: bool = false
			for position: int in mission.progress.values():
				any_reached = any_reached or position > index
			if any_reached != (first != null) or (first != null and mission.progress[first] <= index):
				return "estado_invalido"
		var arrivals: Array = mission.arrival_order.duplicate()
		arrivals.sort()
		reached.sort()
		if arrivals != reached or (not arrivals.is_empty() and mission.arrival_order[0] != mission.first_arrivals.p12):
			return "estado_invalido"
	var winners: Array = []
	for player_id: String in completed:
		if completed[player_id] == 3:
			winners.append(player_id)
	if state.lifecycle == "en_curso":
		if state.outcome != null or not winners.is_empty():
			return "estado_invalido"
	else:
		if state.outcome == null or winners != [state.outcome.winner_id] 			or state.outcome.winner_id != state.turn.active_id or state.outcome.turn_number != state.turn.number:
			return "estado_invalido"
	return ""


func advance(snapshot: Variant, actor_id: String, mission_id: String) -> Dictionary:
	if not state_error(snapshot).is_empty():
		return _reject("estado_invalido")
	if snapshot.lifecycle != "en_curso" or snapshot.turn.active_id != actor_id or not snapshot.missions.has(mission_id):
		return _reject("accion_ilegal")
	var player: Dictionary = _player(snapshot, actor_id)
	var mission: Dictionary = snapshot.missions[mission_id]
	if player.eliminated or player.turn_resources.mision < 1 or mission.progress[actor_id] >= 12:
		return _reject("accion_ilegal")
	var candidate: Dictionary = snapshot.duplicate(true)
	var staged: Dictionary = candidate.missions[mission_id]
	var position: int = staged.progress[actor_id] + 1
	var cell_id: String = "p%02d" % position
	staged.progress[actor_id] = position
	_player(candidate, actor_id).turn_resources.mision -= 1
	if staged.first_arrivals[cell_id] == null:
		staged.first_arrivals[cell_id] = actor_id
	if position == 12:
		staged.arrival_order.append(actor_id)
	var all_complete: bool = true
	for value: Dictionary in candidate.missions.values():
		all_complete = all_complete and value.progress[actor_id] == 12
	if all_complete:
		candidate.lifecycle = "finalizada"
		candidate.turn.phase = "finalizada"
		candidate.outcome = {"winner_id": actor_id, "reason": "tres_misiones", "mission_id": mission_id, "turn_number": candidate.turn.number}
	else:
		var cell: Dictionary = _definitions[staged.definition_id].rasgos.recorridos[0].casillas[position - 1]
		for group: String in ["normal", "primero"]:
			if group == "primero" and staged.first_arrivals[cell_id] != actor_id:
				continue
			var effects: Array = cell.efectos if group == "normal" else cell.primero
			for effect: Dictionary in effects:
				if not _apply(candidate, actor_id, effect):
					return _reject("estado_invalido")
			if not effects.is_empty():
				# Training reemplaza la copia completa del candidato.
				candidate.missions[mission_id].rewards[actor_id].append(cell_id + "_" + group)
	if not state_error(candidate).is_empty():
		return _reject("estado_invalido")
	return {"ok": true, "codigo": "aceptada", "candidate": candidate}


func _apply(state: Dictionary, actor_id: String, effect: Dictionary) -> bool:
	var player: Dictionary = _player(state, actor_id)
	var amount: int = int(effect.cantidad)
	if effect.op == "curar":
		player.health = mini(40, player.health + amount)
		return true
	if effect.op == "avanzar":
		var result: Dictionary = _training.advance_for_mission(state, actor_id)
		if not result.ok:
			return false
		state.merge(result.candidate, true)
		return true
	if effect.op != "ganar":
		return false
	if effect.recurso != "atium":
		if player.turn_resources[effect.recurso] > Registry.MAX_INT - amount:
			return false
		player.turn_resources[effect.recurso] += amount
		return true
	if player.persistent.atium > Registry.MAX_INT - amount or state.authority.next_id > Registry.MAX_INT - amount:
		return false
	for index: int in amount:
		var id: String = "token_atium_" + str(state.authority.next_id)
		for token: Dictionary in player.metals:
			if token.token_id == id:
				return false
		player.metals.append({"token_id": id, "metal": "atium", "exhausted": false, "used_this_turn": false})
		player.persistent.atium += 1
		state.authority.next_id += 1
	return true


static func _cell_ids(cells: Array) -> Array:
	var ids: Array = []
	for cell: Dictionary in cells:
		ids.append(cell.id)
	return ids


static func _player(state: Dictionary, id: Variant) -> Dictionary:
	for player: Dictionary in state.players:
		if player.player_id == id:
			return player
	return {}


static func _writable_tree(value: Variant) -> bool:
	if value is Dictionary:
		if value.is_read_only() or value.is_typed():
			return false
		for item: Variant in value.values():
			if not _writable_tree(item):
				return false
	elif value is Array:
		if value.is_read_only() or value.is_typed():
			return false
		for item: Variant in value:
			if not _writable_tree(item):
				return false
	return true


static func _reject(code: String) -> Dictionary:
	return {"ok": false, "codigo": code}
