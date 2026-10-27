extends Control

const Probe = preload("res://scripts/network/connection_probe.gd")
var session: Probe

@onready var name_input: LineEdit = %NameInput
@onready var address_input: LineEdit = %AddressInput
@onready var port_input: SpinBox = %PortInput
@onready var key_input: LineEdit = %KeyInput
@onready var status_label: Label = %ConnectionStatus
@onready var people_label: Label = %PeopleLabel
@onready var counter_label: Label = %CounterLabel
@onready var invitation: LineEdit = %Invitation


func _ready() -> void:
	session = Probe.new()
	add_child(session)
	session.changed.connect(_refresh)
	session.notice.connect(_on_notice)
	%HostButton.pressed.connect(_on_host)
	%JoinButton.pressed.connect(_on_join)
	%SignalButton.pressed.connect(session.request_signal)
	%DisconnectButton.pressed.connect(session.close_session)
	%BackButton.pressed.connect(_on_back)
	_refresh()


func _on_host() -> void:
	session.host_session(name_input.text, int(port_input.value))


func _on_join() -> void:
	session.join_session(name_input.text, address_input.text, int(port_input.value), key_input.text)


func _refresh() -> void:
	status_label.text = session.status
	%HostButton.disabled = session.active
	%JoinButton.disabled = session.active
	%DisconnectButton.disabled = not session.active
	%SignalButton.disabled = not session.accepted
	for field: Control in [name_input, address_input, port_input, key_input]:
		if field is LineEdit:
			field.editable = not session.active
	port_input.editable = not session.active
	invitation.text = session.room_key if session.is_host else ""
	counter_label.text = "%d" % session.counter
	var lines: PackedStringArray = []
	for id: int in session.participants:
		var suffix: String = " · anfitrión" if id == 1 else ""
		if id == session.local_id:
			suffix += " · tú"
		lines.append("%s%s" % [session.participants[id], suffix])
	people_label.text = "%d / 4 participantes\n\n%s" % [lines.size(), "\n".join(lines)]


func _on_notice(message: String) -> void:
	status_label.text = message


func _on_back() -> void:
	session.close_session()
	get_tree().change_scene_to_file("res://scenes/MainScreen.tscn")
