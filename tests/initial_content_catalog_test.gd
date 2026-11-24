extends SceneTree
## Verifica el lote físico de autoría sin admitirlo a producto ni ejecutar efectos.

const Validator = preload("res://scripts/catalog/catalog_validator.gd")
const Bindings = preload("res://scripts/catalog/initial_competitive_bindings.gd")
const OWNERS: Array[String] = ["kelsier", "marsh", "shan", "vin"]
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var document: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/inicio_competitivo.json"))
	_expect(document is Dictionary, "Documento de autoría legible.")
	if not document is Dictionary:
		quit(1)
		return
	var validator: RefCounted = Validator.new()
	var result: Dictionary = validator.validate(document)
	_expect(result.ok, "Estructura v5 y fuentes locales admitidas.")
	if not result.ok:
		push_error("INICIO_CATALOG_FAIL: " + str(result.errors))
		quit(1)
		return
	_expect(document.version_esquema == 5 and document.fuentes.size() == 6 and result.cards.size() == 22,
		"Seis fuentes y 22 definiciones exactas.")
	_expect(result.verified.is_empty() and result.counts.borrador == 22,
		"Ningún borrador se promociona por validar estructura.")
	for owner: String in OWNERS:
		var character: Dictionary = result.cards[owner]
		_expect(character.tipo == "personaje" and character.cantidad == 1 and character.vinculos.size() == 4,
			"Personaje y sus cuatro cartas: " + owner)
		for id: String in character.vinculos:
			var training: Dictionary = result.cards.get(id, {})
			_expect(id.begins_with(owner + "_") and training.get("tipo") == "entrenamiento"
				and training.get("cantidad") == 1 and training.get("vinculos") == [owner]
				and training.get("metales", []).size() == 2,
				"Training pertenece sólo a su personaje: " + id)
	_expect(result.cards.financiacion.cantidad == 24 and result.cards.financiacion.metales.is_empty(),
		"Seis Financiación por cuatro plazas, sin metal.")
	_expect(result.cards.pista_entrenamiento.cantidad == 4
		and result.cards.pista_entrenamiento.rasgos.recorridos[0].casillas.size() == 21,
		"Cuatro pistas de 21 huecos.")
	var manifest: Dictionary = {"characters": [], "funding_id": "financiacion", "training_track_id": "pista_entrenamiento"}
	for owner: String in OWNERS:
		manifest.characters.append({"character_id": owner, "starters": result.cards[owner].vinculos.duplicate()})
	_expect(Bindings.check_authoring(result.cards, manifest), "Vínculos exactos de las cuatro agrupaciones.")
	var wrong_owner: Dictionary = manifest.duplicate(true)
	wrong_owner.characters[0].starters[0] = result.cards.marsh.vinculos[0]
	_expect(not Bindings.check_authoring(result.cards, wrong_owner), "Carta ajena del mismo tipo rechazada.")
	var duplicate: Dictionary = manifest.duplicate(true)
	duplicate.characters[0].starters[0] = duplicate.characters[0].starters[1]
	_expect(not Bindings.check_authoring(result.cards, duplicate), "Duplicado del mismo propietario rechazado.")
	var changed_quantity: Dictionary = result.cards.duplicate(true)
	changed_quantity.financiacion.cantidad = 23
	_expect(not Bindings.check_authoring(changed_quantity, manifest), "Cantidad física alterada rechazada.")
	var missing_character: Dictionary = manifest.duplicate(true)
	missing_character.characters[0].character_id = "vin"
	_expect(not Bindings.check_authoring(result.cards, missing_character), "Personaje repetido rechazado.")
	for card: Dictionary in result.cards.values():
		_expect(card.ruta_imagen == null, "El borrador no incorpora PNG: " + card.id)
	var tampered: Dictionary = document.duplicate(true)
	tampered.fuentes[0].sha256 = "0".repeat(64)
	_expect(not validator.validate(tampered).ok, "Se rechaza una fuente distinta.")
	var old: Dictionary = document.duplicate(true)
	old.version_esquema = 4
	_expect(not validator.validate(old).ok, "v4 no interpreta el lote v5.")
	if failures == 0:
		print("P08_INITIAL_CONTENT_CATALOG_OK: ", checks, " comprobaciones; sin ejecución de cartas.")
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("INICIO_CATALOG_FAIL: " + message)
