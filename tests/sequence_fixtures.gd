extends RefCounted
## Programas técnicos de prueba. No registrar en adaptadores de producto.

const Registry = preload("res://scripts/game/sequence_registry.gd")
const MAX_INT: int = Registry.MAX_INT
const CONTEXT: Dictionary = {"owner_id": "player_id", "turn_number": "int", "entry_phase": "id",
	"occurrence_id": "id", "recipient_id": "player_id"}


static func registration() -> Dictionary:
	var operations: Dictionary = {
		"fixture_add": _operation({"amount": "int"}, _valid_add, _add),
		"fixture_roll": _operation({}, _valid_empty, _roll),
		"fixture_wait": _operation({"kind": "id", "min": "int", "to_owner": "bool"}, _valid_window, _answer),
		"fixture_fail": _operation({}, _valid_empty, _fail)
	}
	operations.fixture_wait["offer"] = _offer
	return {"operations": operations, "programs": {
		"automatic_v1": program([step("s1", "fixture_add", {"amount": 2}), step("s2", "fixture_roll")]),
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
		"test_pause": start.bind("pause_v1", 0),
		"test_reaction": start.bind("reaction_v1", 1),
		"test_twice": start.bind("twice_v1", 1),
		"test_optional": start.bind("optional_v1", 0),
		"test_before_failure": start.bind("before_failure_v1", 0),
		"test_after_failure": start.bind("after_failure_v1", 0),
		"test_private_alt": start.bind("private_alt_v1", 2),
		"test_unknown": start.bind("unknown_v1", 0)
	}


static func program(steps: Array, recipient_offset: int = 0) -> Dictionary:
	return {"steps": steps, "context": CONTEXT.duplicate(), "scope": _scope.bind(recipient_offset), "allow_null_source": true}


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
