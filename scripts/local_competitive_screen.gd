extends Control
## Mesa local E2: solo envía intenciones a la autoridad. El pase oculta la mano.

const Play = preload("res://scripts/game/local_competitive_play.gd")
const Fixtures = preload("res://tests/local_competitive_fixtures.gd")
const GOLD: Color = Color("#d1b57e")
const MUTED: Color = Color("#aebbc2")

var _play: RefCounted
var _match_index: int = 0
var _action_index: int = 0
var _covered: bool = false
var _message: String = ""
var _count: SpinBox
var _body: VBoxContainer


func _ready() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color("#111b24")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin: MarginContainer = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.custom_minimum_size.x = maxf(0.0, size.x - 16.0)
	resized.connect(func() -> void: margin.custom_minimum_size.x = maxf(0.0, size.x - 16.0))
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	scroll.add_child(margin)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 12)
	margin.add_child(_body)
	_render()


func _label(parent: Node, value: String, size: int = 16, color: Color = MUTED) -> Label:
	var item: Label = Label.new()
	item.text = value
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	item.add_theme_color_override("font_color", color)
	parent.add_child(item)
	return item


func _button(parent: Node, value: String, callback: Callable) -> Button:
	var item: Button = Button.new()
	item.text = value
	item.pressed.connect(callback)
	parent.add_child(item)
	return item


func _row(parent: Node) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	return row


func _render() -> void:
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	_label(_body, "MISTBORN  /  PARTIDA LOCAL", 27, GOLD)
	_label(_body, "Ensayo E2 con cartas iniciales provisionales y mercado de prueba. Solo en este equipo.", 14)
	if _play == null:
		_render_setup()
		return
	var state: Dictionary = _play.get_authority_snapshot()
	if state.is_empty():
		_label(_body, "La partida no tiene estado válido.", 16)
		return
	if state.outcome != null:
		(get_child(1) as ScrollContainer).scroll_vertical = 0
		var winner: String = _player_name(state.players, state.outcome.winner_id)
		var reason: String = {"tres_misiones": "completó las tres misiones", "ultimo_superviviente": "quedó como único superviviente"}.get(state.outcome.reason, "alcanzó la victoria")
		_label(_body, "Partida terminada · gana %s: %s." % [winner, reason], 23, GOLD)
		_button(_body, "Nueva partida", func() -> void:
			_play = null
			_render())
		return
	var actor: String = state.turn.active_id
	if _covered:
		_label(_body, "Pasa el equipo a %s. Su mano permanece oculta." % _player_name(state.players, actor), 22, GOLD)
		_button(_body, "Soy %s · mostrar mi turno" % _player_name(state.players, actor), func() -> void:
			_covered = false
			_render())
		return
	var view: Dictionary = _play.get_view(actor)
	if view.is_empty():
		_label(_body, "No se pudo abrir la vista privada.", 16)
		return
	_label(_body, "Turno %d · %s · fase %s" % [state.turn.number, _player_name(view.players, actor), state.turn.phase], 21, GOLD)
	_button(_body, "Ocultar mano", func() -> void:
		_covered = true
		_render())
	if not _message.is_empty():
		_label(_body, _message, 15, Color("#e5a399"))
	var active: Dictionary = _player(view, actor)
	_label(_body, "Salud %d  ·  monedas %d  ·  combate %d  ·  misión %d  ·  entrenamiento %d" % [active.health, active.turn_resources.recursos, active.turn_resources.ataque, active.turn_resources.mision, active.training], 16)
	_label(_body, "Boxings %d  ·  Atium %d  ·  Target: %s" % [active.persistent.boxings, active.persistent.atium, "sin objetivo" if view.target_id == null else _player_name(view.players, view.target_id)], 15)
	match state.turn.phase:
		"inicio":
			_button(_body, "Iniciar turno", func() -> void: _send("iniciar_turno", {"turn_number": state.turn.number}, true))
		"libre":
			_render_free(view, actor)
		"combate":
			_render_combat(view, actor)
		"limpieza":
			_button(_body, "Cerrar turno y pasar equipo", func() -> void: _send("cerrar_limpieza", {"turn_number": state.turn.number}, false, true))
		_:
			_label(_body, "Fase pendiente: " + state.turn.phase)
	_render_table(view, actor)
	_button(_body, "Volver al inicio", func() -> void: get_tree().change_scene_to_file("res://scenes/MainScreen.tscn"))


func _render_setup() -> void:
	var row: HBoxContainer = _row(_body)
	_label(row, "Personas", 17)
	_count = SpinBox.new()
	_count.min_value = 2
	_count.max_value = 4
	_count.value = 2
	row.add_child(_count)
	_button(_body, "Preparar partida", _prepare)
	if not _message.is_empty():
		_label(_body, _message, 15, Color("#e5a399"))
	_button(_body, "Volver", func() -> void: get_tree().change_scene_to_file("res://scenes/MainScreen.tscn"))


func _prepare() -> void:
	_match_index += 1
	_action_index = 0
	(get_child(1) as ScrollContainer).scroll_vertical = 0
	var count: int = int(_count.value)
	_play = Play.new(Fixtures.catalog(), Fixtures.manifest())
	if not _play.is_supported():
		_message = "No se pudo admitir el contenido de ensayo."
		_play = null
		_render()
		return
	var seed: int = Fixtures.supported_seed(count)
	var result: Dictionary = _play.prepare_match("e2_local_%d" % _match_index, Fixtures.seats(count), "p1", seed)
	if not result.ok:
		_message = "Preparación rechazada: " + str(result.get("codigo", "error"))
		_play = null
	else:
		_message = ""
		_covered = true
	_render()


func _render_table(view: Dictionary, actor: String) -> void:
	_label(_body, "Mesa", 20, GOLD)
	for player: Dictionary in view.players:
		_label(_body, "%s  ·  %s  ·  salud %d  ·  %s" % [player.name, player.character_id, player.health, "eliminado" if player.eliminated else "en juego"], 14)
	var market: Dictionary = view.zones.get("mercado", {})
	var market_cards: Array = market.get("cards", [])
	_label(_body, "Mercado · %d cartas" % market_cards.size(), 16, GOLD)
	for card: Dictionary in market_cards:
		var definition: Dictionary = Fixtures.definition(card.definition_id)
		var row: HBoxContainer = _row(_body)
		_label(row, "%s · coste %s · %s" % [definition.get("nombre", card.definition_id), str(definition.get("coste_compra", "?")), _card_effect(definition)], 14)
		if view.turn.phase == "libre":
			_button(row, "Comprar", func() -> void: _send("comprar_carta", {"instance_id": card.instance_id, "nivel_ii": false}))
			_button(row, "Comprar + nivel II", func() -> void: _send("comprar_carta", {"instance_id": card.instance_id, "nivel_ii": true}))
	_label(_body, "Misiones", 16, GOLD)
	for mission_id: String in view.missions:
		var mission: Dictionary = view.missions[mission_id]
		var progress: int = int(mission.progress.get(actor, 0))
		var mission_definition: Dictionary = Fixtures.definition(mission.definition_id)
		var line: String = "%s  ·  %d/12" % [mission_definition.get("nombre", mission.definition_id), progress]
		for opponent: String in view.player_order:
			if opponent != actor:
				line += "  ·  %s %d" % [_player_name(view.players, opponent), mission.progress.get(opponent, 0)]
		if progress < 12:
			line += _next_mission_reward(mission_definition, mission, progress)
		var row: HBoxContainer = _row(_body)
		_label(row, line, 14)
		if view.turn.phase == "libre":
			_button(row, "Avanzar", func() -> void: _send("avanzar_mision", {"mission_id": mission_id}))


func _render_free(view: Dictionary, actor: String) -> void:
	_label(_body, "Tu mano", 20, GOLD)
	var hand: Array = view.zones.get(actor + "_mano", {}).get("cards", [])
	for card: Dictionary in hand:
		var definition: Dictionary = Fixtures.definition(card.definition_id)
		var row: HBoxContainer = _row(_body)
		_label(row, definition.get("nombre", card.definition_id) + " · " + _card_effect(definition), 15)
		if card.definition_id == "financiacion":
			_button(row, "Jugar", func() -> void: _send("jugar_funding", {"instance_id": card.instance_id, "aplicar": true}))
		elif definition.get("tipo") in ["entrenamiento", "accion"]:
			_button(row, "Jugar sin quemar", func() -> void: _send(_play_kind(definition), {"instance_id": card.instance_id, "aplicar": false, "metal": null, "origen": {}}))
			_render_burn_controls(card, definition, view, actor)
	var player: Dictionary = _player(view, actor)
	var signature: String = Play.SIGNATURES.get(player.character_id, "?")
	var level_one: Array = Play._signature_gains(player.character_id)
	_label(_body, "Nivel I (entrenamiento 5): tras quemar %s, %s. Nivel II (8): primaria al comprar y eliminar la carta. Nivel III (13): tras quemar Atium, +3 combate y +3 misión." % [signature, _gains_label(level_one)], 13)
	var row: HBoxContainer = _row(_body)
	_button(row, "Habilidad I", func() -> void: _send("activar_personaje", {"nivel": 1, "aplicar": true}))
	_button(row, "Habilidad III", func() -> void: _send("activar_personaje", {"nivel": 3, "aplicar": true}))
	_button(row, "Entrar en combate", func() -> void: _send("entrar_combate", {}))
	var boxings: HBoxContainer = _row(_body)
	if player.turn_resources.recursos >= 2:
		_button(boxings, "Comprar Boxing · 2 monedas", func() -> void: _send("comprar_boxing", {}))
	if player.persistent.boxings >= 1:
		_button(boxings, "Canjear Boxing · +1 moneda", func() -> void: _send("canjear_boxing", {}))
	_render_metal_controls(view, actor)


func _render_burn_controls(card: Dictionary, definition: Dictionary, view: Dictionary, actor: String) -> void:
	var row: HBoxContainer = _row(_body)
	var primary: String = definition.habilidades[0].condicion.metales[0]
	_label(row, "Activar %s · quemar %s" % [definition.get("nombre", card.definition_id), primary], 13)
	var source: OptionButton = OptionButton.new()
	for token: Dictionary in _player(view, actor).metals:
		if token.metal in [primary, "atium"] and not token.exhausted and not token.used_this_turn:
			source.add_item("Ficha " + token.metal)
			source.set_item_metadata(source.item_count - 1, {"tipo": "ficha", "id": token.token_id})
			if token.metal != "atium":
				source.add_item("Fulgurar " + token.metal)
				source.set_item_metadata(source.item_count - 1, {"tipo": "fulgurar", "id": token.token_id})
	for fuel: Dictionary in view.zones.get(actor + "_mano", {}).get("cards", []):
		if fuel.instance_id != card.instance_id and primary in Fixtures.definition(fuel.definition_id).get("metales", []):
			source.add_item("Carta " + Fixtures.definition(fuel.definition_id).get("nombre", fuel.definition_id))
			source.set_item_metadata(source.item_count - 1, {"tipo": "carta", "id": fuel.instance_id})
	row.add_child(source)
	_button(row, "Jugar + quemar", func() -> void:
		if source.item_count == 0:
			_message = "No hay fuente de metal disponible."
			_render()
			return
		_send(_play_kind(definition), {"instance_id": card.instance_id, "aplicar": true, "metal": primary, "origen": source.get_item_metadata(source.selected)}))


func _render_metal_controls(view: Dictionary, actor: String) -> void:
	_label(_body, "Metales", 16, GOLD)
	var tokens: Array = _player(view, actor).metals
	var exhausted: Array = []
	for token: Dictionary in tokens:
		_label(_body, "%s · %s" % [token.metal.capitalize(), "agotado" if token.exhausted else ("usado este turno" if token.used_this_turn else "disponible")], 13)
		var row: HBoxContainer = _row(_body)
		if not token.exhausted and not token.used_this_turn:
			_button(row, "Quemar", func() -> void: _send("quemar_metal", {"metal": token.metal, "origen": {"tipo": "ficha", "id": token.token_id}}))
			if token.metal != "atium":
				_button(row, "Fulgurar", func() -> void: _send("quemar_metal", {"metal": token.metal, "origen": {"tipo": "fulgurar", "id": token.token_id}}))
		if token.exhausted:
			exhausted.append(token)
	if not exhausted.is_empty():
		var refresh: HBoxContainer = _row(_body)
		var token_choice: OptionButton = OptionButton.new()
		for token: Dictionary in exhausted:
			token_choice.add_item(token.metal)
			token_choice.set_item_metadata(token_choice.item_count - 1, token.token_id)
		refresh.add_child(token_choice)
		var card_choice: OptionButton = OptionButton.new()
		for card: Dictionary in view.zones.get(actor + "_mano", {}).get("cards", []):
			card_choice.add_item(card.definition_id)
			card_choice.set_item_metadata(card_choice.item_count - 1, card.instance_id)
		refresh.add_child(card_choice)
		_button(refresh, "Refrescar con carta", func() -> void:
			if card_choice.item_count == 0:
				_message = "Necesitas una carta para refrescar."
				_render()
				return
			_send("refrescar_metal", {"instance_id": card_choice.get_item_metadata(card_choice.selected), "token_id": token_choice.get_item_metadata(token_choice.selected)}))


func _render_combat(view: Dictionary, actor: String) -> void:
	_label(_body, "Combate", 20, GOLD)
	var combat: Dictionary = view.get("combat", {})
	if combat.get("awaiting_target", false):
		_label(_body, "Recibiste daño. Elige conservar o pasar Target.", 15)
		_button(_body, "Conservar Target", func() -> void: _send("pasar_target", {"target_id": null}))
		for player: Dictionary in view.players:
			if player.player_id != actor and not player.eliminated:
				_button(_body, "Pasar Target a " + player.name, func() -> void: _send("pasar_target", {"target_id": player.player_id}))
		return
	if combat.get("resolved", false):
		_button(_body, "Entrar en limpieza", func() -> void: _send("entrar_limpieza", {}))
		return
	_label(_body, "Elige daño. Si eliminas al portador de Target, escribe los nombres de los siguientes portadores separados por comas.", 14)
	var row: HBoxContainer = _row(_body)
	var damage: SpinBox = SpinBox.new()
	var active: Dictionary = _player(view, actor)
	var to_damage: int = int(active.turn_resources.ataque)
	_damage_setup(damage, to_damage)
	if view.target_id == actor:
		damage.min_value = to_damage
	row.add_child(damage)
	var order: LineEdit = LineEdit.new()
	order.custom_minimum_size.x = 320
	order.placeholder_text = "Jugador 2, Jugador 3"
	row.add_child(order)
	_button(row, "Resolver combate", func() -> void:
		var ids: Array[String] = []
		if not order.text.strip_edges().is_empty():
			for raw: String in order.text.split(",", false):
				ids.append(_player_id(view.players, raw.strip_edges()))
		_send("resolver_combate", {"damage": int(damage.value), "target_order": ids, "pass_target_id": null}))


func _damage_setup(input: SpinBox, maximum: int) -> void:
	input.min_value = 0
	input.max_value = maximum
	input.value = maximum


func _send(kind: String, payload: Dictionary, starting: bool = false, cleanup: bool = false) -> void:
	var state: Dictionary = _play.get_authority_snapshot()
	var previous_actor: String = state.turn.active_id
	_action_index += 1
	var prefix: String = "inicio_" if starting else ("limpieza_" if cleanup else "ui_")
	var intent: Dictionary = Fixtures.intent(state, prefix + str(_action_index), kind, payload)
	var result: Dictionary
	if starting:
		result = _play.start_turn(state.turn.active_id, intent)
	elif cleanup:
		result = _play.finish_cleanup(state.turn.active_id, intent)
	else:
		result = _play.submit(state.turn.active_id, intent)
	_message = "" if result.ok else _error_message(str(result.get("codigo", "error")))
	if result.ok and (cleanup or _play.get_authority_snapshot().turn.active_id != previous_actor):
		_covered = true
	_render()


func _player(view: Dictionary, id: String) -> Dictionary:
	for player: Dictionary in view.players:
		if player.player_id == id:
			return player
	return {}


func _play_kind(definition: Dictionary) -> String:
	return "jugar_entrenamiento" if definition.tipo == "entrenamiento" else "jugar_accion"


func _player_name(players: Array, id: String) -> String:
	for player: Dictionary in players:
		if player.player_id == id:
			return player.name
	return id


func _player_id(players: Array, name: String) -> String:
	for player: Dictionary in players:
		if player.name.to_lower() == name.to_lower() or player.player_id == name:
			return player.player_id
	return name


func _card_effect(definition: Dictionary) -> String:
	if definition.get("id") == "financiacion":
		return "+1 moneda"
	var abilities: Array = definition.get("habilidades", [])
	if abilities.is_empty():
		return "sin efecto de prueba"
	var primary: Dictionary = abilities[0]
	var condition: Dictionary = primary.get("condicion", {})
	var metals: Array = condition.get("metales", [])
	var metal_labels: PackedStringArray = PackedStringArray()
	for value: Variant in metals:
		metal_labels.append(str(value))
	var requirement: String = " · quemar " + "/".join(metal_labels) if not metals.is_empty() else ""
	var effect: String = _effects_summary(primary.get("efectos", []))
	return (effect if not effect.is_empty() else "sin efecto de prueba") + requirement


func _effects_summary(effects: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for effect: Dictionary in effects:
		if effect.get("op") == "ganar":
			var resource: String = {"recursos": "moneda", "ataque": "combate", "mision": "misión", "atium": "Atium"}.get(effect.get("recurso", ""), str(effect.get("recurso", "")))
			parts.append("+%d %s" % [effect.get("cantidad", 0), resource])
		elif effect.get("op") == "curar":
			parts.append("+%d salud" % effect.get("cantidad", 0))
		elif effect.get("op") == "avanzar":
			parts.append("+%d entrenamiento" % effect.get("cantidad", 0))
	return ", ".join(parts)


func _next_mission_reward(definition: Dictionary, mission: Dictionary, progress: int) -> String:
	var cells: Array = definition.rasgos.recorridos[0].casillas
	for index: int in range(progress, cells.size()):
		var cell: Dictionary = cells[index]
		var reward: String = _effects_summary(cell.get("efectos", []))
		var first: String = _effects_summary(cell.get("primero", [])) if mission.first_arrivals.get(cell.id) == null else ""
		if not reward.is_empty() or not first.is_empty():
			var result: String = " · premio en %d: %s" % [index + 1, reward]
			if not first.is_empty():
				result += " · primero: " + first
			return result
	return ""


func _gains_label(gains: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for index: int in mini(gains.size(), 4):
		if int(gains[index]) > 0:
			parts.append("+%d %s" % [gains[index], ["moneda", "combate", "misión", "salud"][index]])
	return ", ".join(parts)


func _error_message(code: String) -> String:
	return {
		"accion_ilegal": "Esa acción no está disponible ahora. Comprueba recursos, fase y carta elegida.",
		"eleccion_invalida": "La elección no es válida. Revisa los objetivos o metales seleccionados.",
		"formato_invalido": "Faltan datos para esa acción. Revisa la selección.",
		"revision_obsoleta": "La mesa cambió. Repite la acción con la vista actual.",
		"accion_no_soportada": "Esa acción no está disponible en este ensayo.",
		"estado_invalido": "La partida no pudo aplicar la acción. Puedes continuar desde el estado anterior.",
		"identidad_no_autorizada": "Esta plaza no puede actuar ahora."
	}.get(code, "No se pudo aplicar la acción. Revisa la selección e inténtalo de nuevo.")
