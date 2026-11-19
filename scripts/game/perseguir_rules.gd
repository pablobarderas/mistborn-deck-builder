extends RefCounted
## Reglas cerradas de la primera Acción española; nunca interpreta texto de carta.

const Funding = preload("res://scripts/game/funding_play.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Core = preload("res://scripts/game/game_engine.gd")
const ACTION: String = "jugar_perseguir"
const MARK: String = "perseguir_revision"
const SOURCE_ID: String = "src_005_mercado_3"
const SOURCE_SHA256: String = "747a01d7ebbf69e8272c052c81a40beaa5ef67fff853c1c4e1e8c69b49a105cb"


static func card_supported(card: Dictionary) -> bool:
	if card.id != "perseguir" or card.tipo != "accion" or card.cantidad != 1 or card.coste_compra != 3 or card.metales != ["cobre", "bronce"] or card.vinculos != [] or card.rasgos != {} or card.habilidades.size() != 2:
		return false
	return Funding._same_descriptor(card.habilidades, [
		{"id": "principal_bronce", "momento": "al_jugar", "condicion": {"op": "metal_asignado", "metales": ["bronce"]}, "limite_por_turno": null, "efectos": [{"op": "ganar", "recurso": "mision", "cantidad": 2, "objetivo": "propio"}, {"op": "ganar", "recurso": "recursos", "cantidad": 2, "objetivo": "propio"}]},
		{"id": "savant_metal", "momento": "metal_quemado", "condicion": {"op": "esta_carta_como_metal", "metales": ["cobre", "bronce"]}, "limite_por_turno": null, "efectos": [{"op": "ganar", "recurso": "mision", "cantidad": 1, "objetivo": "propio"}]}])


static func source_supported(catalog: Dictionary) -> bool:
	# Una huella válida de cualquier fichero no acredita esta carta concreta.
	var card: Dictionary = {}
	for definition: Dictionary in catalog.cartas:
		if definition.id == "perseguir":
			card = definition
	if card.is_empty() or card.fuentes.size() != 1 or card.fuentes[0].id != SOURCE_ID:
		return false
	for source: Dictionary in catalog.fuentes:
		if source.id == SOURCE_ID:
			return source.tipo == "carta_fisica" and source.get("sha256") == SOURCE_SHA256
	return false


static func payload_error(payload: Dictionary) -> String:
	if not Registry.exact_keys(payload, ["instance_id", "ruta", "aplicar", "metal", "origen"]) or not Registry.valid_id(payload.instance_id) or not payload.aplicar is bool or payload.ruta not in ["primaria", "metal"] or not payload.origen is Dictionary:
		return "formato_invalido"
	if payload.ruta == "metal":
		return "" if payload.metal in ["cobre", "bronce"] and payload.origen.is_empty() else "formato_invalido"
	if not payload.aplicar:
		return "" if payload.metal == null and payload.origen.is_empty() else "formato_invalido"
	return "" if payload.metal == "bronce" and Registry.exact_keys(payload.origen, ["tipo", "id"]) and payload.origen.tipo in ["ficha", "carta"] and Registry.valid_id(payload.origen.id) else "formato_invalido"


static func apply(state: Dictionary, owner: String, payload: Dictionary, definitions: Dictionary) -> String:
	var syntax: String = payload_error(payload)
	if not syntax.is_empty():
		return syntax
	if not Funding._eligible(state, owner, payload.instance_id, "perseguir"):
		return "accion_ilegal"
	var player: Dictionary = Funding._funding_player(state, owner)
	var hand: Dictionary = Funding._zone(state, "mano", owner)
	var play: Dictionary = Funding._zone(state, "juego", owner)
	var mission: int = (2 if payload.ruta == "primaria" else 1) if payload.aplicar else 0
	var coins: int = 2 if payload.ruta == "primaria" and payload.aplicar else 0
	var fuel: String = ""
	var token: Dictionary = {}
	if payload.ruta == "primaria" and payload.aplicar:
		if payload.origen.tipo == "carta":
			fuel = payload.origen.id
			var instance: Dictionary = state.instances.get(fuel, {})
			var definition: Dictionary = definitions.get(instance.get("definition_id"), {})
			if fuel == payload.instance_id or fuel not in hand.cards or instance.get("owner_id") != owner or definition.get("tipo") != "accion" or "bronce" not in definition.get("metales", []) or instance.state.ability_uses.has(MARK):
				return "accion_ilegal"
		else:
			var used: int = 0
			for item: Dictionary in player.metals:
				used += 1 if item.used_this_turn else 0
				if item.token_id == payload.origen.id:
					token = item
			if token.is_empty() or token.metal not in ["bronce", "atium"] or token.exhausted or token.used_this_turn or used >= player.burn_limit:
				return "accion_ilegal"
	if player.turn_resources.mision > Registry.MAX_INT - mission or player.turn_resources.recursos > Registry.MAX_INT - coins or play.cards.size() > 10000 - (2 if not fuel.is_empty() else 1):
		return "estado_invalido"
	if not token.is_empty():
		if player.burned.get(token.metal, 0) == Registry.MAX_INT:
			return "estado_invalido"
		token.used_this_turn = true
		# La quema ordinaria sólo marca el uso del turno. El agotamiento
		# persistente pertenece a Flaring, que este perfil no admite.
		player.burned[token.metal] = player.burned.get(token.metal, 0) + 1
	var moving: Array = [payload.instance_id]
	if not fuel.is_empty():
		moving.append(fuel)
	for id: String in moving:
		if not state.instances[id].state.ability_uses.is_empty() or not state.instances[id].state.flags.is_empty():
			return "estado_invalido"
		hand.cards.erase(id)
		play.cards.append(id)
		state.instances[id].state.ability_uses[MARK] = state.revision + 1
	player.turn_resources.mision += mission
	player.turn_resources.recursos += coins
	return ""


static func closures_valid(state: Dictionary, definitions: Dictionary) -> bool:
	var expected: Dictionary = {}
	var engine: Core = Core.new({}, "canonical_only")
	for owner: String in state.authority.receipts:
		for id: String in state.authority.receipts[owner]:
			var receipt: Dictionary = state.authority.receipts[owner][id]
			var cursor: Array = [0, 256]
			var parsed: Variant = _decode(receipt.canonical, cursor, 0)
			if cursor[0] != receipt.canonical.length() or not parsed is Dictionary or parsed.get("tipo") != ACTION:
				continue
			if not engine._check_syntax(parsed).is_empty() or engine._canonical(parsed) != receipt.canonical or parsed.action_id != id or parsed.match_id != state.match_id or parsed.expected_revision != receipt.revision_aplicada - 1 or not payload_error(parsed.payload).is_empty():
				return false
			var payload: Dictionary = parsed.payload
			var card: Dictionary = state.instances.get(payload.instance_id, {})
			if card.get("definition_id") != "perseguir" or card.get("owner_id") != owner:
				return false
			var ids: Array = [payload.instance_id]
			if payload.ruta == "primaria" and payload.aplicar:
				if payload.origen.tipo == "carta":
					var fuel: Dictionary = state.instances.get(payload.origen.id, {})
					var definition: Dictionary = definitions.get(fuel.get("definition_id"), {})
					if fuel.get("owner_id") != owner or definition.get("tipo") != "accion" or "bronce" not in definition.get("metales", []) or payload.origen.id == payload.instance_id:
						return false
					ids.append(payload.origen.id)
				else:
					var found: bool = false
					for token: Dictionary in Funding._funding_player(state, owner).metals:
						if token.token_id == payload.origen.id and token.metal in ["bronce", "atium"] and token.used_this_turn and not token.exhausted:
							found = true
					if not found:
						return false
			for instance_id: String in ids:
				if expected.has(instance_id):
					return false
				expected[instance_id] = receipt.revision_aplicada
	var per_count: int = 0
	for instance: Dictionary in state.instances.values():
		per_count += 1 if instance.definition_id == "perseguir" else 0
		var mark: Dictionary = instance.state.ability_uses
		if expected.has(instance.instance_id):
			if mark != {MARK: expected[instance.instance_id]} or not instance.state.flags.is_empty():
				return false
			var zone: Dictionary = _location(state, instance.instance_id)
			if zone.kind not in ["juego", "eliminadas"] or (zone.kind == "juego" and zone.holder_id != instance.owner_id):
				return false
		elif not mark.is_empty() or not instance.state.flags.is_empty() or (instance.definition_id == "perseguir" and _location(state, instance.instance_id).get("kind") == "juego"):
			return false
	return per_count <= 1


static func _location(state: Dictionary, id: String) -> Dictionary:
	for zone: Dictionary in state.zones.values():
		if id in zone.cards:
			return zone
	return {}


static func _decode(value: String, cursor: Array, depth: int) -> Variant:
	# Lee sólo la representación canónica acotada de P07; nunca ejecuta datos.
	cursor[1] -= 1
	if cursor[0] < 0 or cursor[0] >= value.length() or cursor[1] < 0 or depth > 8:
		cursor[0] = -10000
		return null
	var kind: String = value[cursor[0]]
	cursor[0] += 1
	if kind == "n":
		return null
	if kind == "b":
		if cursor[0] < value.length() and value[cursor[0]] in ["0", "1"]:
			cursor[0] += 1
			return value[cursor[0] - 1] == "1"
	else:
		var delimiter: String = {"i": ";", "s": ":", "a": "[", "d": "{"}.get(kind, "")
		var end: int = value.find(delimiter, cursor[0]) if not delimiter.is_empty() else -1
		if end >= cursor[0]:
			var digits: String = value.substr(cursor[0], end - cursor[0])
			if digits.is_valid_int():
				var count: int = int(digits)
				cursor[0] = end + 1
				if kind == "i":
					return count
				if count >= 0 and count <= 4096:
					if kind == "s" and cursor[0] + count <= value.length():
						var result: String = value.substr(cursor[0], count)
						cursor[0] += count
						return result
					if kind in ["a", "d"] and count <= 256:
						var result: Variant = [] if kind == "a" else {}
						for index: int in count:
							var item: Variant = _decode(value, cursor, depth + 1)
							if cursor[0] < 0:
								return null
							if kind == "a":
								result.append(item)
							else:
								if not item is String or result.has(item):
									cursor[0] = -10000
									return null
								result[item] = _decode(value, cursor, depth + 1)
								if cursor[0] < 0:
									return null
						if cursor[0] < value.length() and value[cursor[0]] == ("]" if kind == "a" else "}"):
							cursor[0] += 1
							return result
	cursor[0] = -10000
	return null
