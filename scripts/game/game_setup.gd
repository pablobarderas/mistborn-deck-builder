extends RefCounted
## Preparación de autoridad desde un manifiesto físico completo; no interpreta efectos.

const Validator = preload("res://scripts/game/state_validator.gd")
const METALS: Array[String] = ["peltre", "estano", "bronce", "cobre", "zinc", "laton", "hierro", "acero"]
var _definitions: Dictionary
var _catalog_id: String


func _init(definitions: Dictionary, catalog_id: String) -> void:
	# El adaptador entrega solo definiciones verificadas; el fixture de tests es ficticio.
	_definitions = definitions.duplicate(true)
	_catalog_id = catalog_id


func create(match_id: String, mode: String, seats: Variant, first_player_id: Variant, manifest: Variant, seed: Variant) -> Dictionary:
	if not _valid_request(match_id, mode, seats, first_player_id, seed):
		return _fail("configuracion_invalida")
	if not _valid_manifest(manifest, mode):
		return _fail("contenido_incompleto")
	if not _valid_inventory(manifest, mode, seats.size()):
		return _fail("contenido_incompleto")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed
	var chosen_first: String = first_player_id if mode == "competitivo" else seats[rng.randi_range(0, seats.size() - 1)].player_id
	var order: Array = []
	var first_index: int = -1
	for index: int in seats.size():
		if seats[index].player_id == chosen_first:
			first_index = index
	for offset: int in seats.size():
		order.append(seats[(first_index + offset) % seats.size()].player_id)
	var characters: Array = manifest.characters.duplicate(true)
	_shuffle(characters, rng)
	var state: Dictionary = _empty_state(match_id, mode, order, seed)
	for index: int in seats.size():
		var player_id: String = seats[index].player_id
		var player: Dictionary = _new_player(seats[index], characters[index].character_id, manifest.training_track_id)
		var rank: int = order.find(player_id)
		if mode == "competitivo":
			if rank == 1:
				player.health += 2
			elif rank >= 2:
				player.health += 4
			if rank == 3:
				player.persistent.boxings = 1
		state.players.append(player)
		for kind: String in Validator.PLAYER_ZONES:
			_add_zone(state, player_id + "_" + kind, kind, player_id)
		var starter_deck: Array = characters[index].starters.duplicate()
		for unused: int in 6:
			starter_deck.append(manifest.funding_id)
		_shuffle(starter_deck, rng)
		for definition_id: String in starter_deck:
			_add_card(state, definition_id, player_id, player_id + "_mazo")
		_draw_five(state, player_id)
	for kind: String in ["mazo_mercado", "mercado", "eliminadas"]:
		_add_zone(state, kind, kind, null)
	var market: Array = manifest.market_cards.duplicate()
	_shuffle(market, rng)
	for definition_id: String in market:
		_add_card(state, definition_id, null, "mazo_mercado")
	for unused: int in 6:
		state.zones.mercado.cards.append(state.zones.mazo_mercado.cards.pop_back())
	var missions: Array = manifest.missions.duplicate()
	_shuffle(missions, rng)
	for index: int in 3:
		var mission_id: String = "mission_%d" % (index + 1)
		var progress: Dictionary = {}
		var rewards: Dictionary = {}
		for seat: Dictionary in seats:
			progress[seat.player_id] = 0
			rewards[seat.player_id] = []
		state.missions[mission_id] = {"definition_id": missions[index], "progress": progress,
			"rewards": rewards, "arrival_order": []}
	if mode == "competitivo" and seats.size() >= 3:
		state.target_id = order.back()
	if mode != "competitivo":
		_add_zone(state, "mazo_rival", "mazo_rival", null)
		_add_zone(state, "descarte_rival", "descarte_rival", null)
		_add_zone(state, "adversarios", "adversarios", null)
		var rival_cards: Array = manifest.rival.cards.duplicate()
		_shuffle(rival_cards, rng)
		for definition_id: String in rival_cards:
			_add_card(state, definition_id, null, "mazo_rival")
		state.rival = {"definition_id": manifest.rival.definition_id, "health": 48,
			"deck_zone": "mazo_rival", "discard_zone": "descarte_rival", "adversary_zone": "adversarios",
			"domination": {"definition_id": manifest.rival.domination_id, "face": 0,
				"position": 0, "visible_value": 1}, "adversaries": {}}
	state.authority.rng_state = rng.state
	var validation: Dictionary = Validator.new().validate(state, _definitions, _catalog_id)
	if not validation.ok:
		push_error("La preparación construyó un estado inválido: " + str(validation.errors))
		return _fail("estado_invalido")
	return {"ok": true, "codigo": "preparada", "snapshot": state}


func _valid_request(match_id: String, mode: String, seats: Variant, first_player_id: Variant, seed: Variant) -> bool:
	if not _id(match_id) or not _id(_catalog_id) or typeof(seed) != TYPE_INT or not seats is Array:
		return false
	if (mode == "solitario" and seats.size() != 1) or (mode in ["competitivo", "cooperativo"] and (seats.size() < 2 or seats.size() > 4)):
		return false
	if not mode in ["competitivo", "cooperativo", "solitario"]:
		return false
	var ids: Dictionary = {}
	for seat: Variant in seats:
		if not _keys(seat, ["player_id", "name"]) or not _id(seat.player_id) or not seat.name is String or seat.name.strip_edges().is_empty() or seat.name.length() > 128 or ids.has(seat.player_id):
			return false
		ids[seat.player_id] = true
	if mode == "competitivo":
		return first_player_id is String and ids.has(first_player_id)
	return first_player_id == null


func _valid_manifest(manifest: Variant, mode: String) -> bool:
	if not _keys(manifest, ["characters", "funding_id", "training_track_id", "market_cards", "missions", "rival"]):
		return false
	if not _type(manifest.funding_id, ["funding"]) or not _type(manifest.training_track_id, ["pista_entrenamiento"]):
		return false
	if not manifest.characters is Array or manifest.characters.size() != 4:
		return false
	var character_ids: Dictionary = {}
	for character: Variant in manifest.characters:
		if not _keys(character, ["character_id", "starters"]) or not _type(character.character_id, ["personaje"]) or character_ids.has(character.character_id):
			return false
		character_ids[character.character_id] = true
		if not _typed_list(character.starters, 4, ["entrenamiento"]):
			return false
	if not _typed_list(manifest.market_cards, 82, ["accion", "aliado"]):
		return false
	if not _typed_list(manifest.missions, 8, ["mision"]):
		return false
	var missions_seen: Dictionary = {}
	for mission_id: String in manifest.missions:
		if missions_seen.has(mission_id):
			return false
		missions_seen[mission_id] = true
	if mode == "competitivo":
		return manifest.rival == null
	if not _keys(manifest.rival, ["definition_id", "domination_id", "cards"]):
		return false
	return _type(manifest.rival.definition_id, ["rival"]) and _type(manifest.rival.domination_id, ["dominacion"]) and _typed_list(manifest.rival.cards, 36, ["edicto", "adversario"])


func _valid_inventory(manifest: Dictionary, mode: String, player_count: int) -> bool:
	if _definitions[manifest.training_track_id].cantidad < player_count:
		return false
	var used: Dictionary = {}
	for character: Dictionary in manifest.characters:
		for definition_id: String in character.starters:
			used[definition_id] = used.get(definition_id, 0) + 1
	used[manifest.funding_id] = used.get(manifest.funding_id, 0) + 6 * player_count
	for definition_id: String in manifest.market_cards:
		used[definition_id] = used.get(definition_id, 0) + 1
	if mode != "competitivo":
		for definition_id: String in manifest.rival.cards:
			used[definition_id] = used.get(definition_id, 0) + 1
	for definition_id: String in used:
		if used[definition_id] > _definitions[definition_id].cantidad:
			return false
	return true


func _typed_list(value: Variant, count: int, kinds: Array[String]) -> bool:
	if not value is Array or value.size() != count:
		return false
	for definition_id: Variant in value:
		if not _type(definition_id, kinds):
			return false
	return true


func _type(definition_id: Variant, kinds: Array[String]) -> bool:
	if not _id(definition_id) or not _definitions.has(definition_id):
		return false
	var definition: Variant = _definitions[definition_id]
	return (definition is Dictionary and definition.get("id") == definition_id and definition.get("tipo") in kinds
		and definition.get("revision") is Dictionary and definition.revision.get("estado") == "verificada"
		and typeof(definition.get("cantidad")) == TYPE_INT and definition.cantidad > 0)


func _keys(value: Variant, names: Array) -> bool:
	if not value is Dictionary or value.size() != names.size():
		return false
	for name: String in names:
		if not value.has(name):
			return false
	return true


func _id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.length() <= 128 and value.is_valid_identifier()


func _empty_state(match_id: String, mode: String, order: Array, seed: int) -> Dictionary:
	return {"version_esquema": Validator.SCHEMA_VERSION, "version_motor": Validator.ENGINE_VERSION,
		"catalog_id": _catalog_id, "match_id": match_id, "mode": mode, "revision": 0,
		"lifecycle": "en_curso", "players": [], "player_order": order,
		"instances": {}, "zones": {}, "turn": {"number": 1, "active_id": order[0], "phase": "inicio", "counters": {}},
		"missions": {}, "target_id": null, "rival": null, "resolution": null,
		"authority": {"rng_seed": seed, "rng_state": seed, "next_id": 1, "receipts": {}}}


func _new_player(seat: Dictionary, character_id: String, track_id: String) -> Dictionary:
	var metals: Array = []
	for metal: String in METALS:
		metals.append({"token_id": "token_" + metal, "metal": metal, "exhausted": false, "used_this_turn": false})
	return {"player_id": seat.player_id, "name": seat.name, "eliminated": false, "health": 36,
		"character_id": character_id, "training_track_id": track_id,
		"persistent": {"atium": 0, "boxings": 0}, "turn_resources": {"recursos": 0, "ataque": 0},
		"training": 0, "ability_uses": {}, "metals": metals, "burned": {}, "burn_limit": 1}


func _add_zone(state: Dictionary, zone_id: String, kind: String, holder_id: Variant) -> void:
	state.zones[zone_id] = {"zone_id": zone_id, "kind": kind, "holder_id": holder_id, "cards": []}


func _add_card(state: Dictionary, definition_id: String, owner_id: Variant, zone_id: String) -> void:
	var card_id: String = "card_%d" % state.authority.next_id
	state.authority.next_id += 1
	state.instances[card_id] = {"instance_id": card_id, "definition_id": definition_id,
		"owner_id": owner_id, "state": {"ability_uses": {}, "flags": {}}}
	state.zones[zone_id].cards.append(card_id)


func _draw_five(state: Dictionary, player_id: String) -> void:
	var deck: Array = state.zones[player_id + "_mazo"].cards
	var hand: Array = state.zones[player_id + "_mano"].cards
	for unused: int in 5:
		hand.append(deck.pop_back())


func _shuffle(items: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(items.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var saved: Variant = items[index]
		items[index] = items[other]
		items[other] = saved


func _fail(code: String) -> Dictionary:
	return {"ok": false, "codigo": code}
