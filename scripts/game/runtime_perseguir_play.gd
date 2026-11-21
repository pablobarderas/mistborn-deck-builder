extends "res://scripts/game/perseguir_play.gd"
## Perfil aislado de ensayo: no está registrado en Database, escenas ni producto.
const Loader = preload("res://scripts/catalog/runtime_catalog_loader.gd")
const Training = preload("res://scripts/game/training_advance.gd")
var _admitted_document: Dictionary = {}
var _admitted_inert: Dictionary = {}


func _init(artifact_path: String) -> void:
	var loaded: Dictionary = Loader.new().load_file(artifact_path)
	var document: Dictionary = loaded.get("document", {})
	_admitted_document = document.duplicate(true)
	_admitted_inert = document.duplicate(true)
	var cards: Array = []
	var inerts: Dictionary = {}
	var missions: Dictionary = {}
	for card: Dictionary in document.get("cartas", []):
		if card.id == "perseguir":
			continue
		if card.tipo == "mision":
			missions[card.id] = card.duplicate(true)
		else:
			inerts[card.id] = card.duplicate(true)
		var inert: Dictionary = card.duplicate(true)
		if inert.tipo != "mision":
			inert.metales = []
		cards.append(inert)
	_admitted_inert.cartas = cards
	var training: Dictionary = {"catalog_id": identity_for(document), "track_id": "test_training_track", "definition": inerts.get("test_training_track", {}), "marks": Array(Training.PANEL)}
	super(document, inerts, training, missions)


func _validate_catalog(catalog: Dictionary) -> Dictionary:
	var valid: bool = not _admitted_document.is_empty() and (catalog == _admitted_document or catalog == _admitted_inert)
	var cards: Dictionary = {}
	if valid:
		for card: Dictionary in catalog.cartas:
			cards[card.id] = card.duplicate(true)
	return {"ok": valid, "cards": cards, "verified": cards.duplicate(true)}
