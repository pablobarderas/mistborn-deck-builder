extends RefCounted
class_name GameEngineHandlers
## Manejadores ficticios de prueba. No registrarlos en la aplicación.


static func registry() -> Dictionary:
	return {"test_move": Callable(GameEngineHandlers, "move_card"),
		"test_spend": Callable(GameEngineHandlers, "spend"),
		"test_shuffle": Callable(GameEngineHandlers, "shuffle_deck"),
		"test_fail": Callable(GameEngineHandlers, "fail_after_rng"),
		"test_corrupt": Callable(GameEngineHandlers, "corrupt_after_rng"),
		"test_erase": Callable(GameEngineHandlers, "erase_authority"),
		"test_rewind": Callable(GameEngineHandlers, "rewind_id"),
		"test_forget": Callable(GameEngineHandlers, "forget_receipts"),
		"responder": Callable(GameEngineHandlers, "respond")}


static func move_card(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if payload.size() != 2 or not payload.has("instance_id") or not payload.has("to_zone"):
		return "formato_invalido"
	if not payload.instance_id is String or not payload.to_zone is String:
		return "formato_invalido"
	if not state.instances.has(payload.instance_id):
		return "accion_ilegal"
	if state.instances[payload.instance_id].owner_id != actor_id:
		return "accion_ilegal"
	var source: Dictionary = state.zones[actor_id + "_mano"]
	if not payload.instance_id in source.cards:
		return "accion_ilegal"
	if payload.to_zone != actor_id + "_descarte":
		return "accion_ilegal"
	source.cards.erase(payload.instance_id)
	state.zones[payload.to_zone].cards.append(payload.instance_id)
	return ""


static func spend(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if payload.size() != 1 or not payload.has("amount") or typeof(payload.amount) != TYPE_INT or payload.amount <= 0:
		return "formato_invalido"
	for player: Dictionary in state.players:
		if player.player_id == actor_id:
			if player.turn_resources.recursos < payload.amount:
				return "accion_ilegal"
			player.turn_resources.recursos -= payload.amount
			return ""
	return "accion_ilegal"


static func shuffle_deck(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	if payload.size() != 1 or not payload.has("zone_id") or payload.zone_id != actor_id + "_mazo":
		return "accion_ilegal"
	var cards: Array = state.zones[payload.zone_id].cards
	for index: int in range(cards.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var saved: Variant = cards[index]
		cards[index] = cards[other]
		cards[other] = saved
	return ""


static func fail_after_rng(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	state.zones[actor_id + "_mano"].cards.clear()
	state.players[0].turn_resources.recursos = 0
	rng.randi()
	return "accion_ilegal"


static func corrupt_after_rng(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	state.players[0].persistent.atium = -1
	rng.randi()
	return ""


static func respond(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	# Efecto ficticio inequívoco para probar la continuación, no regla de carta.
	if "accept" in payload.options:
		for player: Dictionary in state.players:
			if player.player_id == actor_id:
				player.health += 1
	state.resolution.cursor += 1
	if state.resolution.cursor >= state.resolution.steps.size():
		state.resolution = null
	else:
		state.resolution.pending = null
	return ""


static func erase_authority(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	state.erase("authority")
	rng.randi()
	return ""


static func rewind_id(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	state.authority.next_id = 0
	return ""


static func forget_receipts(state: Dictionary, actor_id: String, payload: Dictionary, rng: RandomNumberGenerator) -> String:
	state.authority.receipts.clear()
	return ""
