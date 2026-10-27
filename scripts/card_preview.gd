extends PanelContainer


func set_card(card: Dictionary) -> void:
	%Name.text = str(card.get("nombre", card.get("id", "Carta")))
	%Effect.text = str(card.get("efecto", "Sin descripción."))
	%Stats.text = "Coste %s · Recurso %s · Ataque %s" % [
		_display_stat(card.get("coste_compra", "—")),
		_display_stat(card.get("generacion_recurso", "—")),
		_display_stat(card.get("poder_ataque", "—"))
	]
	$Content/Mark.text = %Name.text.left(1).to_upper()


func _display_stat(value: Variant) -> String:
	# Godot representa los números JSON como float; mostrar enteros sin ".0".
	if value is float and value == floor(value):
		return "%.0f" % value
	return str(value)
