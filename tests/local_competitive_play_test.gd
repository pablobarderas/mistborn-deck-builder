extends SceneTree
## E2-01..04/06: partidas por intenciones; el ensayo focal de mercado
## usa estados derivados declarados y no acredita una partida completa.
const Play = preload("res://scripts/game/local_competitive_play.gd")
const Fixtures = preload("res://tests/local_competitive_fixtures.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
var checks: int = 0
var failures: int = 0
var serial: int = 0
var primaries: Dictionary = {}
var signatures: Dictionary = {}
var saw_ii: bool = false
var saw_iii: bool = false
var saw_recycle: bool = false
var saw_market_recycle: bool = false
var saw_target: bool = false
var saw_flare: bool = false
var saw_card_fuel: bool = false
var saw_refresh: bool = false
var checked_bad_restore: bool = false

class Source extends Play.SnapshotSource:
	var entry: Dictionary
	func _init(value: Dictionary) -> void:
		entry = value.duplicate(true)
	func latest(_match_id: String, _profile_id: String) -> Dictionary:
		return entry.duplicate(true)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var validation: Dictionary = Play.Catalog.new().validate(Fixtures.catalog())
	_expect(validation.ok, "Catálogo compuesto válido: " + str(validation.errors))
	if not validation.ok:
		quit(1)
		return
	print("E2_STAGE preparation")
	_preparation()
	print("E2_STAGE boxings")
	_boxing_cases()
	print("E2_STAGE market_recycle")
	_market_recycle_cases()
	print("E2_STAGE mission")
	_full_game("mission")
	print("E2_STAGE combat")
	_full_game("combat")
	print("E2_STAGE metals")
	_metals_and_levels()
	print("E2_STAGE target3")
	_target_game(3)
	print("E2_STAGE target4")
	_target_game(4)
	_expect(primaries.size() == 16, "Las dieciséis primarias se ejecutan jugando turnos legales.")
	_expect(signatures.size() == 4, "Las cuatro firmas de personaje se activan.")
	_expect(saw_ii and saw_iii and saw_recycle and saw_market_recycle and saw_flare and saw_card_fuel and saw_refresh and saw_target, "Rutas II/III, reciclaje, fulguración, combustible, refresco y Target alcanzadas.")
	var disk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/inicio_competitivo.json"))
	for card: Dictionary in disk.cartas:
		_expect(card.revision.estado == "borrador", "Promoción únicamente en memoria: " + card.id)
	if failures == 0:
		print("P08_LOCAL_COMPETITIVE_PLAY_OK: ", checks, " comprobaciones; partidas completas por misiones/combate, Target 3/4, autoridad y restauración.")
	else:
		print("P08_LOCAL_COMPETITIVE_PLAY_FAIL: ", failures, "/", checks)
	quit(0 if failures == 0 else 1)


func _engine(count: int = 2, seed_value: int = -1) -> RefCounted:
	var engine: RefCounted = Play.new(Fixtures.catalog(), Fixtures.manifest())
	_expect(engine.is_supported(), "Perfil cerrado admitido.")
	var result: Dictionary = engine.prepare_match("e2_match", Fixtures.seats(count), "p1", (Fixtures.supported_seed(count) if seed_value < 0 else seed_value))
	_expect(result.ok, "Preparación reproducible: " + str(result))
	return engine


func _send(engine: RefCounted, kind: String, payload: Dictionary, actor: String = "") -> Dictionary:
	var state: Dictionary = engine.get_authority_snapshot()
	if actor.is_empty():
		actor = state.turn.active_id
	serial += 1
	var prefix: String = "inicio_" if kind == Play.START_TURN_ACTION else ("limpieza_" if kind == Play.CLEANUP_ACTION else "accion_")
	var intent: Dictionary = Fixtures.intent(state, prefix + str(serial), kind, payload)
	var result: Dictionary
	if kind == Play.START_TURN_ACTION:
		result = engine.start_turn(actor, intent)
	elif kind == Play.CLEANUP_ACTION:
		result = engine.finish_cleanup(actor, intent)
	else:
		result = engine.submit(actor, intent)
	_expect(result.ok, "Intención legal " + kind + ": " + str(result))
	return result


func _reject(engine: RefCounted, kind: String, payload: Dictionary, actor: String = "") -> void:
	var before: Dictionary = engine.get_authority_snapshot()
	if actor.is_empty():
		actor = before.turn.active_id
	serial += 1
	var result: Dictionary = engine.submit(actor, Fixtures.intent(before, "invalida_" + str(serial), kind, payload))
	_expect(not result.ok and engine.get_authority_snapshot() == before, "Rechazo atómico (incluido RNG): " + kind)


func _preparation() -> void:
	for count: int in [2, 3, 4]:
		var engine: RefCounted = _engine(count)
		var state: Dictionary = engine.get_authority_snapshot()
		_expect(state.players.size() == count and state.turn.phase == "inicio" and state.zones.mercado.cards.size() == 6, "Preparación 2/3/4 conserva mercado y fase.")
		_expect(state.target_id == ("p%d" % count if count >= 3 else null), "Target inicial sólo 3/4.")
		for mission: Dictionary in state.missions.values():
			_expect(mission.definition_id in ["mision_m5", "mision_m6", "mision_m7"], "La selección aleatoria es admitida sin sustituirla.")
		for player: Dictionary in state.players:
			var own: Array = Play.zone(state, "mano", player.player_id).cards + Play.zone(state, "mazo", player.player_id).cards
			var distribution: Dictionary = {}
			for id: String in own:
				var definition_id: String = state.instances[id].definition_id
				distribution[definition_id] = distribution.get(definition_id, 0) + 1
			_expect(distribution.get("financiacion") == 6 and distribution.size() == 5, "Mazo de seis Funding y cuatro entrenamientos propios.")
			for id: String in Play.Bindings.STARTERS[player.character_id]:
				_expect(distribution.get(id) == 1, "Entrenamiento propio " + id)
		var stranger: Dictionary = engine.get_view("p2")
		var secret: String = Play.zone(state, "mano", "p1").cards[0]
		_expect(not JSON.stringify(stranger).contains(JSON.stringify(secret)) and not stranger.has("authority") and engine.get_view("intruso").is_empty(), "Vistas privadas sin mano ajena ni autoridad.")
		var copy: Dictionary = engine.get_authority_snapshot()
		copy.players[0].health = 0
		_expect(engine.get_authority_snapshot() == state, "Snapshot copia profunda.")
		_reject(engine, "entrar_combate", {})
		var start: Dictionary = Fixtures.intent(state, "inicio_reenvio", Play.START_TURN_ACTION, {"turn_number": 1})
		_expect(engine.start_turn("p1", start).ok, "Inicio legal.")
		var started: Dictionary = engine.get_authority_snapshot()
		_expect(engine.start_turn("p1", start).ok and engine.get_authority_snapshot() == started, "Reenvío idempotente del inicio.")
		_reject(engine, "activar_personaje", {"nivel": 1, "aplicar": true})
		_reject(engine, "comprar_carta", {"instance_id": started.zones.mercado.cards[0], "nivel_ii": true})
		_reject(engine, "entrar_combate", {}, "p2")
		_restore(engine)
	var unsupported: RefCounted = Play.new(Fixtures.catalog(), Fixtures.manifest())
	var rejected_seed: int = 1
	while rejected_seed == Fixtures.supported_seed(2):
		rejected_seed += 1
	_expect(not unsupported.prepare_match("e2_bad_seed", Fixtures.seats(2), "p1", rejected_seed).ok and unsupported.get_authority_snapshot().is_empty(), "Semilla con otras misiones rechazada antes de jugar.")
	var wrong: Dictionary = Fixtures.manifest()
	wrong.characters[0].starters[0] = wrong.characters[1].starters[0]
	_expect(not Play.new(Fixtures.catalog(), wrong).is_supported(), "Vínculo de propietario falso rechazado.")
	var altered: Dictionary = Fixtures.catalog()
	for card: Dictionary in altered.cartas:
		if card.id == "e2_mision":
			card.habilidades[0].efectos[0].cantidad = 99
	_expect(not Play.new(altered, Fixtures.manifest()).is_supported(), "Programa de mercado alterado no admitido.")


func _boxing_cases() -> void:
	var engine: RefCounted = _engine(4)
	var state: Dictionary = engine.get_authority_snapshot()
	for player: Dictionary in state.players:
		_expect(player.persistent.boxings == (1 if player.player_id == "p4" else 0), "La cuarta plaza recibe un Boxing inicial; las otras no.")
	_reject(engine, "comprar_boxing", {})
	_reject(engine, "canjear_boxing", {})
	_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
	_reject(engine, "comprar_boxing", {})
	_reject(engine, "canjear_boxing", {})
	_reject(engine, "comprar_boxing", {"cantidad": 1})
	_reject(engine, "canjear_boxing", {"cantidad": 1})
	_play_hand(engine)
	state = engine.get_authority_snapshot()
	var old_coins: int = Funding._funding_player(state, "p1").turn_resources.recursos
	_send(engine, "comprar_boxing", {})
	var bought: Dictionary = engine.get_authority_snapshot()
	_expect(Funding._funding_player(bought, "p1").persistent.boxings == 1 and Funding._funding_player(bought, "p1").turn_resources.recursos == old_coins - 2, "Comprar un Boxing cuesta exactamente dos monedas.")
	_restore(engine)
	_end(engine)
	state = engine.get_authority_snapshot()
	_expect(Funding._funding_player(state, "p1").persistent.boxings == 1 and Funding._funding_player(state, "p1").turn_resources.recursos == 0, "El Boxing comprado persiste al limpiar aunque las monedas se reinicien.")
	# La cuarta plaza conserva su bonificación mientras pasan las otras plazas.
	for unused: int in 2:
		state = engine.get_authority_snapshot()
		_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
		_end(engine)
	state = engine.get_authority_snapshot()
	_expect(state.turn.active_id == "p4" and Funding._funding_player(state, "p4").persistent.boxings == 1, "La bonificación de la cuarta plaza persiste hasta su turno.")
	_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
	_send(engine, "canjear_boxing", {})
	state = engine.get_authority_snapshot()
	_expect(Funding._funding_player(state, "p4").persistent.boxings == 0 and Funding._funding_player(state, "p4").turn_resources.recursos == 1, "Canjear el Boxing inicial concede una moneda y devuelve la ficha.")
	_reject(engine, "canjear_boxing", {})
	_end(engine)
	state = engine.get_authority_snapshot()
	_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
	_expect(Funding._funding_player(engine.get_authority_snapshot(), "p1").persistent.boxings == 1, "El Boxing comprado llega al siguiente turno propio.")
	_send(engine, "canjear_boxing", {})
	state = engine.get_authority_snapshot()
	_expect(Funding._funding_player(state, "p1").persistent.boxings == 0 and Funding._funding_player(state, "p1").turn_resources.recursos == 1, "El Boxing comprado se canjea en un turno posterior.")
	_reject(engine, "canjear_boxing", {})
	_restore(engine)
	_send(engine, "entrar_combate", {})
	_reject(engine, "comprar_boxing", {})
	_reject(engine, "canjear_boxing", {})


func _market_recycle_cases() -> void:
	# Ensayo de rama REG-068: derivar zonas y reservas desde GameSetup,
	# admitiendo el candidato exclusivamente por el acceso interno del test.
	# No es un checkpoint publicable ni una partida completa jugada.
	var engine: RefCounted = _engine()
	var initial: Dictionary = engine.get_authority_snapshot()
	_send(engine, Play.START_TURN_ACTION, {"turn_number": initial.turn.number})
	var boundary: Dictionary = engine.get_authority_snapshot()
	var recycled_ids: Array = boundary.zones.mazo_mercado.cards.duplicate()
	boundary.zones.eliminadas.cards.assign(recycled_ids)
	boundary.zones.mazo_mercado.cards.clear()
	Funding._funding_player(boundary, "p1").turn_resources.recursos = 2
	# Las cartas eliminadas pueden conservar propietario y marcas previas.
	for id: String in recycled_ids:
		boundary.instances[id].owner_id = "p2"
		boundary.instances[id].state = {"ability_uses": {"e2_play_revision": boundary.revision}, "flags": {"e2_metal_peltre": true}}
	_expect(not engine.load_authority_snapshot(boundary).ok, "El fixture derivado de mercado no entra por carga publica.")
	_expect(engine._state.try_load(boundary).ok, "Candidato focal derivado estructuralmente valido.")
	var twin: RefCounted = Play.new(Fixtures.catalog(), Fixtures.manifest())
	_expect(twin._state.try_load(boundary).ok, "Segunda autoridad del ensayo recibe el mismo candidato.")
	var purchased: String = boundary.zones.mercado.cards[0]
	var market_before: Array = boundary.zones.mercado.cards.duplicate()
	var intent: Dictionary = Fixtures.intent(boundary, "market_recycle_focal", "comprar_carta", {"instance_id": purchased, "nivel_ii": false})
	_expect(engine.submit("p1", intent).ok and twin.submit("p1", intent).ok, "Compra con mazo vacio recicla eliminadas mediante autoridad.")
	var after: Dictionary = engine.get_authority_snapshot()
	_expect(after == twin.get_authority_snapshot(), "Mismo candidato e intencion producen el mismo orden, recibo y RNG.")
	_expect(after.authority.rng_state != boundary.authority.rng_state and after.authority.rng_seed == boundary.authority.rng_seed, "El reciclado de mercado consume RNG y conserva semilla.")
	_expect(after.zones.mercado.cards.size() == 6 and after.zones.eliminadas.cards.is_empty() and after.zones.mazo_mercado.cards.size() == recycled_ids.size() - 1, "Se barajan eliminadas y se repone un hueco inmediatamente.")
	var supplied: String = after.zones.mercado.cards.back()
	var remaining_market: Array = market_before.duplicate()
	remaining_market.erase(purchased)
	var expected_market: Array = remaining_market + [supplied]
	_expect(after.zones.mercado.cards == expected_market and supplied in recycled_ids, "El mercado conserva sus otras cinco cartas y recibe una del reciclado.")
	var conserved: Array = after.zones.mazo_mercado.cards.duplicate()
	conserved.append(supplied)
	conserved.sort()
	recycled_ids.sort()
	_expect(conserved == recycled_ids, "El reciclado conserva exactamente las instancias eliminadas.")
	for id: String in recycled_ids:
		_expect(after.instances[id].owner_id == null and after.instances[id].state == {"ability_uses": {}, "flags": {}}, "Las instancias vuelven al suministro sin propietario ni marcas.")
	_expect(purchased in Play.zone(after, "descarte", "p1").cards and after.instances[purchased].owner_id == "p1" and Funding._funding_player(after, "p1").turn_resources.recursos == 0, "La compra se cobra una vez y va al descarte propio.")
	_expect(engine.submit("p1", intent).ok and engine.get_authority_snapshot() == after, "Reenvio de compra no vuelve a barajar ni avanzar RNG.")
	saw_market_recycle = true
	# Agotamiento simultaneo: todas las cartas restantes estan en una zona
	# personal ficticia; no hay ninguna en mazo de mercado o eliminadas.
	var exhausted: Dictionary = boundary.duplicate(true)
	for id: String in exhausted.zones.eliminadas.cards:
		exhausted.instances[id].state = {"ability_uses": {}, "flags": {}}
		Play.zone(exhausted, "descarte", "p2").cards.append(id)
	exhausted.zones.eliminadas.cards.clear()
	var blocked: RefCounted = Play.new(Fixtures.catalog(), Fixtures.manifest())
	_expect(blocked._state.try_load(exhausted).ok, "Candidato focal sin suministro es estructuralmente valido.")
	_reject(blocked, "comprar_carta", {"instance_id": purchased, "nivel_ii": false}, "p1")
	_expect(blocked.get_authority_snapshot().authority.rng_state == exhausted.authority.rng_state and blocked.export_authority_entry().commands.is_empty(), "El rechazo sin suministro conserva RNG y registro.")


func _origin(state: Dictionary, owner: String, metal: String, excluded: String) -> Dictionary:
	var player: Dictionary = Funding._funding_player(state, owner)
	var used: int = 0
	for token: Dictionary in player.metals:
		if token.used_this_turn and not player.ability_uses.has("e2_flare_" + token.token_id):
			used += 1
	for token: Dictionary in player.metals:
		if not token.used_this_turn and not token.exhausted and token.metal in [metal, "atium"]:
			if used < player.burn_limit:
				return {"tipo": "ficha", "id": token.token_id}
			if token.metal != "atium":
				return {"tipo": "fulgurar", "id": token.token_id}
	for id: String in Play.zone(state, "mano", owner).cards:
		if id != excluded and metal in Fixtures.definition(state.instances[id].definition_id).get("metales", []):
			return {"tipo": "carta", "id": id}
	return {}


func _play_hand(engine: RefCounted) -> void:
	var state: Dictionary = engine.get_authority_snapshot()
	var owner: String = state.turn.active_id
	var hand: Array = Play.zone(state, "mano", owner).cards.duplicate()
	for id: String in hand:
		if state.instances[id].definition_id == "financiacion":
			_send(engine, Funding.ACTION_ID, {"instance_id": id, "aplicar": true})
	for id: String in hand:
		state = engine.get_authority_snapshot()
		if id not in Play.zone(state, "mano", owner).cards or state.instances[id].definition_id == "financiacion":
			continue
		var definition: Dictionary = Fixtures.definition(state.instances[id].definition_id)
		var metal: String = definition.habilidades[0].condicion.metales[0]
		var origin: Dictionary = _origin(state, owner, metal, id)
		if origin.is_empty():
			continue
		var before: Dictionary = Funding._funding_player(state, owner).turn_resources.duplicate()
		_send(engine, Play.PLAY if definition.tipo == "entrenamiento" else "jugar_accion", {"instance_id": id, "aplicar": true, "metal": metal, "origen": origin})
		saw_flare = saw_flare or origin.tipo == "fulgurar"
		saw_card_fuel = saw_card_fuel or origin.tipo == "carta"
		if definition.tipo == "entrenamiento":
			primaries[definition.id] = true
			var after: Dictionary = Funding._funding_player(engine.get_authority_snapshot(), owner).turn_resources
			var expected: Array = [0, 0, 2] if definition.id.ends_with("estano") or definition.id.ends_with("bronce") else ([1, 0, 1] if definition.id.ends_with("cinc") or definition.id.ends_with("laton") else [1, 2, 0])
			_expect(after.recursos - before.recursos == expected[0] and after.ataque - before.ataque == expected[1] and after.mision - before.mision == expected[2], "Ganancias de primaria " + definition.id)
	state = engine.get_authority_snapshot()
	var player: Dictionary = Funding._funding_player(state, owner)
	for level: int in [1, 3]:
		var required: String = Play.SIGNATURES[player.character_id] if level == 1 else "atium"
		if Play.Training.unlocked_level(player.training) >= level and player.burned.get(required, 0) > 0 and not player.ability_uses.has("e2_nivel_" + str(level)):
			_send(engine, Play.CHARACTER, {"nivel": level, "aplicar": true})
			if level == 1:
				signatures[player.character_id] = true
			else:
				saw_iii = true


func _buy_preferred(engine: RefCounted, preferred: String) -> void:
	for unused: int in 3:
		var state: Dictionary = engine.get_authority_snapshot()
		var player: Dictionary = Funding._funding_player(state, state.turn.active_id)
		if player.turn_resources.recursos < 2:
			return
		var selected: String = ""
		for id: String in state.zones.mercado.cards:
			if state.instances[id].definition_id == preferred:
				selected = id
		if selected.is_empty():
			selected = state.zones.mercado.cards[0]
		var level_ii: bool = player.training >= 8 and not player.ability_uses.has("e2_nivel_2")
		_send(engine, "comprar_carta", {"instance_id": selected, "nivel_ii": level_ii})
		saw_ii = saw_ii or level_ii
		var bought: Dictionary = engine.get_authority_snapshot()
		_expect(bought.zones.mercado.cards.size() == 6 and selected not in bought.zones.mercado.cards, "Compra repone inmediatamente el mercado.")
		_expect(selected in Play.zone(bought, "eliminadas", null).cards if level_ii else selected in Play.zone(bought, "descarte", player.player_id).cards, "Compra va a descarte o resuelve II y elimina.")


func _end(engine: RefCounted, damage: int = 0, choices: Array = []) -> void:
	_send(engine, "entrar_combate", {})
	var state: Dictionary = engine.get_authority_snapshot()
	if state.target_id == state.turn.active_id:
		damage = Funding._funding_player(state, state.turn.active_id).turn_resources.ataque
	_send(engine, "resolver_combate", {"damage": damage, "target_order": choices, "pass_target_id": null})
	state = engine.get_authority_snapshot()
	if state.lifecycle == "finalizada":
		return
	if engine.get_view(state.turn.active_id).combat.awaiting_target:
		_send(engine, "pasar_target", {"target_id": null})
	_send(engine, "entrar_limpieza", {})
	state = engine.get_authority_snapshot()
	var old_rng: int = state.authority.rng_state
	_send(engine, Play.CLEANUP_ACTION, {"turn_number": state.turn.number})
	var cleaned: Dictionary = engine.get_authority_snapshot()
	saw_recycle = saw_recycle or old_rng != cleaned.authority.rng_state
	_expect(cleaned.turn.phase == "inicio" and Play.zone(cleaned, "mano", state.turn.active_id).cards.size() == 5, "Limpieza roba cinco y entrega inicio.")
	var active: Dictionary = Funding._funding_player(cleaned, state.turn.active_id)
	_expect(active.turn_resources == {"recursos": 0, "ataque": 0, "mision": 0} and active.burned.is_empty() and active.ability_uses.is_empty(), "Limpieza reinicia reservas y usos.")


func _full_game(route: String) -> void:
	var engine: RefCounted = _engine()
	for turn: int in 160:
		if failures > 0:
			return
		var state: Dictionary = engine.get_authority_snapshot()
		if state.lifecycle == "finalizada":
			break
		_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
		if state.turn.active_id == "p1":
			_play_hand(engine)
			_buy_preferred(engine, "e2_mision" if route == "mission" else "e2_combate")
			if route == "mission":
				for unused: int in 50:
					state = engine.get_authority_snapshot()
					if state.lifecycle == "finalizada" or Funding._funding_player(state, "p1").turn_resources.mision == 0:
						break
					for id: String in state.missions:
						if state.missions[id].progress.p1 < 12:
							_send(engine, "avanzar_mision", {"mission_id": id})
							break
		state = engine.get_authority_snapshot()
		if state.lifecycle == "finalizada":
			break
		var damage: int = Funding._funding_player(state, "p1").turn_resources.ataque if route == "combat" and state.turn.active_id == "p1" else 0
		_end(engine, damage)
	var terminal: Dictionary = engine.get_authority_snapshot()
	_expect(terminal.lifecycle == "finalizada" and terminal.outcome != null and terminal.outcome.winner_id == "p1" and terminal.outcome.reason == ("tres_misiones" if route == "mission" else "ultimo_superviviente"), "Partida completa por " + route)
	if route == "mission":
		var rewards: int = 0
		for mission: Dictionary in terminal.missions.values():
			rewards += mission.rewards.p1.size()
		_expect(rewards > 0, "Premios de misión registrados durante partida legal.")
	_reject(engine, "entrar_combate", {})
	_restore(engine)


func _restore(engine: RefCounted) -> void:
	var entry: Dictionary = engine.export_authority_entry()
	var restored: RefCounted = Play.new(Fixtures.catalog(), Fixtures.manifest())
	_expect(restored.restore_match("e2_match", Source.new(entry)).ok and restored.get_authority_snapshot() == engine.get_authority_snapshot(), "Restauración reproduce checkpoint, acciones y RNG.")
	if not entry.commands.is_empty():
		var last: Dictionary = entry.commands.back()
		var before: Dictionary = restored.get_authority_snapshot()
		var result: Dictionary
		match last.intent.tipo:
			Play.START_TURN_ACTION: result = restored.start_turn(last.actor, last.intent)
			Play.CLEANUP_ACTION: result = restored.finish_cleanup(last.actor, last.intent)
			_: result = restored.submit(last.actor, last.intent)
		_expect(result.ok and restored.get_authority_snapshot() == before, "Reenvío después de restaurar no duplica efectos.")
	if checked_bad_restore:
		return
	checked_bad_restore = true
	var bad: Dictionary = entry.duplicate(true)
	bad.snapshot.players[0].health -= 1
	var target: RefCounted = Play.new(Fixtures.catalog(), Fixtures.manifest())
	_expect(not target.restore_match("e2_match", Source.new(bad)).ok and target.get_authority_snapshot().is_empty(), "Snapshot alterado rechazado sin carga parcial.")
	bad = entry.duplicate(true)
	bad.checkpoint.players[0].health -= 1
	target = Play.new(Fixtures.catalog(), Fixtures.manifest())
	_expect(not target.restore_match("e2_match", Source.new(bad)).ok and target.get_authority_snapshot().is_empty(), "Checkpoint fabricado rechazado al reconstruir preparación.")


func _metals_and_levels() -> void:
	var covered: Dictionary = {}
	var seed_value: int = 0
	for attempt: int in 8:
		seed_value = Fixtures.supported_seed(2, seed_value)
		var engine: RefCounted = _engine(2, seed_value)
		var useful: bool = false
		for player: Dictionary in engine.get_authority_snapshot().players:
			useful = useful or not covered.has(player.character_id)
			covered[player.character_id] = true
		if useful:
			_metals_session(engine)
		if covered.size() == 4:
			break


func _metals_session(engine: RefCounted) -> void:
	for unused: int in 44:
		if failures > 0:
			return
		var state: Dictionary = engine.get_authority_snapshot()
		_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
		_play_hand(engine)
		state = engine.get_authority_snapshot()
		var owner: String = state.turn.active_id
		var player: Dictionary = Funding._funding_player(state, owner)
		# Quema directa de Atium y firmas para cubrir III y desbloqueo tardío.
		for level: int in [1, 3]:
			state = engine.get_authority_snapshot()
			player = Funding._funding_player(state, owner)
			var metal: String = Play.SIGNATURES[player.character_id] if level == 1 else "atium"
			if Play.Training.unlocked_level(player.training) < level or player.ability_uses.has("e2_nivel_" + str(level)):
				continue
			if player.burned.get(metal, 0) == 0:
				var origin: Dictionary = _origin(state, owner, metal, "")
				if not origin.is_empty():
					_send(engine, "quemar_metal", {"metal": metal, "origen": origin})
			state = engine.get_authority_snapshot()
			if Funding._funding_player(state, owner).burned.get(metal, 0) > 0:
				_send(engine, Play.CHARACTER, {"nivel": level, "aplicar": true})
				if level == 1:
					signatures[player.character_id] = true
				else:
					saw_iii = true
		state = engine.get_authority_snapshot()
		# Refresca un agotado con una carta aún en mano, sin reusarlo este turno.
		for card_id: String in Play.zone(state, "mano", owner).cards.duplicate():
			var definition: Dictionary = Fixtures.definition(state.instances[card_id].definition_id)
			for token: Dictionary in Funding._funding_player(state, owner).metals:
				if token.exhausted and token.metal in definition.metales:
					_send(engine, "refrescar_metal", {"instance_id": card_id, "token_id": token.token_id})
					saw_refresh = true
					if token.used_this_turn:
						_reject(engine, "quemar_metal", {"metal": token.metal, "origen": {"tipo": "fulgurar", "id": token.token_id}})
					break
		_end(engine)


func _target_game(count: int) -> void:
	var engine: RefCounted = _engine(count)
	for unused: int in 200:
		if failures > 0:
			return
		var state: Dictionary = engine.get_authority_snapshot()
		if state.lifecycle == "finalizada":
			break
		_send(engine, Play.START_TURN_ACTION, {"turn_number": state.turn.number})
		_play_hand(engine)
		_buy_preferred(engine, "e2_combate")
		_send(engine, "entrar_combate", {})
		state = engine.get_authority_snapshot()
		var owner: String = state.turn.active_id
		var attack: int = Funding._funding_player(state, owner).turn_resources.ataque
		if state.target_id == owner and attack > 0:
			_reject(engine, "resolver_combate", {"damage": attack - 1, "target_order": [], "pass_target_id": null})
		var order: Array = []
		# Anticipa eliminaciones del portador para elegir al propio atacante.
		if state.target_id != null and state.target_id != owner and Funding._funding_player(state, state.target_id).health <= attack and engine._alive(state).size() > 3:
			order.append(owner)
		_send(engine, "resolver_combate", {"damage": attack, "target_order": order, "pass_target_id": null})
		state = engine.get_authority_snapshot()
		if state.lifecycle == "finalizada":
			break
		if engine.get_view(state.turn.active_id).combat.awaiting_target:
			saw_target = true
			_reject(engine, "entrar_limpieza", {})
			_reject(engine, "pasar_target", {"target_id": owner}, owner)
			_send(engine, "pasar_target", {"target_id": owner})
			_expect(engine.get_authority_snapshot().target_id == owner and engine.get_authority_snapshot().turn.active_id == owner, "El portador decide pasar Target y vuelve el atacante.")
		state = engine.get_authority_snapshot()
		if engine._alive(state).size() == 2:
			_expect(state.target_id == null, "Target se retira con dos supervivientes.")
		_send(engine, "entrar_limpieza", {})
		state = engine.get_authority_snapshot()
		_send(engine, Play.CLEANUP_ACTION, {"turn_number": state.turn.number})
	_expect(engine.get_authority_snapshot().lifecycle == "finalizada", "Partida Target %dp alcanza último superviviente." % count)
	_restore(engine)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("E2_FAIL: " + message)
