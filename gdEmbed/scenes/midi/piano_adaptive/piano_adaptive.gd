extends Control

# Adaptive MIDI Piano - Complete Rewrite
# Clean octave-based layout for MIDI monitoring and touch keyboard

# Piano configuration
const KEYS_PER_OCTAVE = 12
const MIN_OCTAVES_PER_ROW = 1
const MAX_OCTAVES_PER_ROW = 4
const MIN_ROWS = 1
const MAX_ROWS = 8
const MIDI_MIN = 0    # C-1
const MIDI_MAX = 127  # G9

# Current settings
var octaves_per_row: int = 2  # Default to 2 octaves per row
var num_rows: int = 2         # Default to 2 rows
var start_octave: int = 1     # Start from C1 (MIDI 24)

# Scene references
const WhiteKeyScene := preload("res://scenes/midi/piano_adaptive/piano_keys/white_piano_key_adaptive.tscn")
const BlackKeyScene := preload("res://scenes/midi/piano_adaptive/piano_keys/black_piano_key_adaptive.tscn")

# UI nodes
@onready var piano_rows_container: VBoxContainer = $VBoxContainer/PianoContainer/PianoMargin/PianoVBox/PianoRowsContainer
@onready var toggle_controls_button: Button = $VBoxContainer/ControlsTogglePanel/ToggleHBox/ToggleControlsButton
@onready var quick_info_label: Label = $VBoxContainer/ControlsTogglePanel/ToggleHBox/QuickInfoLabel
@onready var controls_overlay: PanelContainer = $VBoxContainer/ControlsOverlay
@onready var octaves_down_button: Button = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/OctaveGroup/OctaveControlsHBox/OctaveDownButton
@onready var octaves_up_button: Button = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/OctaveGroup/OctaveControlsHBox/OctaveUpButton
@onready var current_octave_label: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/OctaveGroup/OctaveControlsHBox/CurrentOctaveLabel
@onready var keys_down_button: Button = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/LayoutGroup/LayoutControlsHBox/KeysControls/KeysHBox/KeysDownButton
@onready var keys_up_button: Button = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/LayoutGroup/LayoutControlsHBox/KeysControls/KeysHBox/KeysUpButton
@onready var current_keys_label: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/LayoutGroup/LayoutControlsHBox/KeysControls/KeysHBox/CurrentKeysLabel
@onready var rows_down_button: Button = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/LayoutGroup/LayoutControlsHBox/RowsControls/RowsHBox/RowsDownButton
@onready var rows_up_button: Button = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/LayoutGroup/LayoutControlsHBox/RowsControls/RowsHBox/RowsUpButton
@onready var current_rows_label: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/LayoutGroup/LayoutControlsHBox/RowsControls/RowsHBox/CurrentRowsLabel
@onready var volume_slider: HSlider = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/AudioControlsHBox/VolumeGroup/VolumeControlsHBox/VolumeSlider
@onready var volume_value_label: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/AudioControlsHBox/VolumeGroup/VolumeControlsHBox/VolumeValueLabel
@onready var key_count_label: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/OctaveControlsHBox/OctaveGroup/OctaveControlsHBox/KeyCountLabel
@onready var resolution_info: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/AudioControlsHBox/StatusGroup/StatusVBox/ResolutionInfo
@onready var velocity_toggle: CheckButton = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/AudioControlsHBox/MIDIGroup/MIDIControlsVBox/VelocityToggle
@onready var note_off_toggle: CheckButton = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/AudioControlsHBox/MIDIGroup/MIDIControlsVBox/NoteOffToggle
@onready var key_count_label2: Label = $VBoxContainer/ControlsOverlay/ControlsMargin/ControlsVBox/AudioControlsHBox/StatusGroup/StatusVBox/KeyCountLabel2

# Piano state
var piano_keys := Dictionary()  # MIDI note -> key instance
var active_notes := Dictionary()  # MIDI note -> bool (currently playing)
var audio_players := Dictionary()  # MIDI note -> Array[AudioStreamPlayer] (for polyphonic playback)
var current_volume: float = 0.8
var is_mobile_layout: bool = false
var _is_resizing: bool = false
var _resize_timer: Timer
var last_midi_velocity: int = 0  # Track last MIDI velocity for display
var ignore_velocity: bool = false  # Toggle to ignore incoming MIDI velocity
var ignore_note_off: bool = false  # Toggle to ignore MIDI note off messages

# Audio system for notes outside visible range
var base_audio_stream: AudioStream

func _ready() -> void:
	print("🎹 Initializing Adaptive MIDI Piano (Clean Version)...")
	
	_setup_resize_timer()
	_setup_audio_system()
	await _wait_for_layout()
	_connect_signals()
	await _detect_screen_layout()
	_apply_mobile_optimizations()
	_update_all_displays()
	_create_piano_layout()
	_setup_midi_input()
	
	print("🎹 Piano ready! %d rows × %d octave(s) = %d total octaves" % [
		num_rows, octaves_per_row, num_rows * octaves_per_row
	])

func _setup_resize_timer() -> void:
	_resize_timer = Timer.new()
	_resize_timer.wait_time = 0.3
	_resize_timer.one_shot = true
	_resize_timer.timeout.connect(_on_resize_complete)
	add_child(_resize_timer)

func _setup_audio_system() -> void:
	# Load the base audio stream (A440) for pitch-shifting
	base_audio_stream = preload("res://scenes/midi/piano/piano_keys/A440.wav")
	print("🔊 Audio system initialized for full MIDI range")

func _wait_for_layout() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _connect_signals() -> void:
	toggle_controls_button.pressed.connect(_on_toggle_controls)
	octaves_down_button.pressed.connect(_on_octaves_down)
	octaves_up_button.pressed.connect(_on_octaves_up)
	keys_down_button.pressed.connect(_on_octaves_per_row_down)
	keys_up_button.pressed.connect(_on_octaves_per_row_up)
	rows_down_button.pressed.connect(_on_rows_down)
	rows_up_button.pressed.connect(_on_rows_up)
	volume_slider.value_changed.connect(_on_volume_changed)
	velocity_toggle.toggled.connect(_on_velocity_toggle_changed)
	note_off_toggle.toggled.connect(_on_note_off_toggle_changed)
	resized.connect(_on_control_resized)

func _detect_screen_layout() -> void:
	await get_tree().process_frame
	var screen_size = size
	is_mobile_layout = screen_size.x < 768 or screen_size.y < 600
	
	if resolution_info:
		resolution_info.text = "%dx%d" % [screen_size.x, screen_size.y]
	
	print("📱 Layout: %s (%dx%d)" % [
		"Mobile" if is_mobile_layout else "Desktop", 
		screen_size.x, screen_size.y
	])

func _apply_mobile_optimizations() -> void:
	if is_mobile_layout:
		# Mobile: keep current settings or use smaller layout
		if octaves_per_row > 2:
			octaves_per_row = 2
		if num_rows > 2:
			num_rows = 2
	else:
		# Desktop: can handle more rows if desired
		if octaves_per_row == 2 and num_rows == 2:
			# Keep defaults for desktop, they work well
			pass

func _create_piano_layout() -> void:
	_clear_all_keys()
	
	print("🎼 Creating piano: %d rows × %d octave(s) per row" % [num_rows, octaves_per_row])
	
	# Create rows from top to bottom (highest to lowest notes)
	for row_index in range(num_rows):
		var visual_row = row_index  # 0 = top row
		var logical_row = num_rows - 1 - row_index  # Reverse: 0 = bottom row (lowest notes)
		
		_create_row_separator(visual_row)
		_create_piano_row(visual_row, logical_row)

func _create_row_separator(row_index: int) -> void:
	if row_index == 0:
		return  # No separator above first row
	
	var separator = ColorRect.new()
	separator.name = "RowSeparator%d" % row_index
	separator.color = Color.BLACK
	separator.custom_minimum_size = Vector2(0, 4)
	separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	piano_rows_container.add_child(separator)

func _create_piano_row(visual_row_index: int, logical_row_index: int) -> void:
	# Calculate the starting octave for this logical row
	var row_start_octave = start_octave + (logical_row_index * octaves_per_row)
	var row_start_midi = _octave_to_midi_start(row_start_octave)
	var keys_in_row = octaves_per_row * KEYS_PER_OCTAVE
	
	print("🎼 Row %d (visual %d): octave %d-%d, MIDI %d-%d" % [
		logical_row_index + 1,
		visual_row_index + 1,
		row_start_octave,
		row_start_octave + octaves_per_row - 1,
		row_start_midi,
		row_start_midi + keys_in_row - 1
	])
	
	# Create row container
	var row_container = Control.new()
	row_container.name = "PianoRow%d" % visual_row_index
	row_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	piano_rows_container.add_child(row_container)
	
	# Create octave label
	_create_row_label(row_container, row_start_octave)
	
	# Create key containers
	var white_container = _create_white_keys_container(row_container)
	var black_container = _create_black_keys_container(row_container)
	
	# Create all keys for this row
	_create_keys_for_row(white_container, black_container, row_start_midi, keys_in_row)

func _create_row_label(parent: Control, start_octave: int) -> void:
	var label = Label.new()
	label.name = "OctaveLabel"
	label.text = "C%d" % start_octave
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.position = Vector2(8, 8)
	label.z_index = 100
	
	# Style the label
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	
	parent.add_child(label)

func _create_white_keys_container(parent: Control) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.name = "WhiteKeys"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(container)
	return container

func _create_black_keys_container(parent: Control) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.name = "BlackKeys"
	container.anchor_right = 1.0
	container.anchor_bottom = 0.6  # Black keys are 60% of row height
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(container)
	return container

func _create_keys_for_row(white_container: HBoxContainer, black_container: HBoxContainer, start_midi: int, key_count: int) -> void:
	var white_keys_created = 0
	
	for i in range(key_count):
		var midi_note = start_midi + i
		if midi_note > MIDI_MAX:
			break
			
		var note_in_octave = midi_note % KEYS_PER_OCTAVE
		var is_black_key = _is_black_key(note_in_octave)
		
		if is_black_key:
			_create_black_key(black_container, midi_note)
		else:
			_create_white_key(white_container, midi_note)
			white_keys_created += 1
			
			# Add black key placeholder if needed
			if _should_add_black_placeholder(midi_note, start_midi + key_count - 1):
				_create_black_placeholder(black_container)
	
	# Balance containers
	_balance_containers(white_container, black_container)

func _create_white_key(container: HBoxContainer, midi_note: int) -> void:
	var key = WhiteKeyScene.instantiate()
	if not key:
		print("❌ Failed to create white key for MIDI %d" % midi_note)
		return
	
	container.add_child(key)
	_setup_key(key, midi_note)
	piano_keys[midi_note] = key

func _create_black_key(container: HBoxContainer, midi_note: int) -> void:
	var key = BlackKeyScene.instantiate()
	if not key:
		print("❌ Failed to create black key for MIDI %d" % midi_note)
		return
	
	container.add_child(key)
	_setup_key(key, midi_note)
	piano_keys[midi_note] = key

func _create_black_placeholder(container: HBoxContainer) -> void:
	var placeholder = Control.new()
	placeholder.name = "BlackPlaceholder"
	placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(placeholder)

func _setup_key(key: Control, midi_note: int) -> void:
	key.setup(midi_note)
	
	if key.has_method("set_volume"):
		key.set_volume(current_volume)
	
	if key.has_method("set_mobile_mode"):
		key.set_mobile_mode(is_mobile_layout)

func _balance_containers(white_container: HBoxContainer, black_container: HBoxContainer) -> void:
	var white_count = white_container.get_child_count()
	var black_count = black_container.get_child_count()
	
	while black_count < white_count:
		_create_black_placeholder(black_container)
		black_count += 1

func _clear_all_keys() -> void:
	for child in piano_rows_container.get_children():
		child.queue_free()
	piano_keys.clear()
	
	# Don't clear active_notes here as we may be preserving them
	# But do cleanup any orphaned audio players for invisible notes
	_cleanup_orphaned_audio_players()
	
	await get_tree().process_frame

func _cleanup_orphaned_audio_players() -> void:
	# Clean up audio players for notes that are no longer active
	var notes_to_remove = []
	for midi_note in audio_players:
		if not active_notes.get(midi_note, false):
			var players_array = audio_players[midi_note]
			for audio_player in players_array:
				if is_instance_valid(audio_player):
					audio_player.stop()
					audio_player.queue_free()
			notes_to_remove.append(midi_note)
	
	for midi_note in notes_to_remove:
		audio_players.erase(midi_note)

func _setup_midi_input() -> void:
	OS.open_midi_inputs()
	var devices = OS.get_connected_midi_inputs()
	if not devices.is_empty():
		print("🎵 MIDI devices: %s" % devices)
	else:
		print("ℹ️ No MIDI devices detected")

func _input(event: InputEvent) -> void:
	if not event is InputEventMIDI:
		return
	
	var midi_event: InputEventMIDI = event
	var midi_note = midi_event.pitch
	
	if midi_event.message == MIDI_MESSAGE_NOTE_ON and midi_event.velocity > 0:
		last_midi_velocity = midi_event.velocity
		_play_midi_note(midi_note, midi_event.velocity)
		active_notes[midi_note] = true
		_update_velocity_display()
	elif not ignore_note_off:
		# Only process note off if not ignoring them
		_stop_midi_note(midi_note)
		active_notes[midi_note] = false

func _play_midi_note(midi_note: int, velocity: int) -> void:
	# Always use our centralized audio system for consistent velocity response
	_create_audio_for_note(midi_note, velocity)
	
	# If there's a visible key, activate its visual feedback only (no audio)
	var key = piano_keys.get(midi_note)
	if key:
		_activate_key_visual_only(key)
		print("🎵 Playing visible MIDI note %d (velocity %d)" % [midi_note, velocity])
	else:
		print("🎵 Playing invisible MIDI note %d (velocity %d)" % [midi_note, velocity])

func _stop_midi_note(midi_note: int) -> void:
	# Stop all audio players for this note (polyphonic)
	if midi_note in audio_players:
		var players_array = audio_players[midi_note]
		for audio_player in players_array:
			if audio_player and is_instance_valid(audio_player):
				audio_player.stop()
				audio_player.queue_free()
		audio_players.erase(midi_note)
	
	# If there's a visible key, deactivate its visual feedback
	var key = piano_keys.get(midi_note)
	if key:
		_deactivate_key_visual_only(key)

func _create_audio_for_note(midi_note: int, velocity: int) -> void:
	# Don't stop existing audio - allow polyphonic playback
	
	# Use fixed velocity if ignore_velocity is enabled
	var effective_velocity = 100 if ignore_velocity else velocity
	
	# Calculate pitch scale (A440 = MIDI 69 = 440Hz)
	var exponent := (midi_note - 69.0) / 12.0
	var pitch_scale = pow(2, exponent)
	
	# Create and configure audio player
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = base_audio_stream
	audio_player.pitch_scale = pitch_scale
	audio_player.volume_db = linear_to_db(current_volume * (effective_velocity / 127.0))
	
	# Add to scene and play
	add_child(audio_player)
	audio_player.play()
	
	# Store in polyphonic array
	if not midi_note in audio_players:
		audio_players[midi_note] = []
	audio_players[midi_note].append(audio_player)
	
	# Auto-cleanup after 8 seconds
	_cleanup_audio_after_delay(audio_player, midi_note)

func _cleanup_audio_after_delay(audio_player: AudioStreamPlayer, midi_note: int) -> void:
	# Wait 8 seconds then cleanup if still playing
	await get_tree().create_timer(8.0).timeout
	if is_instance_valid(audio_player):
		audio_player.queue_free()
		
		# Remove from the polyphonic array
		if midi_note in audio_players:
			var players_array = audio_players[midi_note]
			var index = players_array.find(audio_player)
			if index >= 0:
				players_array.remove_at(index)
			
			# If no more players for this note, remove the array
			if players_array.is_empty():
				audio_players.erase(midi_note)

func _recreate_piano_preserving_sound() -> void:
	# Store currently active notes - but don't duplicate audio
	var notes_to_restore = {}
	for midi_note in active_notes:
		if active_notes[midi_note]:
			notes_to_restore[midi_note] = true
	
	# Recreate the piano layout
	_create_piano_layout()
	
	# Restore ONLY visual state for notes that are still playing
	# (the audio is already playing and should not be recreated)
	for midi_note in notes_to_restore:
		if midi_note in piano_keys:
			var key = piano_keys[midi_note]
			if key:
				_activate_key_visual_only(key)
		
		# Keep the note marked as active
		active_notes[midi_note] = true

# Button handlers
func _on_toggle_controls() -> void:
	var is_visible = controls_overlay.visible
	controls_overlay.visible = not is_visible
	
	if controls_overlay.visible:
		toggle_controls_button.text = "Hide Controls ▲"
	else:
		toggle_controls_button.text = "Show Controls ▼"

func _on_octaves_down() -> void:
	start_octave = max(-1, start_octave - 1)
	_update_octave_display()
	_recreate_piano_preserving_sound()

func _on_octaves_up() -> void:
	start_octave = min(8, start_octave + 1)
	_update_octave_display()
	_recreate_piano_preserving_sound()

func _on_octaves_per_row_down() -> void:
	octaves_per_row = max(MIN_OCTAVES_PER_ROW, octaves_per_row - 1)
	_update_keys_display()
	_recreate_piano_preserving_sound()

func _on_octaves_per_row_up() -> void:
	octaves_per_row = min(MAX_OCTAVES_PER_ROW, octaves_per_row + 1)
	_update_keys_display()
	_recreate_piano_preserving_sound()

func _on_rows_down() -> void:
	num_rows = max(MIN_ROWS, num_rows - 1)
	_update_rows_display()
	_recreate_piano_preserving_sound()

func _on_rows_up() -> void:
	num_rows = min(MAX_ROWS, num_rows + 1)
	_update_rows_display()
	_recreate_piano_preserving_sound()

func _on_volume_changed(value: float) -> void:
	current_volume = value
	
	# Update volume percentage display
	if volume_value_label:
		volume_value_label.text = "%d%%" % (value * 100)
	
	# Update quick info
	_update_quick_info()
	
	# Update volume for visible keys
	for key in piano_keys.values():
		if key.has_method("set_volume"):
			key.set_volume(current_volume)
	
	# Update volume for invisible note audio players (polyphonic)
	for players_array in audio_players.values():
		for audio_player in players_array:
			if is_instance_valid(audio_player):
				audio_player.volume_db = linear_to_db(current_volume)

func _on_velocity_toggle_changed(is_pressed: bool) -> void:
	ignore_velocity = is_pressed
	print("🎛️ Velocity sensitivity: %s" % ("IGNORED" if ignore_velocity else "ENABLED"))

func _on_note_off_toggle_changed(is_pressed: bool) -> void:
	ignore_note_off = is_pressed
	print("🎛️ Note Off messages: %s" % ("IGNORED" if ignore_note_off else "ENABLED"))

func _on_control_resized() -> void:
	if not _is_resizing:
		_is_resizing = true
		print("📐 Screen resized, debouncing...")
	_resize_timer.start()

func _on_resize_complete() -> void:
	_is_resizing = false
	print("📐 Resize complete, updating layout...")
	
	var old_mobile = is_mobile_layout
	await _detect_screen_layout()
	
	if old_mobile != is_mobile_layout:
		print("📐 Layout type changed, optimizing...")
		_apply_mobile_optimizations()
		_update_all_displays()
		_create_piano_layout()

# Display updates
func _update_all_displays() -> void:
	_update_octave_display()
	_update_keys_display()
	_update_rows_display()
	_update_velocity_display()
	_update_quick_info()

func _update_quick_info() -> void:
	# Update the quick info display in the toggle panel
	var total_octaves = num_rows * octaves_per_row
	var end_octave = start_octave + total_octaves - 1
	var total_keys = num_rows * octaves_per_row * KEYS_PER_OCTAVE
	var volume_percent = int(current_volume * 100)
	var velocity_text = "FIXED" if ignore_velocity else str(last_midi_velocity)
	
	if quick_info_label:
		quick_info_label.text = "C%d-C%d | %d keys | Vol: %d%% | Vel: %s" % [
			start_octave, end_octave, total_keys, volume_percent, velocity_text
		]

func _update_octave_display() -> void:
	var total_octaves = num_rows * octaves_per_row
	var end_octave = start_octave + total_octaves - 1
	current_octave_label.text = "C%d-C%d" % [start_octave, end_octave]
	
	# Update key count in the octave group
	var total_keys = num_rows * octaves_per_row * KEYS_PER_OCTAVE
	if key_count_label:
		key_count_label.text = "Keys: %d" % total_keys
	
	# Enable/disable buttons
	octaves_down_button.disabled = start_octave <= -1
	octaves_up_button.disabled = start_octave >= 8

func _update_keys_display() -> void:
	current_keys_label.text = "%d oct/row" % octaves_per_row
	
	keys_down_button.disabled = octaves_per_row <= MIN_OCTAVES_PER_ROW
	keys_up_button.disabled = octaves_per_row >= MAX_OCTAVES_PER_ROW

func _update_rows_display() -> void:
	current_rows_label.text = str(num_rows)
	
	rows_down_button.disabled = num_rows <= MIN_ROWS
	rows_up_button.disabled = num_rows >= MAX_ROWS

func _update_velocity_display() -> void:
	# Update the key count label to also show velocity info
	var total_keys = num_rows * octaves_per_row * KEYS_PER_OCTAVE
	var velocity_text = "FIXED" if ignore_velocity else str(last_midi_velocity)
	if key_count_label2:
		key_count_label2.text = "%d keys | Vel: %s" % [total_keys, velocity_text]
	
	_update_quick_info()

func _activate_key_visual_only(key: Control) -> void:
	# Activate only the visual feedback without triggering the key's internal audio
	if key.has_node("Key"):
		var key_rect = key.get_node("Key")
		if key_rect is ColorRect:
			var start_color = key_rect.color
			key_rect.color = (Color.YELLOW + start_color) / 2
			
			# Start the color timer if it exists
			if key.has_node("ColorTimer"):
				var color_timer = key.get_node("ColorTimer")
				if color_timer is Timer:
					color_timer.start()

func _deactivate_key_visual_only(key: Control) -> void:
	# Deactivate only the visual feedback
	if key.has_node("Key"):
		var key_rect = key.get_node("Key")
		if key_rect is ColorRect and key_rect.has_method("get_start_color"):
			# Try to restore original color if available
			var start_color = key_rect.get("start_color")
			if start_color:
				key_rect.color = start_color
		elif key_rect is ColorRect:
			# Fallback to white for white keys, black for black keys
			var is_black = key.name.begins_with("Black") or "black" in key.name.to_lower()
			key_rect.color = Color.BLACK if is_black else Color(0.95, 0.95, 0.95, 1)

# Helper functions
func _octave_to_midi_start(octave: int) -> int:
	# C-1 = MIDI 0, C0 = MIDI 12, C1 = MIDI 24, etc.
	return (octave + 1) * KEYS_PER_OCTAVE

func _is_black_key(note_in_octave: int) -> bool:
	# Black keys: C#=1, D#=3, F#=6, G#=8, A#=10
	return note_in_octave in [1, 3, 6, 8, 10]

func _should_add_black_placeholder(current_midi: int, last_midi: int) -> bool:
	var note = current_midi % KEYS_PER_OCTAVE
	var next_midi = current_midi + 1
	
	# Add placeholder if next note would be white (gap between white keys)
	if next_midi <= last_midi:
		var next_note = next_midi % KEYS_PER_OCTAVE
		return not _is_black_key(next_note)
	else:
		# Last key in row, add placeholder if this white key normally has a black key after it
		return note in [0, 2, 4, 5, 7, 9]  # C, D, E, F, G, A (all except B)
