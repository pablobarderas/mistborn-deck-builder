extends SceneTree
const F = preload("res://tests/perseguir_fixtures.gd")
const Builder = preload("res://scripts/catalog/runtime_catalog_builder.gd")
const Loader = preload("res://scripts/catalog/runtime_catalog_loader.gd")
const Validator = preload("res://scripts/catalog/catalog_validator.gd")
var _checks: int = 0
var _failures: int = 0
func _expect(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures += 1
		printerr("AUTHORING_FAIL: " + label)
		quit(1)
func _initialize() -> void:
	var document: Dictionary = F.catalog()
	var changed := FileAccess.open("res://tmp/runtime_catalog/changed.png", FileAccess.WRITE)
	changed.store_string("altered source bytes")
	changed.close()
	var before: Dictionary = document.duplicate(true)
	var builder := Builder.new()
	var first: Dictionary = builder.build(document)
	var second: Dictionary = builder.build(document)
	_expect(first.ok and second == first and document == before, "construcción determinista sin mutación")
	var stored: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tmp/runtime_catalog/trial.json"))
	_expect(Loader.new().admit(stored).ok and first.artifact.digest == stored.digest, "artefacto local reproducible")
	for index: int in document.fuentes.size():
		if document.fuentes[index].id == "FIXTURE": continue
		for mode: String in ["absent", "changed"]:
			var altered: Dictionary = document.duplicate(true)
			if mode == "absent": altered.fuentes[index].ruta = "res://evidencia_local/src_005/absent.png"
			else: altered.fuentes[index].ruta = "res://tmp/runtime_catalog/changed.png"
			_expect(not Validator.new().validate(altered).ok and not builder.build(altered).ok, "fuente " + mode + str(index))
	for mode: String in ["draft", "definition", "unknown", "source"]:
		var altered: Dictionary = document.duplicate(true)
		match mode:
			"draft": altered.cartas[-1].revision.estado = "borrador"
			"definition": altered.cartas[-1].cantidad = 2
			"unknown": altered.cartas[-1].id = "client"
			"source": altered.fuentes[0].id = "client"
		_expect(not builder.build(altered).ok, "autoría alterada " + mode)
	_expect(not builder.build(JSON.parse_string(FileAccess.get_file_as_string("res://data/perseguir.json"))).ok, "borrador original no promovido")
	if _failures == 0: print("P08_RUNTIME_AUTHORING_OK: %d comprobaciones." % _checks)
	quit(0 if _failures == 0 else 1)
