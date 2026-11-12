extends SceneTree

const Validator = preload("res://scripts/catalog/catalog_validator.gd")
const Catalog = preload("res://scripts/Database.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const Start = preload("res://scripts/game/competitive_start.gd")
const FundingFixtures = preload("res://tests/funding_fixtures.gd")
const StartFixtures = preload("res://tests/competitive_start_fixtures.gd")
const LOT_PATH: String = "res://data/misiones.json"
const TEMP_PATH: String = "res://tmp/test-fixtures/mission_catalog_invalid.json"
const SHEET_HASHES: Array[String] = [
	"0185c0d65d2cec7b66070bd08d5cd7d8fe618272be490ed82c725c419346fa9d",
	"3da0cf82f7ccb10cc08afa27ee3f694a8cf51b6c536e153cb21f8db6f5225b5b",
]
const NAMES: Array[String] = ["Cavernas Skaa", "Guarnición de Luthadel", "Fortaleza Venture", "Kredik Shaw",
	"Pozos de Hathsin", "Tejados de Luthadel", "Escondite de la Banda", "Cantón de la Ortodoxia"]
const SHEETS: Array[int] = [1, 1, 1, 2, 2, 1, 2, 2]
const QUADRANTS: Array[String] = ["superior izquierda", "inferior izquierda", "superior derecha", "superior derecha",
	"inferior izquierda", "inferior derecha", "superior izquierda", "inferior derecha"]
const INTERMEDIATE: Array[Dictionary] = [
	{5: "refrescar:1/refrescar:1", 9: "refrescar:1/refrescar:1"},
	{4: "ataque:1/derrotar", 7: "ataque:2/derrotar", 10: "ataque:3/derrotar"},
	{4: "recursos:1/recursos:1", 6: "recursos:1/recursos:1", 8: "recursos:1/recursos:1", 10: "recursos:1/recursos:1"},
	{4: "robar:1/robar:1", 8: "robar:1/robar:1"},
	{4: "recursos:1/recursos:1", 8: "ataque:2/curar:2"},
	{6: "entrenamiento:1/entrenamiento:1"}, {6: "curar:4/curar:2"},
	{5: "eliminar:1/eliminar:1", 9: "eliminar:1/eliminar:1"},
]
const SUMMITS: Array[String] = ["/refrescar:todos/capacidad_quema:1", "/ataque:1/cada_turno:ataque:2",
	"/recursos:3/cada_turno:recursos:2", "/robar:2/mano_nueva:1", "atium:1/atium:1/",
	"entrenamiento:1/entrenamiento:1/", "curar:6/curar:2/", "eliminar:4/eliminar:1/"]

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(LOT_PATH))
	if not value is Dictionary:
		push_error("No se pudo leer el lote de misiones.")
		quit(1)
		return
	var lot: Dictionary = value
	var validator: RefCounted = Validator.new()
	var report: Dictionary = validator.validate(lot)
	if not report.ok:
		push_error("Preparar primero los escaneos de SRC-005. " + " ".join(report.errors))
		quit(1)
		return
	_expect(report.counts == {"muestra": 0, "borrador": 0, "verificada": 8}, "Ocho misiones verificadas.")
	_expect(lot.version_esquema == 2 and lot.id_catalogo == "mistborn_es_misiones", "Sobre del lote.")
	_expect(_matches_sources(lot), "Fuentes, huellas y localizadores coinciden con SRC-005.")
	_check_rewards(report.verified)
	_check_invalid_variants(validator, lot)
	_check_sources(validator, lot)
	_check_profiles(validator, lot)
	_check_loading(lot)
	if failures == 0:
		print("P08_MISSION_CATALOG_OK: ", checks, " comprobaciones de catálogo de misiones.")
	quit(0 if failures == 0 else 1)


func _matches_sources(lot: Dictionary) -> bool:
	if lot.fuentes.size() != 2 or lot.cartas.size() != 8:
		return false
	var sources: Dictionary = {}
	for source: Dictionary in lot.fuentes:
		sources[source.id] = source
	for sheet: int in [1, 2]:
		var source: Dictionary = sources.get("src_005_misiones_%d" % sheet, {})
		if (source.get("ruta") != "res://evidencia_local/src_005/misiones.%d.png" % sheet
			or source.get("sha256") != SHEET_HASHES[sheet - 1] or source.get("tipo") != "carta_fisica"
			or source.get("url", "") != null):
			return false
	var cards: Dictionary = FundingFixtures.definitions(lot)
	for index: int in 8:
		var card: Dictionary = cards.get("mision_m%d" % (index + 1), {})
		if card.get("fuentes") != [{"id": "src_005_misiones_%d" % SHEETS[index],
			"localizador": "M%d, %s" % [index + 1, QUADRANTS[index]]}]:
			return false
	return true


func _check_rewards(cards: Dictionary) -> void:
	for index: int in 8:
		var id: String = "mision_m%d" % (index + 1)
		var card: Dictionary = cards.get(id, {})
		_expect(card.get("nombre") == NAMES[index] and card.get("cantidad") == 1 and card.get("tipo") == "mision",
			"Nombre, tipo y cantidad de " + id)
		if card.is_empty():
			continue
		var cells: Array = _cells(card)
		for position: int in range(1, 13):
			var cell: Dictionary = cells[position - 1]
			var signature: String = _signature(cell.efectos) + "/" + _signature(cell.primero)
			var expected: String = INTERMEDIATE[index].get(position, "/")
			if position == 12:
				signature += "/" + _permanent_signature(cell.permanente)
				expected = SUMMITS[index]
			_expect(signature == expected, "%s p%02d: %s" % [id, position, expected])


func _signature(effects: Array) -> String:
	var parts: PackedStringArray = []
	for effect: Dictionary in effects:
		match effect.op:
			"ganar": parts.append("%s:%d" % [effect.recurso, int(effect.cantidad)])
			"avanzar": parts.append("%s:%d" % [effect.pista, int(effect.cantidad)])
			"refrescar_agotados":
				var quantity: String = effect.cantidad if effect.cantidad is String else str(int(effect.cantidad))
				parts.append("refrescar:" + quantity)
			"derrotar_aliado_en_juego": parts.append("derrotar")
			"eliminar_propias": parts.append("eliminar:%d" % int(effect.maximo))
			_: parts.append("%s:%d" % [effect.op, int(effect.cantidad)])
	return "+".join(parts)


func _permanent_signature(value: Variant) -> String:
	if value == null:
		return ""
	if value.tipo == "cada_turno":
		return "%s:%s:%d" % [value.tipo, value.recurso, int(value.cantidad)]
	return "%s:%d" % [value.tipo, int(value.cantidad)]


func _cells(card: Dictionary) -> Array:
	return card.rasgos.recorridos[0].casillas


func _check_invalid_variants(validator: RefCounted, lot: Dictionary) -> void:
	# Usar una fuente física pequeña de prueba para las mutaciones estructurales.
	var fixture: Dictionary = lot.duplicate(true)
	var path: String = "res://tests/funding_fixtures.gd"
	for source: Dictionary in fixture.fuentes:
		source.ruta = path
		source.sha256 = FileAccess.get_sha256(path)
	for case_id: int in 11:
		var invalid: Dictionary = fixture.duplicate(true)
		var cells: Array = _cells(invalid.cartas[0])
		var field: String
		match case_id:
			0:
				cells.pop_back()
				field = ".casillas"
			1:
				cells[0].id = "p02"
				field = ".id"
			2:
				cells[0].primero = cells[4].primero
				field = ".primero"
			3:
				cells[0].permanente = null
				field = ".permanente"
			4:
				cells[11].permanente = null
				field = ".permanente"
			5:
				cells[11].efectos = cells[4].efectos
				field = ".permanente"
			6:
				cells[4].efectos = [{"op": "sin_efecto"}]
				field = ".op"
			7:
				cells[4].efectos[0].cantidad = 0
				field = ".cantidad"
			8:
				cells[4].efectos = [{"op": "pendiente", "nota": "Fixture"}]
				field = ".revision"
			9:
				cells[0].erase("primero")
				field = ".primero"
			10:
				invalid.cartas[0].fuentes[0].id = "sin_fuente"
				field = ".fuentes.id"
		_reject(validator.validate(invalid), field)
		if case_id == 8:
			invalid.cartas[0].revision.estado = "borrador"
			var draft: Dictionary = validator.validate(invalid)
			_expect(draft.ok and draft.verified.size() == 7 and not draft.verified.has("mision_m1"),
				"Una operación pendiente se admite sólo en borrador.")
	fixture.version_esquema = 1
	for source: Dictionary in fixture.fuentes:
		source.erase("sha256")
	_reject(validator.validate(fixture), ".primero")


func _check_sources(validator: RefCounted, lot: Dictionary) -> void:
	var invalid: Dictionary = lot.duplicate(true)
	invalid.fuentes[0].ruta = "C:/evidencia/externa.png"
	_reject(validator.validate(invalid), ".ruta")
	invalid.fuentes[0].ruta = "res://evidencia_local/ausente.png"
	_reject(validator.validate(invalid), "archivo fuente ausente")
	invalid.fuentes[0].ruta = lot.fuentes[1].ruta
	_reject(validator.validate(invalid), ".sha256")
	invalid.fuentes[0].sha256 = lot.fuentes[1].sha256
	_expect(validator.validate(invalid).ok and not _matches_sources(invalid), "La comprobación del lote rechaza sustitución coordinada.")
	invalid.fuentes[1].ruta = lot.fuentes[0].ruta
	invalid.fuentes[1].sha256 = lot.fuentes[0].sha256
	_expect(validator.validate(invalid).ok and not _matches_sources(invalid), "La comprobación del lote rechaza hojas intercambiadas.")
	invalid.fuentes[0].sha256 = "no-es-una-huella"
	_reject(validator.validate(invalid), ".sha256")
	invalid = lot.duplicate(true)
	invalid.fuentes.append({"id": "sin_referencia", "tipo": 1, "descripcion": "Fixture", "ruta": null, "url": null})
	_reject(validator.validate(invalid), ".tipo")


func _check_profiles(validator: RefCounted, lot: Dictionary) -> void:
	var original: Dictionary = StartFixtures.catalog()
	var training: Dictionary = StartFixtures.training_profile(original)
	_expect(Funding.new(original, StartFixtures.FUNDING_ID, FundingFixtures.inerts(original)).is_supported()
		and Start.new(original, StartFixtures.FUNDING_ID, FundingFixtures.inerts(original), training).is_supported(),
		"Los perfiles ficticios originales son admisibles.")
	var mixed: Dictionary = original.duplicate(true)
	mixed.version_esquema = 2
	mixed.cartas = mixed.cartas.filter(func(card: Dictionary) -> bool: return card.tipo != "mision")
	mixed.fuentes.append(lot.fuentes[0])
	var inerts: Dictionary = FundingFixtures.inerts(mixed)
	_expect(Funding.new(mixed, StartFixtures.FUNDING_ID, inerts).is_supported(), "El perfil v2 de control conserva Funding.")
	training = StartFixtures.training_profile(mixed)
	_expect(Start.new(mixed, StartFixtures.FUNDING_ID, inerts, training).is_supported(), "El perfil v2 de control conserva el inicio.")
	mixed.cartas.append(lot.cartas[0])
	inerts = FundingFixtures.inerts(mixed)
	_expect(validator.validate(mixed).ok, "La misión añadida es válida en el catálogo v2 de control.")
	_expect(not Funding.new(mixed, StartFixtures.FUNDING_ID, inerts).is_supported(), "Funding rechaza la misión con premios.")
	_expect(not Start.new(mixed, StartFixtures.FUNDING_ID, inerts, training).is_supported(), "Inicio aislado rechaza la misión con premios.")


func _check_loading(lot: Dictionary) -> void:
	var startup: Node = root.get_node("Database")
	var loader: Node = Catalog.new()
	_expect(startup.is_loaded and startup.cartas.size() == 2, "El arranque sigue cargando dos muestras.")
	_expect(loader.load_cards(LOT_PATH) and loader.get_verified_definitions().size() == 8, "Carga explícita del lote.")
	var missing: Dictionary = lot.duplicate(true)
	missing.fuentes[0].ruta = "res://evidencia_local/ausente.png"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TEMP_PATH.get_base_dir()))
	var file: FileAccess = FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		_expect(false, "Crear catálogo negativo de prueba.")
		loader.free()
		return
	file.store_string(JSON.stringify(missing))
	file.close()
	print("FALLO ESPERADO: falta una fuente física en el catálogo de prueba.")
	_expect(not loader.load_cards(TEMP_PATH) and loader.cartas.is_empty() and loader.counts.is_empty()
		and loader.get_verified_definitions().is_empty(), "El fallo de fuente vacía la carga explícita.")
	_expect(loader.load_cards(LOT_PATH) and loader.get_verified_definitions().size() == 8, "Recuperación con fuente válida.")
	_expect(startup.is_loaded and startup.cartas.size() == 2, "La carga explícita no altera el catálogo de arranque.")
	loader.free()
	DirAccess.remove_absolute(TEMP_PATH)


func _reject(report: Dictionary, field: String) -> void:
	_expect(not report.ok and report.cards.is_empty() and report.verified.is_empty()
		and field in " ".join(report.errors), "Rechazo atómico con diagnóstico de " + field)


func _expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
