extends SceneTree
## Recorrido visible de la mesa local; requiere render gráfico.

const Fixtures = preload("res://tests/local_competitive_fixtures.gd")

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("La revisión visual E2 requiere renderizador gráfico.")
		quit(1)
		return
	change_scene_to_file("res://scenes/MainScreen.tscn")
	await process_frame
	await process_frame
	current_scene.get_node("%LocalGameButton").pressed.emit()
	await process_frame
	await process_frame
	var screen: Control = current_scene as Control
	_expect(screen != null and screen.name == "LocalCompetitive", "Entrada desde inicio a mesa local.")
	if screen == null:
		quit(1)
		return
	await _capture("e2-setup.png")
	screen._prepare()
	_expect(screen._play != null and screen._covered, "Preparación oculta la primera mano.")
	await _capture("e2-pass.png")
	screen._covered = false
	screen._render()
	var state: Dictionary = screen._play.get_authority_snapshot()
	_expect(state.turn.phase == "inicio", "La mesa comienza antes del inicio del turno.")
	screen._send("iniciar_turno", {"turn_number": state.turn.number}, true)
	state = screen._play.get_authority_snapshot()
	_expect(state.turn.phase == "libre", "La pantalla inicia un turno real.")
	var hand: Array = state.zones["p1_mano"].cards
	for id: String in hand:
		if state.instances[id].definition_id == "financiacion":
			screen._send("jugar_funding", {"instance_id": id, "aplicar": true})
			break
	_expect(screen._play.get_authority_snapshot().revision >= 2, "La pantalla envía una carta de mano.")
	await _capture("e2-turn.png")
	var before_error: Dictionary = screen._play.get_authority_snapshot()
	screen._send("comprar_carta", {"instance_id": "ausente", "nivel_ii": false})
	_expect(screen._play.get_authority_snapshot() == before_error and screen._message.contains("acción"), "Rechazo visible y estado intacto.")
	await _capture("e2-error.png")
	var scrolling: ScrollContainer = screen.get_child(1) as ScrollContainer
	scrolling.scroll_vertical = 100000
	await process_frame
	_expect(scrolling.scroll_vertical > 0, "La parte inferior del turno es accesible.")
	await _capture("e2-bottom.png")
	root.size = Vector2i(1024, 640)
	await process_frame
	await process_frame
	await _capture("e2-compact.png")
	root.size = Vector2i(1280, 800)
	screen._send("entrar_combate", {})
	await _capture("e2-combat.png")
	screen._send("resolver_combate", {"damage": 0, "target_order": [], "pass_target_id": null})
	screen._send("entrar_limpieza", {})
	state = screen._play.get_authority_snapshot()
	_expect(state.turn.phase == "limpieza", "La pantalla ofrece cierre de combate.")
	screen._send("cerrar_limpieza", {"turn_number": state.turn.number}, false, true)
	state = screen._play.get_authority_snapshot()
	_expect(state.turn.active_id == "p2" and screen._covered, "El pase oculta la mano de la siguiente plaza.")
	await _capture("e2-next-pass.png")
	screen._play = null
	screen._render()
	screen._count.value = 3
	screen._prepare()
	_expect(screen._play != null and screen._play.get_authority_snapshot().target_id != null, "Preparación de tres plazas crea Target.")
	screen._covered = false
	screen._render()
	state = screen._play.get_authority_snapshot()
	screen._send("iniciar_turno", {"turn_number": state.turn.number}, true)
	screen._send("entrar_combate", {})
	await _capture("e2-target-combat.png")
	await _win_from_screen(screen)
	if failures == 0:
		print("E2_LOCAL_SCREEN_OK: ", checks, " comprobaciones y diez capturas.")
	quit(0 if failures == 0 else 1)


func _win_from_screen(screen: Control) -> void:
	screen._play = null
	screen._render()
	screen._count.value = 2
	screen._prepare()
	screen._covered = false
	for unused: int in 100:
		var state: Dictionary = screen._play.get_authority_snapshot()
		if state.lifecycle == "finalizada" or failures > 0:
			break
		var owner: String = state.turn.active_id
		screen._send("iniciar_turno", {"turn_number": state.turn.number}, true)
		if owner == "p1":
			state = screen._play.get_authority_snapshot()
			var hand: Array = state.zones[owner + "_mano"].cards.duplicate()
			for id: String in hand:
				if state.instances[id].definition_id == "financiacion":
					screen._send("jugar_funding", {"instance_id": id, "aplicar": true})
			for id: String in hand:
				state = screen._play.get_authority_snapshot()
				if id not in state.zones[owner + "_mano"].cards:
					continue
				var definition: Dictionary = Fixtures.definition(state.instances[id].definition_id)
				if definition.get("tipo") not in ["entrenamiento", "accion"]:
					continue
				var metal: String = definition.habilidades[0].condicion.metales[0]
				var origin: Dictionary = {}
				for player: Dictionary in state.players:
					if player.player_id == owner:
						for token: Dictionary in player.metals:
							if token.metal == metal and not token.used_this_turn and not token.exhausted:
								origin = {"tipo": "ficha", "id": token.token_id}
								break
					if not origin.is_empty():
						break
				var kind: String = "jugar_entrenamiento" if definition.tipo == "entrenamiento" else "jugar_accion"
				screen._send(kind, {"instance_id": id, "aplicar": not origin.is_empty(), "metal": metal if not origin.is_empty() else null, "origen": origin})
		state = screen._play.get_authority_snapshot()
		var coins: int = 0
		var attack: int = 0
		for player: Dictionary in state.players:
			if player.player_id == owner:
				coins = player.turn_resources.recursos
				attack = player.turn_resources.ataque
		if owner == "p1" and coins >= 2:
			var chosen: String = state.zones.mercado.cards[0]
			for id: String in state.zones.mercado.cards:
				if state.instances[id].definition_id == "e2_combate":
					chosen = id
					break
			screen._send("comprar_carta", {"instance_id": chosen, "nivel_ii": false})
		screen._send("entrar_combate", {})
		screen._send("resolver_combate", {"damage": attack if owner == "p1" else 0, "target_order": [], "pass_target_id": null})
		state = screen._play.get_authority_snapshot()
		if state.lifecycle == "finalizada":
			break
		screen._send("entrar_limpieza", {})
		state = screen._play.get_authority_snapshot()
		screen._send("cerrar_limpieza", {"turn_number": state.turn.number}, false, true)
		_expect(screen._message.is_empty(), "Recorrido de pantalla sin rechazo inesperado.")
	var terminal: Dictionary = screen._play.get_authority_snapshot()
	_expect(terminal.lifecycle == "finalizada" and terminal.outcome.reason == "ultimo_superviviente", "La pantalla permite terminar una partida desde preparación.")
	screen._covered = false
	screen._render()
	await _capture("e2-victory.png")


func _capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var directory: String = ProjectSettings.globalize_path("res://tmp/screenshots")
	DirAccess.make_dir_recursive_absolute(directory)
	var image: Image = root.get_texture().get_image()
	_expect(image != null and not image.is_empty(), "Render visible: " + filename)
	if image != null:
		_expect(image.save_png(directory.path_join(filename)) == OK, "Captura guardada: " + filename)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("E2_SCREEN_FAIL: " + message)
