extends RefCounted
## Valida estructura y revisión declarada; no ejecuta texto ni efectos.

const VERSION: int = 1
const MAX_DEPTH: int = 8
const MAX_NUMBER: int = 1000000
const TYPES: Array[String] = ["muestra", "sin_clasificar", "funding", "entrenamiento", "accion", "aliado", "personaje", "mision", "edicto", "adversario", "rival", "dominacion", "pista_entrenamiento"]
const METALS: Array[String] = ["peltre", "estano", "bronce", "cobre", "zinc", "laton", "hierro", "acero"]
const TARGETS: Array[String] = ["propio", "jugador", "oponente", "oponentes", "rival", "adversario", "aliado"]
const ZONES: Array[String] = ["mano", "mazo", "descarte", "juego", "mercado", "eliminadas"]
const MOMENTS: Array[String] = ["pendiente", "al_jugar", "al_comprar", "metal_quemado", "al_entrenar", "al_progresar", "reaccion", "continuo", "resolver_rival"]

var _errors: PackedStringArray = []
var _warnings: PackedStringArray = []
var _sources: Dictionary = {}


func validate(document: Variant) -> Dictionary:
	_errors.clear()
	_warnings.clear()
	_sources.clear()
	var cards: Dictionary = {}
	var verified: Dictionary = {}
	var counts: Dictionary = {"muestra": 0, "borrador": 0, "verificada": 0}
	if not _shape(document, ["version_esquema", "id_catalogo", "idioma", "fuentes", "cartas"], [], "$catalogo"):
		return _result(cards, verified, counts)
	if not _integer(document["version_esquema"], 1) or document["version_esquema"] != VERSION:
		_error("version_esquema", "versión no admitida; se requiere 1")
	_identifier(document["id_catalogo"], "id_catalogo")
	_enum(document["idioma"], ["es"], "idioma")
	if _array(document["fuentes"], "fuentes", 1, 256):
		for index: int in document["fuentes"].size():
			_validate_source(document["fuentes"][index], "fuentes[%d]" % index)
	if _array(document["cartas"], "cartas", 1, 512):
		for index: int in document["cartas"].size():
			var entry: Variant = document["cartas"][index]
			var before: int = _errors.size()
			_validate_card(entry, "cartas[%d]" % index)
			if before != _errors.size():
				continue
			var id: String = entry["id"]
			if cards.has(id):
				_error("cartas[%d].id" % index, "id duplicado '%s'" % id)
				continue
			cards[id] = entry.duplicate(true)
			var state: String = entry["revision"]["estado"]
			counts[state] += 1
			if state == "verificada":
				verified[id] = entry.duplicate(true)
			else:
				_warnings.append("Carta %s: estado %s; excluida del catálogo verificado." % [id, state])
	for id: String in cards:
		for linked: String in cards[id]["vinculos"]:
			if linked == id or not cards.has(linked):
				_error("carta[%s].vinculos" % id, "referencia inexistente o a sí misma '%s'" % linked)
			elif cards[id]["revision"]["estado"] == "verificada" and cards[linked]["revision"]["estado"] != "verificada":
				_error("carta[%s].vinculos" % id, "carta verificada depende de una definición sin verificar")
	return _result(cards, verified, counts)


func _result(cards: Dictionary, verified: Dictionary, counts: Dictionary) -> Dictionary:
	return {"ok": _errors.is_empty(), "errors": _errors.duplicate(), "warnings": _warnings.duplicate(), "cards": cards if _errors.is_empty() else {}, "verified": verified if _errors.is_empty() else {}, "counts": counts if _errors.is_empty() else {}}


func _validate_source(value: Variant, at: String) -> void:
	if not _shape(value, ["id", "tipo", "descripcion", "ruta", "url"], [], at):
		return
	if not _text(value["id"], at + ".id", 64):
		return
	var id: String = value["id"]
	if _sources.has(id):
		_error(at + ".id", "fuente duplicada '%s'" % id)
	if not _enum(value["tipo"], ["muestra", "reglamento", "errata", "carta_fisica", "editorial"], at + ".tipo"):
		return
	_text(value["descripcion"], at + ".descripcion", 2000)
	if value["ruta"] != null:
		if _safe_path(value["ruta"], at + ".ruta", "res://") and not FileAccess.file_exists(value["ruta"]):
			_error(at + ".ruta", "archivo fuente ausente")
	if value["url"] != null:
		if not _text(value["url"], at + ".url", 2048) or not String(value["url"]).begins_with("https://"):
			_error(at + ".url", "se requiere una URL https")
	if value["tipo"] != "muestra" and value["ruta"] == null and value["url"] == null:
		_error(at, "fuente real sin archivo ni URL")
	if value["tipo"] == "carta_fisica" and value["ruta"] == null:
		_error(at + ".ruta", "una carta física necesita su foto/escaneo local")
	_sources[id] = value


func _validate_card(value: Variant, at: String) -> void:
	if not _shape(value, ["id", "nombre", "tipo", "cantidad", "coste_compra", "texto_original", "resumen", "metales", "ruta_imagen", "fuentes", "revision", "vinculos", "rasgos", "habilidades"], [], at):
		return
	_identifier(value["id"], at + ".id")
	at += "(%s)" % str(value["id"])
	_text(value["nombre"], at + ".nombre", 160)
	if not _enum(value["tipo"], TYPES, at + ".tipo"):
		return
	if value["cantidad"] != null:
		_number(value["cantidad"], at + ".cantidad", 1)
	if value["coste_compra"] != null:
		_number(value["coste_compra"], at + ".coste_compra")
	_text(value["texto_original"], at + ".texto_original", 16000)
	if _shape(value["resumen"], ["recurso", "ataque"], [], at + ".resumen"):
		for key: String in ["recurso", "ataque"]:
			if value["resumen"][key] != null:
				_number(value["resumen"][key], at + ".resumen." + key)
	if _string_list(value["metales"], at + ".metales", 8):
		for metal: String in value["metales"]:
			_enum(metal, METALS, at + ".metales")
	_validate_image(value["ruta_imagen"], at + ".ruta_imagen")
	_string_list(value["vinculos"], at + ".vinculos", 128)
	var has_real_source: bool = false
	if _array(value["fuentes"], at + ".fuentes", 1, 64):
		for ref: Variant in value["fuentes"]:
			if _shape(ref, ["id", "localizador"], [], at + ".fuentes"):
				_text(ref["localizador"], at + ".fuentes.localizador", 2000)
				if not ref["id"] is String or not _sources.has(ref["id"]):
					_error(at + ".fuentes.id", "fuente no declarada")
				elif _sources[ref["id"]]["tipo"] != "muestra":
					has_real_source = true
	_validate_traits(value["rasgos"], at + ".rasgos")
	if _array(value["habilidades"], at + ".habilidades", 0, 32):
		var ability_ids: Dictionary = {}
		for index: int in value["habilidades"].size():
			var ability: Variant = value["habilidades"][index]
			var ability_at: String = at + ".habilidades[%d]" % index
			if not _shape(ability, ["id", "momento", "condicion", "limite_por_turno", "efectos"], [], ability_at):
				continue
			if _identifier(ability["id"], ability_at + ".id"):
				if ability_ids.has(ability["id"]):
					_error(ability_at + ".id", "habilidad duplicada")
				ability_ids[ability["id"]] = true
			_enum(ability["momento"], MOMENTS, ability_at + ".momento")
			if ability["limite_por_turno"] != null:
				_number(ability["limite_por_turno"], ability_at + ".limite_por_turno", 1)
			_condition(ability["condicion"], ability_at + ".condicion", 0)
			_effects(ability["efectos"], ability_at + ".efectos", 0)
	if not _shape(value["revision"], ["estado", "idioma_verificado", "dudas"], [], at + ".revision"):
		return
	var review: Dictionary = value["revision"]
	if not _enum(review["estado"], ["muestra", "borrador", "verificada"], at + ".revision.estado"):
		return
	if not review["idioma_verificado"] is bool:
		_error(at + ".revision.idioma_verificado", "se requiere booleano")
		return
	if not _string_list(review["dudas"], at + ".revision.dudas", 128):
		return
	if review["estado"] == "verificada":
		if not has_real_source or review["idioma_verificado"] != true or review["dudas"] != [] or _has_pending(value):
			_error(at + ".revision", "verificada exige fuente real, idioma revisado, ninguna duda ni operación/momento pendiente")
		if value["tipo"] in ["muestra", "sin_clasificar"]:
			_error(at + ".tipo", "una muestra o carta sin clasificar no puede declararse verificada")
		_validate_verified_traits(value, at)


func _validate_image(value: Variant, at: String) -> void:
	if value == null:
		_warnings.append(at + ": ilustración pendiente; usar sustituto visual.")
		return
	if not _safe_path(value, at, "res://assets/images/"):
		return
	if not String(value).get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "svg"]:
		_error(at, "extensión visual no admitida")
	elif not ResourceLoader.exists(value, "Texture2D"):
		_warnings.append(at + ": recurso ausente; usar sustituto visual.")


func _validate_traits(value: Variant, at: String) -> void:
	if not _shape(value, [], ["salud", "escudos", "posiciones_limpieza", "recorridos"], at):
		return
	for key: String in ["salud", "escudos"]:
		if value.has(key):
			_number(value[key], at + "." + key)
	if value.has("posiciones_limpieza") and _array(value["posiciones_limpieza"], at + ".posiciones_limpieza", 0, 6):
		var seen: Dictionary = {}
		for position: Variant in value["posiciones_limpieza"]:
			if not _integer(position, 1, 6) or seen.has(position):
				_error(at + ".posiciones_limpieza", "posiciones únicas entre 1 y 6")
			seen[position] = true
	if value.has("recorridos") and _array(value["recorridos"], at + ".recorridos", 0, 8):
		var tracks: Dictionary = {}
		for track: Variant in value["recorridos"]:
			if not _shape(track, ["id", "casillas"], [], at + ".recorridos"):
				continue
			if _identifier(track["id"], at + ".recorridos.id"):
				if tracks.has(track["id"]):
					_error(at, "recorrido duplicado")
				tracks[track["id"]] = true
			if _array(track["casillas"], at + ".casillas", 1, 64):
				var cells: Dictionary = {}
				for cell: Variant in track["casillas"]:
					if not _shape(cell, ["id", "efectos"], [], at + ".casillas"):
						continue
					if _identifier(cell["id"], at + ".casillas.id"):
						if cells.has(cell["id"]):
							_error(at, "casilla duplicada")
						cells[cell["id"]] = true
					_effects(cell["efectos"], at + ".casillas.efectos", 0)


func _validate_verified_traits(card: Dictionary, at: String) -> void:
	if card["cantidad"] == null:
		_error(at + ".cantidad", "carta verificada sin cantidad confirmada")
	if card["tipo"] in ["accion", "aliado"] and card["coste_compra"] == null:
		_error(at + ".coste_compra", "carta de mercado verificada sin coste confirmado")
	if not card["rasgos"] is Dictionary or not card["habilidades"] is Array:
		return
	var traits: Dictionary = card["rasgos"]
	var tracks: Variant = traits.get("recorridos", [])
	if card["habilidades"].is_empty() and (not tracks is Array or tracks.is_empty()):
		_error(at, "carta verificada sin habilidades ni recorridos")
	if card["tipo"] == "adversario" and not traits.has("escudos"):
		_error(at + ".rasgos.escudos", "adversario verificado sin escudos")
	if card["tipo"] == "rival" and not traits.has("salud"):
		_error(at + ".rasgos.salud", "rival verificado sin salud")
	if card["tipo"] in ["mision", "dominacion", "pista_entrenamiento"]:
		if not tracks is Array or tracks.is_empty() or (card["tipo"] == "dominacion" and tracks.size() != 2):
			_error(at + ".rasgos.recorridos", "recorrido requerido; Dominación requiere dos caras")
	if card["tipo"] in ["personaje", "mision", "edicto", "adversario", "rival", "dominacion", "pista_entrenamiento"] and card["coste_compra"] != null:
		_error(at + ".coste_compra", "este tipo no usa coste de compra")


func _condition(value: Variant, at: String, depth: int) -> void:
	if depth > MAX_DEPTH:
		_error(at, "profundidad máxima excedida")
		return
	if not value is Dictionary or not value.get("op") is String:
		_error(at, "condición debe ser objeto con op textual")
		return
	match value["op"]:
		"siempre":
			_shape(value, ["op"], [], at)
		"pendiente":
			if _shape(value, ["op", "nota"], [], at):
				_text(value["nota"], at + ".nota", 2000)
		"metales_quemados":
			if _shape(value, ["op", "metales"], [], at) and _string_list(value["metales"], at + ".metales", 8):
				if value["metales"].is_empty():
					_error(at, "condición sin metales")
				for metal: String in value["metales"]:
					_enum(metal, METALS, at + ".metales")
		"todas", "alguna":
			if _shape(value, ["op", "condiciones"], [], at) and _array(value["condiciones"], at + ".condiciones", 1, 16):
				for child: Variant in value["condiciones"]:
					_condition(child, at + ".condiciones", depth + 1)
		_:
			_error(at + ".op", "condición desconocida")


func _effects(value: Variant, at: String, depth: int) -> void:
	if depth > MAX_DEPTH:
		_error(at, "profundidad máxima excedida")
		return
	if not _array(value, at, 1, 64):
		return
	for index: int in value.size():
		var effect: Variant = value[index]
		var effect_at: String = at + "[%d]" % index
		if not effect is Dictionary or not effect.get("op") is String:
			_error(effect_at, "efecto debe ser objeto con op textual")
			continue
		match effect["op"]:
			"sin_efecto":
				_shape(effect, ["op"], [], effect_at)
			"pendiente":
				if _shape(effect, ["op", "nota"], [], effect_at):
					_text(effect["nota"], effect_at + ".nota", 2000)
			"ganar", "robar", "curar", "danar", "avanzar", "mover_carta", "refrescar_metal":
				var required: Array = ["op", "cantidad", "objetivo"]
				match effect["op"]:
					"ganar": required.append("recurso")
					"avanzar": required.append("pista")
					"mover_carta": required.append_array(["origen", "destino"])
					"refrescar_metal": required.append("metal")
				if not _shape(effect, required, [], effect_at):
					continue
				_number(effect["cantidad"], effect_at + ".cantidad", 1)
				_enum(effect["objetivo"], TARGETS, effect_at + ".objetivo")
				if effect.has("recurso"):
					_enum(effect["recurso"], ["recursos", "ataque", "atium", "boxings"], effect_at + ".recurso")
				if effect.has("pista"):
					_enum(effect["pista"], ["entrenamiento", "mision", "dominacion"], effect_at + ".pista")
				if effect.has("metal"):
					_enum(effect["metal"], METALS, effect_at + ".metal")
				if effect.has("origen"):
					_enum(effect["origen"], ZONES, effect_at + ".origen")
					_enum(effect["destino"], ZONES, effect_at + ".destino")
			"elegir":
				if not _shape(effect, ["op", "min", "max", "opciones"], [], effect_at):
					continue
				if _array(effect["opciones"], effect_at + ".opciones", 1, 16):
					if not _integer(effect["min"], 0, effect["opciones"].size()) or not _integer(effect["max"], 1, effect["opciones"].size()) or effect["min"] > effect["max"]:
						_error(effect_at, "límites de elección inválidos")
					for option: Variant in effect["opciones"]:
						_effects(option, effect_at + ".opciones", depth + 1)
			_:
				_error(effect_at + ".op", "operación desconocida; declarar pendiente si falta modelarla")


func _has_pending(value: Variant, depth: int = 0) -> bool:
	if depth > MAX_DEPTH + 16:
		return true
	if value is Dictionary:
		var operation: Variant = value.get("op")
		var moment: Variant = value.get("momento")
		if (operation is String and operation == "pendiente") or (moment is String and moment == "pendiente"):
			return true
		for child: Variant in value.values():
			if _has_pending(child, depth + 1):
				return true
	elif value is Array:
		for child: Variant in value:
			if _has_pending(child, depth + 1):
				return true
	return false


func _shape(value: Variant, required: Array, optional: Array, at: String) -> bool:
	if not value is Dictionary:
		_error(at, "se esperaba un objeto; el array legado necesita migración explícita")
		return false
	var valid: bool = true
	for key: String in required:
		if not value.has(key):
			_error(at + "." + key, "campo obligatorio ausente")
			valid = false
	for key: Variant in value:
		if not key in required and not key in optional:
			_error(at + "." + str(key), "campo desconocido")
			valid = false
	return valid


func _array(value: Variant, at: String, minimum: int, maximum: int) -> bool:
	if not value is Array or value.size() < minimum or value.size() > maximum:
		_error(at, "se requiere array con %d–%d elementos" % [minimum, maximum])
		return false
	return true


func _string_list(value: Variant, at: String, maximum: int) -> bool:
	if not _array(value, at, 0, maximum):
		return false
	var seen: Dictionary = {}
	var valid: bool = true
	for item: Variant in value:
		if not _text(item, at, 2000):
			valid = false
		elif seen.has(item):
			_error(at, "valor duplicado")
			valid = false
		else:
			seen[item] = true
	return valid


func _text(value: Variant, at: String, maximum: int) -> bool:
	if not value is String or value.is_empty() or value != value.strip_edges() or value.length() > maximum:
		_error(at, "texto no vacío, sin espacios exteriores, máximo %d caracteres" % maximum)
		return false
	return true


func _identifier(value: Variant, at: String) -> bool:
	if not _text(value, at, 80):
		return false
	var expression: RegEx = RegEx.new()
	expression.compile("^[a-z][a-z0-9_]*$")
	if expression.search(value) == null:
		_error(at, "identificador debe usar minúsculas ASCII, cifras y guion bajo")
		return false
	return true


func _enum(value: Variant, values: Array, at: String) -> bool:
	if not value is String or not value in values:
		_error(at, "valor fuera de enumeración")
		return false
	return true


func _integer(value: Variant, minimum: int = 0, maximum: int = MAX_NUMBER) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(float(value)) and value >= minimum and value <= maximum


func _number(value: Variant, at: String, minimum: int = 0) -> void:
	if not _integer(value, minimum):
		_error(at, "se requiere entero entre %d y %d" % [minimum, MAX_NUMBER])


func _safe_path(value: Variant, at: String, prefix: String) -> bool:
	if not _text(value, at, 512):
		return false
	if not value.begins_with(prefix) or ".." in value or "\\" in value or value.trim_prefix("res://").contains(":"):
		_error(at, "ruta debe permanecer dentro de %s" % prefix)
		return false
	return true


func _error(at: String, message: String) -> void:
	_errors.append(at + ": " + message + ".")
