extends SceneTree

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var database: Node = root.get_node_or_null("Database")
	_expect(database != null, "Database debe existir como Autoload.")
	if database == null:
		quit(1)
		return
	_expect(database.is_loaded, "El Autoload debe cargar antes de la pantalla.")
	_expect(database.cartas.size() == 2, "El catálogo original tiene dos cartas.")
	_expect(database.cartas.has("moneda_de_cobre") and database.cartas.has("kelsier"), "Se conservan los IDs originales.")

	var scene: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene")) as PackedScene
	_expect(scene != null, "La escena principal debe poder cargarse.")
	if scene == null:
		quit(1)
		return
	var screen: Control = scene.instantiate() as Control
	root.add_child(screen)
	await process_frame
	var cards: HBoxContainer = screen.get_node("%Cards") as HBoxContainer
	var reload_button: Button = screen.get_node("%ReloadButton") as Button
	var error_label: Label = screen.get_node("%ErrorLabel") as Label
	_expect(cards.get_child_count() == 2, "Se muestran ambas cartas sin ilustraciones externas.")
	_expect(cards.get_child(0).get_node("%Name").text == "Moneda de Cobre", "La primera vista usa el nombre del JSON.")
	_expect(cards.get_child(1).get_node("%Name").text == "Kelsier", "La segunda vista usa el nombre del JSON.")
	_expect(cards.get_child(0).get_node("%Stats").text == "Coste 2 · Recurso 1 · Ataque 0", "Los enteros JSON se muestran sin decimales artificiales.")
	_expect(not error_label.visible, "La pantalla inicial no debe estar en error.")
	reload_button.pressed.emit()
	await process_frame
	_expect(cards.get_child_count() == 2, "La recarga no duplica cartas.")

	var fixture_dir: String = "res://tmp/test-fixtures"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(fixture_dir))
	var cases: Array[Dictionary] = [
		{"name": "invalid_json", "text": "[{"},
		{"name": "wrong_root", "text": "{}"},
		{"name": "not_object", "text": "[42]"},
		{"name": "missing_id", "text": "[{}]"},
		{"name": "invalid_id", "text": "[{\"id\": 3}]"},
		{"name": "empty_id", "text": "[{\"id\": \"  \"}]"},
		{"name": "duplicate_id", "text": "[{\"id\":\"x\"},{\"id\":\"x\"}]"}
	]
	var failed_signals: Array[String] = []
	database.catalog_failed.connect(func(message: String) -> void: failed_signals.append(message))
	for test_case: Dictionary in cases:
		var path: String = "%s/%s.json" % [fixture_dir, test_case["name"]]
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		_expect(file != null, "Debe poder escribirse la entrada de prueba.")
		if file == null:
			continue
		file.store_string(test_case["text"])
		file.close()
		print("FALLO ESPERADO: ", test_case["name"])
		_expect(not database.load_cards(path), "Debe rechazarse %s." % test_case["name"])
		_expect(not database.is_loaded and database.cartas.is_empty(), "Un fallo no conserva un catálogo válido o parcial.")
		_expect(database.last_error.contains(path), "El diagnóstico identifica la ruta.")
		await process_frame
		_expect(error_label.visible and cards.get_child_count() == 0, "El error es visible y retira las cartas.")
		reload_button.pressed.emit()
		await process_frame
		_expect(database.is_loaded and cards.get_child_count() == 2, "La recarga se recupera tras %s." % test_case["name"])

	var missing_path: String = fixture_dir + "/does_not_exist.json"
	print("FALLO ESPERADO: archivo inexistente")
	_expect(not database.load_cards(missing_path), "Debe rechazarse un archivo ausente.")
	_expect(database.cartas.is_empty(), "Un archivo ausente no conserva datos anteriores.")
	_expect(failed_signals.size() == cases.size() + 1, "Cada fallo emite un diagnóstico observable.")
	reload_button.pressed.emit()
	await process_frame
	_expect(database.last_error.is_empty() and database.is_loaded, "Una carga correcta limpia el error anterior.")
	_expect(screen.get_node("%CardCount").text == "2 cartas de prueba", "La pantalla refleja el catálogo recuperado.")

	if failures == 0:
		print("P03_STARTUP_OK: %d comprobaciones; los 8 errores de carga anteriores eran casos negativos esperados." % checks)
	else:
		push_error("P03: %d comprobaciones fallidas de %d." % [failures, checks])
	screen.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("COMPROBACIÓN FALLIDA: " + message)
