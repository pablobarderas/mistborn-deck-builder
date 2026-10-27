extends RefCounted
## Paleta de la propuesta P05, adaptada visualmente de SRC-001.

const BG: Color = Color("101923")
const SURFACE: Color = Color("182430")
const RAISED: Color = Color("20303e")
const LINE: Color = Color("354654")
const TEXT: Color = Color("eeeae1")
const MUTED: Color = Color("a7b5c1")
const GOLD: Color = Color("d4b77a")
const BLUE: Color = Color("9cc8e4")
const GREEN: Color = Color("7ebba8")
const METALS: Array[Dictionary] = [
	{"name": "Peltre", "mark": "Pe", "color": Color("ce8894")},
	{"name": "Estaño", "mark": "Es", "color": Color("d67b84")},
	{"name": "Bronce", "mark": "Br", "color": Color("68b6a1")},
	{"name": "Cobre", "mark": "Cu", "color": Color("d69b72")},
	{"name": "Zinc", "mark": "Zn", "color": Color("d5d1b9")},
	{"name": "Latón", "mark": "La", "color": Color("d4b77a")},
	{"name": "Hierro", "mark": "Fe", "color": Color("75b7dd")},
	{"name": "Acero", "mark": "Ac", "color": Color("d5e4ee")}
]
const ATLAS: Texture2D = preload("res://assets/images/board/concept-atlas.png")


static func box(color: Color, border: Color = Color.TRANSPARENT, radius: int = 10, padding: int = 12) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style


static func art(index: int) -> AtlasTexture:
	var texture: AtlasTexture = AtlasTexture.new()
	texture.atlas = ATLAS
	var half: Vector2 = ATLAS.get_size() / 2.0
	texture.region = Rect2(Vector2(index % 2, index / 2) * half, half)
	return texture


static func font(serif: bool = false) -> SystemFont:
	var result: SystemFont = SystemFont.new()
	result.font_names = PackedStringArray(["Georgia", "Cambria"] if serif else ["Segoe UI"])
	return result


static func theme() -> Theme:
	var result: Theme = Theme.new()
	result.default_font = font()
	result.default_font_size = 15
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_color", "Button", TEXT)
	result.set_color("font_hover_color", "Button", TEXT)
	result.set_color("font_pressed_color", "Button", BG)
	result.set_color("font_disabled_color", "Button", Color("83909a"))
	result.set_stylebox("normal", "Button", box(RAISED, LINE, 8, 10))
	result.set_stylebox("hover", "Button", box(Color("2c4051"), BLUE, 8, 10))
	result.set_stylebox("pressed", "Button", box(BLUE, BLUE, 8, 10))
	result.set_stylebox("disabled", "Button", box(SURFACE, LINE, 8, 10))
	result.set_stylebox("focus", "Button", box(Color.TRANSPARENT, GOLD, 8, 0))
	return result
