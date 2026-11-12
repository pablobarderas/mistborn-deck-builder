extends "res://scripts/game/game_engine.gd"
## Perfil de autoridad aislado: sólo avance automático M5/M6/M7.

const CatalogValidator = preload("res://scripts/catalog/catalog_validator.gd")
const Funding = preload("res://scripts/game/funding_play.gd")
const Advance = preload("res://scripts/game/mission_advance.gd")
const ACTION_ID: String = "avanzar_mision"


class SnapshotSource extends RefCounted:
	## El propietario fiable selecciona el último estado confirmado; nunca un cliente.
	func latest(_match_id: String, _profile_id: String) -> Dictionary:
		return {}


var _advance: Advance
var _supported: bool = false
var _identity: String = "mission_invalid"
var _profile_id: String = ""
var _owner_thread: int = OS.get_thread_caller_id()
var _busy: bool = false


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	var checked: Dictionary = CatalogValidator.new().validate(catalog)
	var content: Dictionary = checked.cards
	var handlers: Dictionary = {}
	if checked.ok and checked.cards.size() == checked.verified.size() 		and _matches(content, inert_descriptors, mission_descriptors):
		_identity = identity_for(catalog)
		_advance = Advance.new(content, _identity, training_profile)
		_supported = _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
		if _supported:
			_profile_id = "mission_profile_" + (_identity + Funding._canonical_content(training_profile)).sha256_text()
			handlers[ACTION_ID] = _advance_action
	super(content, _identity, handlers)


static func identity_for(catalog: Dictionary) -> String:
	return "missions_" + Funding._canonical_content(catalog).sha256_text()


func is_supported() -> bool:
	return _supported


func catalog_identity() -> String:
	return _identity


func profile_identity() -> String:
	return _profile_id


func load_authority_snapshot(_document: Variant) -> Dictionary:
	return _load_rejected("Usa la fuente de restauración de autoridad.")


func restore_match(match_id: String, source: Variant) -> Dictionary:
	if not _begin_operation():
		return _load_rejected("Autoridad ocupada o hilo incorrecto.")
	var result: Dictionary = _restore(match_id, source)
	_busy = false
	return result


func _restore(match_id: String, source: Variant) -> Dictionary:
	if not _supported or not _state.get_snapshot().is_empty() or not Registry.valid_id(match_id) or not source is SnapshotSource:
		return _load_rejected("Restauración no disponible.")
	var entry: Dictionary = source.latest(match_id, _profile_id)
	if not Registry.exact_keys(entry, ["profile_id", "snapshot"]) or entry.profile_id != _profile_id 		or not entry.snapshot is Dictionary or entry.snapshot.get("match_id") != match_id:
		return _load_rejected("Fuente incompatible con la partida y perfil.")
	if not _advance.state_error(entry.snapshot).is_empty():
		return _load_rejected("Estado incompatible con el perfil de misiones.")
	return super.load_authority_snapshot(entry.snapshot)


func submit(actor_id: String, input: Variant) -> Dictionary:
	if not _begin_operation():
		return _reject("accion_ilegal", 0)
	var result: Dictionary = super.submit(actor_id, input)
	_busy = false
	return result


func _advance_action(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not Registry.exact_keys(payload, ["mission_id"]) or not Registry.valid_id(payload.mission_id):
		return "formato_invalido"
	var result: Dictionary = _advance.advance(candidate, actor_id, payload.mission_id)
	if not result.ok:
		return result.codigo
	candidate.merge(result.candidate, true)
	return ""


func _begin_operation() -> bool:
	if _busy or OS.get_thread_caller_id() != _owner_thread:
		return false
	_busy = true
	return true


static func _matches(content: Dictionary, inerts: Dictionary, missions: Dictionary) -> bool:
	if missions.size() != 8 or content.size() != inerts.size() + 8:
		return false
	for index: int in range(1, 9):
		var id: String = "mision_m%d" % index
		if not content.has(id) or not Funding._same_descriptor(missions.get(id), content[id]) 			or content[id].tipo != "mision" or content[id].cantidad != 1:
			return false
	for id: String in content:
		if missions.has(id):
			continue
		if not Funding._same_descriptor(inerts.get(id), content[id]) or not Funding._inert(content[id]) 			or content[id].tipo not in ["accion", "aliado", "entrenamiento", "personaje", "pista_entrenamiento"]:
			return false
	return true


static func _load_rejected(reason: String) -> Dictionary:
	return {"ok": false, "errors": PackedStringArray([reason])}
