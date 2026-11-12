extends "res://scripts/game/funding_play.gd"
## Perfil aislado de autoridad. La interfaz de jugador sólo recibe submit y vistas.
## Preparación y restauración se invocan en el hilo propietario de la partida.

const Setup = preload("res://scripts/game/game_setup.gd")
const Advance = preload("res://scripts/game/training_advance.gd")


class SnapshotSource extends RefCounted:
	## Fuente de autoridad que devuelve el último estado confirmado por partida y perfil.
	func latest(_match_id: String, _profile_id: String) -> Dictionary:
		return {}


var _advance: Advance
var _profile_id: String = ""
var _owner_thread: int = OS.get_thread_caller_id()
var _busy: bool = false


func _init(catalog: Dictionary, funding_id: String, inert_descriptors: Dictionary, training_profile: Dictionary) -> void:
	super(catalog, funding_id, inert_descriptors)
	_advance = Advance.new(_funding_definitions, catalog_identity(), training_profile, _funding_registry)
	var track_id: Variant = training_profile.get("track_id")
	if super.is_supported() and _advance.supports_track(track_id):
		_profile_id = "competitive_start_" + (catalog_identity() + ":" + track_id).sha256_text()


func is_supported() -> bool:
	return not _profile_id.is_empty()


func profile_identity() -> String:
	return _profile_id


func load_authority_snapshot(_document: Variant) -> Dictionary:
	return _load_rejected("Usa la preparación o la fuente de restauración de autoridad.")


func prepare_match(match_id: String, seats: Array, first_player_id: String, manifest: Dictionary, seed: int) -> Dictionary:
	if not _begin_operation():
		return _load_rejected("Autoridad ocupada o hilo incorrecto.")
	var result: Dictionary = _prepare(match_id, seats, first_player_id, manifest, seed)
	_busy = false
	return result


func _prepare(match_id: String, seats: Array, first_player_id: String, manifest: Dictionary, seed: int) -> Dictionary:
	if not is_supported() or not _state.get_snapshot().is_empty():
		return _load_rejected("Perfil no admitido o partida ya cargada.")
	var funding_id: Variant = manifest.get("funding_id")
	if not _advance.supports_track(manifest.get("training_track_id")) or not funding_id is String or funding_id != _funding_id:
		return _load_rejected("Pista o Funding incompatibles con el perfil.")
	# P06 valida cantidades enteras aunque provengan de números JSON.
	var definitions: Dictionary = _funding_definitions.duplicate(true)
	for definition: Dictionary in definitions.values():
		definition.cantidad = int(definition.cantidad)
	var setup: Setup = Setup.new(definitions, catalog_identity())
	var prepared: Dictionary = setup.create(match_id, "competitivo", seats, first_player_id, manifest, seed)
	if not prepared.ok:
		return _load_rejected(prepared.codigo)
	if not _continuity_error(prepared.snapshot).is_empty():
		return _load_rejected("La preparación no acredita que la partida pueda continuar.")
	return _admit(prepared.snapshot)


func restore_match(match_id: String, source: Variant) -> Dictionary:
	if not _begin_operation():
		return _load_rejected("Autoridad ocupada o hilo incorrecto.")
	var result: Dictionary = _restore(match_id, source)
	_busy = false
	return result


func _restore(match_id: String, source: Variant) -> Dictionary:
	# La fuente fiable selecciona su último estado, incluso entre revisiones
	# de la misma versión. No es un proveedor de datos del cliente.
	if not is_supported() or not _state.get_snapshot().is_empty() or not Registry.valid_id(match_id) \
		or not source is SnapshotSource:
		return _load_rejected("Restauración no disponible.")
	var entry: Dictionary = source.latest(match_id, _profile_id)
	if not Registry.exact_keys(entry, ["profile_id", "snapshot"]) \
		or not entry.profile_id is String or entry.profile_id != _profile_id or not entry.snapshot is Dictionary \
		or not entry.snapshot.get("match_id") is String or entry.snapshot.match_id != match_id:
		return _load_rejected("La fuente no devolvió un estado confirmado de la partida y perfil.")
	return _admit(entry.snapshot)


func _admit(document: Dictionary) -> Dictionary:
	var validation: Dictionary = _state.validate_candidate(document)
	if not validation.ok:
		return validation
	if document.mode != "competitivo" or document.turn.number < 1 or document.resolution != null \
		or not document.turn.phase in ["inicio", "libre", "finalizada"] \
		or document.lifecycle != ("finalizada" if document.turn.phase == "finalizada" else "en_curso"):
		return _load_rejected("Turno incompatible con el perfil de inicio.")
	if document.lifecycle == "en_curso" and not document.turn.active_id is String:
		return _load_rejected("Falta la plaza activa.")
	for player: Dictionary in document.players:
		if not _advance.supports_track(player.training_track_id) or player.training > Advance.LAST_POSITION:
			return _load_rejected("Pista incompatible con el perfil de inicio.")
	if document.turn.phase == "libre":
		var active: Dictionary = _funding_player(document, document.turn.active_id)
		if active.eliminated or not _continuity_error(document).is_empty():
			return _load_rejected("El estado no acredita una fase libre válida.")
	return super.load_authority_snapshot(document)


func submit(actor_id: String, input: Variant) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	var result: Dictionary = super.submit(actor_id, input)
	_busy = false
	return result


func start_turn(actor_id: String, input: Variant) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	var result: Dictionary = _submit(actor_id, input, _start_turn)
	_busy = false
	return result


func _begin_operation() -> bool:
	if OS.get_thread_caller_id() != _owner_thread or _busy:
		return false
	_busy = true
	return true


func _start_turn(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["turn_number"]) or not payload.turn_number is int or payload.turn_number < 1:
		return "formato_invalido"
	if candidate.turn.phase != "inicio" or payload.turn_number != candidate.turn.number:
		return "accion_ilegal"
	var error: String = _continuity_error(candidate)
	if not error.is_empty():
		return error
	var advanced: Dictionary = _advance.advance(candidate, actor_id)
	if not advanced.ok:
		return "accion_ilegal" if advanced.codigo == "accion_ilegal" else "estado_invalido"
	var staged: Dictionary = advanced.candidate
	staged.turn.phase = "libre"
	error = _continuity_error(staged)
	if not error.is_empty():
		return error
	candidate.merge(staged, true)
	return ""


func _continuity_error(state: Dictionary) -> String:
	if not _known_dynamic_state(state):
		return "regla_pendiente"
	var survivors: int = 0
	var completed: Dictionary = {}
	for player: Dictionary in state.players:
		if player.eliminated != (player.health == 0):
			return "estado_invalido"
		if not player.eliminated:
			survivors += 1
		completed[player.player_id] = 0
	if survivors < 2 or state.missions.size() != 3:
		return "regla_pendiente"
	var definitions_seen: Dictionary = {}
	for mission: Dictionary in state.missions.values():
		var definition: Dictionary = _funding_definitions[mission.definition_id]
		var tracks: Array = definition.rasgos.recorridos
		if definitions_seen.has(mission.definition_id) or tracks.size() != 1 or tracks[0].casillas.size() != 1:
			return "regla_pendiente"
		definitions_seen[mission.definition_id] = true
		for id: String in completed:
			var position: int = mission.progress[id]
			if position > 1 or (position == 1) != (id in mission.arrival_order):
				return "regla_pendiente"
			completed[id] += position
			if completed[id] == 3:
				return "regla_pendiente"
	# Funding y los descriptores inertes son los únicos programas admitidos.
	# Por procedencia, este perfil no puede haber activado Confrontation.
	return ""


static func _load_rejected(reason: String) -> Dictionary:
	return {"ok": false, "errors": PackedStringArray([reason])}
