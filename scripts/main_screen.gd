extends Control

const CardView = preload("res://scripts/card_preview.gd")
const CARD_SCENE: PackedScene = preload("res://scenes/CardPreview.tscn")
const SUCCESS_COLOR: Color = Color("#a8c1b5")
const ERROR_COLOR: Color = Color("#e5a399")

@onready var cards: HBoxContainer = %Cards
@onready var card_count: Label = %CardCount
@onready var status_label: Label = %StatusLabel
@onready var error_label: Label = %ErrorLabel


func _ready() -> void:
	Database.catalog_loaded.connect(_on_catalog_loaded)
	Database.catalog_failed.connect(_on_catalog_failed)
	_render_catalog()


func _render_catalog() -> void:
	for child: Node in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	error_label.visible = not Database.is_loaded
	if not Database.is_loaded:
		card_count.text = "Sin contenido"
		status_label.text = "No se pudo comprobar el catálogo."
		status_label.add_theme_color_override("font_color", ERROR_COLOR)
		error_label.text = Database.last_error
		return
	var sample_count: int = int(Database.counts.get("muestra", 0))
	card_count.text = "%d cartas de prueba" % sample_count if sample_count == Database.cartas.size() else "%d definiciones" % Database.cartas.size()
	status_label.text = "Catálogo comprobado · %d muestras · %d borradores · %d verificadas." % [
		Database.counts.get("muestra", 0), Database.counts.get("borrador", 0), Database.counts.get("verificada", 0)
	]
	if not Database.catalog_warnings.is_empty():
		status_label.text += "\n%d avisos de contenido o ilustración pendiente." % Database.catalog_warnings.size()
	status_label.tooltip_text = "\n".join(Database.catalog_warnings)
	status_label.add_theme_color_override("font_color", SUCCESS_COLOR)
	for card: Dictionary in Database.cartas.values():
		var preview: CardView = CARD_SCENE.instantiate() as CardView
		if preview == null:
			push_error("No se pudo instanciar la vista de una carta.")
			continue
		cards.add_child(preview)
		preview.set_card(card)


func _on_catalog_loaded(_count: int) -> void:
	_render_catalog()


func _on_catalog_failed(_message: String) -> void:
	_render_catalog()


func _on_reload_pressed() -> void:
	Database.load_cards()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_connection_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ConnectionScreen.tscn")


func _on_board_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/BoardPreview.tscn")
