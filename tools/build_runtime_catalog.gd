extends SceneTree
## Construcción local del ensayo: no escribe ni promueve data/perseguir.json.
const F = preload("res://tests/perseguir_fixtures.gd")
const Builder = preload("res://scripts/catalog/runtime_catalog_builder.gd")
const Loader = preload("res://scripts/catalog/runtime_catalog_loader.gd")
const Play = preload("res://scripts/game/runtime_perseguir_play.gd")

func _initialize() -> void:
	var result: Dictionary = Builder.new().build(F.catalog())
	if not result.ok:
		printerr(result.errors)
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://tmp/runtime_catalog")
	var output := FileAccess.open("res://tmp/runtime_catalog/trial.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(result.artifact, "\t"))
	output.close()
	var play := Play.new("res://tmp/runtime_catalog/trial.json")
	if not play.is_supported():
		printerr("Perfil generado no soportado")
		quit(1)
		return
	output = FileAccess.open("res://tmp/runtime_catalog/authoring.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(F.catalog(), "\t"))
	output.close()
	var states: Dictionary = {}
	for count: int in [2, 3, 4]:
		var state: Dictionary = F.snapshot(count)
		state.catalog_id = play.catalog_identity()
		states[str(count)] = state
	for number: int in range(1, 9):
		var numbers: Array = [number, number % 8 + 1, (number + 1) % 8 + 1]
		var state: Dictionary = F.snapshot(2, numbers)
		state.catalog_id = play.catalog_identity()
		states["mission_%d" % number] = state
	output = FileAccess.open("res://tmp/runtime_catalog/states.bin", FileAccess.WRITE)
	output.store_var(states)
	output.close()
	print("P08_RUNTIME_BUILD_OK: " + result.artifact.digest)
	quit()
