extends RefCounted
## Un paso de autoridad en inicio competitivo. El llamador decide si confirma
## el candidato y debe garantizar el consumo único del inicio al integrarlo.

const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")

# Marcas del panel SRC-004 en orden de recorrido, incluida la capacidad inicial.
const PANEL: Array[String] = [
	"quema", "", "", "quema", "", "nivel_1", "", "", "nivel_2", "quema",
	"", "atium", "", "nivel_3", "", "quema", "atium", "", "", "", "atium_continuo",
]
const LAST_POSITION: int = 20

var _definitions: Dictionary
var _catalog_id: String
var _registry: Registry
var _track_id: String = ""


func _init(definitions: Dictionary, catalog_id: String, profile: Dictionary, registry: Registry = null) -> void:
	_definitions = definitions.duplicate(true)
	_catalog_id = catalog_id
	_registry = registry
	# Descriptor técnico de autoridad, externo a la gramática de efectos P06.
	if not Registry.exact_keys(profile, ["catalog_id", "track_id", "definition", "marks"]) \
		or _catalog_id.is_empty() or not profile.catalog_id is String or profile.catalog_id != _catalog_id \
		or not Registry.valid_id(profile.track_id) or not profile.definition is Dictionary \
		or not profile.marks is Array or profile.marks.size() != PANEL.size():
		return
	for index: int in PANEL.size():
		if not profile.marks[index] is String or profile.marks[index] != PANEL[index]:
			return
	var definition: Variant = _definitions.get(profile.track_id)
	if definition is Dictionary and definition.get("id") is String and definition.id == profile.track_id \
		and definition.get("tipo") is String and definition.tipo == "pista_entrenamiento" \
		and definition == profile.definition:
		_track_id = profile.track_id


func supports_track(track_id: Variant) -> bool:
	return track_id is String and not _track_id.is_empty() and track_id == _track_id


static func unlocked_level(position: int) -> int:
	if position < 0 or position > LAST_POSITION:
		return 0
	if position >= 13:
		return 3
	if position >= 8:
		return 2
	return 1 if position >= 5 else 0


func advance(snapshot: Variant, player_id: Variant) -> Dictionary:
	var validator: Validator = Validator.new()
	if not validator.validate(snapshot, _definitions, _catalog_id, _registry).ok:
		return _reject("estado_invalido")
	if not player_id is String:
		return _reject("formato_invalido")
	if snapshot.mode != "competitivo" or snapshot.lifecycle != "en_curso" \
		or snapshot.turn.phase != "inicio" or snapshot.turn.number < 1 \
		or snapshot.turn.active_id != player_id or snapshot.resolution != null:
		return _reject("accion_ilegal")
	var player_index: int = -1
	# El orden de turno puede diferir del orden de almacenamiento.
	for index: int in snapshot.players.size():
		if snapshot.players[index].player_id == player_id:
			player_index = index
			break
	if player_index < 0:
		return _reject("estado_invalido")
	var player: Dictionary = snapshot.players[player_index]
	if player.eliminated or player.health <= 0:
		return _reject("accion_ilegal")
	if not supports_track(player.training_track_id):
		return _reject("pista_incompatible")
	var position: int = player.training
	if position > LAST_POSITION or not _writable(player):
		return _reject("estado_invalido")
	var next_position: int = mini(position + 1, LAST_POSITION)
	var gain_burn: bool = PANEL[next_position] == "quema"
	var gain_atium: bool = PANEL[next_position] == "atium" or position == LAST_POSITION
	if gain_burn and player.burn_limit == Registry.MAX_INT:
		return _reject("estado_invalido")
	var token_id: String = ""
	if gain_atium:
		var authority: Dictionary = snapshot.authority
		var metals: Array = player.metals
		if not _writable(authority) or not _writable(player.persistent) \
			or metals.is_read_only() or (metals.is_typed() and metals.get_typed_builtin() != TYPE_DICTIONARY) \
			or authority.next_id == Registry.MAX_INT or player.persistent.atium == Registry.MAX_INT:
			return _reject("estado_invalido")
		token_id = "token_atium_" + str(authority.next_id)
		for token: Dictionary in metals:
			if token.token_id == token_id:
				return _reject("estado_invalido")

	var candidate: Dictionary = snapshot.duplicate(true)
	var staged: Dictionary = candidate.players[player_index]
	staged.training = next_position
	if gain_burn:
		staged.burn_limit += 1
	if gain_atium:
		staged.metals.append({"token_id": token_id, "metal": "atium", "exhausted": false, "used_this_turn": false})
		staged.persistent.atium += 1
		candidate.authority.next_id += 1
	if not validator.validate(candidate, _definitions, _catalog_id, _registry).ok:
		return _reject("estado_invalido")
	return {"ok": true, "codigo": "aceptada", "candidate": candidate}


static func _writable(map: Dictionary) -> bool:
	return not map.is_read_only() and not map.is_typed()


static func _reject(code: String) -> Dictionary:
	return {"ok": false, "codigo": code}
