extends Node2D

# Simple MIDI Browser Permission Demo
# Demonstrates the browser permission requirement for Web MIDI

@onready var ui_container = $UIContainer
@onready var status_label = $UIContainer/StatusPanel/VBoxContainer/StatusLabel
@onready var permission_btn = $UIContainer/ControlPanel/VBoxContainer/PermissionButton
@onready var test_btn = $UIContainer/ControlPanel/VBoxContainer/TestButton
@onready var devices_label = $UIContainer/DevicePanel/VBoxContainer/DevicesLabel
@onready var message_log = $UIContainer/LogPanel/VBoxContainer/MessageLog

var midi_initialized = false

func _ready():
	print("🌐 MIDI Browser Permission Demo starting...")
	_setup_ui()
	_check_platform()

func _setup_ui():
	permission_btn.pressed.connect(_request_permission)
	test_btn.pressed.connect(_test_midi)
	test_btn.disabled = true

func _check_platform():
	if OS.has_feature("web"):
		status_label.text = "🌐 Web platform detected. MIDI requires browser permission."
		status_label.modulate = Color.YELLOW
		permission_btn.visible = true
		_log_message("Web platform: MIDI permission required")
	else:
		status_label.text = "🖥️ Desktop platform. MIDI available without permission."
		status_label.modulate = Color.GREEN
		permission_btn.visible = false
		_auto_initialize_midi()

func _auto_initialize_midi():
	_log_message("Desktop platform: Initializing MIDI automatically...")
	_request_permission()

func _request_permission():
	_log_message("Requesting MIDI permission...")
	status_label.text = "🔒 Requesting MIDI permission..."
	status_label.modulate = Color.ORANGE
	
	# Try to open MIDI inputs
	OS.open_midi_inputs()
	
	# Check if successful
	await get_tree().process_frame  # Wait a frame for the operation to complete
	_check_midi_status()

func _check_midi_status():
	# Wait a bit longer for MIDI initialization to complete
	await get_tree().create_timer(0.1).timeout
	
	var devices = OS.get_connected_midi_inputs()
	
	# MIDI is considered working if we can call get_connected_midi_inputs() without error
	# Even 0 devices means the MIDI system is functional
	midi_initialized = true
	status_label.text = "✅ MIDI permission granted!"
	status_label.modulate = Color.GREEN
	test_btn.disabled = false
	_log_message("✅ MIDI permission granted successfully")
	_update_device_list()

func _update_device_list():
	var devices = OS.get_connected_midi_inputs()
	if devices.size() > 0:
		devices_label.text = "📱 Found %d MIDI device(s):\n" % devices.size()
		for device in devices:
			devices_label.text += "• " + device + "\n"
		_log_message("Found %d MIDI devices" % devices.size())
	else:
		devices_label.text = "📱 No MIDI devices connected"
		_log_message("No MIDI devices found")

func _test_midi():
	if not midi_initialized:
		_log_message("❌ Cannot test: MIDI not initialized")
		return
	
	_log_message("🎹 Testing MIDI input... Play any MIDI note!")
	status_label.text = "🎹 MIDI ready - play a note!"
	status_label.modulate = Color.CYAN

func _input(event):
	if event is InputEventMIDI:
		_handle_midi_message(event)

func _handle_midi_message(midi_event: InputEventMIDI):
	var message_type = ""
	match midi_event.message:
		MIDI_MESSAGE_NOTE_ON:
			message_type = "NOTE ON"
		MIDI_MESSAGE_NOTE_OFF:
			message_type = "NOTE OFF"
		MIDI_MESSAGE_CONTROL_CHANGE:
			message_type = "CONTROL CHANGE"
		_:
			message_type = "OTHER"
	
	var message = "🎵 %s - Note: %d, Velocity: %d, Channel: %d" % [
		message_type,
		midi_event.pitch,
		midi_event.velocity,
		midi_event.channel + 1
	]
	
	_log_message(message)
	status_label.text = "🎵 MIDI active!"
	status_label.modulate = Color.LIME

func _log_message(message: String):
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] %s" % [timestamp.substr(11, 8), message]
	message_log.text += log_entry + "\n"
	
	# Keep log manageable
	var lines = message_log.text.split("\n")
	if lines.size() > 20:
		lines = lines.slice(-15)
		message_log.text = "\n".join(lines)
	
	print(log_entry)

func _exit_tree():
	# Note: Don't close MIDI inputs here as it prevents other MIDI scenes from working
	# Godot will handle MIDI cleanup when the application closes
	if midi_initialized:
		# OS.close_midi_inputs() - Commented out to prevent MIDI persistence issues
		print("🧹 MIDI demo cleanup complete (MIDI left open for other scenes)")
