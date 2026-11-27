extends "res://scripts/game/sequence_registry.gd"
## Registro cerrado del ensayo integrado. Ningún descriptor procede del cliente.

const Core = preload("res://scripts/game/game_engine.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
const Resolver = preload("res://scripts/game/sequence_resolver.gd")
const Cleanup = preload("res://scripts/game/turn_cleanup.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")
const Exchange = preload("res://scripts/game/turn_resource_exchange.gd")
const Cycle = preload("res://scripts/game/card_cycle.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const ENGINE: String = "e3-integrated-fixture-1/godot-4.7.2"
const CATALOG: String = "e3_integrated_fixture"
const SCHEMA: int = 9
const OWNER: String = "p1"
const OPPONENT: String = "p2"
const PROGRAM: String = "integrado_seleccion_v1"
const REACTION: String = "integrado_reaccion_v1"
const OCCURRENCE: String = "integrado_seleccion_1"
const REACTION_OCCURRENCE: String = "integrado_reaccion_1"
const SELECT_STEP: String = "seleccionar_ficha"
const ALTERNATIVE_STEP: String = "elegir_destino"
const REACTION_STEP: String = "canjear_carga"
const START: String = "iniciar_integrado"
const HANDOFF: String = Core.CLEANUP_ACTION
const HANDOFF_PREFIX: String = Core.CLEANUP_ID_PREFIX
const DISPATCH: String = "despachar_integrado"
const DISPATCH_PREFIX: String = "despacho_integrado_"
const MISSIONS: Array[String] = ["integrado_1", "integrado_2", "integrado_3"]
const LAST_MISSION: String = "integrado_3"
var _cleanup_only: bool = false


func _init() -> void:
	super({"operations": {
		"seleccion": {"params": {}, "validate_params": _empty, "offer": _selection, "execute": _discard},
		"destino": {"params": {}, "validate_params": _empty, "offer": _alternative, "execute": _exchange},
		"reaccion": {"params": {}, "validate_params": _empty, "offer": _reaction, "execute": _redeem}
	}, "programs": {
		PROGRAM: {"steps": [{"step_id": SELECT_STEP, "operation": "seleccion", "params": {}},
			{"step_id": ALTERNATIVE_STEP, "operation": "destino", "params": {}}],
			"context": BASE_CONTEXT, "scope": _scope_a, "allow_null_source": true, "binding": _bound_a},
		REACTION: {"steps": [{"step_id": REACTION_STEP, "operation": "reaccion", "params": {}}],
			"context": BASE_CONTEXT, "scope": _scope_b, "allow_null_source": true, "binding": _bound_b}
	}})


func snapshot_profile() -> Dictionary:
	return {"schema_version": SCHEMA, "engine_version": ENGINE, "authority_fields": ["deferred_effect"]}


func accepts_snapshot(state: Dictionary) -> bool:
	# TurnCleanup valida sus candidatos antes del commit P07. Su registro privado
	# conserva las guardas estructurales; la autoridad siempre usa la carga estricta.
	if _cleanup_only:
		return state.catalog_id == CATALOG and state.mode == "competitivo" \
			and state.authority.deferred_effect == obligation() and state.revision == 3 \
			and state.resolution == null and state.lifecycle == "en_curso" \
			and ((state.turn.number == 1 and state.turn.active_id == OWNER and state.turn.phase == "limpieza") \
			or (state.turn.number == 2 and state.turn.active_id == OPPONENT and state.turn.phase == "inicio"))
	if state.revision < 0 or state.revision > 6:
		return false
	var by_revision: Dictionary = {}
	for actor: String in state.authority.receipts:
		for id: String in state.authority.receipts[actor]:
			var receipt: Dictionary = state.authority.receipts[actor][id]
			if by_revision.has(receipt.revision_aplicada):
				return false
			by_revision[receipt.revision_aplicada] = {"actor": actor, "id": id, "receipt": receipt}
	if by_revision.size() != state.revision:
		return false
	for initial_charge: int in [0, MAX_INT]:
		for selected: String in ["a1", "a2"]:
			for branch: String in ["donar", "conservar"]:
				if _history_matches(state, by_revision, initial_charge, selected, branch):
					return true
	return false


func _history_matches(state: Dictionary, history: Dictionary, initial_charge: int, selected: String, branch: String) -> bool:
	var expected: Dictionary = initial()
	expected.players[1].turn_resources.ataque = initial_charge
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = expected.authority.rng_seed
	rng.state = expected.authority.rng_state
	var resolver: Resolver = Resolver.new(self, definitions())
	for revision: int in range(1, state.revision + 1):
		if not history.has(revision) or (branch == "conservar" and revision > 3):
			return false
		var item: Dictionary = history[revision]
		var actor: String = OWNER if revision <= 4 else OPPONENT
		var action: String = START
		var payload: Dictionary = {}
		if revision in [2, 3, 6]:
			action = "responder"
			payload = {"resolution_id": expected.resolution.resolution_id,
				"step_id": expected.resolution.steps[expected.resolution.cursor],
				"options": [selected if revision == 2 else (branch if revision == 3 else "canjear")]}
		elif revision == 4:
			action = HANDOFF
		elif revision == 5:
			action = DISPATCH
		var internal: bool = revision in [4, 5]
		if item.actor != actor or (revision == 4 and not item.id.begins_with(HANDOFF_PREFIX)) \
			or (revision == 5 and not item.id.begins_with(DISPATCH_PREFIX)):
			return false
		if not internal:
			for prefix: String in [Core.START_TURN_ID_PREFIX, HANDOFF_PREFIX, DISPATCH_PREFIX]:
				if item.id.begins_with(prefix):
					return false
		var intent: Dictionary = {"version_accion": Core.ACTION_VERSION, "match_id": expected.match_id,
			"expected_revision": revision - 1, "action_id": item.id, "tipo": action, "payload": payload}
		if item.receipt.canonical != Core.canonical_intent(intent):
			return false
		if revision == 4:
			if not handoff(expected, actor, rng):
				return false
		else:
			var result: Resolver.Result
			if revision in [1, 5]:
				result = resolver.begin(expected, actor, request(revision == 5), rng)
			else:
				result = resolver.resume(expected, payload.options, rng)
			if result.status not in [Resolver.Result.Status.PAUSED, Resolver.Result.Status.CLOSED]:
				return false
			if result.status == Resolver.Result.Status.PAUSED:
				expected.resolution = result.resolution
			else:
				result.close["revision_aplicada"] = revision
				expected.authority.completed_sequences[result.closed_id] = result.close
				expected.resolution = null
				if not close_sequence(expected, result.close):
					return false
		expected.revision = revision
		expected.authority.rng_state = rng.state
		if not expected.authority.receipts.has(actor):
			expected.authority.receipts[actor] = {}
		expected.authority.receipts[actor][item.id] = item.receipt.duplicate(true)
	return expected == state


static func definitions() -> Dictionary:
	var result: Dictionary = Fixtures.definitions()
	var cells: Array[Dictionary] = []
	for position: int in range(1, 13):
		cells.append({"id": "p%02d" % position})
	result.test_mission["rasgos"] = {"recorridos": [{"casillas": cells}]}
	return result


static func initial() -> Dictionary:
	var state: Dictionary = Fixtures.snapshot()
	state.version_esquema = SCHEMA
	state.version_motor = ENGINE
	state.catalog_id = CATALOG
	state.lifecycle = "en_curso"
	state.turn = {"number": 1, "active_id": OWNER, "phase": "libre", "counters": {}}
	state.players[0].name = "A"
	state.players[1].name = "B"
	state.players[0].turn_resources = {"recursos": 4, "ataque": 0, "mision": 0}
	state.players[1].turn_resources = {"recursos": 0, "ataque": 0, "mision": 0}
	state.instances = {"a1": Fixtures.instance("a1", "test_action", OWNER),
		"a2": Fixtures.instance("a2", "test_action", OWNER), "b1": Fixtures.instance("b1", "test_action", OPPONENT)}
	for zone: Dictionary in state.zones.values():
		zone.cards = []
	state.zones.p1_mano.cards = ["a1", "a2"]
	state.zones.p2_mano.cards = ["b1"]
	state.authority["deferred_effect"] = null
	state.missions.clear()
	for mission_id: String in MISSIONS:
		var position: int = 11 if mission_id == LAST_MISSION else 12
		var arrivals: Dictionary = {}
		for cell: int in range(1, 13):
			arrivals["p%02d" % cell] = OPPONENT if cell <= position else null
		state.missions[mission_id] = {"definition_id": "test_mission", "progress": {OWNER: 0, OPPONENT: position},
			"rewards": {OWNER: [], OPPONENT: []}, "arrival_order": [OPPONENT] if position == 12 else [],
			"first_arrivals": arrivals}
	return state


static func request(reaction: bool) -> Dictionary:
	return {"program_id": REACTION if reaction else PROGRAM, "source_id": null,
		"recipients": [OPPONENT if reaction else OWNER],
		"context": {"owner_id": OPPONENT if reaction else OWNER, "turn_number": 2 if reaction else 1,
			"entry_phase": "inicio" if reaction else "libre",
			"occurrence_id": REACTION_OCCURRENCE if reaction else OCCURRENCE}}


static func obligation() -> Dictionary:
	return {"occurrence_id": REACTION_OCCURRENCE, "scheduled_turn": 1, "due_turn": 2, "owner_id": OPPONENT}


static func outcome() -> Dictionary:
	return {"winner_id": OPPONENT, "reason": "tres_misiones", "mission_id": LAST_MISSION, "turn_number": 2}


static func handoff(state: Dictionary, actor: String, rng: RandomNumberGenerator) -> bool:
	if actor != OWNER or state.turn.number != 1 or state.turn.phase != "libre" \
		or state.authority.deferred_effect != obligation():
		return false
	var registry: GDScript = load("res://tests/integrated_trial_registry.gd")
	var cleanup_profile: RefCounted = registry.new()
	cleanup_profile._cleanup_only = true
	state.turn.phase = "limpieza"
	return Cleanup.new(definitions(), CATALOG, cleanup_profile).finish_cleanup(state, actor, rng).ok


static func close_sequence(state: Dictionary, close: Dictionary) -> bool:
	if close.program_id == PROGRAM and close.occurrence_id == OCCURRENCE:
		state.authority.deferred_effect = obligation() if state.players[0].turn_resources.ataque == 0 else null
		return true
	if close.program_id != REACTION or close.occurrence_id != REACTION_OCCURRENCE \
		or state.authority.deferred_effect != obligation():
		return false
	state.authority.deferred_effect = null
	if not Advance.arrive(state, OPPONENT, LAST_MISSION, 12):
		return false
	state.outcome = outcome()
	state.lifecycle = "finalizada"
	state.turn.phase = "finalizada"
	return true


static func _empty(params: Dictionary) -> bool:
	return params.is_empty()


static func _scope_a(_state: Dictionary, _context: Dictionary) -> Array:
	return [OWNER]


static func _scope_b(_state: Dictionary, _context: Dictionary) -> Array:
	return [OPPONENT]


static func _bound_a(state: Dictionary, resolution: Dictionary) -> bool:
	return state.turn.number == 1 and state.turn.active_id == OWNER and state.turn.phase == "libre" \
		and state.authority.deferred_effect == null and state.authority.completed_sequences.is_empty() \
		and resolution.source_id == null and resolution.context == request(false).context


static func _bound_b(state: Dictionary, resolution: Dictionary) -> bool:
	return state.turn.number == 2 and state.turn.active_id == OPPONENT and state.turn.phase == "inicio" \
		and state.authority.deferred_effect == obligation() and state.authority.completed_sequences.size() == 1 \
		and resolution.source_id == null and resolution.context == request(true).context


static func _selection(state: Dictionary, _context: Dictionary, _params: Dictionary) -> Dictionary:
	return {"kind": "eleccion", "recipients": [OWNER], "options": state.zones.p1_mano.cards.duplicate(), "min": 1, "max": 1}


static func _alternative(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Dictionary:
	return {"kind": "eleccion", "recipients": [OWNER], "options": ["donar", "conservar"], "min": 1, "max": 1}


static func _reaction(_state: Dictionary, _context: Dictionary, _params: Dictionary) -> Dictionary:
	return {"kind": "reaccion", "recipients": [OPPONENT], "options": ["canjear"], "min": 1, "max": 1}


static func _discard(state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	if selected.size() != 1 or not selected[0] in state.zones.p1_mano.cards:
		return false
	# Copia estructural del ciclo: la ventana del segmento aún no está confirmada.
	# Solo se devuelven ambas zonas; versiones, autoridad y ventana permanecen intactas.
	var working: Dictionary = state.duplicate(true)
	working.resolution = null
	working.version_esquema = Validator.SCHEMA_VERSION
	working.version_motor = Validator.ENGINE_VERSION
	working.authority.erase("deferred_effect")
	if not Cycle.new(definitions(), CATALOG).discard_from_hand(working, OWNER, selected):
		return false
	state.zones.p1_mano.cards = working.zones.p1_mano.cards
	state.zones.p1_descarte.cards = working.zones.p1_descarte.cards
	return true


static func _exchange(state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var a: Dictionary = state.players[0].turn_resources
	var b: Dictionary = state.players[1].turn_resources
	if selected not in [["donar"], ["conservar"]] \
		or not Exchange.apply(a, "recursos", 2, "ataque", 1):
		return false
	if selected == ["donar"]:
		if b.ataque == MAX_INT:
			return false
		a.ataque -= 1
		b.ataque += 1
	return true


static func _redeem(state: Dictionary, _context: Dictionary, _params: Dictionary, _rng: RandomNumberGenerator, selected: Array) -> bool:
	var resources: Dictionary = state.players[1].turn_resources
	return selected == ["canjear"] and Exchange.apply(resources, "ataque", 1, "mision", 1)
