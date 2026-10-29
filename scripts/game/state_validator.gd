extends RefCounted
## Invariantes estructurales del snapshot privado. No aplica reglas ni efectos.

const SCHEMA_VERSION: int = 1
const ENGINE_VERSION: String = "p08-atium-1/godot-4.7.2"
const METALS: Array[String] = ["peltre", "estano", "bronce", "cobre", "zinc", "laton", "hierro", "acero", "atium"]
const PLAYER_ZONES: Array[String] = ["mano", "mazo", "descarte", "juego"]
const SHARED_ZONES: Array[String] = ["mazo_mercado", "mercado", "eliminadas", "mazo_rival", "descarte_rival", "adversarios"]
# Límites técnicos de entrada, no cantidades máximas del juego de mesa.
const MAX_ITEMS: int = 10000
const MAX_DEPTH: int = 20
const MAX_NODES: int = 50000
var _remaining_nodes: int = MAX_NODES
var _errors: PackedStringArray = []
var _players: Dictionary = {}
var _definitions: Dictionary = {}
var _instances: Dictionary = {}
var _zones: Dictionary = {}


func validate(document: Variant, definitions: Dictionary, catalog_id: String) -> Dictionary:
	_errors.clear()
	_remaining_nodes = MAX_NODES
	_players = {}
	_definitions = definitions
	_instances = {}
	_zones = {}
	if not _plain(document, 0):
		_error("$", "datos no serializables o límite técnico excedido")
		return _result()
	if not _shape(document, ["version_esquema", "version_motor", "catalog_id", "match_id", "mode", "revision", "lifecycle", "players", "player_order", "instances", "zones", "turn", "missions", "target_id", "rival", "resolution", "authority"], "$"):
		return _result()
	if typeof(document.version_esquema) != TYPE_INT or document.version_esquema != SCHEMA_VERSION:
		_error("version_esquema", "versión no admitida")
	if not document.version_motor is String or document.version_motor != ENGINE_VERSION:
		_error("version_motor", "versión no admitida")
	if not document.catalog_id is String or document.catalog_id != catalog_id or catalog_id.is_empty():
		_error("catalog_id", "catálogo incompatible")
	_id(document.match_id, "match_id")
	_number(document.revision, "revision")
	_enum(document.lifecycle, ["sin_preparar", "en_curso", "finalizada"], "lifecycle")
	if _array(document.players, "players"):
		for value: Variant in document.players:
			_validate_player(value)
	if not _errors.is_empty():
		return _result()
	_validate_mode(document.mode, _players.size())
	if not _errors.is_empty():
		return _result()
	if _array(document.player_order, "player_order"):
		if not _player_list(document.player_order, "player_order") or document.player_order.size() != _players.size():
			_error("player_order", "debe contener todas las plazas una vez")
	if not _errors.is_empty():
		return _result()
	if _map(document.instances, "instances"):
		_instances = document.instances
		for key: Variant in _instances:
			_validate_instance(key, _instances[key])
	if not _errors.is_empty():
		return _result()
	if _map(document.zones, "zones"):
		_zones = document.zones
		_validate_zones(document.mode)
	if not _errors.is_empty():
		return _result()
	_validate_turn(document.turn)
	_validate_missions(document.missions)
	if document.target_id != null:
		_player_ref(document.target_id, "target_id")
		if document.mode != "competitivo" or _players.size() < 3:
			_error("target_id", "Target no aplicable a esta configuración")
	_validate_rival(document.rival, document.mode)
	_validate_resolution(document.resolution)
	_validate_authority(document.authority, document.revision)
	return _result()


func _validate_player(value: Variant) -> void:
	if not _shape(value, ["player_id", "name", "eliminated", "health", "character_id", "training_track_id", "persistent", "turn_resources", "training", "ability_uses", "metals", "burned", "burn_limit"], "players"):
		return
	if _id(value.player_id, "players.player_id"):
		if _players.has(value.player_id):
			_error("players.player_id", "plaza duplicada")
		_players[value.player_id] = true
	_text(value.name, "players.name")
	_bool(value.eliminated, "players.eliminated")
	_number(value.health, "players.health")
	_definition_ref(value.character_id, "players.character_id", "personaje", true)
	_definition_ref(value.training_track_id, "players.training_track_id", "pista_entrenamiento", true)
	_resources(value.persistent, ["atium", "boxings"], "players.persistent")
	_resources(value.turn_resources, ["recursos", "ataque"], "players.turn_resources")
	_number(value.training, "players.training")
	_counters(value.ability_uses, "players.ability_uses")
	_number(value.burn_limit, "players.burn_limit")
	if _map(value.burned, "players.burned"):
		for metal: Variant in value.burned:
			_enum(metal, METALS, "players.burned.metal")
			_number(value.burned[metal], "players.burned.count")
	var seen: Dictionary = {}
	var atium_count: int = 0
	if _array(value.metals, "players.metals"):
		for token: Variant in value.metals:
			if not _shape(token, ["token_id", "metal", "exhausted", "used_this_turn"], "players.metals"):
				continue
			if _id(token.token_id, "players.metals.token_id"):
				if seen.has(token.token_id):
					_error("players.metals.token_id", "ficha duplicada")
				seen[token.token_id] = true
			_enum(token.metal, METALS, "players.metals.metal")
			_bool(token.exhausted, "players.metals.exhausted")
			_bool(token.used_this_turn, "players.metals.used_this_turn")
			if token.metal is String and token.metal == "atium":
				atium_count += 1
				if token.exhausted is bool and token.exhausted:
					_error("players.metals.exhausted", "Atium no admite agotamiento en este subconjunto")
		# El total incluye las fichas usadas hasta su devolución en limpieza.
		if value.persistent is Dictionary and value.persistent.has("atium") \
			and typeof(value.persistent.atium) == TYPE_INT and value.persistent.atium != atium_count:
			_error("players.persistent.atium", "saldo distinto del total de fichas de Atium")


func _validate_instance(key: Variant, value: Variant) -> void:
	_id(key, "instances.key")
	if not _shape(value, ["instance_id", "definition_id", "owner_id", "state"], "instances"):
		return
	if not _id(value.instance_id, "instances.instance_id") or value.instance_id != key:
		_error("instances.instance_id", "identidad no coincide con clave")
	_definition_ref(value.definition_id, "instances.definition_id")
	if value.owner_id != null:
		_player_ref(value.owner_id, "instances.owner_id")
	# Solo contadores y marcas conocidos; no almacena texto ejecutable ni zona duplicada.
	if _shape(value.state, ["ability_uses", "flags"], "instances.state"):
		_counters(value.state.ability_uses, "instances.state.ability_uses")
		if _map(value.state.flags, "instances.state.flags"):
			for flag: Variant in value.state.flags:
				_id(flag, "instances.state.flags.key")
				_bool(value.state.flags[flag], "instances.state.flags.value")


func _validate_zones(mode: Variant) -> void:
	var locations: Dictionary = {}
	var slots: Dictionary = {}
	for key: Variant in _zones:
		_id(key, "zones.key")
		var zone: Variant = _zones[key]
		if not _shape(zone, ["zone_id", "kind", "holder_id", "cards"], "zones"):
			continue
		if not _id(zone.zone_id, "zones.zone_id") or zone.zone_id != key:
			_error("zones.zone_id", "identidad no coincide con clave")
		_enum(zone.kind, PLAYER_ZONES + SHARED_ZONES, "zones.kind")
		if not zone.kind is String:
			continue
		if zone.kind in PLAYER_ZONES:
			if not _player_ref(zone.holder_id, "zones.holder_id"):
				continue
		elif zone.holder_id != null:
			_error("zones.holder_id", "zona compartida sin titular")
		if mode == "competitivo" and zone.kind in ["mazo_rival", "descarte_rival", "adversarios"]:
			_error("zones.kind", "zona rival en competitivo")
		var slot: String = zone.kind + ":" + (zone.holder_id if zone.holder_id is String else "")
		if slots.has(slot):
			_error("zones", "zona lógica duplicada")
		slots[slot] = true
		if not _array(zone.cards, "zones.cards"):
			continue
		for instance_id: Variant in zone.cards:
			if not _id(instance_id, "zones.cards.instance_id"):
				continue
			if not _instances.has(instance_id):
				_error("zones.cards", "instancia inexistente")
				continue
			if locations.has(instance_id):
				_error("zones.cards", "instancia en más de una posición")
			locations[instance_id] = true
			var card: Variant = _instances[instance_id]
			if not card is Dictionary:
				continue
			if zone.kind in PLAYER_ZONES and card.get("owner_id") != zone.holder_id:
				_error("zones.cards", "carta ajena en zona personal")
			if zone.kind in SHARED_ZONES and zone.kind != "eliminadas" and card.owner_id != null:
				_error("zones.cards", "carta con propietario en suministro o rival")
	for key: Variant in _instances:
		if not locations.has(key):
			_error("instances", "instancia sin zona")
	for player_id: String in _players:
		for kind: String in PLAYER_ZONES:
			if not slots.has(kind + ":" + player_id):
				_error("zones", "falta zona personal")
	for kind: String in ["mazo_mercado", "mercado", "eliminadas"]:
		if not slots.has(kind + ":"):
			_error("zones", "falta zona compartida")


func _validate_turn(value: Variant) -> void:
	if not _shape(value, ["number", "active_id", "phase", "counters"], "turn"):
		return
	_number(value.number, "turn.number")
	if value.active_id != null:
		_player_ref(value.active_id, "turn.active_id")
	# Vocabulario técnico. Las transiciones reglamentarias llegarán en P08.
	_enum(value.phase, ["sin_iniciar", "inicio", "libre", "combate", "limpieza", "rival", "finalizada"], "turn.phase")
	_counters(value.counters, "turn.counters")


func _validate_missions(value: Variant) -> void:
	if not _map(value, "missions"):
		return
	for key: Variant in value:
		_id(key, "missions.key")
		var mission: Variant = value[key]
		if not _shape(mission, ["definition_id", "progress", "rewards", "arrival_order"], "missions"):
			continue
		_definition_ref(mission.definition_id, "missions.definition_id", "mision")
		for field: String in ["progress", "rewards"]:
			if not _map(mission[field], "missions." + field):
				continue
			if mission[field].size() != _players.size():
				_error("missions." + field, "faltan plazas")
			for player_id: Variant in mission[field]:
				_player_ref(player_id, "missions." + field)
				if field == "progress":
					_number(mission[field][player_id], "missions.progress.value")
				elif _array(mission[field][player_id], "missions.rewards.value"):
					_unique_ids(mission[field][player_id], "missions.rewards.value")
		if _array(mission.arrival_order, "missions.arrival_order"):
			_player_list(mission.arrival_order, "missions.arrival_order")


func _validate_rival(value: Variant, mode: Variant) -> void:
	if mode == "competitivo":
		if value != null:
			_error("rival", "competitivo no admite rival")
		return
	if not _shape(value, ["definition_id", "health", "deck_zone", "discard_zone", "adversary_zone", "domination", "adversaries"], "rival"):
		return
	_definition_ref(value.definition_id, "rival.definition_id", "rival", true)
	_number(value.health, "rival.health")
	_zone_ref(value.deck_zone, "mazo_rival", "rival.deck_zone")
	_zone_ref(value.discard_zone, "descarte_rival", "rival.discard_zone")
	_zone_ref(value.adversary_zone, "adversarios", "rival.adversary_zone")
	if _shape(value.domination, ["definition_id", "face", "position", "visible_value"], "rival.domination"):
		_definition_ref(value.domination.definition_id, "rival.domination.definition_id", "dominacion", true)
		for field: String in ["face", "position", "visible_value"]:
			_number(value.domination[field], "rival.domination." + field)
	if not _map(value.adversaries, "rival.adversaries"):
		return
	for key: Variant in value.adversaries:
		var enemy: Variant = value.adversaries[key]
		if not _shape(enemy, ["facing_id", "destroyed_shields"], "rival.adversaries"):
			continue
		_player_ref(enemy.facing_id, "rival.adversaries.facing_id")
		if not _instances.has(key) or not _instances[key] is Dictionary:
			_error("rival.adversaries", "instancia inexistente")
			continue
		var definition: Variant = _definitions.get(_instances[key].get("definition_id"), {})
		if not definition is Dictionary or definition.get("tipo") != "adversario":
			_error("rival.adversaries", "definición no es adversario")
		var shields: Variant = definition.get("rasgos", {}).get("escudos", 0) if definition is Dictionary and definition.get("rasgos", {}) is Dictionary else 0
		if not _number(shields, "rival.adversaries.shield_count"):
			continue
		if _array(enemy.destroyed_shields, "rival.adversaries.destroyed_shields"):
			var seen: Dictionary = {}
			for index: Variant in enemy.destroyed_shields:
				if _number(index, "rival.adversaries.shield_index"):
					if index >= shields or seen.has(index):
						_error("rival.adversaries.destroyed_shields", "índice fuera de rango o duplicado")
					seen[index] = true
		var zone: Variant = _zones.get(value.adversary_zone, {})
		if not zone is Dictionary or not zone.get("cards") is Array or not key in zone.cards:
			_error("rival.adversaries", "adversario fuera de su zona")
	var enemy_zone: Variant = _zones.get(value.adversary_zone, {})
	if enemy_zone is Dictionary and enemy_zone.get("cards") is Array:
		for instance_id: Variant in enemy_zone.cards:
			if not value.adversaries.has(instance_id):
				_error("rival.adversaries", "adversario sin estado")


func _validate_resolution(value: Variant) -> void:
	if value == null:
		return
	if not _shape(value, ["resolution_id", "source_id", "steps", "cursor", "recipients", "pending"], "resolution"):
		return
	_id(value.resolution_id, "resolution.resolution_id")
	if value.source_id != null and not _instances.has(value.source_id) and not _definitions.has(value.source_id):
		_error("resolution.source_id", "origen inexistente")
	if _array(value.steps, "resolution.steps"):
		_unique_ids(value.steps, "resolution.steps")
		if _number(value.cursor, "resolution.cursor") and value.cursor >= value.steps.size():
			_error("resolution.cursor", "cursor fuera de pasos pendientes")
	if _array(value.recipients, "resolution.recipients"):
		_player_list(value.recipients, "resolution.recipients")
	if value.pending == null:
		return
	if not _shape(value.pending, ["kind", "recipients", "options", "min", "max"], "resolution.pending"):
		return
	var pending: Dictionary = value.pending
	_enum(pending.kind, ["eleccion", "reaccion"], "resolution.pending.kind")
	if _array(pending.recipients, "resolution.pending.recipients"):
		_player_list(pending.recipients, "resolution.pending.recipients")
		if pending.recipients.is_empty():
			_error("resolution.pending.recipients", "sin destinatarios")
		for player_id: Variant in pending.recipients:
			if value.recipients is Array and not player_id in value.recipients:
				_error("resolution.pending.recipients", "destinatario fuera de resolución")
	if _array(pending.options, "resolution.pending.options"):
		_unique_ids(pending.options, "resolution.pending.options")
		if _number(pending.min, "resolution.pending.min") and _number(pending.max, "resolution.pending.max"):
			if pending.min > pending.max or pending.max > pending.options.size() or pending.max == 0:
				_error("resolution.pending", "límites de elección inválidos")


func _validate_authority(value: Variant, revision: Variant) -> void:
	if not _shape(value, ["rng_seed", "rng_state", "next_id", "receipts"], "authority"):
		return
	# Estado RNG admite int64 con signo (Godot); no se convierte a float/JSON.
	for field: String in ["rng_seed", "rng_state"]:
		if typeof(value[field]) != TYPE_INT:
			_error("authority." + field, "se requiere int64")
	_number(value.next_id, "authority.next_id")
	if not _map(value.receipts, "authority.receipts"):
		return
	for player_id: Variant in value.receipts:
		_player_ref(player_id, "authority.receipts.player_id")
		var per_player: Variant = value.receipts[player_id]
		if not _map(per_player, "authority.receipts.actions"):
			continue
		for action_id: Variant in per_player:
			_id(action_id, "authority.receipts.action_id")
			var receipt: Variant = per_player[action_id]
			if not _shape(receipt, ["canonical", "revision_aplicada"], "authority.receipts.receipt"):
				continue
			if not receipt.canonical is String or receipt.canonical.is_empty():
				_error("authority.receipts.canonical", "huella vacía o inválida")
			if _number(receipt.revision_aplicada, "authority.receipts.revision_aplicada"):
				if receipt.revision_aplicada == 0 or (typeof(revision) == TYPE_INT and receipt.revision_aplicada > revision):
					_error("authority.receipts.revision_aplicada", "revisión imposible")


func _validate_mode(value: Variant, count: int) -> void:
	_enum(value, ["competitivo", "cooperativo", "solitario"], "mode")
	if not value is String:
		return
	if (value == "solitario" and count != 1) or (value in ["competitivo", "cooperativo"] and (count < 2 or count > 4)):
		_error("players", "cantidad incompatible con modo")


func _definition_ref(value: Variant, at: String, kind: String = "", nullable: bool = false) -> void:
	if nullable and value == null:
		return
	if not _id(value, at):
		return
	var definition: Variant = _definitions.get(value)
	if not definition is Dictionary or definition.get("id") != value:
		_error(at, "definición no disponible")
	elif not kind.is_empty() and definition.get("tipo") != kind:
		_error(at, "tipo de definición incorrecto")


func _zone_ref(value: Variant, kind: String, at: String) -> void:
	if not _id(value, at):
		return
	var zone: Variant = _zones.get(value)
	if not zone is Dictionary or zone.get("kind") != kind:
		_error(at, "zona ausente o tipo incorrecto")


func _player_ref(value: Variant, at: String) -> bool:
	if not _id(value, at):
		return false
	if not _players.has(value):
		_error(at, "plaza inexistente")
		return false
	return true


func _player_list(value: Array, at: String) -> bool:
	var before: int = _errors.size()
	_unique_ids(value, at)
	for player_id: Variant in value:
		_player_ref(player_id, at)
	return before == _errors.size()


func _unique_ids(value: Array, at: String) -> void:
	var seen: Dictionary = {}
	for item: Variant in value:
		if _id(item, at):
			if seen.has(item):
				_error(at, "identificador duplicado")
			seen[item] = true


func _resources(value: Variant, keys: Array, at: String) -> void:
	if _shape(value, keys, at):
		for key: String in keys:
			_number(value[key], at + "." + key)


func _counters(value: Variant, at: String) -> void:
	if _map(value, at):
		for key: Variant in value:
			_id(key, at + ".key")
			_number(value[key], at + ".value")


func _shape(value: Variant, keys: Array, at: String) -> bool:
	if not _map(value, at):
		return false
	var valid: bool = true
	for key: String in keys:
		if not value.has(key):
			_error(at + "." + key, "campo obligatorio ausente")
			valid = false
	for key: Variant in value:
		if not key in keys:
			_error(at, "campo desconocido")
			valid = false
	return valid


func _plain(value: Variant, depth: int) -> bool:
	_remaining_nodes -= 1
	if depth > MAX_DEPTH or _remaining_nodes < 0:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return not value is String or value.length() <= 4096
		TYPE_ARRAY, TYPE_DICTIONARY:
			if value.size() > MAX_ITEMS:
				return false
			for key: Variant in value:
				if value is Dictionary and (not key is String or not _plain(value[key], depth + 1)):
					return false
				if value is Array and not _plain(key, depth + 1):
					return false
			return true
	return false


func _map(value: Variant, at: String) -> bool:
	if value is Dictionary:
		return true
	_error(at, "se requiere objeto")
	return false


func _array(value: Variant, at: String) -> bool:
	if value is Array:
		return true
	_error(at, "se requiere array")
	return false


func _number(value: Variant, at: String) -> bool:
	if typeof(value) == TYPE_INT and value >= 0:
		return true
	_error(at, "se requiere entero no negativo")
	return false


func _bool(value: Variant, at: String) -> void:
	if typeof(value) != TYPE_BOOL:
		_error(at, "se requiere booleano")


func _id(value: Variant, at: String) -> bool:
	if value is String and not value.is_empty() and value.length() <= 128 and value.is_valid_identifier():
		return true
	_error(at, "identificador inválido")
	return false


func _text(value: Variant, at: String) -> void:
	if not value is String or value.strip_edges().is_empty():
		_error(at, "se requiere texto no vacío")


func _enum(value: Variant, options: Array, at: String) -> void:
	if not value is String or not value in options:
		_error(at, "valor no admitido")


func _error(at: String, message: String) -> void:
	_errors.append(at + ": " + message)


func _result() -> Dictionary:
	return {"ok": _errors.is_empty(), "errors": _errors.duplicate()}
