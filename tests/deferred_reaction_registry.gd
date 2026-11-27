extends "res://scripts/game/sequence_registry.gd"
## Programa, versiones y obligación privada exclusivos de DIF-01–03.

const SCHEMA: int = 9
const ENGINE: String = "e3-deferred-fixture-1/godot-4.7.2"
const CATALOG: String = "e3_deferred_fixture"
const PROGRAM: String = "diferido_reaccion_v1"
const STEP: String = "esperar_reaccion"
const OCCURRENCE: String = "diferido_ensayo_1"
const RECIPIENT: String = "p1"
const OWNER: String = "p2"


func _init() -> void:
	var context: Dictionary = BASE_CONTEXT.duplicate()
	context["recipient_id"] = "player_id"
	super({
		"operations": {"reaccion_ficticia": {
			"params": {}, "validate_params": _empty, "offer": _offer, "execute": _apply
		}},
		"programs": {PROGRAM: {
			"steps": [{"step_id": STEP, "operation": "reaccion_ficticia", "params": {}}],
			"context": context, "scope": _scope, "allow_null_source": true, "binding": _bound
		}}
	})


func snapshot_profile() -> Dictionary:
	return {"schema_version": SCHEMA, "engine_version": ENGINE, "authority_fields": ["deferred_effect"]}


func accepts_snapshot(document: Dictionary) -> bool:
	if document.catalog_id != CATALOG or document.mode != "competitivo" or document.player_order != [RECIPIENT, OWNER]:
		return false
	var effect: Variant = document.authority.deferred_effect
	for close: Dictionary in document.authority.completed_sequences.values():
		if effect != null or close.program_id != PROGRAM or close.occurrence_id != OCCURRENCE \
			or close.owner_id != OWNER or close.turn_number != 2:
			return false
	if effect == null:
		return document.resolution == null
	return _valid_obligation(document)


static func obligation() -> Dictionary:
	return {"occurrence_id": OCCURRENCE, "scheduled_turn": 1, "due_turn": 2, "recipient_id": RECIPIENT}


static func due(state: Dictionary) -> bool:
	return state.authority.deferred_effect != null and state.turn.number == 2 \
		and state.turn.active_id == OWNER and state.turn.phase == "libre"


static func request() -> Dictionary:
	return {"program_id": PROGRAM, "source_id": null, "recipients": [RECIPIENT],
		"context": {"owner_id": OWNER, "turn_number": 2, "entry_phase": "libre",
			"occurrence_id": OCCURRENCE, "recipient_id": RECIPIENT}}


static func _valid_obligation(state: Dictionary) -> bool:
	var value: Variant = state.authority.deferred_effect
	if not exact_keys(value, ["occurrence_id", "scheduled_turn", "due_turn", "recipient_id"]):
		return false
	if not value.occurrence_id is String or not value.recipient_id is String \
		or not value.scheduled_turn is int or not value.due_turn is int or value != obligation():
		return false
	if state.lifecycle != "en_curso" or not state.authority.completed_sequences.is_empty():
		return false
	for player: Dictionary in state.players:
		if player.eliminated or player.health <= 0:
			return false
	if state.resolution != null and not due(state):
		return false
	if state.turn.number == 1:
		return state.turn.active_id == RECIPIENT and state.turn.phase in ["libre", "combate", "limpieza"]
	return state.turn.number == 2 and state.turn.active_id == OWNER and state.turn.phase in ["inicio", "libre"]


static func _bound(state: Dictionary, resolution: Dictionary) -> bool:
	return due(state) and _valid_obligation(state) and resolution.source_id == null \
		and resolution.context == request().context


static func _empty(params: Dictionary) -> bool:
	return params.is_empty()


static func _scope(_state: Dictionary, _context: Dictionary) -> Array:
	return [RECIPIENT]


static func _offer(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Dictionary:
	return {"kind": "reaccion", "recipients": [RECIPIENT], "options": ["activar"], "min": 0, "max": 1}


static func _apply(state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var resources: Dictionary = _seat(state, OWNER).turn_resources
	if resources.recursos == MAX_INT:
		return false
	resources.recursos += 1
	if not selected.is_empty():
		var recipient: Dictionary = _seat(state, RECIPIENT)
		if recipient.health == MAX_INT:
			return false
		recipient.health += 1
	return true


static func _seat(state: Dictionary, player_id: String) -> Dictionary:
	for player: Dictionary in state.players:
		if player.player_id == player_id:
			return player
	return {}
