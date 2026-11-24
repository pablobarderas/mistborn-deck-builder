extends "res://scripts/game/game_engine.gd"
## Autoridad local cerrada E2. Contenido provisional; nunca interpreta texto.

const Catalog = preload("res://scripts/catalog/catalog_validator.gd")
const Bindings = preload("res://scripts/catalog/initial_competitive_bindings.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const Setup = preload("res://scripts/game/game_setup.gd")
const Training = preload("res://scripts/game/training_advance.gd")
const LocalState = preload("res://scripts/game/local_competitive_state.gd")
const Cycle = preload("res://scripts/game/card_cycle.gd")
const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
const Mission = preload("res://scripts/game/mission_advance.gd")
const PLAY: String = "jugar_entrenamiento"
const CHARACTER: String = "activar_personaje"
const MARK: String = "e2_play_revision"
const SIGNATURES: Dictionary = {"kelsier": "acero", "marsh": "bronce", "shan": "zinc", "vin": "peltre"}
const MARKET: Dictionary = {"e2_mision": [0, 0, 4], "e2_combate": [0, 5, 0], "e2_monedas": [3, 0, 0], "e2_equilibrio": [1, 2, 2]}
const PROGRAM: String = "local_competitive_closed_v2_boxings"

class SnapshotSource extends RefCounted:
	func latest(_match_id: String, _profile_id: String) -> Dictionary:
		return {}

var _catalog: Dictionary
var _manifest: Dictionary
var _content: Dictionary = {}
var _identity: String = ""
var _supported: bool = false
var _advance: Training
var _checkpoint: Dictionary = {}
var _commands: Array = []
var _owner_thread: int = OS.get_thread_caller_id()
var _busy: bool = false
var _intent: Dictionary = {}
var _actor: String = ""
var _expected_rng: int = 0


func _init(catalog: Dictionary, manifest: Dictionary) -> void:
	_catalog = catalog.duplicate(true)
	_manifest = manifest.duplicate(true)
	var checked: Dictionary = Catalog.new().validate(_catalog)
	_supported = checked.ok and _catalog.get("version_esquema") == 5 and checked.cards.size() == checked.verified.size()
	if _supported:
		_content = checked.cards.duplicate(true)
		_supported = _closed_content()
	if _supported:
		_identity = "local_competitive_" + Funding._canonical_content([PROGRAM, _catalog, _manifest]).sha256_text()
	super(_content, _identity, {Funding.ACTION_ID: _funding, PLAY: _play_card, CHARACTER: _character,
		"jugar_accion": _play_card, "comprar_carta": _buy, "avanzar_mision": _mission,
		"comprar_boxing": _buy_boxing, "canjear_boxing": _redeem_boxing,
		"entrar_combate": _enter_combat, "resolver_combate": _combat, "pasar_target": _pass_target,
		"entrar_limpieza": _enter_cleanup, "quemar_metal": _burn_action, "refrescar_metal": _refresh})
	_state = LocalState.new(_content, _identity)
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
	return _supported and _state._definitions == _content and _advance._definitions == _content \
		and _state._catalog_id == _identity and _advance._catalog_id == _identity \
		and _identity == "local_competitive_" + Funding._canonical_content([PROGRAM, _catalog, _manifest]).sha256_text()


func load_authority_snapshot(_document: Variant) -> Dictionary:
	return _load_rejected("Usa preparación o registro de autoridad E2.")


func prepare_match(match_id: String, seats: Array, first_player_id: String, seed: int) -> Dictionary:
	if not _begin():
		return _load_rejected("Autoridad ocupada o hilo incorrecto.")
	var result: Dictionary = _load_rejected("Perfil incompatible o partida ya cargada.")
	if _profile_intact() and _state.get_snapshot().is_empty():
		var definitions: Dictionary = _content.duplicate(true)
		for card: Dictionary in definitions.values():
			card.cantidad = int(card.cantidad)
		var prepared: Dictionary = Setup.new(definitions, _identity).create(match_id, "competitivo", seats, first_player_id, _manifest, seed)
		if prepared.ok:
			var supported: bool = true
			for mission: Dictionary in prepared.snapshot.missions.values():
				supported = supported and mission.definition_id in Mission.ACTIVE_DEFINITIONS
			if supported:
				result = _state.try_load(prepared.snapshot)
				if result.ok:
					_checkpoint = prepared.snapshot.duplicate(true)
			else:
				result = _load_rejected("La semilla selecciona misiones no admitidas. El ensayo sólo ejecuta M5/M6/M7.")
	_busy = false
	return result


func export_authority_entry() -> Dictionary:
	return {"profile_id": _identity, "checkpoint": _checkpoint.duplicate(true), "commands": _commands.duplicate(true), "snapshot": get_authority_snapshot()}


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
	if not Registry.exact_keys(entry, ["profile_id", "checkpoint", "commands", "snapshot"]) or entry.profile_id != _identity \
		or not entry.checkpoint is Dictionary or not entry.commands is Array or not entry.snapshot is Dictionary \
		or not _state.validate_candidate(entry.checkpoint).ok or entry.checkpoint.match_id != match_id:
		return _load_rejected("Fuente incompatible con partida y perfil.")
	var seats: Array = []
	for player: Dictionary in entry.checkpoint.players:
		seats.append({"player_id": player.player_id, "name": player.name})
	var replay: RefCounted = get_script().new(_catalog, _manifest)
	if not replay.prepare_match(match_id, seats, entry.checkpoint.player_order[0], entry.checkpoint.authority.rng_seed).ok \
		or replay.get_authority_snapshot() != entry.checkpoint:
		return _load_rejected("Checkpoint distinto de la preparación reproducida.")
	for command: Variant in entry.commands:
		if not command is Dictionary or not Registry.exact_keys(command, ["actor", "intent"]) or not command.actor is String or not command.intent is Dictionary:
			return _load_rejected("Registro incompatible.")
		var before: int = replay.get_authority_snapshot().revision
		var result: Dictionary
		match command.intent.get("tipo"):
			START_TURN_ACTION: result = replay.start_turn(command.actor, command.intent)
			CLEANUP_ACTION: result = replay.finish_cleanup(command.actor, command.intent)
			_: result = replay.submit(command.actor, command.intent)
		if not result.ok or replay.get_authority_snapshot().revision != before + 1:
			return _load_rejected("Registro incompatible o duplicado.")
	if replay.get_authority_snapshot() != entry.snapshot:
		return _load_rejected("Snapshot distinto del registro confirmado.")
	var loaded: Dictionary = _state.try_load(entry.snapshot)
	if loaded.ok:
		_checkpoint = entry.checkpoint.duplicate(true)
		_commands = entry.commands.duplicate(true)
	return loaded


func start_turn(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, START_TURN_ACTION)


func submit(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, "")


func finish_cleanup(actor_id: String, input: Variant) -> Dictionary:
	return _operation(actor_id, input, CLEANUP_ACTION)


func _operation(actor_id: String, input: Variant, internal: String) -> Dictionary:
	if not _begin():
		return _reject("accion_ilegal", 0)
	var before: Dictionary = get_authority_snapshot()
	var result: Dictionary = _reject("estado_invalido", before.get("revision", 0))
	if _profile_intact() and not before.is_empty() and _state_error(before).is_empty():
		_intent = input.duplicate(true) if input is Dictionary else {}
		_actor = actor_id
		result = _submit(actor_id, input, _start if internal == START_TURN_ACTION else (_cleanup if internal == CLEANUP_ACTION else Callable()), internal if internal != "" else START_TURN_ACTION)
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


func _character(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["nivel", "aplicar"]) or not payload.nivel is int or payload.nivel not in [1, 3] or not payload.aplicar is bool:
		return "formato_invalido"
	var player: Dictionary = Funding._funding_player(candidate, owner)
	var key: String = "e2_nivel_" + str(payload.nivel)
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
	zone(state, "mano", owner).cards.erase(id)
	zone(state, "juego", owner).cards.append(id)
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


func _play_card(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["instance_id", "aplicar", "metal", "origen"]) or not Registry.valid_id(payload.instance_id) \
		or not payload.aplicar is bool or not payload.origen is Dictionary:
		return "formato_invalido"
	var instance: Dictionary = candidate.instances.get(payload.instance_id, {})
	var definition: Dictionary = _content.get(instance.get("definition_id"), {})
	if definition.get("tipo") not in ["entrenamiento", "accion"] or not Funding._eligible(candidate, owner, payload.instance_id, definition.id):
		return "accion_ilegal"
	if (definition.tipo == "entrenamiento") != (_intent.tipo == PLAY):
		return "accion_ilegal"
	if not payload.aplicar:
		if payload.metal != null or not payload.origen.is_empty():
			return "formato_invalido"
	else:
		var primary: String = definition.habilidades[0].condicion.metales[0]
		if payload.metal != primary or payload.origen.get("id") == payload.instance_id:
			return "accion_ilegal"
		var error: String = _burn(candidate, owner, primary, payload.origen)
		if not error.is_empty():
			return error
		var gains: Array = _primary_gains(definition.id) if definition.tipo == "entrenamiento" else MARKET[definition.id]
		if not _gain(Funding._funding_player(candidate, owner), gains[0], gains[1], gains[2], 0):
			return "estado_invalido"
	_move(candidate, owner, payload.instance_id)
	return ""


func _burn_action(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["metal", "origen"]) or not payload.metal is String or not payload.origen is Dictionary:
		return "formato_invalido"
	return _burn(candidate, owner, payload.metal, payload.origen)


func _burn(candidate: Dictionary, owner: String, metal: String, origin: Dictionary) -> String:
	if candidate.turn.phase != "libre" or metal not in Catalog.METALS + ["atium"]:
		return "accion_ilegal"
	if not Registry.exact_keys(origin, ["tipo", "id"]) or not Registry.valid_id(origin.id):
		return "formato_invalido"
	var player: Dictionary = Funding._funding_player(candidate, owner)
	if origin.tipo in ["ficha", "fulgurar"]:
		var token: Dictionary = {}
		var used: int = 0
		for item: Dictionary in player.metals:
			if item.used_this_turn and not player.ability_uses.has("e2_flare_" + item.token_id):
				used += 1
			if item.token_id == origin.id:
				token = item
		if token.is_empty() or token.metal not in [metal, "atium"] or token.exhausted or token.used_this_turn:
			return "accion_ilegal"
		if origin.tipo == "fulgurar":
			if token.metal == "atium":
				return "accion_ilegal"
			token.exhausted = true
			player.ability_uses["e2_flare_" + token.token_id] = candidate.revision + 1
		elif used >= player.burn_limit:
			return "accion_ilegal"
		token.used_this_turn = true
		_increment_burned(player, token.metal)
		if token.metal == "atium" and metal != "atium":
			_increment_burned(player, metal)
	elif origin.tipo == "carta":
		var fuel: Dictionary = candidate.instances.get(origin.id, {})
		var definition: Dictionary = _content.get(fuel.get("definition_id"), {})
		if fuel.get("owner_id") != owner or definition.get("tipo") not in ["entrenamiento", "accion"] \
			or metal not in definition.get("metales", []) or origin.id not in zone(candidate, "mano", owner).cards:
			return "accion_ilegal"
		_move(candidate, owner, origin.id)
		fuel.state.flags["e2_metal_" + metal] = true
		_increment_burned(player, metal)
	else:
		return "formato_invalido"
	return ""


func _refresh(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["instance_id", "token_id"]) or not Registry.valid_id(payload.instance_id) or not Registry.valid_id(payload.token_id):
		return "formato_invalido"
	var card: Dictionary = candidate.instances.get(payload.instance_id, {})
	var definition: Dictionary = _content.get(card.get("definition_id"), {})
	if candidate.turn.phase != "libre" or card.get("owner_id") != owner or definition.get("tipo") not in ["accion", "entrenamiento"] \
		or payload.instance_id not in zone(candidate, "mano", owner).cards:
		return "accion_ilegal"
	for token: Dictionary in Funding._funding_player(candidate, owner).metals:
		if token.token_id == payload.token_id and token.exhausted and token.metal in definition.metales:
			token.exhausted = false
			zone(candidate, "mano", owner).cards.erase(payload.instance_id)
			zone(candidate, "descarte", owner).cards.append(payload.instance_id)
			return ""
	return "accion_ilegal"


func _buy_boxing(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	if candidate.turn.phase != "libre":
		return "accion_ilegal"
	var player: Dictionary = Funding._funding_player(candidate, owner)
	if player.turn_resources.recursos < 2 or player.persistent.boxings == Registry.MAX_INT:
		return "accion_ilegal"
	player.turn_resources.recursos -= 2
	player.persistent.boxings += 1
	return ""


func _redeem_boxing(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	if candidate.turn.phase != "libre":
		return "accion_ilegal"
	var player: Dictionary = Funding._funding_player(candidate, owner)
	if player.persistent.boxings < 1 or player.turn_resources.recursos == Registry.MAX_INT:
		return "accion_ilegal"
	player.persistent.boxings -= 1
	player.turn_resources.recursos += 1
	return ""


func _buy(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["instance_id", "nivel_ii"]) or not Registry.valid_id(payload.instance_id) or not payload.nivel_ii is bool:
		return "formato_invalido"
	var market: Dictionary = zone(candidate, "mercado", null)
	if candidate.turn.phase != "libre" or payload.instance_id not in market.cards:
		return "accion_ilegal"
	var card: Dictionary = candidate.instances[payload.instance_id]
	var definition: Dictionary = _content[card.definition_id]
	var player: Dictionary = Funding._funding_player(candidate, owner)
	if player.turn_resources.recursos < definition.coste_compra:
		return "accion_ilegal"
	if payload.nivel_ii and (Training.unlocked_level(player.training) < 2 or player.ability_uses.has("e2_nivel_2")):
		return "accion_ilegal"
	player.turn_resources.recursos -= int(definition.coste_compra)
	market.cards.erase(payload.instance_id)
	card.owner_id = owner
	zone(candidate, "descarte", owner).cards.append(payload.instance_id)
	if payload.nivel_ii:
		var gains: Array = MARKET[definition.id]
		if not _gain(player, gains[0], gains[1], gains[2], 0):
			return "estado_invalido"
		player.ability_uses["e2_nivel_2"] = candidate.revision + 1
		zone(candidate, "descarte", owner).cards.erase(payload.instance_id)
		zone(candidate, "eliminadas", null).cards.append(payload.instance_id)
	var deck: Dictionary = zone(candidate, "mazo_mercado", null)
	if deck.cards.is_empty():
		var eliminated: Dictionary = zone(candidate, "eliminadas", null)
		if eliminated.cards.is_empty():
			return "accion_ilegal"
		deck.cards.assign(eliminated.cards)
		eliminated.cards.clear()
		for id: String in deck.cards:
			candidate.instances[id].owner_id = null
			candidate.instances[id].state = {"ability_uses": {}, "flags": {}}
		Cycle.new(_content, _identity)._shuffle(deck.cards, rng)
	market.cards.append(deck.cards.pop_back())
	return ""


func _mission(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["mission_id"]) or not Registry.valid_id(payload.mission_id):
		return "formato_invalido"
	if candidate.turn.phase != "libre" or not candidate.missions.has(payload.mission_id):
		return "accion_ilegal"
	var mission: Dictionary = candidate.missions[payload.mission_id]
	var position: int = mission.progress[owner] + 1
	if position > 12 or not Mission.arrive(candidate, owner, payload.mission_id, position):
		return "accion_ilegal"
	var complete: bool = true
	for value: Dictionary in candidate.missions.values():
		complete = complete and value.progress[owner] == 12
	if complete:
		candidate.lifecycle = "finalizada"
		candidate.turn.phase = "finalizada"
		candidate.outcome = {"winner_id": owner, "reason": "tres_misiones", "mission_id": payload.mission_id, "turn_number": candidate.turn.number}
		return ""
	var cell: Dictionary = _content[mission.definition_id].rasgos.recorridos[0].casillas[position - 1]
	var helper: RefCounted = Mission.new(_content, _identity, {"catalog_id": _identity, "track_id": "pista_entrenamiento", "definition": _content.pista_entrenamiento, "marks": Training.PANEL.duplicate()})
	for group: String in ["normal", "primero"]:
		if group == "primero" and mission.first_arrivals[cell.id] != owner:
			continue
		var effects: Array = cell.efectos if group == "normal" else cell.primero
		for effect: Dictionary in effects:
			if not helper._apply(candidate, owner, effect, rng):
				return "estado_invalido"
		if not effects.is_empty():
			candidate.missions[payload.mission_id].rewards[owner].append(cell.id + "_" + group)
	return ""


func _enter_combat(candidate: Dictionary, _owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	if candidate.turn.phase != "libre":
		return "accion_ilegal"
	candidate.turn.phase = "combate"
	return ""


func _alive(candidate: Dictionary) -> Array:
	var result: Array = []
	for id: String in candidate.player_order:
		if not Funding._funding_player(candidate, id).eliminated:
			result.append(id)
	return result


func _combat(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["damage", "target_order", "pass_target_id"]) or not payload.damage is int \
		or not payload.target_order is Array or payload.pass_target_id != null:
		return "formato_invalido"
	if candidate.turn.phase != "combate" or not candidate.turn.counters.is_empty():
		return "accion_ilegal"
	var player: Dictionary = Funding._funding_player(candidate, owner)
	if payload.damage < 0 or payload.damage > player.turn_resources.ataque or (candidate.target_id == owner and payload.damage != player.turn_resources.ataque):
		return "accion_ilegal"
	var remaining: int = payload.damage
	var choices: Array = payload.target_order.duplicate()
	var alive: Array = _alive(candidate)
	var damaged_holder: String = ""
	if candidate.target_id == owner:
		# Target activo: todo el combate elegido se aplica a cada rival.
		for id: String in alive:
			if id != owner:
				_damage(candidate, id, remaining)
	else:
		while remaining > 0 and alive.size() > 1:
			var target: String = candidate.target_id if candidate.target_id != null else (alive[0] if alive[1] == owner else alive[1])
			var defender: Dictionary = Funding._funding_player(candidate, target)
			var inflicted: int = mini(remaining, defender.health)
			_damage(candidate, target, inflicted)
			remaining -= inflicted
			alive = _alive(candidate)
			if not defender.eliminated:
				if inflicted > 0 and candidate.target_id != null:
					damaged_holder = target
				break
			if alive.size() <= 2:
				candidate.target_id = null
			elif not choices.is_empty() and choices[0] is String and choices[0] in alive:
				candidate.target_id = choices.pop_front()
				# Elegirse a sí mismo cambia el remanente a daño a todos los rivales.
				if candidate.target_id == owner:
					for id: String in alive:
						if id != owner:
							_damage(candidate, id, remaining)
					remaining = 0
			else:
				return "eleccion_invalida"
	if not choices.is_empty():
		return "eleccion_invalida"
	player.turn_resources.ataque -= payload.damage
	alive = _alive(candidate)
	if alive.size() < 3:
		candidate.target_id = null
	if alive.size() == 1:
		candidate.lifecycle = "finalizada"
		candidate.turn.phase = "finalizada"
		candidate.outcome = {"winner_id": owner, "reason": "ultimo_superviviente", "mission_id": null, "turn_number": candidate.turn.number}
	elif not damaged_holder.is_empty() and alive.size() >= 3:
		candidate.turn.counters["e2_combat_owner"] = candidate.player_order.find(owner) + 1
		candidate.turn.active_id = damaged_holder
	else:
		candidate.turn.counters["e2_combat_resuelto"] = 1
	return ""


func _damage(candidate: Dictionary, id: String, amount: int) -> void:
	var player: Dictionary = Funding._funding_player(candidate, id)
	player.health = maxi(0, player.health - amount)
	player.eliminated = player.health == 0


func _pass_target(candidate: Dictionary, owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["target_id"]) or (payload.target_id != null and not payload.target_id is String):
		return "formato_invalido"
	var attacker: String = _combat_owner(candidate)
	if candidate.turn.phase != "combate" or attacker.is_empty() or candidate.target_id != owner:
		return "accion_ilegal"
	if payload.target_id != null:
		if payload.target_id not in _alive(candidate) or payload.target_id == owner:
			return "eleccion_invalida"
		candidate.target_id = payload.target_id
	candidate.turn.active_id = attacker
	candidate.turn.counters = {"e2_combat_resuelto": 1}
	return ""


func _combat_owner(state: Dictionary) -> String:
	var index: int = state.turn.counters.get("e2_combat_owner", 0) - 1
	return state.player_order[index] if index >= 0 and index < state.player_order.size() else ""


func get_view(recipient_id: String) -> Dictionary:
	var view: Dictionary = super.get_view(recipient_id)
	if not view.is_empty():
		var snapshot: Dictionary = get_authority_snapshot()
		view["combat"] = {"attacker_id": _combat_owner(snapshot), "awaiting_target": not _combat_owner(snapshot).is_empty(), "resolved": snapshot.turn.counters.has("e2_combat_resuelto")}
	return view


func _enter_cleanup(candidate: Dictionary, _owner: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not payload.is_empty():
		return "formato_invalido"
	if candidate.turn.phase != "combate" or candidate.turn.counters != {"e2_combat_resuelto": 1}:
		return "accion_ilegal"
	candidate.turn.counters.clear()
	candidate.turn.phase = "limpieza"
	return ""


func _cleanup(candidate: Dictionary, owner: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["turn_number"]) or not payload.turn_number is int:
		return "formato_invalido"
	if candidate.turn.phase != "limpieza" or payload.turn_number != candidate.turn.number:
		return "accion_ilegal"
	for instance: Dictionary in candidate.instances.values():
		if instance.owner_id == owner:
			instance.state.flags.clear()
	var result: Dictionary = Cleanup.new(_content, _identity).finish_cleanup(candidate, owner, rng)
	return "" if result.ok else result.codigo


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if not super._protected_fields(candidate, current) or not _profile_intact():
		return false
	var expected: Dictionary = current.duplicate(true)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = current.authority.rng_seed
	rng.state = current.authority.rng_state
	var error: String = _dispatch(expected, _actor, _intent.tipo, _intent.payload, rng)
	_expected_rng = rng.state
	return error.is_empty() and expected == candidate


func _dispatch(candidate: Dictionary, owner: String, kind: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	match kind:
		START_TURN_ACTION: return _start(candidate, owner, payload, rng)
		CLEANUP_ACTION: return _cleanup(candidate, owner, payload, rng)
		Funding.ACTION_ID: return _funding(candidate, owner, payload, rng)
		PLAY, "jugar_accion": return _play_card(candidate, owner, payload, rng)
		CHARACTER: return _character(candidate, owner, payload, rng)
		"comprar_carta": return _buy(candidate, owner, payload, rng)
		"comprar_boxing": return _buy_boxing(candidate, owner, payload, rng)
		"canjear_boxing": return _redeem_boxing(candidate, owner, payload, rng)
		"avanzar_mision": return _mission(candidate, owner, payload, rng)
		"entrar_combate": return _enter_combat(candidate, owner, payload, rng)
		"resolver_combate": return _combat(candidate, owner, payload, rng)
		"pasar_target": return _pass_target(candidate, owner, payload, rng)
		"entrar_limpieza": return _enter_cleanup(candidate, owner, payload, rng)
		"quemar_metal": return _burn_action(candidate, owner, payload, rng)
		"refrescar_metal": return _refresh(candidate, owner, payload, rng)
	return "accion_no_soportada"


func _candidate_error(candidate: Dictionary) -> String:
	if candidate.authority.rng_state != _expected_rng:
		return "estado_invalido"
	return _state_error(candidate)


func _state_error(state: Dictionary) -> String:
	if not _state.validate_candidate(state).ok or state.mode != "competitivo" or state.players.size() < 2 or state.players.size() > 4 \
		or state.turn.number < 1 or state.resolution != null or state.rival != null or state.missions.size() != 3 \
		or not state.authority.completed_sequences.is_empty() or not state.authority.mission_permanents.is_empty():
		return "estado_invalido"
	if state.lifecycle == "en_curso" and (state.turn.phase not in ["inicio", "libre", "combate", "limpieza"] or state.outcome != null or _alive(state).size() < 2):
		return "estado_invalido"
	if state.lifecycle == "finalizada" and (state.outcome == null or state.turn.phase != "finalizada"):
		return "estado_invalido"
	var characters: Array = []
	for player: Dictionary in state.players:
		if player.character_id not in SIGNATURES or player.character_id in characters or player.training_track_id != "pista_entrenamiento" \
			or player.training > 20 or player.health > 40 or player.eliminated != (player.health == 0):
			return "estado_invalido"
		characters.append(player.character_id)
		var expected: int = 1
		for position: int in [3, 9, 15]:
			expected += 1 if player.training >= position else 0
		if player.burn_limit != expected:
			return "estado_invalido"
	for mission: Dictionary in state.missions.values():
		if mission.definition_id not in Mission.ACTIVE_DEFINITIONS:
			return "estado_invalido"
	return ""


func _closed_content() -> bool:
	if not Bindings.check_authoring(_content, _manifest):
		return false
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
		if id not in MARKET or _content[id].tipo != "accion" or _content[id].coste_compra != 2 or _content[id].metales != ["peltre", "estano"]:
			return false
		var gains: Array = MARKET[id]
		var primary: Dictionary = {"id": "primaria", "momento": "al_jugar", "condicion": {"op": "metal_asignado", "metales": ["peltre"]}, "limite_por_turno": null, "efectos": _effects(gains[0], gains[1], gains[2], 0)}
		if not _content[id].rasgos.is_empty() or not Funding._same_descriptor(_content[id].habilidades, [primary]):
			return false
		allowed[id] = true
	for id: Variant in _manifest.get("missions", []):
		if not id is String or not _content.has(id) or _content[id].tipo != "mision":
			return false
		if id in Mission.ACTIVE_DEFINITIONS and not Mission.supported_mission(_content[id]):
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


static func zone(state: Dictionary, kind: String, holder: Variant) -> Dictionary:
	for value: Dictionary in state.zones.values():
		if value.kind == kind and value.holder_id == holder:
			return value
	return {}
