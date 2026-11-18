extends SceneTree

const Validator = preload("res://scripts/catalog/catalog_validator.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var document: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/perseguir.json"))
	_expect(document is Dictionary, "JSON de Perseguir legible.")
	if not document is Dictionary:
		quit(1)
		return
	var validator: RefCounted = Validator.new()
	var result: Dictionary = validator.validate(document)
	_expect(result["ok"], "Definición v3 estructuralmente válida con fuente local.")
	_expect(result["verified"].is_empty(), "Perseguir no aparece entre definiciones verificadas.")
	_expect(result["counts"] == {"muestra": 0, "borrador": 1, "verificada": 0}, "Una carta en borrador.")
	var card: Dictionary = document["cartas"][0]
	_expect(card["id"] == "perseguir" and card["cantidad"] == 1 and card["coste_compra"] == 3, "Identidad, cantidad y coste cotejados.")
	_expect(card["metales"] == ["cobre", "bronce"], "Pareja de metales cotejada.")
	_expect(card["habilidades"].size() == 2, "Primaria y Savant separados.")
	var primary: Array = card["habilidades"][0]["efectos"]
	_expect(primary.size() == 2 and primary[0]["op"] == "ganar" and primary[0]["recurso"] == "mision" and primary[0]["cantidad"] == 2.0 and primary[1]["op"] == "ganar" and primary[1]["recurso"] == "recursos" and primary[1]["cantidad"] == 2.0, "Primaria conserva orden y cantidades.")
	var savant: Array = card["habilidades"][1]["efectos"]
	_expect(savant.size() == 1 and savant[0]["op"] == "ganar" and savant[0]["recurso"] == "mision" and savant[0]["cantidad"] == 1.0, "Savant reserva un punto separado.")
	var missing: Dictionary = document.duplicate(true)
	missing["fuentes"][0]["ruta"] = "res://evidencia_local/src_005/ausente.png"
	_expect(not validator.validate(missing)["ok"], "Fuente ausente rechazada.")
	var tampered: Dictionary = document.duplicate(true)
	tampered["fuentes"][0]["sha256"] = "0".repeat(64)
	_expect(not validator.validate(tampered)["ok"], "Huella alterada rechazada.")
	var old_version: Dictionary = document.duplicate(true)
	old_version["version_esquema"] = 2
	_expect(not validator.validate(old_version)["ok"], "v2 no admite reserva de puntos de misión.")
	if failures == 0:
		print("P08_PERSEGUIR_CATALOG_OK: ", checks, " comprobaciones; ninguna habilidad ejecutada.")
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("PERSEGUIR_CATALOG_FAIL: " + message)
