extends RefCounted
## Comprueba el lote inicial de autoría. No admite borradores a una partida.

const STARTERS: Dictionary = {
	"kelsier": ["kelsier_estano", "kelsier_cobre", "kelsier_cinc", "kelsier_acero"],
	"marsh": ["marsh_bronce", "marsh_hierro", "marsh_peltre", "marsh_laton"],
	"shan": ["shan_cinc", "shan_estano", "shan_cobre", "shan_acero"],
	"vin": ["vin_bronce", "vin_hierro", "vin_laton", "vin_peltre"],
}


static func check_authoring(definitions: Variant, manifest: Variant) -> bool:
	if not definitions is Dictionary or not manifest is Dictionary or not manifest.has("characters") \
		or not manifest.characters is Array or manifest.characters.size() != STARTERS.size() \
		or manifest.get("funding_id") != "financiacion" or manifest.get("training_track_id") != "pista_entrenamiento":
		return false
	if not _card(definitions, "financiacion", "funding", 24, []) \
		or not _card(definitions, "pista_entrenamiento", "pista_entrenamiento", 4, []):
		return false
	var seen: Dictionary = {}
	for entry: Variant in manifest.characters:
		if not entry is Dictionary or entry.size() != 2 or not entry.has("character_id") \
			or not entry.has("starters") or not entry.character_id is String \
			or not STARTERS.has(entry.character_id) or seen.has(entry.character_id) \
			or not entry.starters is Array or entry.starters.size() != 4:
			return false
		var id: String = entry.character_id
		seen[id] = true
		if not _card(definitions, id, "personaje", 1, STARTERS[id]) \
			or not _same_set(entry.starters, STARTERS[id]):
			return false
		for starter: String in STARTERS[id]:
			if not _card(definitions, starter, "entrenamiento", 1, [id]):
				return false
	return seen.size() == STARTERS.size()


static func _card(definitions: Dictionary, id: String, kind: String, quantity: int, links: Array) -> bool:
	var card: Variant = definitions.get(id)
	return card is Dictionary and card.get("id") == id and card.get("tipo") == kind \
		and (card.get("cantidad") is int or card.get("cantidad") is float) and card.cantidad == quantity \
		and card.get("vinculos") is Array and _same_set(card.vinculos, links)


static func _same_set(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	var seen: Dictionary = {}
	for id: Variant in actual:
		if not id is String or id not in expected or seen.has(id):
			return false
		seen[id] = true
	return true
