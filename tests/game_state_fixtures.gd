extends RefCounted
## Fixtures técnicos ficticios. No cartas revisadas ni preparación oficial.

const Validator = preload("res://scripts/game/state_validator.gd")


static func definitions() -> Dictionary:
	return {
		"test_action": {"id": "test_action", "tipo": "accion"},
		"test_character": {"id": "test_character", "tipo": "personaje"},
		"test_training_track": {"id": "test_training_track", "tipo": "pista_entrenamiento"},
		"test_mission": {"id": "test_mission", "tipo": "mision"},
		"test_rival": {"id": "test_rival", "tipo": "rival"},
		"test_domination": {"id": "test_domination", "tipo": "dominacion"},
		"test_enemy": {"id": "test_enemy", "tipo": "adversario", "rasgos": {"escudos": 3}}
	}


static func snapshot(mode: String = "competitivo", count: int = 2) -> Dictionary:
	var players: Array = []
	var order: Array = []
	var zones: Dictionary = {}
	var progress: Dictionary = {}
	var rewards: Dictionary = {}
	for index: int in count:
		var id: String = "p%d" % (index + 1)
		order.append(id)
		progress[id] = index
		rewards[id] = ["reward_a"] if index == 0 else []
		players.append({"player_id": id, "name": "Prueba %d" % index, "eliminated": false,
			"health": 7 + index, "character_id": "test_character", "training_track_id": "test_training_track", "persistent": {"atium": 2, "boxings": 3},
			"turn_resources": {"recursos": 4, "ataque": 5}, "training": 2, "ability_uses": {"test": 1},
			"metals": [{"token_id": "cobre_1", "metal": "cobre", "exhausted": false, "used_this_turn": true},
				{"token_id": "atium_1", "metal": "atium", "exhausted": false, "used_this_turn": false}],
			"burned": {"cobre": 1}, "burn_limit": 2})
		for kind: String in Validator.PLAYER_ZONES:
			add_zone(zones, id + "_" + kind, kind, id)
	for kind: String in ["mazo_mercado", "mercado", "eliminadas"]:
		add_zone(zones, kind, kind)
	var instances: Dictionary = {}
	if count > 0:
		for id: String in ["c1", "c2"]:
			instances[id] = instance(id, "test_action", "p1")
		zones.p1_mano.cards = ["c1"]
		zones.p1_mazo.cards = ["c2"]
	var rival: Variant = null
	if mode != "competitivo":
		for kind: String in ["mazo_rival", "descarte_rival", "adversarios"]:
			add_zone(zones, kind, kind)
		instances["enemy_1"] = instance("enemy_1", "test_enemy", null)
		zones.adversarios.cards = ["enemy_1"]
		rival = {"definition_id": "test_rival", "health": 17, "deck_zone": "mazo_rival",
			"discard_zone": "descarte_rival", "adversary_zone": "adversarios",
			"domination": {"definition_id": "test_domination", "face": 1, "position": 2, "visible_value": 3},
			"adversaries": {"enemy_1": {"facing_id": "p1", "destroyed_shields": [0, 1]}}}
	return {"version_esquema": 1, "version_motor": Validator.ENGINE_VERSION, "catalog_id": "test_catalog",
		"match_id": "test_match", "mode": mode, "revision": 0, "lifecycle": "sin_preparar",
		"players": players, "player_order": order, "instances": instances, "zones": zones,
		"turn": {"number": 0, "active_id": null, "phase": "sin_iniciar", "counters": {}},
		"missions": {"mission_1": {"definition_id": "test_mission", "progress": progress,
			"rewards": rewards, "arrival_order": []}}, "target_id": null, "rival": rival,
		"resolution": null, "authority": {"rng_seed": 101, "rng_state": -456, "next_id": 3, "receipts": {}}}


static func instance(id: String, definition_id: String, owner_id: Variant) -> Dictionary:
	return {"instance_id": id, "definition_id": definition_id, "owner_id": owner_id,
		"state": {"ability_uses": {}, "flags": {}}}


static func add_zone(zones: Dictionary, id: String, kind: String, holder: Variant = null) -> void:
	zones[id] = {"zone_id": id, "kind": kind, "holder_id": holder, "cards": []}


static func resolution() -> Dictionary:
	return {"resolution_id": "r1", "source_id": "c1", "steps": ["before", "choose", "after"], "cursor": 1,
		"recipients": ["p1", "p2"], "pending": {"kind": "reaccion", "recipients": ["p2"],
			"options": ["accept", "decline"], "min": 0, "max": 1}}
