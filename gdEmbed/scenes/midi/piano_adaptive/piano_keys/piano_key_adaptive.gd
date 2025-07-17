class_name PianoKeyAdaptive
extends Control

# Adaptive Piano Key with responsive behavior
# Adjusts size, labels, and touch targets based on screen size

var pitch_scale: float
var pitch_index: int
var note_name: String
var volume: float = 0.8
var is_mobile: bool = false

@onready var key: ColorRect = $Key
@onready var start_color: Color = key.color
@onready var color_timer: Timer = $ColorTimer
@onready var key_label: Label = $Key/KeyLabel
@onready var key_border: NinePatchRect = $Key/KeyBorder

func setup(pitch_idx: int) -> void:
	pitch_index = pitch_idx
	name = "PianoKey" + str(pitch_index)
	
	# Calculate pitch scale for audio
	var exponent := (pitch_index - 69.0) / 12.0
	pitch_scale = pow(2, exponent)
	
	# Calculate note name
	note_name = _get_note_name(pitch_index)
	
	# Update label
	if key_label:
		key_label.text = note_name
		_update_label_visibility()

func set_volume(vol: float) -> void:
	volume = vol

func set_mobile_mode(mobile: bool) -> void:
	is_mobile = mobile
	_update_appearance()

func _update_appearance() -> void:
	if is_mobile:
		# Larger touch targets on mobile
		if _is_white_key():
			custom_minimum_size = Vector2(25, 150)
		else:
			custom_minimum_size = Vector2(18, 100)
		
		# Larger font on mobile
		if key_label:
			key_label.add_theme_font_size_override("font_size", 10)
	else:
		# Standard desktop sizes
		if _is_white_key():
			custom_minimum_size = Vector2(20, 120)
		else:
			custom_minimum_size = Vector2(15, 80)
		
		# Standard font size
		if key_label:
			key_label.add_theme_font_size_override("font_size", 8)
	
	_update_label_visibility()

func _update_label_visibility() -> void:
	if not key_label:
		return
	
	# Show labels on white keys and some black keys for better UX
	var should_show_label = false
	
	if _is_white_key():
		# Show labels on C, F notes for orientation
		should_show_label = note_name.begins_with("C") or note_name.begins_with("F")
	else:
		# Show labels on black keys only in mobile mode for better touch feedback
		should_show_label = is_mobile
	
	key_label.visible = should_show_label

func activate() -> void:
	# Visual feedback with adaptive colors
	var activation_color: Color
	if _is_white_key():
		activation_color = Color(0.9, 0.9, 0.3, 1)  # Bright yellow for white keys
	else:
		activation_color = Color(0.8, 0.3, 0.3, 1)  # Red for black keys
	
	key.color = activation_color
	
	# Audio playback with volume control
	var audio := AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = preload("res://scenes/midi/piano/piano_keys/A440.wav")
	audio.pitch_scale = pitch_scale
	audio.volume_db = linear_to_db(volume)
	audio.play()
	
	# Visual feedback duration (shorter on mobile for responsiveness)
	var feedback_duration = 0.3 if is_mobile else 0.5
	color_timer.wait_time = feedback_duration
	color_timer.start()
	
	# Cleanup audio after playing
	await get_tree().create_timer(8.0).timeout
	if audio and is_instance_valid(audio):
		audio.queue_free()

func deactivate() -> void:
	key.color = start_color

func _is_white_key() -> bool:
	var note_index = _pitch_index_to_note_index(pitch_index)
	return not _is_note_index_sharp(note_index)

func _get_note_name(pitch: int) -> String:
	var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	var octave = int((pitch - 12) / 12)
	var note_index = (pitch - 12) % 12
	return note_names[note_index] + str(octave)

func _pitch_index_to_note_index(pitch: int) -> int:
	pitch += 3
	return pitch % 12

func _is_note_index_sharp(note_index: int) -> bool:
	return note_index in [1, 4, 6, 9, 11]  # A#, C#, D#, F#, G#
