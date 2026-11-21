extends RefCounted
## Frontera de ejecución: nunca consulta originales ni admite JSON de autoría.
const Manifest = preload("res://scripts/catalog/runtime_catalog_manifest.gd")
const Canonical = preload("res://scripts/game/funding_play.gd")
const Keys = preload("res://scripts/game/sequence_registry.gd")
const MAX_BYTES: int = 4194304
var _document: Dictionary = {}


static func digest(value: Variant) -> String:
	return _canonical(value).sha256_text()


static func _canonical(value: Variant) -> String:
	# JSON integral y Variant int comparten identidad; los decimales nunca se
	# truncan: hacerlo permitiría adulterar cantidades sin cambiar el digest.
	if value is float and (not is_finite(value) or value != float(int(value))):
		return "float:" + JSON.stringify(value)
	if value is Dictionary:
		var names: Array = value.keys()
		names.sort()
		var result: String = "d["
		for name: String in names:
			result += _canonical(name) + _canonical(value[name])
		return result + "]"
	if value is Array:
		var result: String = "a["
		for item: Variant in value:
			result += _canonical(item)
		return result + "]"
	return Canonical._canonical_content(value)


func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "errors": ["Artefacto ausente."]}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {"ok": false, "errors": ["Artefacto ilegible o demasiado grande."]}
	var raw: PackedByteArray = file.get_buffer(file.get_length())
	var hashing := HashingContext.new()
	# Fija los bytes completos, incluidas claves duplicadas ignoradas por JSON.
	if hashing.start(HashingContext.HASH_SHA256) != OK or hashing.update(raw) != OK or hashing.finish().hex_encode() != Manifest.FILE_SHA256:
		return {"ok": false, "errors": ["Archivo no admitido por autoridad."]}
	return admit(JSON.parse_string(raw.get_string_from_utf8()))


func admit(value: Variant) -> Dictionary:
	# La huella se compara con código de autoridad, nunca con una propuesta cliente.
	if not value is Dictionary or _plain_tree(value) < 0 or not Keys.exact_keys(value, ["format_version", "catalog_id", "resolver_version", "sources", "definitions", "digest"]):
		return {"ok": false, "errors": ["Formato de ejecución incompatible."]}
	var payload: Dictionary = value.duplicate(true)
	payload.erase("digest")
	if value.format_version != Manifest.FORMAT_VERSION or value.catalog_id != Manifest.CATALOG_ID or value.resolver_version != Manifest.RESOLVER_VERSION or value.digest != Manifest.PAYLOAD_DIGEST or digest(payload) != Manifest.PAYLOAD_DIGEST:
		return {"ok": false, "errors": ["Identidad no admitida por autoridad."]}
	# El digest fija también esquema, IDs, metadatos y ausencia de rutas/bytes.
	var document: Dictionary = {"version_esquema": 4, "id_catalogo": Manifest.CATALOG_ID + "_" + Manifest.PAYLOAD_DIGEST, "idioma": "es", "fuentes": value.sources.duplicate(true), "cartas": value.definitions.duplicate(true)}
	for card: Dictionary in document.cartas:
		card["revision"] = {"estado": "verificada", "idioma_verificado": true, "dudas": []}
		card["ruta_imagen"] = null
	_document = document
	return {"ok": true, "errors": [], "document": _document.duplicate(true)}


static func _plain_tree(value: Variant, depth: int = 0) -> int:
	if depth > 32:
		return -1
	if value == null or value is String or value is bool:
		return 1
	if value is int or value is float:
		return 1 if is_finite(float(value)) and abs(float(value)) <= 9007199254740991.0 and float(value) == float(int(value)) else -1
	if not value is Array and not value is Dictionary:
		return -1
	var nodes: int = 1
	for item: Variant in value:
		if value is Dictionary and not item is String and not item is StringName:
			return -1
		var size: int = _plain_tree(value[item] if value is Dictionary else item, depth + 1)
		if size < 0:
			return -1
		nodes += size
		if nodes > 50000:
			return -1
	return nodes


func get_document() -> Dictionary:
	return _document.duplicate(true)
