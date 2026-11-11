extends "res://scripts/game/game_engine.gd"
## Adaptador de autoridad aislado. Sólo registra Funding sobre un perfil completo.
## Los descriptores inertes son configuración fiable, nunca entrada de jugadores.

const CatalogValidator = preload("res://scripts/catalog/catalog_validator.gd")
const PROGRAM_ID: String = "funding_play_v1"
const ACTION_ID: String = "jugar_funding"
const OCCURRENCE_PREFIX: String = "funding_play_"
var _supported: bool = false
var _funding_id: String
var _identity: String = "funding_invalid"


func _init(catalog: Dictionary, funding_id: String, inert_descriptors: Dictionary) -> void:
	_funding_id = funding_id
	var checked: Dictionary = CatalogValidator.new().validate(catalog)
	var content: Dictionary = checked.cards
	var registry: Registry = Registry.new()
	var starters: Dictionary = {}
	if checked.ok and content.size() == checked.verified.size() and _matches_profile(content, funding_id, inert_descriptors):
		registry = Registry.new(_registration(funding_id))
		_supported = registry.is_valid()
	if _supported:
		# Sólo una definición Funding puede pasar el perfil. Los descriptores
		# inertes coinciden con el catálogo y sus copias quedan en GameEngine.
		_identity = "funding_" + _canonical_content(catalog).sha256_text()
		starters[ACTION_ID] = _start
	super(content, _identity, {}, registry, starters)


func is_supported() -> bool:
	return _supported


func catalog_identity() -> String:
	return _identity


func load_authority_snapshot(document: Variant) -> Dictionary:
	if not _supported:
		return {"ok": false, "errors": PackedStringArray(["Perfil de contenido no soportado."])}
	var validation: Dictionary = _state.validate_candidate(document)
	if not validation.ok:
		push_warning("Estado de partida rechazado; se conserva el snapshot anterior.")
		return validation
	# Las marcas privadas incompatibles se rechazan al admitir el snapshot,
	# antes de que una acción de otro jugador pueda observarlas por su resultado.
	if not _known_dynamic_state(document):
		push_warning("Estado de partida rechazado; se conserva el snapshot anterior.")
		return {"ok": false, "errors": PackedStringArray(["Estado incompatible con el perfil Funding."])}
	if not _valid_funding_closures(document.authority.completed_sequences):
		push_warning("Estado de partida rechazado; se conserva el snapshot anterior.")
		return {"ok": false, "errors": PackedStringArray(["Cierre incompatible con el programa Funding."])}
	return super.load_authority_snapshot(document)


func _start(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	if not Registry.exact_keys(payload, ["instance_id", "aplicar"]) or not Registry.valid_id(payload.instance_id) or not payload.aplicar is bool:
		return "formato_invalido"
	if not _supported or not _eligible(state, actor_id, payload.instance_id, _funding_id) or not _known_dynamic_state(state):
		return "accion_ilegal"
	if not _can_write(state, actor_id, payload.aplicar):
		return "estado_invalido"
	return {"program_id": PROGRAM_ID, "source_id": payload.instance_id, "recipients": [actor_id],
		"context": {"owner_id": actor_id, "turn_number": state.turn.number, "entry_phase": "libre",
			"occurrence_id": OCCURRENCE_PREFIX + str(state.authority.next_id),
			"card_id": payload.instance_id, "apply_effect": payload.aplicar}}


static func _registration(funding_id: String) -> Dictionary:
	return {"operations": {"funding_play": {"params": {}, "validate_params": _empty_params,
		"execute": _play.bind(funding_id)}}, "programs": {PROGRAM_ID: {
		"steps": [{"step_id": "play_and_gain", "operation": "funding_play", "params": {}}],
		"context": {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id", "occurrence_id": "id",
			"card_id": "instance_id", "apply_effect": "bool"}, "scope": _funding_scope.bind(funding_id), "allow_null_source": false}}}


static func _empty_params(params: Dictionary) -> bool:
	return params.is_empty()


static func _funding_scope(state: Dictionary, context: Dictionary, funding_id: String) -> Array:
	# Se comprueba también tras ejecutar el paso: la carta estará entonces en juego.
	if state.mode != "competitivo" or context.entry_phase != "libre" or not _known_dynamic_state(state):
		return []
	var card: Dictionary = state.instances.get(context.card_id, {})
	if card.get("owner_id") != context.owner_id or card.get("definition_id") != funding_id:
		return []
	var next_id: int = state.authority.next_id
	if context.occurrence_id not in [OCCURRENCE_PREFIX + str(next_id), OCCURRENCE_PREFIX + str(next_id - 1)]:
		return []
	return [context.owner_id]


static func _play(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array, funding_id: String) -> bool:
	if not selected.is_empty() or not _eligible(state, context.owner_id, context.card_id, funding_id) \
		or not _known_dynamic_state(state) or not _can_write(state, context.owner_id, context.apply_effect):
		return false
	var hand: Dictionary = _zone(state, "mano", context.owner_id)
	var play: Dictionary = _zone(state, "juego", context.owner_id)
	hand.cards.remove_at(hand.cards.find(context.card_id))
	play.cards.append(context.card_id)
	if context.apply_effect:
		_funding_player(state, context.owner_id).turn_resources.recursos += 1
	return true


static func _eligible(state: Dictionary, actor_id: String, card_id: String, funding_id: String) -> bool:
	if state.mode != "competitivo" or state.players.size() < 2 or state.players.size() > 4 or state.lifecycle != "en_curso" \
		or state.turn.active_id != actor_id or state.turn.phase != "libre" or state.turn.number < 1 or state.resolution != null:
		return false
	var player: Dictionary = _funding_player(state, actor_id)
	var card: Dictionary = state.instances.get(card_id, {})
	var hand: Dictionary = _zone(state, "mano", actor_id)
	return not player.is_empty() and not player.eliminated and player.health > 0 \
		and card.get("owner_id") == actor_id and card.get("definition_id") == funding_id \
		and not hand.is_empty() and card_id in hand.cards and not _zone(state, "juego", actor_id).is_empty()


static func _known_dynamic_state(state: Dictionary) -> bool:
	# Ninguna marca o recompensa desconocida se interpreta como ausencia de efectos.
	if not state.turn.counters.is_empty():
		return false
	for player: Dictionary in state.players:
		if not player.ability_uses.is_empty():
			return false
	for card: Dictionary in state.instances.values():
		if not card.state.flags.is_empty() or not card.state.ability_uses.is_empty():
			return false
	for mission: Dictionary in state.missions.values():
		for rewards: Array in mission.rewards.values():
			if not rewards.is_empty():
				return false
	return true


static func _valid_funding_closures(ledger: Dictionary) -> bool:
	for resolution_id: String in ledger:
		var closed: Dictionary = ledger[resolution_id]
		# P07 ya comprobó que la clave tiene el prefijo y sufijo canónicos.
		if closed.program_id == PROGRAM_ID and closed.occurrence_id != OCCURRENCE_PREFIX + resolution_id.trim_prefix(Registry.ID_PREFIX):
			return false
	return true


static func _can_write(state: Dictionary, actor_id: String, apply: bool) -> bool:
	var hand: Array = _zone(state, "mano", actor_id).cards
	var play: Array = _zone(state, "juego", actor_id).cards
	if hand.is_read_only() or play.is_read_only() or (play.is_typed() and play.get_typed_builtin() != TYPE_STRING):
		return false
	if apply:
		var resources: Dictionary = _funding_player(state, actor_id).turn_resources
		return not resources.is_read_only() and resources.recursos < Registry.MAX_INT
	return true


static func _funding_player(state: Dictionary, id: String) -> Dictionary:
	for player: Dictionary in state.players:
		if player.player_id == id:
			return player
	return {}


static func _zone(state: Dictionary, kind: String, holder: String) -> Dictionary:
	for zone: Dictionary in state.zones.values():
		if zone.kind == kind and zone.holder_id == holder:
			return zone
	return {}


static func _matches_profile(content: Dictionary, funding_id: String, inert_descriptors: Dictionary) -> bool:
	if not content.has(funding_id) or not _funding(content[funding_id]) or inert_descriptors.size() != content.size() - 1:
		return false
	for id: String in content:
		if id != funding_id and (not _same_descriptor(inert_descriptors.get(id), content[id]) or not _inert(content[id])):
			return false
	return true


static func _same_descriptor(candidate: Variant, validated: Variant) -> bool:
	# La forma y profundidad las fija el descriptor validado por P06. Sus
	# números son integrales, así que sólo el mismo valor int/float equivale.
	if validated is int or validated is float:
		return (candidate is int or candidate is float) and candidate == validated
	if typeof(candidate) != typeof(validated):
		return false
	if validated is Dictionary:
		if candidate.size() != validated.size():
			return false
		for key: Variant in candidate:
			if not key is String or not validated.has(key) or not _same_descriptor(candidate[key], validated[key]):
				return false
		return true
	if validated is Array:
		if candidate.size() != validated.size():
			return false
		for index: int in validated.size():
			if not _same_descriptor(candidate[index], validated[index]):
				return false
		return true
	return candidate == validated


static func _funding(card: Dictionary) -> bool:
	if card.tipo != "funding" or card.coste_compra != null or card.metales != [] or card.rasgos != {} \
		or card.vinculos != [] or card.habilidades.size() != 1:
		return false
	var ability: Dictionary = card.habilidades[0]
	if ability.momento != "al_jugar" or ability.condicion != {"op": "siempre"} or ability.limite_por_turno != null or ability.efectos.size() != 1:
		return false
	var effect: Dictionary = ability.efectos[0]
	return effect.op == "ganar" and effect.recurso == "recursos" and effect.cantidad == 1 and effect.objetivo == "propio"


static func _inert(card: Dictionary) -> bool:
	if card.tipo not in ["accion", "aliado", "personaje", "mision", "pista_entrenamiento", "rival", "dominacion", "adversario"] \
		or card.metales != [] or card.vinculos != []:
		return false
	for ability: Dictionary in card.habilidades:
		if ability.momento != "al_jugar" or ability.condicion != {"op": "siempre"} or ability.limite_por_turno != null \
			or ability.efectos != [{"op": "sin_efecto"}]:
			return false
	var expected_traits: Array = []
	if card.tipo in ["mision", "pista_entrenamiento", "dominacion"]:
		expected_traits = ["recorridos"]
	elif card.tipo == "rival":
		expected_traits = ["salud"]
	elif card.tipo == "adversario":
		expected_traits = ["escudos"]
	if not Registry.exact_keys(card.rasgos, expected_traits):
		return false
	for track: Dictionary in card.rasgos.get("recorridos", []):
		for cell: Dictionary in track.casillas:
			if cell.efectos != [{"op": "sin_efecto"}]:
				return false
	return true


static func _canonical_content(value: Variant) -> String:
	if value is Dictionary:
		var keys: Array = value.keys()
		keys.sort()
		var result: String = "d["
		for key: String in keys:
			result += _canonical_content(key) + _canonical_content(value[key])
		return result + "]"
	if value is Array:
		var result: String = "a["
		for item: Variant in value:
			result += _canonical_content(item)
		return result + "]"
	# P06 acepta números integrales de JSON y Variant como el mismo dato.
	if value is float:
		return _canonical_content(int(value))
	return str(typeof(value)) + ":" + JSON.stringify(value) + ";"
