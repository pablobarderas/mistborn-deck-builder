extends "res://scripts/game/game_engine.gd"
## Ensayo cerrado de autoridad E1. No admite producto ni interpreta texto.

const Catalog = preload("res://scripts/catalog/catalog_validator.gd")
const Bindings = preload("res://scripts/catalog/initial_competitive_bindings.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const Setup = preload("res://scripts/game/game_setup.gd")
const Training = preload("res://scripts/game/training_advance.gd")
const PROGRAM: String = "initial_competitive_fixture_v1_without_ii_with_panel_descriptor"
const PLAY: String = "jugar_entrenamiento"
const CHARACTER: String = "activar_personaje"
const MARK: String = "e1_play_revision"
const SIGNATURES: Dictionary = {"kelsier": "acero", "marsh": "bronce", "shan": "zinc", "vin": "peltre"}

class SnapshotSource extends RefCounted:
	## La fuente fiable conserva checkpoint, comandos y último snapshot confirmado.
	func latest(_match_id: String, _profile_id: String) -> Dictionary:
		return {}

var _catalog: Dictionary
var _content: Dictionary = {}
var _manifest: Dictionary
var _identity: String = ""
var _content_digest: String = ""
var _supported: bool = false
var _advance: Training
var _checkpoint: Dictionary = {}
var _commands: Array = []
var _owner_thread: int = OS.get_thread_caller_id()
var _busy: bool = false
var _intent: Dictionary = {}
var _actor: String = ""


func _init(catalog: Dictionary, manifest: Dictionary) -> void:
	_catalog = catalog.duplicate(true)
	_manifest = manifest.duplicate(true)
	var checked: Dictionary = Catalog.new().validate(_catalog)
	_supported = checked.ok and _catalog.get("version_esquema") == 5 and checked.cards.size() == checked.verified.size()
	if _supported:
		_content = checked.cards.duplicate(true)
		_supported = Bindings.check_authoring(_content, _manifest) and _closed_content()
	if _supported:
		_identity = "initial_fixture_" + Funding._canonical_content([PROGRAM, _catalog, _manifest]).sha256_text()
		_content_digest = Funding._canonical_content(_content).sha256_text()
	super(_content, _identity, {Funding.ACTION_ID: _funding, PLAY: _training, CHARACTER: _character})
	_advance = Training.new(_content, _identity, {"catalog_id": _identity, "track_id": "pista_entrenamiento",
		"definition": _content.get("pista_entrenamiento", {}), "marks": Training.PANEL.duplicate()})
	_supported = _supported and _advance.supports_track("pista_entrenamiento")


func is_supported() -> bool:
	return _supported


func profile_identity() -> String:
	return _identity


func catalog_identity() -> String:
	return _identity


func _profile_intact() -> bool:
	return _supported and _state._definitions == _content and _state._catalog_id == _identity \
		and _content_digest == Funding._canonical_content(_content).sha256_text() \
		and _advance._definitions == _content and _advance._catalog_id == _identity and _advance.supports_track("pista_entrenamiento") \
		and _identity == "initial_fixture_" + Funding._canonical_content([PROGRAM, _catalog, _manifest]).sha256_text()


func load_authority_snapshot(_document: Variant) -> Dictionary:
	return _load_rejected("Usa preparación o fuente de autoridad del ensayo E1.")


func prepare_match(match_id: String, seats: Array, first_player_id: String, seed: int) -> Dictionary:
	if not _begin():
		return _load_rejected("Autoridad ocupada o hilo incorrecto.")
	var result: Dictionary = _load_rejected("Perfil incompatible o partida ya cargada.")
	if _profile_intact() and _state.get_snapshot().is_empty() and Bindings.check_authoring(_content, _manifest):
		var definitions: Dictionary = _content.duplicate(true)
		for card: Dictionary in definitions.values():
			card.cantidad = int(card.cantidad)
		var prepared: Dictionary = Setup.new(definitions, _identity).create(match_id, "competitivo", seats, first_player_id, _manifest, seed)
		if prepared.ok:
			result = _admit_checkpoint(prepared.snapshot)
	_busy = false
	return result


func export_authority_entry() -> Dictionary:
	return {"profile_id": _identity, "checkpoint": _checkpoint.duplicate(true),
		"commands": _commands.duplicate(true), "snapshot": get_authority_snapshot()}


func restore_match(match_id: String, source: Variant) -> Dictionary:
	if not _begin():
		return _load_rejected("Autoridad ocupada o hilo incorrecto.")
	var result: Dictionary = _restore(match_id, source)
	_busy = false
	return result


func _restore(match_id: String, source: Variant) -> Dictionary:
	if not _profile_intact() or not _state.get_snapshot().is_empty() or not source is SnapshotSource:
		return _load_rejected("Restauración no disponible.")
	var entry: Dictionary = source.latest(match_id, _identity)
	if not Registry.exact_keys(entry, ["profile_id", "checkpoint", "commands", "snapshot"]) \
		or entry.profile_id != _identity or not entry.checkpoint is Dictionary or not entry.commands is Array \
		or not entry.snapshot is Dictionary or entry.checkpoint.get("match_id") != match_id:
		return _load_rejected("Fuente incompatible con partida y perfil.")
	# Reproducir en una autoridad desechable evita admitir recursos o cierres
	# falsos y conserva atómicamente el destino ante cualquier fallo del registro.
	var replay: RefCounted = get_script().new(_catalog, _manifest)
	if not replay._admit_checkpoint(entry.checkpoint).ok:
		return _load_rejected("Checkpoint incompatible.")
	for command: Variant in entry.commands:
		if not command is Dictionary or not Registry.exact_keys(command, ["actor", "intent"]) \
			or not command.actor is String or not command.intent is Dictionary:
			return _load_rejected("Registro incompatible.")
		var before: int = replay.get_authority_snapshot().revision
		var accepted: Dictionary = replay.start_turn(command.actor, command.intent) if command.intent.get("tipo") == START_TURN_ACTION else replay.submit(command.actor, command.intent)
		if not accepted.ok or replay.get_authority_snapshot().revision != before + 1:
			return _load_rejected("Registro incompatible o duplicado.")
	if replay.get_authority_snapshot() != entry.snapshot:
		return _load_rejected("Snapshot distinto del registro confirmado.")
	var loaded: Dictionary = _state.try_load(entry.snapshot)
	if loaded.ok:
		_checkpoint = entry.checkpoint.duplicate(true)
		_commands = entry.commands.duplicate(true)
	return loaded


func _admit_checkpoint(snapshot: Dictionary) -> Dictionary:
	if not _profile_intact() or not _state.get_snapshot().is_empty() or not _state.validate_candidate(snapshot).ok \
		or not _state_error(snapshot).is_empty() or snapshot.revision != 0 or not snapshot.authority.receipts.is_empty() \
		or not snapshot.authority.completed_sequences.is_empty():
		return _load_rejected("Checkpoint de ensayo inválido.")
	for player: Dictionary in snapshot.players:
		if player.turn_resources != {"recursos": 0, "ataque": 0, "mision": 0} or not player.ability_uses.is_empty() or not player.burned.is_empty():
			return _load_rejected("Checkpoint con efectos sin registro.")
	for card: Dictionary in snapshot.instances.values():
		if not card.state.ability_uses.is_empty() or not card.state.flags.is_empty():
			return _load_rejected("Checkpoint con cartas usadas sin registro.")
	var result: Dictionary = _state.try_load(snapshot)
	if result.ok:
		_checkpoint = snapshot.duplicate(true)
	return result


func start_turn(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, true)


func submit(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, false)


func _operation(actor_id: String, input: Variant, starting: bool) -> Dictionary:
	if not _begin():
		return _reject("accion_ilegal", 0)
	var before: Dictionary = get_authority_snapshot()
	var result: Dictionary = _reject("estado_invalido", before.get("revision", 0))
	if _profile_intact() and not before.is_empty() and _state_error(before).is_empty():
		_intent = input.duplicate(true) if input is Dictionary else {}
		_actor = actor_id
		result = _submit(actor_id, input, _start if starting else Callable())
		if result.ok and get_authority_snapshot().revision > before.revision:
			_commands.append({"actor": actor_id, "intent": input.duplicate(true)})
	_intent = {}
	_actor = ""
	_busy = false
	return result


func _begin() -> bool:
	if _busy or OS.get_thread_caller_id() != _owner_thread:
		return false
	_busy = true
	return true


func _start(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["turn_number"]) or not payload.turn_number is int:
		return "formato_invalido"
	if candidate.turn.phase != "inicio" or payload.turn_number != candidate.turn.number:
		return "accion_ilegal"
	var advanced: Dictionary = _advance.advance(candidate, owner)
	if not advanced.ok:
		return "estado_invalido"
	candidate.merge(advanced.candidate, true)
	candidate.turn.phase = "libre"
	return ""


func _funding(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["instance_id", "aplicar"]) or not payload.aplicar is bool or not Registry.valid_id(payload.instance_id):
		return "formato_invalido"
	if not Funding._eligible(candidate, owner, payload.instance_id, "financiacion"):
		return "accion_ilegal"
	if payload.aplicar and not _gain(Funding._funding_player(candidate, owner), 1, 0, 0, 0):
		return "estado_invalido"
	_move(candidate, owner, payload.instance_id)
	return ""


func _training(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["instance_id", "aplicar", "metal", "origen"]) \
		or not Registry.valid_id(payload.instance_id) or not payload.aplicar is bool or not payload.origen is Dictionary:
		return "formato_invalido"
	var instance: Dictionary = candidate.instances.get(payload.instance_id, {})
	var definition: Dictionary = _content.get(instance.get("definition_id"), {})
	if definition.get("tipo") != "entrenamiento" or not Funding._eligible(candidate, owner, payload.instance_id, definition.id):
		return "accion_ilegal"
	if not payload.aplicar:
		if payload.metal != null or not payload.origen.is_empty():
			return "formato_invalido"
	else:
		var primary: String = definition.habilidades[0].condicion.metales[0]
		if payload.metal != primary or not Registry.exact_keys(payload.origen, ["tipo", "id"]) or not Registry.valid_id(payload.origen.id):
			return "formato_invalido"
		var player: Dictionary = Funding._funding_player(candidate, owner)
		if payload.origen.tipo == "ficha":
			var token: Dictionary = {}
			var used: int = 0
			for item: Dictionary in player.metals:
				used += 1 if item.used_this_turn else 0
				if item.token_id == payload.origen.id:
					token = item
			if token.is_empty() or token.metal not in [primary, "atium"] or token.exhausted or token.used_this_turn or used >= player.burn_limit:
				return "accion_ilegal"
			token.used_this_turn = true
			candidate.turn.counters[_burn_key(owner, token.token_id, primary)] = 1
			_increment_burned(player, token.metal)
			if token.metal == "atium":
				_increment_burned(player, primary)
		elif payload.origen.tipo == "carta":
			var fuel: Dictionary = candidate.instances.get(payload.origen.id, {})
			var fuel_definition: Dictionary = _content.get(fuel.get("definition_id"), {})
			if fuel.get("owner_id") != owner or payload.origen.id == payload.instance_id \
				or fuel_definition.get("tipo") not in ["entrenamiento", "accion"] or primary not in fuel_definition.get("metales", []) \
				or payload.origen.id not in Funding._zone(candidate, "mano", owner).cards:
				return "accion_ilegal"
			_move(candidate, owner, payload.origen.id)
			fuel.state.flags["e1_metal_" + primary] = true
			_increment_burned(player, primary)
		else:
			return "formato_invalido"
		var gains: Array = _primary_gains(definition.id)
		if not _gain(player, gains[0], gains[1], gains[2], 0):
			return "estado_invalido"
	_move(candidate, owner, payload.instance_id)
	return ""


func _character(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["nivel", "aplicar"]) or not payload.nivel is int or payload.nivel not in [1, 3] or not payload.aplicar is bool:
		return "formato_invalido"
	var player: Dictionary = Funding._funding_player(candidate, owner)
	var key: String = "e1_nivel_" + str(payload.nivel)
	var metal: String = "atium" if payload.nivel == 3 else SIGNATURES[player.character_id]
	if candidate.turn.phase != "libre" or Training.unlocked_level(player.training) < payload.nivel \
		or player.ability_uses.has(key) or player.burned.get(metal, 0) < 1:
		return "accion_ilegal"
	var gains: Array = [0, 3, 3, 0] if payload.nivel == 3 else _signature_gains(player.character_id)
	if payload.aplicar and not _gain(player, gains[0], gains[1], gains[2], gains[3]):
		return "estado_invalido"
	player.ability_uses[key] = candidate.revision + 1
	return ""


func _move(state: Dictionary, owner: String, id: String) -> void:
	Funding._zone(state, "mano", owner).cards.erase(id)
	Funding._zone(state, "juego", owner).cards.append(id)
	state.instances[id].state.ability_uses[MARK] = state.revision + 1


static func _gain(player: Dictionary, coins: int, attack: int, mission: int, health: int) -> bool:
	for pair: Array in [["recursos", coins], ["ataque", attack], ["mision", mission]]:
		if player.turn_resources[pair[0]] > Registry.MAX_INT - pair[1]:
			return false
	player.turn_resources.recursos += coins
	player.turn_resources.ataque += attack
	player.turn_resources.mision += mission
	player.health = mini(40, player.health + health)
	return true


static func _increment_burned(player: Dictionary, metal: String) -> void:
	player.burned[metal] = player.burned.get(metal, 0) + 1


static func _burn_key(owner: String, token: String, metal: String) -> String:
	return "e1_burn_" + Funding._canonical_content([owner, token, metal]).sha256_text()


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if not super._protected_fields(candidate, current) or not _profile_intact():
		return false
	var expected: Dictionary = current.duplicate(true)
	var error: String = _dispatch(expected, _actor, _intent.tipo, _intent.payload)
	return error.is_empty() and expected == candidate


func _dispatch(candidate: Dictionary, owner: String, kind: String, payload: Dictionary) -> String:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	match kind:
		START_TURN_ACTION: return _start(candidate, owner, payload, rng)
		Funding.ACTION_ID: return _funding(candidate, owner, payload, rng)
		PLAY: return _training(candidate, owner, payload, rng)
		CHARACTER: return _character(candidate, owner, payload, rng)
	return "accion_no_soportada"


func _candidate_error(candidate: Dictionary) -> String:
	if candidate.authority.rng_state != get_authority_snapshot().authority.rng_state:
		return "estado_invalido"
	return _state_error(candidate)


func _state_error(state: Dictionary) -> String:
	if not _state.validate_candidate(state).ok or state.mode != "competitivo" or state.players.size() < 2 or state.players.size() > 4 \
		or state.lifecycle != "en_curso" or state.turn.number < 1 or state.turn.phase not in ["inicio", "libre"] or state.resolution != null \
		or state.rival != null or state.outcome != null or state.missions.size() != 3 or not state.authority.completed_sequences.is_empty() or not state.authority.mission_permanents.is_empty():
		return "estado_invalido"
	var counters: Dictionary = {}
	var characters: Dictionary = {}
	var fixture_fuels: int = 0
	for player: Dictionary in state.players:
		if not SIGNATURES.has(player.character_id) or characters.has(player.character_id) or player.training_track_id != "pista_entrenamiento" \
			or player.training > 20 or player.health < 1 or player.health > 40 or player.eliminated:
			return "estado_invalido"
		characters[player.character_id] = true
		var expected_limit: int = 1
		for position: int in [3, 9, 15]:
			expected_limit += 1 if player.training >= position else 0
		if player.burn_limit != expected_limit:
			return "estado_invalido"
		var burned: Dictionary = {}
		var ordinary: Dictionary = {}
		var used: int = 0
		for token: Dictionary in player.metals:
			if token.exhausted:
				return "estado_invalido"
			if token.metal != "atium":
				if ordinary.has(token.metal):
					return "estado_invalido"
				ordinary[token.metal] = true
			var found: int = 0
			for metal: String in Catalog.METALS:
				var key: String = _burn_key(player.player_id, token.token_id, metal)
				if state.turn.counters.has(key):
					if state.turn.counters[key] != 1 or not token.used_this_turn or token.metal not in [metal, "atium"]:
						return "estado_invalido"
					found += 1
					counters[key] = 1
					burned[metal] = burned.get(metal, 0) + 1
					if token.metal == "atium":
						burned.atium = burned.get("atium", 0) + 1
			if found != (1 if token.used_this_turn else 0):
				return "estado_invalido"
			used += found
		if ordinary.size() != 8 or used > player.burn_limit:
			return "estado_invalido"
		var deck: Dictionary = {}
		for kind: String in ["mano", "mazo", "descarte", "juego"]:
			for id: String in Funding._zone(state, kind, player.player_id).cards:
				var card: Dictionary = state.instances[id]
				var initial: bool = card.definition_id in Bindings.STARTERS[player.character_id] + ["financiacion"]
				var fixture_fuel: bool = card.definition_id in _manifest.market_cards and _content[card.definition_id].tipo == "accion" and not _content[card.definition_id].metales.is_empty()
				if card.owner_id != player.player_id or (not initial and not fixture_fuel):
					return "estado_invalido"
				if initial:
					deck[card.definition_id] = deck.get(card.definition_id, 0) + 1
				elif fixture_fuel:
					fixture_fuels += 1
					if fixture_fuels > 1:
						return "estado_invalido"
				if kind == "juego":
					if card.state.ability_uses.keys() != [MARK] or card.state.ability_uses[MARK] < 1 or card.state.ability_uses[MARK] > state.revision:
						return "estado_invalido"
					for flag: String in card.state.flags:
						var metal: String = flag.trim_prefix("e1_metal_")
						if not flag.begins_with("e1_metal_") or card.state.flags.size() != 1 or not card.state.flags[flag] or metal not in _content[card.definition_id].metales:
							return "estado_invalido"
						burned[metal] = burned.get(metal, 0) + 1
				elif not card.state.flags.is_empty() or not card.state.ability_uses.is_empty():
					return "estado_invalido"
		if deck.get("financiacion") != 6 or deck.size() != 5 or player.burned != burned:
			return "estado_invalido"
		for id: String in Bindings.STARTERS[player.character_id]:
			if deck.get(id) != 1:
				return "estado_invalido"
		for key: String in player.ability_uses:
			var level: int = 1 if key == "e1_nivel_1" else 3 if key == "e1_nivel_3" else 0
			if level == 0 or Training.unlocked_level(player.training) < level or player.ability_uses[key] < 1 \
				or player.ability_uses[key] > state.revision or burned.get("atium" if level == 3 else SIGNATURES[player.character_id], 0) < 1:
				return "estado_invalido"
	if counters != state.turn.counters:
		return "estado_invalido"
	for mission: Dictionary in state.missions.values():
		if mission.definition_id not in _manifest.missions:
			return "estado_invalido"
		for arrival: Variant in mission.first_arrivals.values():
			if arrival != null:
				return "estado_invalido"
		for id: String in mission.progress:
			if mission.progress[id] != 0 or mission.rewards[id] != [] or not mission.arrival_order.is_empty():
				return "estado_invalido"
	return ""


func _closed_content() -> bool:
	if not Registry.exact_keys(_manifest, ["characters", "funding_id", "training_track_id", "market_cards", "missions", "rival"]) or _manifest.rival != null \
		or not _manifest.market_cards is Array or _manifest.market_cards.size() != 82 or not _manifest.missions is Array or _manifest.missions.size() != 8:
		return false
	var track: Dictionary = _content.pista_entrenamiento
	if not track.habilidades.is_empty() or not track.metales.is_empty() or not Registry.exact_keys(track.rasgos, ["recorridos"]) \
		or track.rasgos.recorridos.size() != 1 or track.rasgos.recorridos[0].id != "principal" or track.rasgos.recorridos[0].casillas.size() != 21:
		return false
	for position: int in 21:
		if track.rasgos.recorridos[0].casillas[position] != {"id": "p%02d" % position, "efectos": [{"op": "sin_efecto"}]}:
			return false
	for id: String in Bindings.STARTERS:
		var character: Dictionary = _content[id]
		if not character.metales.is_empty() or not character.rasgos.is_empty() or character.habilidades.size() != 2 \
			or not Funding._same_descriptor(character.habilidades[0], _signature(id, 1)) or not Funding._same_descriptor(character.habilidades[1], _signature(id, 3)):
			return false
		for starter: String in Bindings.STARTERS[id]:
			var card: Dictionary = _content[starter]
			var metal: String = starter.get_slice("_", 1).replace("cinc", "zinc")
			var gains: Array = _primary_gains(starter)
			var pair: Array = []
			for metals: Array in [["peltre", "estano"], ["bronce", "cobre"], ["zinc", "laton"], ["hierro", "acero"]]:
				if metal in metals:
					pair = metals
			if card.metales != pair or card.coste_compra != null or not card.rasgos.is_empty():
				return false
			if not Funding._same_descriptor(card.habilidades, [{"id": "primaria", "momento": "al_jugar", "condicion": {"op": "metal_asignado", "metales": [metal]},
				"limite_por_turno": null, "efectos": _effects(gains[0], gains[1], gains[2], 0)}]):
				return false
	if not Funding._funding(_content.financiacion):
		return false
	var allowed: Dictionary = {"financiacion": true, "pista_entrenamiento": true}
	for id: String in Bindings.STARTERS:
		allowed[id] = true
		for starter: String in Bindings.STARTERS[id]:
			allowed[starter] = true
	for id: Variant in _manifest.get("market_cards", []):
		if not id is String or not _content.has(id) or _content[id].tipo not in ["accion", "aliado"]:
			return false
		var inert: Dictionary = _content[id].duplicate(true)
		if inert.tipo == "accion":
			inert.metales = []
		if not Funding._inert(inert):
			return false
		allowed[id] = true
	for id: Variant in _manifest.get("missions", []):
		if not id is String or not _content.has(id) or _content[id].tipo != "mision":
			return false
		allowed[id] = true
	return allowed.size() == _content.size()


static func _primary_gains(id: String) -> Array:
	var metal: String = id.get_slice("_", 1)
	if metal in ["estano", "bronce"]:
		return [0, 0, 2]
	if metal in ["cinc", "laton"]:
		return [1, 0, 1]
	return [1, 2, 0]


static func _signature_gains(id: String) -> Array:
	return {"kelsier": [0, 2, 0, 0], "marsh": [0, 0, 1, 0], "shan": [2, 0, 0, 0], "vin": [1, 1, 0, 1]}[id]


static func _effects(coins: int, attack: int, mission: int, health: int) -> Array:
	var result: Array = []
	if health > 0:
		result.append({"op": "curar", "cantidad": health, "objetivo": "propio"})
	for pair: Array in [["ataque", attack], ["mision", mission], ["recursos", coins]]:
		if pair[1] > 0:
			result.append({"op": "ganar", "recurso": pair[0], "cantidad": pair[1], "objetivo": "propio"})
	return result


static func _signature(id: String, level: int) -> Dictionary:
	var gains: Array = _signature_gains(id) if level == 1 else [0, 3, 3, 0]
	return {"id": "nivel_i" if level == 1 else "nivel_iii", "momento": "metal_quemado",
		"condicion": {"op": "metales_quemados", "metales": [SIGNATURES[id] if level == 1 else "atium"]},
		"limite_por_turno": 1, "efectos": _effects(gains[0], gains[1], gains[2], gains[3])}


static func _load_rejected(reason: String) -> Dictionary:
	return {"ok": false, "errors": PackedStringArray([reason])}
