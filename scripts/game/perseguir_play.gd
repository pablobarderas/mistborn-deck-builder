extends "res://scripts/game/integrated_missions_play.gd"
## Perfil explícito aislado. No registra la carta en el arranque ni abre producto.

const Rules = preload("res://scripts/game/perseguir_rules.gd")
const PerseguirAdvance = preload("res://scripts/game/perseguir_advance.gd")
const PROFILE_VERSION: String = "perseguir_direct_v1_snapshot8"
var _catalog: Dictionary = {}
var _profile_training: Dictionary = {}


func _init(catalog: Dictionary, inert_descriptors: Dictionary, training_profile: Dictionary, mission_descriptors: Dictionary) -> void:
	var checked: Dictionary = _validate_catalog(catalog)
	var admitted: bool = checked.ok and catalog.get("version_esquema") == 4 and checked.cards.size() == checked.verified.size() and checked.cards.has("perseguir") and Rules.card_supported(checked.cards.perseguir) and Rules.source_supported(catalog)
	var inert_catalog: Dictionary = catalog.duplicate(true) if checked.ok else {}
	var inerts: Dictionary = inert_descriptors.duplicate(true)
	# El padre conserva exactamente su frontera histórica. Su admisión de los
	# componentes inertes se reutiliza sin introducir Perseguir en ese perfil.
	var cards: Array = []
	for card: Dictionary in inert_catalog.get("cartas", []):
		if card.id == "perseguir":
			continue
		if card.tipo != "mision":
			admitted = admitted and Funding._same_descriptor(inert_descriptors.get(card.id), card)
			if not card.metales.is_empty():
				admitted = admitted and card.tipo == "accion"
				card.metales = []
			inerts[card.id] = card.duplicate(true)
		cards.append(card)
	admitted = admitted and inert_descriptors.size() + 9 == checked.cards.size()
	inert_catalog.cartas = cards
	var internal_training: Dictionary = training_profile.duplicate(true)
	internal_training.catalog_id = identity_for(inert_catalog)
	super(inert_catalog, inerts, internal_training, mission_descriptors)
	_supported = _supported and admitted
	_handlers.erase(Rules.ACTION)
	if not _supported:
		_profile_id = ""
		return
	_catalog = catalog.duplicate(true)
	_profile_training = training_profile.duplicate(true)
	_content = checked.cards.duplicate(true)
	_identity = identity_for(_catalog)
	_training_profile = training_profile.duplicate(true)
	_advance = _trusted_advance()
	_supported = _advance.supported() and _advance._training.supports_track(training_profile.get("track_id"))
	_profile_id = "perseguir_profile_" + (_identity + Funding._canonical_content(training_profile) + PROFILE_VERSION).sha256_text() if _supported else ""
	_state = State.new(_content, _identity, _combined_registry)
	_resolver = Resolver.new(_combined_registry, _content)
	if _supported:
		_handlers[Rules.ACTION] = _play


func _trusted_advance() -> Advance:
	return PerseguirAdvance.new(_content, _identity, _training_profile, true, true, Registry.new(registration(_ally_ids)), true, true, true)


func _profile_intact() -> bool:
	if not _supported or identity_for(_catalog) != _identity or _training_profile != _profile_training:
		return false
	var checked: Dictionary = _validate_catalog(_catalog)
	return checked.ok and checked.cards == _content and _state._definitions == _content


func _restore(match_id: String, source: Variant) -> Dictionary:
	if not _profile_intact():
		return _load_rejected("Fuente o perfil de Perseguir incompatible.")
	return super._restore(match_id, source)


func _operation(actor_id: String, input: Variant, handler: Callable, kind: String) -> Dictionary:
	if not _profile_intact():
		return _reject("estado_invalido", _state.get_snapshot().get("revision", 0))
	return super._operation(actor_id, input, handler, kind)


func finish_cleanup(_actor_id: String, _input: Variant) -> Dictionary:
	# El contrato de esta entrega no abre limpieza ni borra oportunidades selladas.
	return _reject("accion_no_soportada", _state.get_snapshot().get("revision", 0))


func _play(candidate: Dictionary, actor_id: String, payload: Dictionary, _rng: RandomNumberGenerator) -> String:
	if not _advance.state_error(candidate).is_empty():
		return "estado_invalido"
	return Rules.apply(candidate, actor_id, payload, _content)


func _protected_fields(candidate: Dictionary, current: Dictionary) -> bool:
	if _submission.get("tipo") != Rules.ACTION:
		return super._protected_fields(candidate, current)
	if not _registry_intact():
		return false
	# Reproduce la intención con código cerrado, al margen del manejador registrado.
	var expected: Dictionary = current.duplicate(true)
	if not _trusted_advance().state_error(current).is_empty() or not Rules.apply(expected, _submission_actor, _submission.payload, _content).is_empty():
		return false
	_expected_rng = current.authority.rng_state
	return candidate == expected
