extends SceneTree

const State = preload("res://scripts/game/game_state.gd")
const Validator = preload("res://scripts/game/state_validator.gd")
const Fixtures = preload("res://tests/game_state_fixtures.gd")
var checks: int = 0
var failures: int = 0
var validator: RefCounted = Validator.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_modes()
	_test_state()
	_test_atium()
	_test_references()
	_test_resolution()
	_test_bad_types()
	if failures == 0:
		print("P07_STATE_OK: %d comprobaciones." % checks)
	else:
		push_error("P07: %d fallos en %d comprobaciones." % [failures, checks])
	quit(0 if failures == 0 else 1)


func _test_modes() -> void:
	for mode: String in ["competitivo", "cooperativo", "solitario"]:
		for count: int in range(0, 6):
			var valid: bool = count == 1 if mode == "solitario" else count >= 2 and count <= 4
			var result: Dictionary = _validate(Fixtures.snapshot(mode, count))
			if valid and not result.ok:
				print(result.errors)
			_expect(result.ok == valid, "Modo/cantidad %s/%d" % [mode, count])
	var base: Dictionary = Fixtures.snapshot()
	bad(base, ["mode"], "otro")
	bad(base, ["players", 1, "player_id"], "p1")
	bad(base, ["player_order"], ["p1", "p1"])
	bad(base, ["player_order"], ["p1"])
	bad(base, ["player_order"], ["p1", "p3"])
	bad(base, ["rival"], Fixtures.snapshot("cooperativo").rival)
	bad(base, ["target_id"], "p1")
	var three: Dictionary = Fixtures.snapshot("competitivo", 3)
	three.target_id = "p3"
	_expect(_validate(three).ok, "Target representable en competitivo tres.")
	bad(three, ["target_id"], "p9")
	bad(Fixtures.snapshot("cooperativo"), ["target_id"], "p1")


func _test_state() -> void:
	var definitions: Dictionary = Fixtures.definitions()
	var state: RefCounted = State.new(definitions, "test_catalog")
	_expect(state.get_class() == "RefCounted", "Estado independiente de nodos y SceneTree.")
	_expect(state.get_snapshot().is_empty(), "Sin estado antes de carga.")
	var base: Dictionary = Fixtures.snapshot()
	var original: Dictionary = base.duplicate(true)
	_expect(state.try_load(base).ok, "Carga de estado válido.")
	_expect(state.get_snapshot() == original, "Round-trip completo sin preparar ni aplicar reglas.")
	base.players[0].persistent.atium = 999
	definitions.test_action.tipo = "modificado"
	var exposed: Dictionary = state.get_snapshot()
	exposed.zones.p1_mano.cards.clear()
	var definition: Dictionary = state.get_definition("test_action")
	definition.tipo = "otro"
	_expect(state.get_snapshot() == original, "Entradas y snapshots no comparten referencias.")
	_expect(state.get_definition("test_action").tipo == "accion", "Definiciones congeladas por copia.")
	_expect(state.get_definition("unknown").is_empty(), "Definición ausente sin excepción.")
	var moved: Dictionary = state.get_snapshot()
	moved.zones.p1_mano.cards.clear()
	moved.zones.eliminadas.cards.append("c1")
	_expect(state.try_load(moved).ok, "Misma instancia cambia de contenedor.")
	_expect(state.get_snapshot().instances.c1.owner_id == "p1", "Eliminada conserva propietario.")
	moved.instances.c2.definition_id = "missing"
	var before: Dictionary = state.get_snapshot()
	print("FALLO ESPERADO P07: snapshot inválido conserva estado.")
	_expect(not state.try_load(moved).ok and state.get_snapshot() == before, "Rechazo completo y conservación del último snapshot.")
	_expect(state.try_load(original).ok, "Recuperación tras rechazo.")
	var cooperative: Dictionary = Fixtures.snapshot("cooperativo")
	_expect(state.try_load(cooperative).ok, "Salud/Dominación/escudos de fixture sin inferir valores de preparación.")
	_expect(state.get_snapshot() == cooperative, "Round-trip rival y escudos persistentes.")
	var serialized: Dictionary = bytes_to_var(var_to_bytes(cooperative))
	_expect(_validate(serialized).ok and serialized == cooperative, "Round-trip Variant conserva int64 RNG.")
	var zero: Dictionary = Fixtures.snapshot()
	zero.players[0].health = 0
	_expect(_validate(zero).ok, "Salud cero no dispara eliminación/victoria durante almacenamiento.")


func _test_atium() -> void:
	_expect(Validator.SCHEMA_VERSION == 1 and Validator.ENGINE_VERSION == "p08-atium-1/godot-4.7.2", "AC18 versión semántica nueva con esquema v1")
	for mode: String in ["competitivo", "cooperativo", "solitario"]:
		var counts: Array = [1] if mode == "solitario" else [2, 3, 4]
		for count: int in counts:
			var base: Dictionary = Fixtures.snapshot(mode, count)
			for index: int in range(count):
				for invalid: Variant in [0, 2, -1, true, 1.0, "1", null]:
					bad(base, ["players", index, "persistent", "atium"], invalid)
				bad(base, ["players", index, "metals", 1, "exhausted"], true)
				var used: Dictionary = base.duplicate(true)
				used.players[index].metals[1].used_this_turn = true
				_expect(_validate(used).ok, "AC15 usado sigue incluido en saldo en cualquier plaza")
				var empty: Dictionary = base.duplicate(true)
				empty.players[index].metals.remove_at(1)
				empty.players[index].persistent.atium = 0
				_expect(_validate(empty).ok, "AC15 cero fichas y cero saldo válidos")
	var abundant: Dictionary = Fixtures.snapshot()
	for index: int in range(1, 40):
		abundant.players[0].metals.append({"token_id": "atium_%d" % (index + 1), "metal": "atium", "exhausted": false, "used_this_turn": index % 2 == 0})
	abundant.players[0].persistent.atium = 40
	_expect(_validate(abundant).ok, "AC15 no impone suministro físico finito")
	var state: RefCounted = State.new(Fixtures.definitions(), "test_catalog")
	var base: Dictionary = Fixtures.snapshot()
	_expect(state.try_load(base).ok, "AC18 carga versión nueva")
	for version: String in ["p08-setup-1/godot-4.7.2", "p07-state-1/godot-4.7.2"]:
		var old: Dictionary = base.duplicate(true)
		old.version_motor = version
		var before: Dictionary = old.duplicate(true)
		_expect(not _validate(old).ok and old == before, "AC18 versión antigua rechazada sin reparar entrada")
		print("FALLO ESPERADO P08: versión antigua rechazada.")
		_expect(not state.try_load(old).ok and state.get_snapshot() == base, "AC18 carga antigua conserva snapshot vigente")


func _test_references() -> void:
	var base: Dictionary = Fixtures.snapshot()
	var cases: Array = [
		[["version_esquema"], 2], [["version_esquema"], true], [["version_motor"], "other"],
		[["catalog_id"], "other"], [["match_id"], ""], [["revision"], -1], [["lifecycle"], "inventada"],
		[["instances", "c1", "instance_id"], "c2"], [["instances", "c1", "definition_id"], "missing"],
		[["instances", "c1", "owner_id"], "p3"], [["instances", "c1", "owner_id"], null],
		[["zones", "p1_mano", "cards"], []], [["zones", "p1_mano", "cards"], ["missing"]],
		[["zones", "p1_mano", "cards"], ["c1", "c1"]], [["zones", "p1_mazo", "cards"], ["c1", "c2"]],
		[["zones", "p1_mano", "holder_id"], "p2"], [["zones", "p1_mano", "zone_id"], "otra"],
		[["zones", "p1_mano", "kind"], "secreto"], [["zones", "mercado", "holder_id"], "p1"],
		[["turn", "phase"], "inventada"], [["turn", "active_id"], "p9"], [["turn", "number"], -1],
		[["players", 0, "health"], -1], [["players", 0, "character_id"], "test_action"],
		[["players", 0, "persistent", "atium"], -1], [["players", 0, "turn_resources", "ataque"], true],
		[["players", 0, "metals", 0, "metal"], "plata"], [["players", 0, "metals", 0, "exhausted"], 1],
		[["players", 0, "metals", 1, "token_id"], "cobre_1"], [["players", 0, "burned"], {"plata": 1}],
		[["missions", "mission_1", "definition_id"], "test_action"],
		[["missions", "mission_1", "progress"], {"p1": 1}],
		[["missions", "mission_1", "rewards", "p1"], ["a", "a"]],
		[["missions", "mission_1", "arrival_order"], ["p1", "p1"]],
		[["missions", "mission_1", "arrival_order"], ["p9"]],
		[["authority", "rng_state"], 1.5], [["authority", "next_id"], -1],
		[["authority", "receipts"], {"p9": {"a": {"canonical": "x", "revision_aplicada": 1}}}]
	]
	for item: Array in cases:
		bad(base, item[0], item[1])
	var missing_zone: Dictionary = base.duplicate(true)
	missing_zone.zones.erase("mercado")
	_expect(not _validate(missing_zone).ok, "Zona obligatoria ausente.")
	var duplicate_zone: Dictionary = base.duplicate(true)
	duplicate_zone.zones["another"] = {"zone_id": "another", "kind": "mano", "holder_id": "p1", "cards": []}
	_expect(not _validate(duplicate_zone).ok, "Zona lógica duplicada.")
	var supplied: Dictionary = base.duplicate(true)
	supplied.zones.p1_mano.cards.clear()
	supplied.zones.mercado.cards.append("c1")
	_expect(not _validate(supplied).ok, "Carta adquirida no puede volver al suministro con propietario.")
	var coop: Dictionary = Fixtures.snapshot("cooperativo")
	var rival_cases: Array = [
		[["rival"], null], [["rival", "health"], -1], [["rival", "definition_id"], "test_action"],
		[["rival", "deck_zone"], "missing"], [["rival", "deck_zone"], "descarte_rival"],
		[["rival", "domination", "definition_id"], "test_enemy"],
		[["rival", "adversaries", "enemy_1", "facing_id"], "p9"],
		[["rival", "adversaries", "enemy_1", "destroyed_shields"], [0, 0]],
		[["rival", "adversaries", "enemy_1", "destroyed_shields"], [3]],
		[["rival", "adversaries", "enemy_1", "destroyed_shields"], [-1]],
		[["rival", "adversaries"], {}], [["zones", "adversarios", "cards"], []]
	]
	for item: Array in rival_cases:
		bad(coop, item[0], item[1])


func _test_resolution() -> void:
	var base: Dictionary = Fixtures.snapshot()
	base.resolution = Fixtures.resolution()
	_expect(_validate(base).ok, "Representa reacción de otra plaza sin inferir ventana reglamentaria.")
	var state: RefCounted = State.new(Fixtures.definitions(), "test_catalog")
	_expect(state.try_load(base).ok and state.get_snapshot().resolution == base.resolution, "Resolución pendiente conserva cursor/destinatarios.")
	for item: Array in [
		[["resolution", "source_id"], "missing"], [["resolution", "cursor"], 3],
		[["resolution", "steps"], []], [["resolution", "recipients"], ["p9"]],
		[["resolution", "pending", "recipients"], []], [["resolution", "pending", "recipients"], ["p9"]],
		[["resolution", "pending", "options"], ["a", "a"]],
		[["resolution", "pending", "max"], 3], [["resolution", "pending", "min"], 2],
		[["resolution", "pending", "kind"], "script"]
	]:
		bad(base, item[0], item[1])


func _test_bad_types() -> void:
	_expect(not _validate(null).ok, "Raíz nula rechazada.")
	_expect(not _validate([]).ok, "Raíz array rechazada.")
	# Mutaciones recursivas de campos: el validador no debe lanzar SCRIPT ERROR.
	var base: Dictionary = Fixtures.snapshot("cooperativo")
	base.resolution = Fixtures.resolution()
	var paths: Array[Array] = []
	_collect(base, [], paths)
	for path: Array in paths:
		for value: Variant in [null, true, -1, 1.5, "wrong", [], {}]:
			var changed: Dictionary = base.duplicate(true)
			_replace_field(changed, path, value)
			var before: Dictionary = changed.duplicate(true)
			var result: Dictionary = _validate(changed)
			_expect(result.has("ok") and result.has("errors") and result.ok == result.errors.is_empty() and changed == before, "Entrada malformada diagnosticada: %s" % str(path))
		var missing: Dictionary = base.duplicate(true)
		var parent: Variant = missing
		for index: int in path.size() - 1:
			parent = parent[path[index]]
		if parent is Dictionary and (path.size() < 2 or not path[-2] in ["ability_uses", "burned", "missions"]):
			parent.erase(path.back())
			_expect(not _validate(missing).ok, "Campo obligatorio eliminado: %s" % str(path))
	var extra: Dictionary = base.duplicate(true)
	extra["unknown"] = true
	_expect(not _validate(extra).ok, "Campo desconocido rechazado.")
	extra = base.duplicate(true)
	extra.instances.c1.state.flags["object"] = RefCounted.new()
	_expect(not _validate(extra).ok, "Objetos de motor rechazados antes de copiar.")
	var recursive: Array = []
	recursive.append(recursive)
	extra = base.duplicate(true)
	extra.resolution.steps = recursive
	_expect(not _validate(extra).ok, "Ciclo de contenedores rechazado por profundidad.")
	recursive.clear()
	var too_many: Array = []
	too_many.resize(Validator.MAX_ITEMS + 1)
	extra = base.duplicate(true)
	extra.resolution.steps = too_many
	_expect(not _validate(extra).ok, "Límite técnico de contenedor.")


func _collect(value: Variant, path: Array, paths: Array[Array]) -> void:
	if value is Dictionary:
		for key: String in value:
			var child: Array = path + [key]
			paths.append(child)
			_collect(value[key], child, paths)
	elif value is Array:
		for index: int in value.size():
			_collect(value[index], path + [index], paths)


func _validate(document: Variant) -> Dictionary:
	return validator.validate(document, Fixtures.definitions(), "test_catalog")


func bad(base: Dictionary, path: Array, value: Variant) -> void:
	var changed: Dictionary = base.duplicate(true)
	_replace_field(changed, path, value)
	_expect(not _validate(changed).ok, "Rechazo esperado en %s" % str(path))


func _replace_field(document: Dictionary, path: Array, value: Variant) -> void:
	var parent: Variant = document
	for index: int in path.size() - 1:
		parent = parent[path[index]]
	parent[path.back()] = value


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
