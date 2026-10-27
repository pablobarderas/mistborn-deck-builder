extends PanelContainer

var _artwork: TextureRect


func set_card(card: Dictionary) -> void:
	%Name.text = str(card.get("nombre", card.get("id", "Carta")))
	%Effect.text = str(card.get("texto_original", "Sin descripción."))
	var summary: Dictionary = card.get("resumen", {})
	%Stats.text = "Coste %s · Recurso %s · Ataque %s" % [
		_display_stat(card.get("coste_compra", "—")),
		_display_stat(summary.get("recurso", "—")),
		_display_stat(summary.get("ataque", "—"))
	]
	$Content/Mark.text = %Name.text.left(1).to_upper()
	var state: String = card.get("revision", {}).get("estado", "borrador")
	$Content/Kind.text = {"muestra": "CONTENIDO DE PRUEBA", "borrador": "BORRADOR · SIN VERIFICAR", "verificada": "DEFINICIÓN REVISADA"}[state]
	if _artwork == null:
		_artwork = TextureRect.new()
		_artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Content/Mark.add_child(_artwork)
	var image_path: Variant = card.get("ruta_imagen")
	_artwork.texture = null
	if image_path is String and image_path.begins_with("res://assets/images/") and ResourceLoader.exists(image_path, "Texture2D"):
		_artwork.texture = load(image_path) as Texture2D
	_artwork.visible = _artwork.texture != null
	$Content/Mark.custom_minimum_size.y = 82
	if _artwork.visible:
		$Content/Mark.text = ""
	$Content/ImageNote.text = "Ilustración del catálogo" if _artwork.visible else "Ilustración pendiente"


func _display_stat(value: Variant) -> String:
	if value == null:
		return "—"
	# Godot representa los números JSON como float; mostrar enteros sin ".0".
	if value is float and value == floor(value):
		return "%.0f" % value
	return str(value)
