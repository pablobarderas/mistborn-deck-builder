extends RefCounted
## Programas técnicos de prueba. No registrar en adaptadores de producto.

const Registry = preload("res://scripts/game/sequence_registry.gd")
const Exchange = preload("res://scripts/game/turn_resource_exchange.gd")
const Cycle = preload("res://scripts/game/card_cycle.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const MAX_INT: int = Registry.MAX_INT
const ALTERNATIVES_PROFILE: String = "test_alternatives_v1"
const CONTEXT: Dictionary = {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id",
	"occurrence_id": "id", "recipient_id": "player_id"}


static func registration() -> Dictionary:
	var operations: Dictionary = {
		"fixture_add": _operation({"amount": "int"}, _valid_add, _add),
		"fixture_exchange": _operation({}, _valid_empty, _exchange),
		"fixture_move": _operation({}, _valid_empty, _move),
		"fixture_hand_select": _operation({}, _valid_empty, _select_from_hand),
		"fixture_roll": _operation({}, _valid_empty, _roll),
		"fixture_wait": _operation({"kind": "id", "min": "int", "to_owner": "bool"}, _valid_window, _answer),
		"fixture_fail": _operation({}, _valid_empty, _fail)
	}
	operations.fixture_wait["offer"] = _offer
	operations.fixture_hand_select["offer"] = _offer_hand
	return {"operations": operations, "programs": {
		"automatic_v1": program([step("s1", "fixture_add", {"amount": 2}), step("s2", "fixture_roll")]),
		"exchange_v1": program([step("exchange", "fixture_exchange")]),
		"move_v1": _move_program([step("move", "fixture_move")]),
		"move_rollback_v1": _move_program([step("add", "fixture_add", {"amount": 1}),
			step("roll", "fixture_roll"), step("move", "fixture_move")]),
		"hand_select_v1": _select_program([step("choose", "fixture_hand_select")]),
		"hand_select_rollback_v1": _select_program([step("before", "fixture_add", {"amount": 2}),
			step("choose", "fixture_hand_select"), step("fail", "fixture_fail")]),
		"pause_v1": program([step("s1", "fixture_add", {"amount": 2}), step("s2", "fixture_roll"),
			window("s3"), step("s4", "fixture_roll")]),
		"reaction_v1": program([step("before", "fixture_add", {"amount": 1}), window("choose", "reaccion", 1, false),
			step("after", "fixture_add", {"amount": 2})], 1),
		"twice_v1": program([window("s1"), step("s2", "fixture_add", {"amount": 2}),
			window("s3", "reaccion", 1, false), step("s4", "fixture_roll")], 1),
		"optional_v1": program([window("s1", "eleccion", 0)]),
		"before_failure_v1": program([step("s1", "fixture_add", {"amount": 2}), step("s2", "fixture_fail"), window("s3")]),
		"after_failure_v1": program([step("s1", "fixture_roll"), window("s2"),
			step("s3", "fixture_add", {"amount": 2}), step("s4", "fixture_fail")]),
		"private_alt_v1": program([window("s8"), window("s9", "reaccion", 1, false)], 2)
	}}


static func starters() -> Dictionary:
	return {
		"test_auto": start.bind("automatic_v1", 0),
		"test_exchange": start.bind("exchange_v1", 0),
		"test_move": _start_move.bind("move_v1", false),
		"test_move_rollback": _start_move.bind("move_rollback_v1", true),
		"test_hand_select": _start_select.bind("hand_select_v1"),
		"test_hand_select_rollback": _start_select.bind("hand_select_rollback_v1"),
		"test_pause": start.bind("pause_v1", 0),
		"test_reaction": start.bind("reaction_v1", 1),
		"test_twice": start.bind("twice_v1", 1),
		"test_optional": start.bind("optional_v1", 0),
		"test_before_failure": start.bind("before_failure_v1", 0),
		"test_after_failure": start.bind("after_failure_v1", 0),
		"test_private_alt": start.bind("private_alt_v1", 2),
		"test_unknown": start.bind("unknown_v1", 0)
	}


static func alternatives_registration() -> Dictionary:
	var branch: Dictionary = _operation({}, _valid_empty, _execute_branch)
	branch["offer"] = _offer_branches
	var alternatives: Dictionary = program([step("before", "fixture_add", {"amount": 1}),
		step("choose", "fixture_branch")])
	alternatives.scope = _owner_scope
	return {"operations": {
		"fixture_add": _operation({"amount": "int"}, _valid_add, _add),
		"fixture_branch": branch
	}, "programs": {"alternatives_v1": alternatives}}


static func alternatives_starters() -> Dictionary:
	return {"test_alternatives": _start_alternatives}


static func program(steps: Array, recipient_offset: int = 0) -> Dictionary:
	return {"steps": steps, "context": CONTEXT.duplicate(), "scope": _scope.bind(recipient_offset), "allow_null_source": true}


static func _move_program(steps: Array) -> Dictionary:
	var result: Dictionary = program(steps)
	result.context.merge({"first_card": "id", "second_card": "id"})
	return result


static func _select_program(steps: Array) -> Dictionary:
	var result: Dictionary = program(steps)
	result.context["hand_binding"] = "id"
	result.scope = _owner_scope
	return result


static func step(id: String, operation: String, params: Dictionary = {}) -> Dictionary:
	return {"step_id": id, "operation": operation, "params": params}


static func window(id: String, kind: String = "eleccion", minimum: int = 1, to_owner: bool = true) -> Dictionary:
	return step(id, "fixture_wait", {"kind": kind, "min": minimum, "to_owner": to_owner})


static func occurrence(match_id: String, turn_number: int, owner_id: String) -> String:
	return "test_turn_" + ("%s:%d:%s" % [match_id, turn_number, owner_id]).sha256_text()


static func start(state: Dictionary, actor_id: String, payload: Dictionary, program_id: String, offset: int) -> Variant:
	if not payload.is_empty():
		return "formato_invalido"
	if state.lifecycle != "en_curso" or state.turn.active_id != actor_id or state.turn.phase != "libre" \
		or state.turn.number < 1 or offset >= state.player_order.size():
		return "accion_ilegal"
	return {"program_id": program_id, "source_id": null, "recipients": state.player_order.duplicate(),
		"context": {"owner_id": actor_id, "turn_number": state.turn.number, "entry_phase": state.turn.phase,
			"occurrence_id": occurrence(state.match_id, state.turn.number, actor_id),
			"recipient_id": _recipient(state.player_order, actor_id, offset)}}


static func _start_move(state: Dictionary, actor_id: String, payload: Dictionary, program_id: String, rollback: bool) -> Variant:
	var request: Variant = start(state, actor_id, payload, program_id, 0)
	if not request is Dictionary:
		return request
	var hand: Array = state.zones[actor_id + "_mano"].cards
	if hand.size() < 3:
		return "accion_ilegal"
	request.context["first_card"] = hand[2]
	request.context["second_card"] = "invalid_target" if rollback else hand[0]
	return request


static func _start_select(state: Dictionary, actor_id: String, payload: Dictionary, program_id: String) -> Variant:
	var request: Variant = start(state, actor_id, payload, program_id, 0)
	if not request is Dictionary:
		return request
	var hand: Dictionary = _owned_zone(state, actor_id, "mano")
	request.recipients = [actor_id]
	request.context["hand_binding"] = _hand_binding(hand.cards)
	return request


static func _start_alternatives(state: Dictionary, actor_id: String, payload: Dictionary) -> Variant:
	var request: Variant = start(state, actor_id, payload, "alternatives_v1", 0)
	if request is Dictionary:
		request.recipients = [actor_id]
	return request


static func reaction(state: Dictionary) -> Dictionary:
	# Snapshot estructural para regresiones del validador y la guardia de limpieza.
	var owner: String = state.turn.active_id
	var recipient: String = _recipient(state.player_order, owner, 1)
	return {"program_id": "reaction_v1", "resolution_id": "resolution_1", "source_id": null,
		"steps": ["before", "choose", "after"], "cursor": 1, "recipients": state.player_order.duplicate(),
		"context": {"owner_id": owner, "turn_number": state.turn.number, "entry_phase": state.turn.phase,
			"occurrence_id": occurrence(state.match_id, state.turn.number, owner), "recipient_id": recipient},
		"pending": {"kind": "reaccion", "recipients": [recipient], "options": ["accept", "decline"], "min": 1, "max": 1}}


static func _scope(state: Dictionary, context: Dictionary, offset: int) -> Variant:
	if offset >= state.player_order.size() or context.recipient_id != _recipient(state.player_order, context.owner_id, offset):
		return null
	if context.occurrence_id != occurrence(state.match_id, context.turn_number, context.owner_id):
		return null
	return state.player_order


static func _owner_scope(state: Dictionary, context: Dictionary) -> Variant:
	return [context.owner_id] if _scope(state, context, 0) != null else null


static func _recipient(order: Array, owner: String, offset: int) -> String:
	return order[(order.find(owner) + offset) % order.size()]


static func _operation(params: Dictionary, validator: Callable, executor: Callable) -> Dictionary:
	return {"params": params, "validate_params": validator, "execute": executor}


static func _valid_add(params: Dictionary) -> bool:
	return params.amount > 0


static func _valid_empty(_params: Dictionary) -> bool:
	return true


static func _valid_window(params: Dictionary) -> bool:
	return params.kind in ["eleccion", "reaccion"] and params.min in [0, 1]


static func _offer(_state: Dictionary, context: Dictionary, params: Dictionary) -> Dictionary:
	var recipient: String = context.owner_id if params.to_owner else context.recipient_id
	return {"kind": params.kind, "recipients": [recipient], "options": ["accept", "decline"], "min": params.min, "max": 1}


static func _add(state: Dictionary, context: Dictionary, params: Dictionary, _rng: RandomNumberGenerator, _selected: Array) -> bool:
	return _add_resource(state, context.owner_id, params.amount)


static func _roll(state: Dictionary, context: Dictionary, _params: Dictionary, rng: RandomNumberGenerator, _selected: Array) -> bool:
	return _add_resource(state, context.owner_id, rng.randi_range(0, 9))


static func _exchange(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, _selected: Array) -> bool:
	for player: Dictionary in state.players:
		if player.player_id == context.owner_id:
			return Exchange.apply(player.turn_resources, "recursos", 2, "ataque", 3)
	return false


static func _offer_branches(_state: Dictionary, context: Dictionary, _params: Dictionary) -> Dictionary:
	return {"kind": "eleccion", "recipients": [context.owner_id], "options": ["rama_a", "rama_b"],
		"min": 1, "max": 1}


static func _execute_branch(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	for player: Dictionary in state.players:
		if player.player_id != context.owner_id:
			continue
		var balances: Dictionary = player.turn_resources
		match selected:
			["rama_a"]:
				return Exchange.apply(balances, "recursos", 2, "ataque", 3) \
					and Exchange.apply(balances, "ataque", 3, "mision", 4)
			["rama_b"]:
				return Exchange.apply(balances, "recursos", 1, "mision", 1)
		return false
	return false


static func _move(state: Dictionary, context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, _selected: Array) -> bool:
	var cycle: Cycle = Cycle.new(Fixtures.definitions(), state.catalog_id, Registry.new(registration()))
	return cycle.discard_from_hand(state, context.owner_id, [context.first_card, context.second_card])


static func _owned_zone(state: Dictionary, owner: String, kind: String) -> Dictionary:
	for zone: Dictionary in state.zones.values():
		if zone.holder_id == owner and zone.kind == kind:
			return zone
	return {}


static func _hand_binding(cards: Array) -> String:
	return "hand_" + JSON.stringify(cards).sha256_text()


static func _offer_hand(state: Dictionary, context: Dictionary, _params: Dictionary) -> Variant:
	var cards: Array = _owned_zone(state, context.owner_id, "mano").cards
	if cards.is_empty() or cards.size() > Registry.MAX_OPTIONS or _hand_binding(cards) != context.hand_binding:
		return null
	var options: Array = []
	for instance_id: String in cards:
		if state.instances[instance_id].owner_id != context.owner_id:
			return null
		options.append("o%05d" % (options.size() + 1))
	return {"kind": "eleccion", "recipients": [context.owner_id], "options": options, "min": 1, "max": 1}


static func _select_from_hand(state: Dictionary, context: Dictionary, params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var offer: Variant = _offer_hand(state, context, params)
	if offer == null or selected.size() != 1:
		return false
	var index: int = offer.options.find(selected[0])
	if index < 0:
		return false
	var owner: String = context.owner_id
	var hand: Dictionary = _owned_zone(state, owner, "mano")
	var discard: Dictionary = _owned_zone(state, owner, "descarte")
	var working: Dictionary = state.duplicate(true)
	# El ciclo valida la copia después del traslado. La ventana previa aún está en el candidato.
	working.resolution = null
	var cycle: Cycle = Cycle.new(Fixtures.definitions(), state.catalog_id, Registry.new(registration()))
	if not cycle.discard_from_hand(working, owner, [hand.cards[index]]):
		return false
	hand.cards = working.zones[hand.zone_id].cards
	discard.cards = working.zones[discard.zone_id].cards
	return true


static func _answer(state: Dictionary, context: Dictionary, params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var recipient: String = context.owner_id if params.to_owner else context.recipient_id
	return not "accept" in selected or _add_resource(state, recipient, 1)


static func _fail(state: Dictionary, context: Dictionary, _params: Dictionary, rng: RandomNumberGenerator, _selected: Array) -> bool:
	_add_resource(state, context.owner_id, 1)
	rng.randi()
	return false


static func _add_resource(state: Dictionary, owner: String, amount: int) -> bool:
	for player: Dictionary in state.players:
		if player.player_id == owner:
			if player.turn_resources.recursos > MAX_INT - amount:
				return false
			player.turn_resources.recursos += amount
			return true
	return false
