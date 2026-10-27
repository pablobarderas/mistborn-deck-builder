extends Button
## Componente visual: emite selección, nunca aplica reglas.

const Palette = preload("res://scripts/board/board_style.gd")
var card: Dictionary = {}
var is_selected: bool = false
var _content: VBoxContainer


func setup(data: Dictionary, card_size: Vector2 = Vector2(136, 190)) -> void:
	card = data.duplicate(true)
	custom_minimum_size = card_size
	clip_contents = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "%s · %s · Pulsa para ampliar" % [card["name"], card["metal"]]
	add_theme_stylebox_override("normal", Palette.box(Palette.SURFACE, Palette.LINE, 9, 0))
	add_theme_stylebox_override("hover", Palette.box(Palette.RAISED, Palette.BLUE, 9, 0))
	add_theme_stylebox_override("pressed", Palette.box(Palette.RAISED, Palette.GOLD, 9, 0))
	add_theme_stylebox_override("focus", Palette.box(Color.TRANSPARENT, Palette.GOLD, 9, 0))
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 5)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(_content)
	var header: HBoxContainer = HBoxContainer.new()
	_content.add_child(header)
	var name_label: Label = _label(card["name"], 14, Palette.TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.add_child(name_label)
	var cost: Label = _label(card["cost"], 15, Palette.GOLD)
	header.add_child(cost)
	var artwork: TextureRect = TextureRect.new()
	artwork.texture = Palette.art(int(card["art"]))
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.custom_minimum_size = Vector2(0, card_size.y - 91)
	artwork.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(artwork)
	var type_label: Label = _label("%s · %s" % [card["kind"], card["metal"]], 11, card["color"])
	type_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_content.add_child(type_label)
	_content.add_child(_label(card["value"], 14, Palette.TEXT))
	_ignore_mouse(_content)
	pressed.connect(func() -> void: set_selected(true))


func set_selected(selected: bool) -> void:
	is_selected = selected
	add_theme_stylebox_override("normal", Palette.box(Palette.RAISED if selected else Palette.SURFACE, Palette.GOLD if selected else Palette.LINE, 9, 0))


func _label(value: String, font_size: int, color: Color) -> Label:
	var result: Label = Label.new()
	result.text = value
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	return result


func _ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_ignore_mouse(child)
