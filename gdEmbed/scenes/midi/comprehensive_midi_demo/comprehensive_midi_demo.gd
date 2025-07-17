extends Node2D

# Comprehensive MIDI Demo
# Demonstrates MIDI input, device selection, debug display, and sampler with ADSR

# UI References
@onready var ui_container = $UIContainer
@onready var midi_status_label = $UIContainer/StatusPanel/VBoxContainer/MIDIStatusLabel
@onready var device_selector = $UIContainer/DevicePanel/VBoxContainer/DeviceSelector
@onready var refresh_devices_btn = $UIContainer/DevicePanel/VBoxContainer/RefreshButton
@onready var permission_btn = $UIContainer/DevicePanel/VBoxContainer/PermissionButton
@onready var midi_log = $UIContainer/DebugPanel/VBoxContainer/MIDILog
@onready var clear_log_btn = $UIContainer/DebugPanel/VBoxContainer/ClearButton

# Sampler UI
@onready var volume_slider = $UIContainer/SamplerPanel/VBoxContainer/VolumeContainer/VolumeSlider
@onready var volume_label = $UIContainer/SamplerPanel/VBoxContainer/VolumeContainer/VolumeLabel

# ADSR UI
@onready var attack_slider = $UIContainer/ADSRPanel/VBoxContainer/AttackContainer/AttackSlider
@onready var decay_slider = $UIContainer/ADSRPanel/VBoxContainer/DecayContainer/DecaySlider
@onready var sustain_slider = $UIContainer/ADSRPanel/VBoxContainer/SustainContainer/SustainSlider
@onready var release_slider = $UIContainer/ADSRPanel/VBoxContainer/ReleaseContainer/ReleaseSlider
@onready var attack_label = $UIContainer/ADSRPanel/VBoxContainer/AttackContainer/AttackLabel
@onready var decay_label = $UIContainer/ADSRPanel/VBoxContainer/DecayContainer/DecayLabel
@onready var sustain_label = $UIContainer/ADSRPanel/VBoxContainer/SustainContainer/SustainLabel
@onready var release_label = $UIContainer/ADSRPanel/VBoxContainer/ReleaseContainer/ReleaseLabel

# Demo area references
@onready var demo_area = $DemoArea
@onready var keyboard_visual = $DemoArea/KeyboardVisual
@onready var envelope_display = $DemoArea/EnvelopeDisplay

# Audio system
var audio_streams: Dictionary = {}
var active_notes: Dictionary = {}  # pitch -> {player, envelope_tween, note_info}
var max_polyphony = 8
var current_volume = 0.8

# ADSR parameters
var attack_time = 0.1
var decay_time = 0.3
var sustain_level = 0.7
var release_time = 0.5

# MIDI state
var midi_initialized = false
var connected_devices: PackedStringArray = []
var last_midi_message: Dictionary = {}

# Demo metadata
var demo_title = "Comprehensive MIDI Demo"
var demo_description = "Complete MIDI input handling with device selection, debug display, and sampler with ADSR"

func _ready():
	print("🎹 Initializing Comprehensive MIDI Demo...")
	_setup_ui()
	_load_audio_samples()
	_setup_demo_area()
	_initialize_midi()
	_setup_keyboard_visual()
	_update_ui()
	print("✅ MIDI Demo Ready!")

func _setup_ui():
	# Setup device controls
	refresh_devices_btn.pressed.connect(_refresh_midi_devices)
	permission_btn.pressed.connect(_request_midi_permission)
	device_selector.item_selected.connect(_on_device_selected)
	clear_log_btn.pressed.connect(_clear_midi_log)
	
	# Setup sampler controls
	volume_slider.value = current_volume * 100
	volume_slider.value_changed.connect(_on_volume_changed)
	
	# Setup ADSR controls
	attack_slider.value = attack_time * 1000  # Convert to ms
	decay_slider.value = decay_time * 1000
	sustain_slider.value = sustain_level * 100  # Convert to percentage
	release_slider.value = release_time * 1000
	
	attack_slider.value_changed.connect(_on_attack_changed)
	decay_slider.value_changed.connect(_on_decay_changed)
	sustain_slider.value_changed.connect(_on_sustain_changed)
	release_slider.value_changed.connect(_on_release_changed)
	
	_update_adsr_labels()

func _load_audio_samples():
	# Load available audio samples
	var sample_paths = [
		"res://assets/audio/1_bar_120bpm_ripplerx-malletripplerx-mallet.ogg",
		"res://assets/audio/1_bar_120bpm_surge-dreamssurge-dreams.ogg"
	]
	
	for i in range(sample_paths.size()):
		var path = sample_paths[i]
		if ResourceLoader.exists(path):
			audio_streams[i] = load(path)
			print("✅ Loaded audio sample: ", path)
		else:
			print("❌ Audio sample not found: ", path)
	
	# Generate some simple synthetic tones for additional notes
	_generate_synthetic_tones()

func _generate_synthetic_tones():
	# Create simple tone mappings for different MIDI notes
	# We'll use the existing samples and map them to note ranges
	var note_frequencies = {
		60: 261.63,  # C4 (Middle C)
		61: 277.18,  # C#4
		62: 293.66,  # D4
		63: 311.13,  # D#4
		64: 329.63,  # E4
		65: 349.23,  # F4
		66: 369.99,  # F#4
		67: 392.00,  # G4
		68: 415.30,  # G#4
		69: 440.00,  # A4
		70: 466.16,  # A#4
		71: 493.88,  # B4
	}
	
	# Map frequencies to existing samples with pitch shifting
	for note in note_frequencies.keys():
		audio_streams[note] = {
			"type": "pitched_sample", 
			"base_sample": 0,  # Use first sample as base
			"frequency": note_frequencies[note],
			"base_frequency": 440.0  # A4 as reference
		}

func _setup_demo_area():
	# Position demo area
	demo_area.position = Vector2(350, 50)

func _setup_keyboard_visual():
	# Create visual keyboard representation
	keyboard_visual.position = Vector2(0, 0)
	_create_keyboard_keys()

func _create_keyboard_keys():
	# Create visual piano keys
	var key_width = 40
	var key_height = 120
	var black_key_height = 80
	var black_key_width = 25
	
	# White keys (C, D, E, F, G, A, B)
	var white_key_positions = [0, 1, 2, 3, 4, 5, 6]
	for i in range(white_key_positions.size()):
		var key = ColorRect.new()
		key.size = Vector2(key_width - 2, key_height)
		key.position = Vector2(i * key_width, 0)
		key.color = Color.WHITE
		key.add_theme_color_override("background_color", Color.WHITE)
		key.name = "WhiteKey_" + str(60 + i)  # MIDI note numbers
		keyboard_visual.add_child(key)
		
		# Add border
		key.add_theme_constant_override("border_width", 1)
		key.material = preload("res://scenes/common_tutorial.gd")  # This won't work, but shows intent
	
	# Black keys (C#, D#, F#, G#, A#)
	var black_key_offsets = [0.7, 1.7, 3.7, 4.7, 5.7]  # Relative positions
	for i in range(black_key_offsets.size()):
		var key = ColorRect.new()
		key.size = Vector2(black_key_width, black_key_height)
		key.position = Vector2(black_key_offsets[i] * key_width - black_key_width/2, 0)
		key.color = Color.BLACK
		key.z_index = 1  # Put black keys on top
		key.name = "BlackKey_" + str(61 + i)  # MIDI note numbers for black keys
		keyboard_visual.add_child(key)

func _initialize_midi():
	print("🎹 Initializing MIDI system...")
	
	# Check if we're on web platform
	if OS.has_feature("web"):
		print("🌐 Web platform detected - MIDI will require browser permission")
		permission_btn.visible = true
		midi_status_label.text = "Web MIDI requires permission. Click 'Request Permission' button."
	else:
		print("🖥️ Desktop platform detected - initializing MIDI directly")
		permission_btn.visible = false
		_open_midi_inputs()

func _request_midi_permission():
	print("🔒 Requesting MIDI permission...")
	midi_status_label.text = "Requesting MIDI permission..."
	_open_midi_inputs()

func _open_midi_inputs():
	print("🎹 Attempting to open MIDI inputs...")
	
	# Check if MIDI is already available (from previous scene)
	var devices_before = OS.get_connected_midi_inputs()
	print("🔍 MIDI devices before opening: %d" % devices_before.size())
	
	# Always call open_midi_inputs to ensure proper initialization
	OS.open_midi_inputs()
	
	# Wait a moment for device detection to complete
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	midi_initialized = true
	midi_status_label.text = "MIDI initialized successfully!"
	midi_status_label.modulate = Color.GREEN
	_refresh_midi_devices()
	print("✅ MIDI inputs opened successfully")

func _refresh_midi_devices():
	if not midi_initialized:
		print("⚠️ MIDI not initialized, cannot refresh devices")
		return
	
	print("🔄 Refreshing MIDI devices...")
	
	# Add a small delay to ensure device detection is complete
	await get_tree().process_frame
	
	connected_devices = OS.get_connected_midi_inputs()
	print("🔍 Device detection result: %d devices found" % connected_devices.size())
	
	# Update device selector
	device_selector.clear()
	device_selector.add_item("No device selected")
	
	if connected_devices.size() > 0:
		for device in connected_devices:
			device_selector.add_item(device)
			print("📱 Added device: %s" % device)
		midi_status_label.text = "Found %d MIDI device(s)" % connected_devices.size()
		midi_status_label.modulate = Color.GREEN
		print("✅ Found MIDI devices: ", connected_devices)
	else:
		midi_status_label.text = "No MIDI devices found"
		midi_status_label.modulate = Color.YELLOW
		print("⚠️ No MIDI devices found - try refreshing or checking connections")

func _on_device_selected(index: int):
	if index == 0:
		print("📱 No MIDI device selected")
	else:
		var device_name = connected_devices[index - 1]
		print("📱 Selected MIDI device: ", device_name)
		midi_status_label.text = "Selected: " + device_name

func _clear_midi_log():
	midi_log.clear()
	print("🧹 MIDI log cleared")

func _on_volume_changed(value: float):
	current_volume = value / 100.0
	volume_label.text = "Volume: %d%%" % int(value)
	print("🔊 Volume changed to: ", current_volume)

func _on_attack_changed(value: float):
	attack_time = value / 1000.0  # Convert from ms
	attack_label.text = "Attack: %dms" % int(value)

func _on_decay_changed(value: float):
	decay_time = value / 1000.0
	decay_label.text = "Decay: %dms" % int(value)

func _on_sustain_changed(value: float):
	sustain_level = value / 100.0
	sustain_label.text = "Sustain: %d%%" % int(value)

func _on_release_changed(value: float):
	release_time = value / 1000.0
	release_label.text = "Release: %dms" % int(value)

func _update_adsr_labels():
	attack_label.text = "Attack: %dms" % int(attack_time * 1000)
	decay_label.text = "Decay: %dms" % int(decay_time * 1000)
	sustain_label.text = "Sustain: %d%%" % int(sustain_level * 100)
	release_label.text = "Release: %dms" % int(release_time * 1000)

func _update_ui():
	volume_label.text = "Volume: %d%%" % int(current_volume * 100)

func _input(event):
	if event is InputEventMIDI:
		_handle_midi_event(event)

func _handle_midi_event(midi_event: InputEventMIDI):
	# Log the MIDI message
	_log_midi_message(midi_event)
	
	# Handle different MIDI message types
	match midi_event.message:
		MIDI_MESSAGE_NOTE_ON:
			if midi_event.velocity > 0:
				_play_note(midi_event.pitch, midi_event.velocity, midi_event.channel)
			else:
				# Note on with velocity 0 is treated as note off
				_stop_note(midi_event.pitch, midi_event.channel)
		
		MIDI_MESSAGE_NOTE_OFF:
			_stop_note(midi_event.pitch, midi_event.channel)
		
		MIDI_MESSAGE_CONTROL_CHANGE:
			_handle_control_change(midi_event)
		
		MIDI_MESSAGE_PITCH_BEND:
			_handle_pitch_bend(midi_event)
	
	# Update visual feedback
	_update_keyboard_visual(midi_event)
	_update_envelope_display()

func _log_midi_message(midi_event: InputEventMIDI):
	var message_type = ""
	match midi_event.message:
		MIDI_MESSAGE_NOTE_ON:
			message_type = "NOTE ON"
		MIDI_MESSAGE_NOTE_OFF:
			message_type = "NOTE OFF"
		MIDI_MESSAGE_CONTROL_CHANGE:
			message_type = "CC"
		MIDI_MESSAGE_PITCH_BEND:
			message_type = "PITCH BEND"
		MIDI_MESSAGE_AFTERTOUCH:
			message_type = "AFTERTOUCH"
		_:
			message_type = "OTHER"
	
	var log_entry = "[%s] Ch:%d Note:%d Vel:%d CC:%d Val:%d" % [
		message_type,
		midi_event.channel + 1,  # Display as 1-16 instead of 0-15
		midi_event.pitch,
		midi_event.velocity,
		midi_event.controller_number,
		midi_event.controller_value
	]
	
	midi_log.text += log_entry + "\n"
	
	# Keep log manageable
	var lines = midi_log.text.split("\n")
	if lines.size() > 50:
		lines = lines.slice(-40)  # Keep last 40 lines
		midi_log.text = "\n".join(lines)
	
	# Auto-scroll to bottom
	midi_log.scroll_vertical = midi_log.get_line_count()

func _play_note(pitch: int, velocity: int, channel: int):
	print("🎵 Playing note: pitch=%d, velocity=%d, channel=%d" % [pitch, velocity, channel])
	
	# Stop existing note if playing
	if active_notes.has(pitch):
		_stop_note_immediately(pitch)
	
	# Create audio player
	var audio_player = AudioStreamPlayer.new()
	demo_area.add_child(audio_player)
	
	# Get audio stream for this pitch
	var audio_stream = _get_audio_stream_for_pitch(pitch)
	if audio_stream:
		audio_player.stream = audio_stream
		
		# Calculate pitch adjustment for mapped samples
		var pitch_scale = 1.0
		if audio_streams.has(pitch) and typeof(audio_streams[pitch]) == TYPE_DICTIONARY:
			var stream_data = audio_streams[pitch]
			if stream_data.has("type") and stream_data.type == "pitched_sample":
				pitch_scale = stream_data.frequency / stream_data.base_frequency
		
		# Set pitch scaling
		audio_player.pitch_scale = pitch_scale
		
		# Set initial volume (will be controlled by ADSR)
		audio_player.volume_db = linear_to_db(0.0)  # Start silent
		
		# Start playback
		audio_player.play()
		
		# Create ADSR envelope
		var envelope_tween = create_tween()
		envelope_tween.set_parallel(true)  # Allow multiple simultaneous tweens
		
		# Attack phase
		var attack_volume = (velocity / 127.0) * current_volume
		envelope_tween.tween_method(_set_note_volume.bind(audio_player), 0.0, attack_volume, attack_time)
		
		# Decay phase (to sustain level)
		var sustain_volume = attack_volume * sustain_level
		envelope_tween.tween_method(_set_note_volume.bind(audio_player), attack_volume, sustain_volume, decay_time).set_delay(attack_time)
		
		# Store note info
		active_notes[pitch] = {
			"player": audio_player,
			"envelope_tween": envelope_tween,
			"sustain_volume": sustain_volume,
			"channel": channel,
			"velocity": velocity,
			"start_time": Time.get_ticks_msec()
		}
		
		print("✅ Note %d started with %d polyphonic notes active" % [pitch, active_notes.size()])
	
	# Manage polyphony
	_manage_polyphony()

func _stop_note(pitch: int, channel: int):
	if not active_notes.has(pitch):
		return
	
	print("🔇 Stopping note: pitch=%d, channel=%d" % [pitch, channel])
	
	var note_info = active_notes[pitch]
	var audio_player = note_info.player
	var current_volume = db_to_linear(audio_player.volume_db)
	
	# Stop existing envelope
	if note_info.envelope_tween.is_valid():
		note_info.envelope_tween.kill()
	
	# Release phase
	var release_tween = create_tween()
	release_tween.tween_method(_set_note_volume.bind(audio_player), current_volume, 0.0, release_time)
	release_tween.tween_callback(_cleanup_note.bind(pitch)).set_delay(release_time)

func _stop_note_immediately(pitch: int):
	if not active_notes.has(pitch):
		return
	
	var note_info = active_notes[pitch]
	if note_info.envelope_tween.is_valid():
		note_info.envelope_tween.kill()
	
	note_info.player.queue_free()
	active_notes.erase(pitch)

func _cleanup_note(pitch: int):
	if active_notes.has(pitch):
		var note_info = active_notes[pitch]
		note_info.player.queue_free()
		active_notes.erase(pitch)
		print("🧹 Cleaned up note %d" % pitch)

func _set_note_volume(audio_player: AudioStreamPlayer, volume: float):
	if is_instance_valid(audio_player):
		audio_player.volume_db = linear_to_db(max(volume, 0.001))  # Prevent -inf dB

func _get_audio_stream_for_pitch(pitch: int) -> AudioStream:
	# Map MIDI pitch to available samples
	if audio_streams.has(pitch):
		var stream_data = audio_streams[pitch]
		if typeof(stream_data) == TYPE_DICTIONARY:
			if stream_data.has("type") and stream_data.type == "pitched_sample":
				# Use existing sample with pitch adjustment
				return audio_streams[stream_data.base_sample]
			else:
				# Fallback for other dictionary types
				return null
		else:
			return stream_data
	
	# Map to available samples using modulo
	var sample_keys = []
	for key in audio_streams.keys():
		if typeof(audio_streams[key]) != TYPE_DICTIONARY:
			sample_keys.append(key)
	
	if sample_keys.size() > 0:
		var mapped_key = sample_keys[pitch % sample_keys.size()]
		return audio_streams[mapped_key]
	
	return null

func _manage_polyphony():
	# Limit polyphony to prevent audio issues
	if active_notes.size() > max_polyphony:
		# Find oldest note and stop it
		var oldest_pitch = -1
		var oldest_time = Time.get_ticks_msec()
		
		for pitch in active_notes.keys():
			var note_info = active_notes[pitch]
			if note_info.start_time < oldest_time:
				oldest_time = note_info.start_time
				oldest_pitch = pitch
		
		if oldest_pitch != -1:
			_stop_note_immediately(oldest_pitch)
			print("⚠️ Polyphony limit reached, stopped oldest note: %d" % oldest_pitch)

func _handle_control_change(midi_event: InputEventMIDI):
	match midi_event.controller_number:
		7:  # Volume CC
			var volume = midi_event.controller_value / 127.0
			current_volume = volume
			volume_slider.value = volume * 100
			_on_volume_changed(volume * 100)
		
		74:  # Filter cutoff (map to attack)
			var attack = (midi_event.controller_value / 127.0) * 1000  # 0-1000ms
			attack_slider.value = attack
			_on_attack_changed(attack)
		
		_:
			print("🎛️ Unhandled CC: %d = %d" % [midi_event.controller_number, midi_event.controller_value])

func _handle_pitch_bend(midi_event: InputEventMIDI):
	# Pitch bend affects all active notes
	var bend_amount = (midi_event.pitch - 8192) / 8192.0  # Convert to -1.0 to 1.0
	print("🎵 Pitch bend: %f" % bend_amount)
	
	# Apply pitch bend to all active notes
	for pitch in active_notes.keys():
		var note_info = active_notes[pitch]
		var audio_player = note_info.player
		if is_instance_valid(audio_player):
			# Simple pitch shifting (not perfect but demonstrates the concept)
			audio_player.pitch_scale = 1.0 + (bend_amount * 0.1)  # ±10% pitch change

func _update_keyboard_visual(midi_event: InputEventMIDI):
	# Highlight pressed keys
	if midi_event.message == MIDI_MESSAGE_NOTE_ON and midi_event.velocity > 0:
		_highlight_key(midi_event.pitch, true)
	elif midi_event.message == MIDI_MESSAGE_NOTE_OFF or (midi_event.message == MIDI_MESSAGE_NOTE_ON and midi_event.velocity == 0):
		_highlight_key(midi_event.pitch, false)

func _highlight_key(pitch: int, pressed: bool):
	# Find the visual key for this pitch
	var key_name = "WhiteKey_" + str(pitch)
	var key = keyboard_visual.get_node_or_null(key_name)
	
	if not key:
		key_name = "BlackKey_" + str(pitch)
		key = keyboard_visual.get_node_or_null(key_name)
	
	if key:
		if pressed:
			key.modulate = Color.YELLOW
		else:
			key.modulate = Color.WHITE

func _update_envelope_display():
	# Visual representation of ADSR envelope
	# This would be a more complex implementation in a real scenario
	if envelope_display:
		envelope_display.queue_redraw()

# Virtual keyboard for testing without MIDI device
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		# Map keyboard keys to MIDI notes for testing
		var key_to_pitch = {
			KEY_A: 60,  # C
			KEY_S: 62,  # D
			KEY_D: 64,  # E
			KEY_F: 65,  # F
			KEY_G: 67,  # G
			KEY_H: 69,  # A
			KEY_J: 71,  # B
			KEY_W: 61,  # C#
			KEY_E: 63,  # D#
			KEY_T: 66,  # F#
			KEY_Y: 68,  # G#
			KEY_U: 70   # A#
		}
		
		if key_to_pitch.has(event.keycode):
			var pitch = key_to_pitch[event.keycode]
			print("⌨️ Virtual keyboard note: %d" % pitch)
			_play_note(pitch, 100, 0)  # Velocity 100, channel 0
			_highlight_key(pitch, true)
	
	elif event is InputEventKey and not event.pressed:
		# Key release for virtual keyboard
		var key_to_pitch = {
			KEY_A: 60, KEY_S: 62, KEY_D: 64, KEY_F: 65, KEY_G: 67, KEY_H: 69, KEY_J: 71,
			KEY_W: 61, KEY_E: 63, KEY_T: 66, KEY_Y: 68, KEY_U: 70
		}
		
		if key_to_pitch.has(event.keycode):
			var pitch = key_to_pitch[event.keycode]
			_stop_note(pitch, 0)
			_highlight_key(pitch, false)

func _exit_tree():
	# Note: Don't close MIDI inputs here as it prevents other MIDI scenes from working
	# Godot will handle MIDI cleanup when the application closes
	if midi_initialized:
		# OS.close_midi_inputs() - Commented out to prevent MIDI persistence issues
		print("🧹 MIDI demo cleanup (MIDI left open for other scenes)")
	
	# Stop all active notes
	for pitch in active_notes.keys():
		_stop_note_immediately(pitch)
	
	print("👋 MIDI Demo cleanup complete")
