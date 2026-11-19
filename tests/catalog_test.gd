extends SceneTree

const Validator = preload("res://scripts/catalog/catalog_validator.gd")
var checks: int = 0
var failures: int = 0
var base: Dictionary


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	create_timer(20.0).timeout.connect(func() -> void:
		push_error("P06: tiempo máximo de prueba excedido.")
		quit(1))
	base = JSON.parse_string(FileAccess.get_file_as_string("res://data/cartas.json"))
	var validator: RefCounted = Validator.new()
	var good: Dictionary = validator.validate(base)
	_expect(good["ok"], "Catálogo migrado válido.")
	_expect(good["cards"].size() == 2 and good["verified"].is_empty(), "Dos muestras, cero cartas verificadas.")
	_expect(good["counts"] == {"muestra": 2, "borrador": 0, "verificada": 0}, "Conteo de estados.")
	_expect(good["warnings"].size() == 4, "Aviso de imagen y revisión por muestra.")
	var cases: Array[Dictionary] = [
		{"path": ["version_esquema"], "value": 5, "field": "version_esquema"},
		{"path": ["version_esquema"], "value": "1", "field": "version_esquema"},
		{"path": ["idioma"], "value": "en", "field": "idioma"},
		{"path": ["cartas"], "value": [], "field": "cartas"},
		{"path": ["cartas", 0, "id"], "value": "Con espacio", "field": ".id"},
		{"path": ["cartas", 1, "id"], "value": "moneda_de_cobre", "field": "duplicado"},
		{"path": ["cartas", 0, "cantidad"], "value": 0, "field": "cantidad"},
		{"path": ["cartas", 0, "cantidad"], "value": 1.5, "field": "cantidad"},
		{"path": ["cartas", 0, "coste_compra"], "value": -1, "field": "coste_compra"},
		{"path": ["cartas", 0, "coste_compra"], "value": true, "field": "coste_compra"},
		{"path": ["cartas", 0, "resumen", "ataque"], "value": "3", "field": "ataque"},
		{"path": ["cartas", 0, "tipo"], "value": "desconocido", "field": ".tipo"},
		{"path": ["cartas", 0, "metales"], "value": ["cobre", "cobre"], "field": "metales"},
		{"path": ["cartas", 0, "metales"], "value": ["plata"], "field": "metales"},
		{"path": ["cartas", 0, "ruta_imagen"], "value": "res://assets/cartas/vieja.png", "field": "ruta_imagen"},
		{"path": ["cartas", 0, "ruta_imagen"], "value": "res://assets/images/../secreto.png", "field": "ruta_imagen"},
		{"path": ["cartas", 0, "ruta_imagen"], "value": "res://assets/images/ejecutable.gd", "field": "ruta_imagen"},
		{"path": ["cartas", 0, "fuentes", 0, "id"], "value": "NO-EXISTE", "field": "fuentes.id"},
		{"path": ["fuentes", 0, "ruta"], "value": "res://no_existe.pdf", "field": ".ruta"},
		{"path": ["fuentes", 0, "url"], "value": "http://example.org", "field": ".url"},
		{"path": ["fuentes", 0, "url"], "value": {}, "field": ".url"},
		{"path": ["fuentes", 0, "tipo"], "value": {}, "field": ".tipo"},
		{"path": ["cartas", 0, "metales"], "value": [{}], "field": "metales"},
		{"path": ["cartas", 0, "revision", "estado"], "value": {}, "field": "estado"},
		{"path": ["cartas", 0, "rasgos"], "value": {"posiciones_limpieza": [{}]}, "field": "posiciones_limpieza"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [{"op": "elegir", "min": {}, "max": 1, "opciones": [[{"op": "sin_efecto"}]]}], "field": "elección"},
		{"path": ["cartas", 0, "vinculos"], "value": ["ausente"], "field": "vinculos"},
		{"path": ["cartas", 0, "vinculos"], "value": ["moneda_de_cobre"], "field": "vinculos"},
		{"path": ["cartas", 0, "rasgos"], "value": {"escudos": -1}, "field": "escudos"},
		{"path": ["cartas", 0, "rasgos"], "value": {"posiciones_limpieza": [1, 7]}, "field": "posiciones_limpieza"},
		{"path": ["cartas", 0, "rasgos"], "value": {"posiciones_limpieza": [1, 1]}, "field": "posiciones_limpieza"},
		{"path": ["cartas", 0, "habilidades", 0, "momento"], "value": "inexistente", "field": "momento"},
		{"path": ["cartas", 0, "habilidades", 0, "limite_por_turno"], "value": 0, "field": "limite_por_turno"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [], "field": "efectos"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [{"op": "ejecutar_script", "ruta": "malicioso.gd"}], "field": ".op"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [{"op": "ganar", "recurso": "recursos", "cantidad": -1, "objetivo": "propio"}], "field": "cantidad"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [{"op": "ganar", "recurso": "salud", "cantidad": 1, "objetivo": "propio"}], "field": "recurso"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [{"op": "robar", "cantidad": 1, "objetivo": "inventado"}], "field": "objetivo"},
		{"path": ["cartas", 0, "habilidades", 0, "efectos"], "value": [{"op": "elegir", "min": 2, "max": 1, "opciones": [[{"op": "pendiente", "nota": "falta"}]]}], "field": "elección"},
		{"path": ["cartas", 0, "habilidades", 0, "condicion"], "value": {"op": "metales_quemados", "metales": []}, "field": "metales"},
		{"path": ["cartas", 0, "habilidades", 0, "condicion"], "value": {"op": "todas", "condiciones": []}, "field": "condiciones"},
		{"path": ["cartas", 0, "revision", "estado"], "value": "lista", "field": "estado"},
		{"path": ["cartas", 0, "revision", "idioma_verificado"], "value": "true", "field": "idioma_verificado"},
		{"path": ["cartas", 0, "revision", "estado"], "value": "verificada", "field": "revision"}
	]
	for test_case: Dictionary in cases:
		var document: Dictionary = base.duplicate(true)
		_replace_field(document, test_case["path"], test_case["value"])
		_assert_rejected(validator.validate(document), test_case["field"])
	var unknown: Dictionary = base.duplicate(true)
	unknown["cartas"][0]["coste_comrpa"] = 3
	_assert_rejected(validator.validate(unknown), "coste_comrpa")
	_assert_rejected(validator.validate([]), "objeto")
	_assert_rejected(validator.validate({}), "version_esquema")
	var deep: Dictionary = {"op": "siempre"}
	for index: int in 10:
		deep = {"op": "todas", "condiciones": [deep]}
	var nested: Dictionary = base.duplicate(true)
	nested["cartas"][0]["habilidades"][0]["condicion"] = deep
	_assert_rejected(validator.validate(nested), "profundidad")
	# Recorrer tipos inesperados en campos de carta sin excepciones del validador.
	for field: String in base["cartas"][0]:
		if field in ["cantidad", "coste_compra", "ruta_imagen"]:
			continue
		var malformed: Dictionary = base.duplicate(true)
		malformed["cartas"][0][field] = null
		_assert_rejected(validator.validate(malformed), field)
	await _positive_cases(validator)
	_mission_point_cases(validator)
	_metal_link_cases(validator)
	var database: Node = root.get_node("Database")
	_expect(database.is_loaded and database.get_verified_definitions().is_empty(), "Autoload filtra muestras.")
	var definition: Dictionary = database.get_definition("kelsier")
	definition["revision"]["estado"] = "verificada"
	definition["nombre"] = "MODIFICADO"
	_expect(database.get_definition("kelsier")["nombre"] == "Kelsier", "Copia profunda impide mutar definición.")
	var exposed: Dictionary = database.cartas
	exposed.clear()
	_expect(database.cartas.size() == 2, "Vista heredada también devuelve copia.")
	var invalid_path: String = "res://tmp/test-fixtures/catalog_invalid.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/test-fixtures"))
	var file: FileAccess = FileAccess.open(invalid_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(unknown))
	file.close()
	print("FALLO ESPERADO: esquema inválido del catálogo.")
	_expect(not database.load_cards(invalid_path), "Cargador rechaza error estructural.")
	_expect(database.cartas.is_empty() and database.counts.is_empty() and database.catalog_warnings.is_empty(), "Rechazo atómico limpia estado y avisos.")
	_expect("coste_comrpa" in database.last_error and invalid_path in database.last_error, "Diagnóstico de archivo/campo.")
	_expect(database.load_cards(), "Recuperación con catálogo válido.")
	var large_path: String = "res://tmp/test-fixtures/catalog_too_large.json"
	file = FileAccess.open(large_path, FileAccess.WRITE)
	file.store_string(" ".repeat(4194305))
	file.close()
	print("FALLO ESPERADO: catálogo por encima del límite técnico.")
	_expect(not database.load_cards(large_path), "Límite de bytes comprobado antes del parseo.")
	_expect("4 MiB" in database.last_error, "Diagnóstico de límite técnico.")
	_expect(database.load_cards(), "Recuperación tras archivo demasiado grande.")
	if failures == 0:
		print("P06_CATALOG_OK: ", checks, " comprobaciones de contrato; ningún efecto ejecutado.")
	quit(0 if failures == 0 else 1)


func _mission_point_cases(validator: RefCounted) -> void:
	# Descriptor ficticio: valida forma, nunca admite la carta Perseguir al producto.
	var document: Dictionary = base.duplicate(true)
	document["version_esquema"] = 3
	var card: Dictionary = document["cartas"][0]
	card["tipo"] = "accion"
	card["habilidades"][0]["momento"] = "al_jugar"
	var point: Dictionary = {"op": "ganar", "recurso": "mision", "cantidad": 2, "objetivo": "propio"}
	card["habilidades"][0]["efectos"] = [point, {"op": "ganar", "recurso": "recursos", "cantidad": 2, "objetivo": "propio"}]
	_expect(validator.validate(document)["ok"], "v3 reserva puntos y recursos en orden sin ejecutar efectos.")
	var savant: Dictionary = document.duplicate(true)
	savant["cartas"][0]["habilidades"][0]["momento"] = "metal_quemado"
	_expect(validator.validate(savant)["ok"], "v3 admite reserva por ruta de metal separada.")
	var nested: Dictionary = document.duplicate(true)
	nested["cartas"][0]["habilidades"][0]["efectos"] = [{"op": "elegir", "min": 1, "max": 1, "opciones": [[point]]}]
	_expect(validator.validate(nested)["ok"], "v3 conserva contexto en efectos anidados.")
	for version: int in [1, 2]:
		var legacy: Dictionary = document.duplicate(true)
		legacy["version_esquema"] = version
		_assert_rejected(validator.validate(legacy), ".recurso")
	for invalid_type: String in ["aliado", "funding"]:
		var wrong_type: Dictionary = document.duplicate(true)
		wrong_type["cartas"][0]["tipo"] = invalid_type
		_assert_rejected(validator.validate(wrong_type), ".recurso")
	var mission_type: Dictionary = document.duplicate(true)
	mission_type["cartas"][0]["tipo"] = "mision"
	_assert_rejected(validator.validate(mission_type), ".habilidades")
	for invalid_moment: String in ["al_comprar", "al_entrenar", "reaccion", "continuo"]:
		var wrong_moment: Dictionary = document.duplicate(true)
		wrong_moment["cartas"][0]["habilidades"][0]["momento"] = invalid_moment
		_assert_rejected(validator.validate(wrong_moment), ".recurso")
	for invalid_point: Dictionary in [
		{"op": "ganar", "recurso": "mision", "cantidad": 0, "objetivo": "propio"},
		{"op": "ganar", "recurso": "mision", "cantidad": 2, "objetivo": "rival"},
		{"op": "ganar", "recurso": "mision", "cantidad": 2, "objetivo": "propio", "pista": "mision"},
	]:
		var malformed: Dictionary = document.duplicate(true)
		malformed["cartas"][0]["habilidades"][0]["efectos"] = [invalid_point]
		_assert_rejected(validator.validate(malformed), "efectos")
	for version: int in [1, 2, 3]:
		for wrong_resource: Variant in [{}, [], 2, false]:
			var malformed_resource: Dictionary = document.duplicate(true)
			malformed_resource["version_esquema"] = version
			malformed_resource["cartas"][0]["habilidades"][0]["efectos"] = [{"op": "ganar", "recurso": wrong_resource, "cantidad": 1, "objetivo": "propio"}]
			_assert_rejected(validator.validate(malformed_resource), ".recurso")
	for wrong_target: Variant in [{}, [], 2, false]:
		var malformed_target: Dictionary = document.duplicate(true)
		malformed_target["cartas"][0]["habilidades"][0]["efectos"] = [{"op": "ganar", "recurso": "mision", "cantidad": 1, "objetivo": wrong_target}]
		_assert_rejected(validator.validate(malformed_target), ".objetivo")
	var no_physical: Dictionary = document.duplicate(true)
	no_physical["fuentes"][0]["tipo"] = "reglamento"
	no_physical["cartas"][0]["revision"] = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
	_assert_rejected(validator.validate(no_physical), ".fuentes")
	_expect(validator.validate(base)["ok"], "Recarga de v1 tras rechazos v3.")


func _positive_cases(validator: RefCounted) -> void:
	var draft: Dictionary = base.duplicate(true)
	draft["cartas"][0]["revision"]["estado"] = "borrador"
	draft["cartas"][0]["tipo"] = "sin_clasificar"
	draft["cartas"][0]["cantidad"] = null
	draft["cartas"][0]["resumen"] = {"recurso": null, "ataque": null}
	draft["cartas"][0]["ruta_imagen"] = "res://assets/images/pendiente.png"
	var report: Dictionary = validator.validate(draft)
	_expect(report["ok"] and report["verified"].is_empty(), "Borrador con dudas y cantidades pendientes admitido solo como trabajo.")
	_expect(report["warnings"].size() == 4, "Imagen ausente avisa sin invalidar borrador.")
	# Fixture estructural de test: no es una transcripción oficial.
	var reviewed: Dictionary = base.duplicate(true)
	reviewed["fuentes"][0]["tipo"] = "reglamento"
	reviewed["fuentes"][0]["ruta"] = "res://docs/referencias/fuentes/MistbornRulebook_V1.pdf"
	var card: Dictionary = reviewed["cartas"][0]
	card["tipo"] = "accion"
	card["revision"] = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
	card["vinculos"] = []
	card["habilidades"][0]["momento"] = "al_jugar"
	card["habilidades"][0]["condicion"] = {"op": "metales_quemados", "metales": ["cobre"]}
	card["habilidades"][0]["efectos"] = [
		{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"},
		{"op": "elegir", "min": 0, "max": 1, "opciones": [
			[{"op": "robar", "cantidad": 1, "objetivo": "propio"}],
			[{"op": "curar", "cantidad": 1, "objetivo": "propio"}]
		]}
	]
	card["ruta_imagen"] = "res://assets/images/mist_background.svg"
	report = validator.validate(reviewed)
	_expect(report["ok"] and report["verified"].size() == 1, "Fixture de declaración revisada pasa requisitos estructurales.")
	_expect(report["verified"]["moneda_de_cobre"]["habilidades"][0]["efectos"][0]["op"] == "ganar", "Se conserva orden de efectos.")
	var invalid_review: Dictionary = reviewed.duplicate(true)
	invalid_review["cartas"][0]["vinculos"] = ["kelsier"]
	_assert_rejected(validator.validate(invalid_review), "vinculos")
	invalid_review = reviewed.duplicate(true)
	invalid_review["cartas"][0]["cantidad"] = null
	_assert_rejected(validator.validate(invalid_review), "cantidad")
	invalid_review = reviewed.duplicate(true)
	invalid_review["cartas"][0]["habilidades"][0]["efectos"].append({"op": "pendiente", "nota": "falta contraste"})
	_assert_rejected(validator.validate(invalid_review), "revision")
	invalid_review = reviewed.duplicate(true)
	invalid_review["cartas"][0]["tipo"] = "adversario"
	_assert_rejected(validator.validate(invalid_review), "escudos")
	var tracks: Dictionary = reviewed.duplicate(true)
	tracks["cartas"][0]["tipo"] = "dominacion"
	tracks["cartas"][0]["coste_compra"] = null
	tracks["cartas"][0]["habilidades"] = []
	tracks["cartas"][0]["rasgos"] = {"recorridos": [
		{"id": "cara_a", "casillas": [{"id": "uno", "efectos": [{"op": "sin_efecto"}]}]},
		{"id": "cara_b", "casillas": [{"id": "dos", "efectos": [{"op": "pendiente", "nota": "falta"}]}]}
	]}
	_assert_rejected(validator.validate(tracks), "revision")
	tracks["cartas"][0]["rasgos"]["recorridos"][1]["casillas"][0]["efectos"] = [{"op": "sin_efecto"}]
	_expect(validator.validate(tracks)["ok"], "Recorridos de dos caras y casilla sin efecto representables.")
	var linked_samples: Dictionary = base.duplicate(true)
	linked_samples["cartas"][0]["vinculos"] = ["kelsier"]
	_expect(validator.validate(linked_samples)["ok"], "Referencias válidas entre definiciones de trabajo.")
	for effects: Array in [
		[{"op": "danar", "cantidad": 2, "objetivo": "rival"}],
		[{"op": "avanzar", "pista": "entrenamiento", "cantidad": 1, "objetivo": "propio"}],
		[{"op": "mover_carta", "origen": "mano", "destino": "descarte", "cantidad": 1, "objetivo": "propio"}],
		[{"op": "refrescar_metal", "metal": "cobre", "cantidad": 1, "objetivo": "propio"}]
	]:
		var family: Dictionary = reviewed.duplicate(true)
		family["cartas"][0]["habilidades"][0]["efectos"] = effects
		_expect(validator.validate(family)["ok"], "Familia estructurada admitida sin ejecutar.")
	var packed: PackedScene = load("res://scenes/CardPreview.tscn") as PackedScene
	var view: Control = packed.instantiate() as Control
	root.add_child(view)
	view.set_card(card)
	_expect(view.get_node("Content/Kind").text == "DEFINICIÓN REVISADA", "Vista distingue revisión de muestra.")
	_expect(view.get_node("Content/ImageNote").text == "Ilustración del catálogo", "Ilustración existente se muestra.")
	view.set_card(base["cartas"][0])
	_expect(view.get_node("Content/Kind").text == "CONTENIDO DE PRUEBA", "Vista recupera etiqueta de muestra.")
	_expect(view.get_node("Content/ImageNote").text == "Ilustración pendiente", "Ausencia de arte conserva sustituto.")
	view.queue_free()
	await process_frame


func _metal_link_cases(validator: RefCounted) -> void:
	for operation: String in ["metal_asignado", "esta_carta_como_metal"]:
		var document: Dictionary = base.duplicate(true)
		document.version_esquema = 4
		var card: Dictionary = document.cartas[0]
		card.tipo = "accion"
		card.metales = ["cobre", "bronce"]
		var ability: Dictionary = card.habilidades[0]
		ability.momento = "al_jugar" if operation == "metal_asignado" else "metal_quemado"
		ability.condicion = {"op": operation, "metales": ["bronce"]}
		ability.efectos = [{"op": "ganar", "recurso": "mision", "cantidad": 1, "objetivo": "propio"}]
		_expect(validator.validate(document).ok, "v4 admite vínculo explícito y reserva mision: " + operation)
		for version: int in [1, 2, 3]:
			var old: Dictionary = document.duplicate(true)
			old.version_esquema = version
			_assert_rejected(validator.validate(old), "condicion")
		for metals: Array in [[], ["bronce", "bronce"], ["atium"], [false], ["plata"]]:
			var invalid: Dictionary = document.duplicate(true)
			invalid.cartas[0].habilidades[0].condicion.metales = metals
			_assert_rejected(validator.validate(invalid), "metales")
		var unprinted: Dictionary = document.duplicate(true)
		unprinted.cartas[0].habilidades[0].condicion.metales = ["acero"]
		if operation == "esta_carta_como_metal":
			_assert_rejected(validator.validate(unprinted), "metales")
		else:
			_expect(validator.validate(unprinted).ok, "metal asignado describe el requisito de la primaria")
		var extra: Dictionary = document.duplicate(true)
		extra.cartas[0].habilidades[0].condicion.instancia = "cliente"
		_assert_rejected(validator.validate(extra), "instancia")
		for moment: String in ["metal_quemado" if operation == "metal_asignado" else "al_jugar", "inicio_turno"]:
			var invalid: Dictionary = document.duplicate(true)
			invalid.cartas[0].habilidades[0].momento = moment
			_assert_rejected(validator.validate(invalid), "condicion")
		var wrong_type: Dictionary = document.duplicate(true)
		wrong_type.cartas[0].tipo = "aliado"
		_assert_rejected(validator.validate(wrong_type), "condicion")


func _replace_field(document: Dictionary, path: Array, value: Variant) -> void:
	var parent: Variant = document
	for index: int in path.size() - 1:
		parent = parent[path[index]]
	parent[path[-1]] = value


func _assert_rejected(report: Dictionary, field: String) -> void:
	_expect(not report["ok"], "Debe rechazar: " + field)
	_expect(report["cards"].is_empty() and report["verified"].is_empty(), "Sin catálogo parcial: " + field)
	_expect(field in "\n".join(report["errors"]), "Campo diagnosticado: " + field)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("COMPROBACIÓN FALLIDA: " + message)
