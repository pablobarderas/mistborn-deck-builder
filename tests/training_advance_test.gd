extends SceneTree

const Advance = preload("res://scripts/game/training_advance.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Registry = preload("res://scripts/game/sequence_registry.gd")
const Base = preload("res://tests/game_state_fixtures.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const FundingFixtures = preload("res://tests/funding_fixtures.gd")
const Sequences = preload("res://tests/sequence_fixtures.gd")
const TRACK_ID: String = "test_training_track"
const CATALOG_ID: String = "test_catalog"

var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_test_panel()
	_test_profiles()
	_test_illegal()
	_test_limits()
	_test_funding()
	if _failures == 0:
		print("P08_TRAINING_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)


func _profile(definitions: Dictionary, catalog_id: String = CATALOG_ID) -> Dictionary:
	# Descriptor ficticio externo al catálogo P06. Las marcas proceden de SRC-004.
	var marks: Array = []
	marks.resize(21)
	marks.fill("")
	for position: int in [0, 3, 9, 15]:
		marks[position] = "quema"
	for position: int in [11, 16]:
		marks[position] = "atium"
	marks[5] = "nivel_1"
	marks[8] = "nivel_2"
	marks[13] = "nivel_3"
	marks[20] = "atium_continuo"
	return {"catalog_id": catalog_id, "track_id": TRACK_ID,
		"definition": definitions[TRACK_ID].duplicate(true), "marks": marks}


func _snapshot(position: int, mode: String = "competitivo", count: int = 2) -> Dictionary:
	var state: Dictionary = Base.snapshot(mode, count)
	state.lifecycle = "en_curso"
	state.turn = {"number": 1, "active_id": "p1", "phase": "inicio", "counters": {}}
	state.players[0].training = position
	return state


func _test_panel() -> void:
	var definitions: Dictionary = Base.definitions()
	var advance: Advance = Advance.new(definitions, CATALOG_ID, _profile(definitions))
	for count: int in [2, 3, 4]:
		var state: Dictionary = _snapshot(0, "competitivo", count)
		state.players[0].burn_limit = 1
		state.players[0].metals[1].used_this_turn = true
		state.player_order.reverse()
		for step: int in range(1, 23):
			var previous: Dictionary = state.duplicate(true)
			var expected: Dictionary = state.duplicate(true)
			var player: Dictionary = expected.players[0]
			player.training = mini(step, 20)
			if step in [3, 9, 15]:
				player.burn_limit += 1
			if step in [11, 16, 21, 22]:
				player.metals.append({"token_id": "token_atium_" + str(expected.authority.next_id),
					"metal": "atium", "exhausted": false, "used_this_turn": false})
				player.persistent.atium += 1
				expected.authority.next_id += 1
			var result: Dictionary = advance.advance(state, "p1")
			_expect(state == previous, "El paso conserva el original")
			_expect(result.ok and result.get("candidate") == expected, "%d plazas, paso %d y delta exacto" % [count, step])
			var level: int = int(step >= 5) + int(step >= 8) + int(step >= 13)
			_expect(Advance.unlocked_level(player.training) == level, "Desbloqueo derivado en %d" % player.training)
			if not result.ok:
				return
			state = result.candidate
		_expect(state.players[0].burn_limit == 4 and state.players[0].persistent.atium == 5,
			"Tres incrementos, cuatro fichas nuevas y Atium usado intacto")
	var high: Dictionary = _snapshot(2)
	high.players[0].burn_limit = 9
	var result: Dictionary = advance.advance(high, "p1")
	_expect(result.ok and result.candidate.players[0].burn_limit == 10, "El aumento se suma a la capacidad existente")
	_expect(Advance.unlocked_level(0) == 0, "Sin niveles en la primera casilla")
	if result.ok:
		result.candidate.players[1].name = "Otra copia"
		_expect(high.players[1].name != "Otra copia", "El candidato no comparte contenedores con el original")


func _test_profiles() -> void:
	var definitions: Dictionary = Base.definitions()
	var state: Dictionary = _snapshot(2)
	var profile: Dictionary = _profile(definitions)
	profile.marks[3] = "atium"
	profile.marks[11] = "quema"
	_reject(Advance.new(definitions, CATALOG_ID, profile), state, "p1", "pista_incompatible", "Marcas reordenadas")
	profile = _profile(definitions, "otro_catalogo")
	_reject(Advance.new(definitions, CATALOG_ID, profile), state, "p1", "pista_incompatible", "Perfil de otro catálogo")
	profile = _profile(definitions)
	profile.definition["otra_pista"] = true
	_reject(Advance.new(definitions, CATALOG_ID, profile), state, "p1", "pista_incompatible", "Definición distinta con mismo ID/tipo")
	for field: String in ["catalog_id", "definition", "track_id"]:
		profile = _profile(definitions)
		profile[field] = 1
		_reject(Advance.new(definitions, CATALOG_ID, profile), state, "p1", "pista_incompatible", "Tipo inválido en perfil: " + field)
	profile = _profile(definitions)
	profile.marks[3] = []
	_reject(Advance.new(definitions, CATALOG_ID, profile), state, "p1", "pista_incompatible", "Tipo inválido en marca")
	for field: String in ["id", "tipo"]:
		var malformed: Dictionary = Base.definitions()
		profile = _profile(malformed)
		malformed[TRACK_ID][field] = []
		_reject(Advance.new(malformed, CATALOG_ID, profile), state, "p1", "estado_invalido", "Definición de tipo inválido: " + field)
	definitions["other_track"] = {"id": "other_track", "tipo": "pista_entrenamiento"}
	var advance: Advance = Advance.new(definitions, CATALOG_ID, _profile(definitions))
	state.players[0].training_track_id = "other_track"
	_reject(advance, state, "p1", "pista_incompatible", "Pista distinta de mismo tipo")
	state.players[0].training_track_id = null
	_reject(advance, state, "p1", "pista_incompatible", "Sin pista ligada")
	state.catalog_id = "otro_catalogo"
	_reject(advance, state, "p1", "estado_invalido", "Snapshot de otro catálogo")


func _test_illegal() -> void:
	var definitions: Dictionary = Base.definitions()
	var profile: Dictionary = _profile(definitions)
	var advance: Advance = Advance.new(definitions, CATALOG_ID, profile)
	var state: Dictionary = _snapshot(2)
	_reject(advance, state, "p2", "accion_ilegal", "Actor ajeno")
	_reject(advance, state, 1, "formato_invalido", "Actor no textual")
	_reject(advance, _snapshot(2, "cooperativo"), "p1", "accion_ilegal", "Cooperativo")
	_reject(advance, _snapshot(2, "solitario", 1), "p1", "accion_ilegal", "Solitario")
	state.players[0].eliminated = true
	_reject(advance, state, "p1", "accion_ilegal", "Eliminado")
	state.players[0].eliminated = false
	state.players[0].health = 0
	_reject(advance, state, "p1", "accion_ilegal", "Sin salud")
	state = _snapshot(2)
	state.turn.number = 0
	_reject(advance, state, "p1", "accion_ilegal", "Turno cero")
	state = _snapshot(2)
	state.lifecycle = "finalizada"
	_reject(advance, state, "p1", "accion_ilegal", "Partida finalizada")
	state = _snapshot(2)
	state.turn.phase = "libre"
	_reject(advance, state, "p1", "accion_ilegal", "Fase libre")
	state = _snapshot(2)
	state.resolution = Sequences.reaction(state)
	var registry: Registry = Registry.new(Sequences.registration())
	_expect(Validator.new().validate(state, definitions, CATALOG_ID, registry).ok, "Resolución pendiente válida en inicio")
	_reject(Advance.new(definitions, CATALOG_ID, profile, registry), state, "p1", "accion_ilegal", "Resolución pendiente")
	_reject(advance, _snapshot(-1), "p1", "estado_invalido", "Índice negativo")
	_reject(advance, _snapshot(21), "p1", "estado_invalido", "Índice posterior al final")


func _test_limits() -> void:
	var definitions: Dictionary = Base.definitions()
	var advance: Advance = Advance.new(definitions, CATALOG_ID, _profile(definitions))
	var state: Dictionary = _snapshot(2)
	state.players[0].burn_limit = Registry.MAX_INT
	_reject(advance, state, "p1", "estado_invalido", "Desbordamiento del límite")
	state = _snapshot(10)
	state.authority.next_id = Registry.MAX_INT
	_reject(advance, state, "p1", "estado_invalido", "Desbordamiento del contador")
	state = _snapshot(10)
	state.players[0].metals[0].token_id = "token_atium_3"
	_reject(advance, state, "p1", "estado_invalido", "Colisión con ficha de la plaza")
	for field: String in ["metals", "persistent"]:
		state = _snapshot(10)
		state.players[0][field].make_read_only()
		_reject(advance, state, "p1", "estado_invalido", "Contenedor de solo lectura: " + field)
	state = _snapshot(10)
	state.authority.make_read_only()
	_reject(advance, state, "p1", "estado_invalido", "Contador de solo lectura")
	state = _snapshot(10)
	var typed_authority: Dictionary[String, Variant] = {}
	typed_authority.assign(state.authority)
	state.authority = typed_authority
	_reject(advance, state, "p1", "estado_invalido", "Contador en diccionario tipado")

	# Llenar el presupuesto de nodos con fichas válidas. El nuevo token
	# rebasa el presupuesto, aunque la entrada y las guardas sean válidas.
	state = _snapshot(10)
	var metals: Array = state.players[0].metals
	for index: int in range(2, Validator.MAX_ITEMS):
		metals.append({"token_id": "cobre_%d" % index, "metal": "cobre", "exhausted": false, "used_this_turn": false})
	var validator: Validator = Validator.new()
	var low: int = 2
	var high: int = metals.size()
	while low + 1 < high:
		var middle: int = (low + high) >> 1
		state.players[0].metals = metals.slice(0, middle)
		if validator.validate(state, definitions, CATALOG_ID).ok:
			low = middle
		else:
			high = middle
	state.players[0].metals = metals.slice(0, low)
	_expect(validator.validate(state, definitions, CATALOG_ID).ok, "Estado de entrada al límite técnico válido")
	_reject(advance, state, "p1", "estado_invalido", "Falla sólo la validación del candidato")


func _test_funding() -> void:
	var document: Dictionary = FundingFixtures.catalog()
	var engine: Funding = Funding.new(document, "test_funding", FundingFixtures.inerts(document))
	_expect(engine.load_authority_snapshot(FundingFixtures.snapshot()).ok, "Fixture Funding válido")
	_expect(engine.submit("p1", {"version_accion": 1, "match_id": "test_match", "action_id": "play",
		"expected_revision": 0, "tipo": "jugar_funding", "payload": {"instance_id": "c1", "aplicar": true}}).ok,
		"Cierre Funding real de un turno anterior")
	var state: Dictionary = engine.get_authority_snapshot()
	state.turn.phase = "inicio"
	state.turn.number += 1
	state.players[0].training = 10
	var definitions: Dictionary = FundingFixtures.definitions(document)
	var catalog_id: String = engine.catalog_identity()
	var profile: Dictionary = _profile(definitions, catalog_id)
	var registry: Registry = Registry.new(Funding._registration("test_funding"))
	var result: Dictionary = Advance.new(definitions, catalog_id, profile, registry).advance(state, "p1")
	_expect(result.ok and result.candidate.revision == state.revision
		and result.candidate.authority.completed_sequences == state.authority.completed_sequences
		and result.candidate.authority.receipts == state.authority.receipts
		and result.candidate.authority.next_id == state.authority.next_id + 1, "Conserva cierres y recibos Funding")
	_reject(Advance.new(definitions, catalog_id, profile), state, "p1", "estado_invalido", "Registro sin el programa Funding")


func _reject(advance: Advance, state: Dictionary, actor: Variant, code: String, label: String) -> void:
	var original: Dictionary = state.duplicate(true)
	_expect(advance.advance(state, actor) == {"ok": false, "codigo": code}, label)
	_expect(state == original, label + ": original intacto")


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(label)
