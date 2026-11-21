extends SceneTree
const Loader = preload("res://scripts/catalog/runtime_catalog_loader.gd")
const Play = preload("res://scripts/game/runtime_perseguir_play.gd")
const Mission = preload("res://scripts/game/mission_play.gd")
const Validator = preload("res://scripts/catalog/catalog_validator.gd")
var _root: String = "res://tmp/runtime_catalog/"
var _artifact: String = _root + "trial.json"
var _checks: int = 0
var _failures: int = 0

class Source extends Mission.SnapshotSource:
	var entry: Dictionary
	func _init(profile: String, state: Dictionary) -> void:
		entry = {"profile_id": profile, "snapshot": state.duplicate(true)}
	func latest(_match: String, _profile: String) -> Dictionary:
		return entry.duplicate(true)

func _expect(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures += 1
		printerr("RUNTIME_FAIL: " + label)
		quit(1)

func _intent(state: Dictionary, id: String, kind: String, payload: Dictionary) -> Dictionary:
	return {"version_accion": 1, "match_id": state.match_id, "action_id": id, "expected_revision": state.revision, "tipo": kind, "payload": payload}

func _loaded(state: Dictionary) -> Play:
	var play := Play.new(_artifact)
	_expect(play.is_supported(), "perfil soportado")
	var restored: Dictionary = play.restore_match(state.match_id, Source.new(play.profile_identity(), state))
	_expect(restored.ok, "restauración fiable " + str(restored))
	return play

func _initialize() -> void:
	if not OS.get_cmdline_user_args().is_empty():
		_root = OS.get_cmdline_user_args()[0]
		_artifact = _root + "trial.json"
	var loader := Loader.new()
	var artifact: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(_artifact))
	_expect(loader.admit(artifact).ok, "artefacto fijado")
	var serialized: String = JSON.stringify(artifact)
	_expect(not serialized.contains("res://") and not serialized.contains("ruta_imagen") and not serialized.contains('"revision"'), "artefacto sin rutas ni campos de autoría")
	var before: Dictionary = loader.get_document()
	var raw: String = FileAccess.get_file_as_string(_artifact)
	for modified: String in [raw + " ", "{\"definitions\":\"hidden-original-bytes\"," + raw.trim_prefix("{")]:
		var path: String = "user://runtime_modified.json"
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(modified)
		file.close()
		_expect(not loader.load_file(path).ok and loader.get_document() == before, "archivo alterado o clave duplicada")
		DirAccess.remove_absolute(path)

	var bom_bytes := PackedByteArray([0xef, 0xbb, 0xbf])
	bom_bytes.append_array(FileAccess.get_file_as_bytes(_artifact))
	var bom_path: String = "user://runtime_bom.json"
	var bom_file := FileAccess.open(bom_path, FileAccess.WRITE)
	bom_file.store_buffer(bom_bytes)
	bom_file.close()
	_expect(not loader.load_file(bom_path).ok and loader.get_document() == before, "BOM altera bytes: rechazo atomico")
	_expect(not Play.new(bom_path).is_supported(), "BOM no crea perfil parcial")
	DirAccess.remove_absolute(bom_path)

	for kind: String in ["format", "resolver", "catalog", "source", "effect", "decimal", "extra", "self_digest", "missing", "draft", "nested_key", "object", "deep"]:
		var altered: Dictionary = artifact.duplicate(true)
		match kind:
			"format": altered.format_version = 2
			"resolver": altered.resolver_version += "x"
			"catalog": altered.catalog_id += "x"
			"source": altered.sources[0].sha256 = "0".repeat(64)
			"effect": altered.definitions[-5].cantidad = 2
			"decimal": altered.definitions[0].cantidad = 1.25
			"extra": altered["ruta"] = "res://evidencia_local/example.png"
			"self_digest":
				altered.catalog_id += "client"
				var payload: Dictionary = altered.duplicate(true)
				payload.erase("digest")
				altered.digest = Loader.digest(payload)
			"missing": altered.definitions.pop_back()
			"draft": altered.definitions[0]["revision"] = {"estado": "verificada"}
			"nested_key": altered.definitions[0] = {1: "invalid"}
			"object": altered.definitions[0] = RefCounted.new()
			"deep":
				var nested: Array = []
				for index: int in 40: nested = [nested]
				altered.definitions = nested
		_expect(not loader.admit(altered).ok and loader.get_document() == before, "rechazo atómico " + kind)
	for value: Variant in [null, [], "catalog", 1, {"digest": artifact.digest}]:
		_expect(not loader.admit(value).ok and loader.get_document() == before, "tipo inválido")
	_expect(not loader.load_file("res://tmp/runtime_catalog/absent.json").ok and loader.get_document() == before, "archivo ausente")
	var invalid := Play.new("res://tmp/runtime_catalog/absent.json")
	_expect(not invalid.is_supported() and invalid.profile_identity().is_empty(), "sin admisión parcial de perfil")
	var states: Dictionary = FileAccess.open(_root + "states.bin", FileAccess.READ).get_var(false)
	for count: int in [2, 3, 4]:
		for route: String in ["primary", "omit", "savant"]:
			var state: Dictionary = states[str(count)].duplicate(true)
			var play: Play = _loaded(state)
			var payload: Dictionary = {"instance_id": "c1", "ruta": "metal" if route == "savant" else "primaria", "aplicar": route != "omit", "metal": null if route == "omit" else "bronce", "origen": {"tipo": "ficha", "id": "bronce_p1"} if route == "primary" else {}}
			var action: Dictionary = _intent(state, "runtime", "jugar_perseguir", payload)
			var result: Dictionary = play.submit("p1", action)
			_expect(result.ok, "Perseguir " + route)
			var after: Dictionary = play.get_authority_snapshot()
			_expect(after.players[0].turn_resources.mision == (2 if route == "primary" else (1 if route == "savant" else 0)), "recursos exactos")
			_expect(after.missions == state.missions and after.authority.rng_state == state.authority.rng_state, "sin avance implícito/RNG")
			_expect(play.submit("p1", action) == result and play.get_authority_snapshot() == after, "idempotencia")
			var restored: Play = _loaded(after)
			_expect(restored.submit("p1", action) == result and restored.get_authority_snapshot() == after, "recibo restaurado")
			var wrong: Dictionary = action.duplicate(true)
			wrong.action_id = "bad"
			wrong.expected_revision = after.revision
			_expect(not play.submit("p1", wrong).ok and play.get_authority_snapshot() == after, "operación rechazada atómica")
			var view: String = JSON.stringify(play.get_view("p2"))
			_expect(not view.contains("rng_state") and not view.contains("perseguir_revision"), "privacidad")
	for number: int in range(1, 9):
		var state: Dictionary = states["mission_%d" % number].duplicate(true)
		state.players[0].turn_resources.mision = 1
		var play: Play = _loaded(state)
		var mission_id: String = "mission_%d" % number
		_expect(play.submit("p1", _intent(state, "mission", "avanzar_mision", {"mission_id": mission_id})).ok, "M%d ejecutable" % number)
		_expect(play.get_authority_snapshot().missions[mission_id].progress.p1 == 1, "avance M%d" % number)
	var state: Dictionary = states["2"].duplicate(true)
	for kind: String in ["catalog", "profile", "schema", "raw"]:
		var play := Play.new(_artifact)
		var altered: Dictionary = state.duplicate(true)
		if kind == "catalog": altered.catalog_id += "old"
		if kind == "schema": altered.version_esquema = 7
		var source = Source.new("foreign" if kind == "profile" else play.profile_identity(), altered)
		_expect(not play.restore_match(state.match_id, altered if kind == "raw" else source).ok and play.get_authority_snapshot().is_empty(), "snapshot incompatible " + kind)
	# La frontera antigua no admite el documento de ejecución como autoría v4.
	_expect(not Validator.new().validate(before).ok, "sin atajo en validador de autoría")
	if not DirAccess.dir_exists_absolute("res://evidencia_local") and FileAccess.file_exists(_root + "authoring.json"):
		var authoring: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(_root + "authoring.json"))
		_expect(not Validator.new().validate(authoring).ok, "autoría real sin PNG rechazada")
	if _failures == 0: print("P08_RUNTIME_CATALOG_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)
