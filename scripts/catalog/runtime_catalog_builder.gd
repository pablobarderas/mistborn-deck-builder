extends RefCounted
## Autoría exclusivamente; no promueve ni escribe los JSON de trabajo.
const Validator = preload("res://scripts/catalog/catalog_validator.gd")
const Loader = preload("res://scripts/catalog/runtime_catalog_loader.gd")
const Manifest = preload("res://scripts/catalog/runtime_catalog_manifest.gd")


func build(document: Dictionary) -> Dictionary:
	var checked: Dictionary = Validator.new().validate(document)
	if not checked.ok or checked.cards.size() != checked.verified.size() or Loader.digest(document) != Manifest.AUTHORING_DIGEST:
		return {"ok": false, "errors": ["Autoría, fuentes o lista cerrada incompatibles."]}
	var ids: Array = checked.cards.keys()
	ids.sort()
	if ids != Array(Manifest.DEFINITION_IDS):
		return {"ok": false, "errors": ["Definiciones fuera del perfil."]}
	var payload: Dictionary = {"format_version": Manifest.FORMAT_VERSION, "catalog_id": Manifest.CATALOG_ID, "resolver_version": Manifest.RESOLVER_VERSION, "sources": [], "definitions": []}
	for source: Dictionary in document.fuentes:
		payload.sources.append({"id": source.id, "tipo": source.tipo, "sha256": source.sha256})
	for id: String in ids:
		var card: Dictionary = checked.cards[id].duplicate(true)
		card.erase("revision")
		card.erase("ruta_imagen")
		payload.definitions.append(card)
	# Relectura posterior: una fuente cambiada durante la construcción invalida todo.
	if not Validator.new().validate(document).ok:
		return {"ok": false, "errors": ["Las fuentes cambiaron durante la construcción."]}
	payload.digest = Loader.digest(payload)
	if not Loader.new().admit(payload).ok or JSON.stringify(payload, "\t").sha256_text() != Manifest.FILE_SHA256:
		return {"ok": false, "errors": ["El resultado no coincide con el manifiesto de ensayo."]}
	return {"ok": true, "errors": [], "artifact": payload}
