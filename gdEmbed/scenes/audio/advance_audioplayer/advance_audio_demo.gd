extends Control

# Professional Audio Sample Player
# Focused on waveform visualization with timeline and loop handles

var audio_player: AudioStreamPlayer
var wav_stream: AudioStreamWAV

# Core UI Elements
var main_container: VBoxContainer
var waveform_container: VBoxContainer
var waveform_display: Control
var timeline_container: HBoxContainer
var transport_container: HBoxContainer

# Transport Controls
var play_button: Button
var stop_button: Button
var loop_button: Button
var loop_type_button: Button

# Timeline Elements
var time_ruler: Control
var position_handle: Control
var loop_start_handle: Control
var loop_end_handle: Control

# Status and Info
var time_display: Label
var file_info: Label
var status_label: Label

# Quick Controls Panel
var volume_slider: HSlider
var pitch_slider: HSlider
var volume_label: Label
var pitch_label: Label
var pitch_reset_button: Button
var pitch_half_button: Button
var pitch_double_button: Button

# File Operations
var load_button: Button
var file_dialog: FileDialog

# Audio Data
var waveform_samples: PackedFloat32Array
var total_duration: float = 0.0
var playback_position: float = 0.0
var loop_start: float = 0.0
var loop_end: float = 1.0
var is_playing: bool = false
var is_looping: bool = false

# Waveform Display Properties
var waveform_height: float = 200.0
var handle_size: float = 20.0  # Increased from 12.0 for better accessibility
var timeline_height: float = 30.0

# Handle interaction
var dragging_handle: String = ""  # "start", "end", "region", or ""
var handle_hover: String = ""     # Which handle is being hovered
var drag_offset: Vector2 = Vector2.ZERO
var loop_region_width: float = 0.0  # Store loop region width when dragging

# Long press functionality - remove these as we're using separate buttons now
# var loop_button_press_time: float = 0.0
# var is_loop_button_pressed: bool = false
# var long_press_threshold: float = 0.8  # seconds
# var loop_type_popup: PopupMenu

var current_loop_type: int = 0  # 0=Forward, 1=PingPong, 2=Disabled

func _ready():
	print("🎵 Professional Audio Player starting...")
	setup_audio()
	setup_professional_ui()
	connect_signals()
	set_process(true)
	print("🎵 Professional Audio Player ready!")

func _process(delta):
	update_playback_display()
	# Handle keyboard input for octave changes
	_handle_keyboard_input()

func _handle_keyboard_input():
	# Check for octave up/down key presses
	if Input.is_action_just_pressed("ui_page_up") or Input.is_key_pressed(KEY_EQUAL):
		# Octave up - double the speed (clamp to maximum)
		var new_value = min(pitch_slider.value * 2.0, pitch_slider.max_value)
		pitch_slider.value = new_value
		_on_pitch_changed(new_value)
		status_label.text = "Octave UP - Speed: %.6fx" % new_value
		status_label.add_theme_color_override("font_color", Color.CYAN)
		print("🎵 Octave UP: %.6fx" % new_value)
	
	elif Input.is_action_just_pressed("ui_page_down") or Input.is_key_pressed(KEY_MINUS):
		# Octave down - halve the speed (clamp to minimum)
		var new_value = max(pitch_slider.value * 0.5, pitch_slider.min_value)
		pitch_slider.value = new_value
		_on_pitch_changed(new_value)
		status_label.text = "Octave DOWN - Speed: %.6fx" % new_value
		status_label.add_theme_color_override("font_color", Color.ORANGE)
		print("🎵 Octave DOWN: %.6fx" % new_value)

func setup_audio():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	create_demo_audio()
	
	if OS.has_feature("web"):
		audio_player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
	else:
		audio_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM

func create_demo_audio():
	print("🎵 Creating demo audio...")
	wav_stream = AudioStreamWAV.new()
	
	var sample_rate = 44100
	var duration = 3.0
	var sample_count = int(sample_rate * duration)
	
	waveform_samples = PackedFloat32Array()
	waveform_samples.resize(sample_count)
	
	var byte_data = PackedByteArray()
	byte_data.resize(sample_count * 2)
	
	# Create a more interesting demo waveform (chord progression)
	for i in range(sample_count):
		var t = float(i) / sample_rate
		var sample_value = 0.0
		
		# Add multiple frequencies for a richer sound
		sample_value += sin(2.0 * PI * 440.0 * t) * 0.3  # A4
		sample_value += sin(2.0 * PI * 554.37 * t) * 0.2  # C#5
		sample_value += sin(2.0 * PI * 659.25 * t) * 0.2  # E5
		
		# Add envelope for more natural sound
		var envelope = sin(PI * t / duration)
		sample_value *= envelope * 0.5
		
		waveform_samples[i] = sample_value
		
		var sample_16bit = int(clamp(sample_value * 32767.0, -32768.0, 32767.0))
		byte_data[i * 2] = sample_16bit & 0xFF
		byte_data[i * 2 + 1] = (sample_16bit >> 8) & 0xFF
	
	wav_stream.data = byte_data
	wav_stream.format = AudioStreamWAV.FORMAT_16_BITS
	wav_stream.mix_rate = sample_rate
	wav_stream.stereo = false
	wav_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	audio_player.stream = wav_stream
	total_duration = duration
	loop_end = duration
	print("🎵 Demo audio created: %.1fs duration" % duration)

func setup_professional_ui():
	print("🎵 Setting up professional UI...")
	
	# Ensure we fill the parent properly for navigation compatibility
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Main container with dark professional theme
	main_container = VBoxContainer.new()
	add_child(main_container)
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 0)
	
	# Header with file info and load button
	setup_header()
	
	# Main waveform area (takes most space)
	setup_waveform_area()
	
	# Timeline with time ruler and handles
	setup_timeline()
	
	# Transport controls
	setup_transport_controls()
	
	# Quick controls panel
	setup_quick_controls()
	
	# Status bar
	setup_status_bar()

func setup_header():
	var header = HBoxContainer.new()
	main_container.add_child(header)
	header.custom_minimum_size = Vector2(0, 40)
	header.add_theme_constant_override("separation", 10)
	
	# File info
	file_info = Label.new()
	file_info.text = "Demo Audio - 440Hz Chord | 44.1kHz 16-bit"
	file_info.add_theme_font_size_override("font_size", 12)
	file_info.add_theme_color_override("font_color", Color.WHITE)
	file_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(file_info)
	
	# Load button
	load_button = Button.new()
	load_button.text = "LOAD"
	load_button.custom_minimum_size = Vector2(60, 30)
	load_button.add_theme_font_size_override("font_size", 11)
	header.add_child(load_button)
	
	# File dialog
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.wav", "WAV Audio Files")
	add_child(file_dialog)

func setup_waveform_area():
	# Waveform container with background
	waveform_container = VBoxContainer.new()
	main_container.add_child(waveform_container)
	waveform_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	waveform_container.add_theme_constant_override("separation", 0)
	
	# Waveform display
	waveform_display = Control.new()
	waveform_container.add_child(waveform_display)
	waveform_display.custom_minimum_size = Vector2(400, waveform_height)
	waveform_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	waveform_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	waveform_display.draw.connect(_draw_professional_waveform)
	waveform_display.gui_input.connect(_on_waveform_input)
	waveform_display.mouse_entered.connect(_on_waveform_mouse_entered)
	waveform_display.mouse_exited.connect(_on_waveform_mouse_exited)

func setup_timeline():
	# Timeline container
	timeline_container = HBoxContainer.new()
	main_container.add_child(timeline_container)
	timeline_container.custom_minimum_size = Vector2(0, timeline_height)
	timeline_container.add_theme_constant_override("separation", 0)
	
	# Time ruler
	time_ruler = Control.new()
	timeline_container.add_child(time_ruler)
	time_ruler.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	time_ruler.draw.connect(_draw_time_ruler)

func setup_transport_controls():
	transport_container = HBoxContainer.new()
	main_container.add_child(transport_container)
	transport_container.custom_minimum_size = Vector2(0, 50)
	transport_container.alignment = BoxContainer.ALIGNMENT_CENTER
	transport_container.add_theme_constant_override("separation", 15)
	
	# Play/Stop buttons with professional styling
	play_button = Button.new()
	play_button.text = "▶"
	play_button.custom_minimum_size = Vector2(50, 40)
	play_button.add_theme_font_size_override("font_size", 18)
	transport_container.add_child(play_button)
	
	stop_button = Button.new()
	stop_button.text = "⏹"
	stop_button.custom_minimum_size = Vector2(50, 40)
	stop_button.add_theme_font_size_override("font_size", 18)
	transport_container.add_child(stop_button)
	
	# Loop enable/disable toggle button
	loop_button = Button.new()
	loop_button.text = "🔄"
	loop_button.custom_minimum_size = Vector2(50, 40)
	loop_button.toggle_mode = true
	loop_button.add_theme_font_size_override("font_size", 16)
	transport_container.add_child(loop_button)
	
	# Loop type toggle button
	loop_type_button = Button.new()
	loop_type_button.text = "🔄"  # Start with forward loop icon
	loop_type_button.custom_minimum_size = Vector2(50, 40)
	loop_type_button.toggle_mode = false  # This cycles through types instead of toggling
	loop_type_button.add_theme_font_size_override("font_size", 16)
	transport_container.add_child(loop_type_button)
	
	# Time display
	time_display = Label.new()
	time_display.text = "00:00.00 / 00:00.00"
	time_display.add_theme_font_size_override("font_size", 14)
	time_display.add_theme_color_override("font_color", Color.WHITE)
	transport_container.add_child(time_display)

func setup_quick_controls():
	var controls_container = HBoxContainer.new()
	main_container.add_child(controls_container)
	controls_container.custom_minimum_size = Vector2(0, 60)
	controls_container.alignment = BoxContainer.ALIGNMENT_CENTER
	controls_container.add_theme_constant_override("separation", 20)
	
	# Volume control
	var vol_container = VBoxContainer.new()
	controls_container.add_child(vol_container)
	vol_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	volume_label = Label.new()
	volume_label.text = "VOL: 0dB"
	volume_label.add_theme_font_size_override("font_size", 10)
	volume_label.add_theme_color_override("font_color", Color.GRAY)
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vol_container.add_child(volume_label)
	
	volume_slider = HSlider.new()
	volume_slider.min_value = -30.0
	volume_slider.max_value = 6.0
	volume_slider.value = 0.0
	volume_slider.step = 1.0
	volume_slider.custom_minimum_size = Vector2(100, 20)
	vol_container.add_child(volume_slider)
	
	# Pitch control with octave buttons
	var pitch_container = VBoxContainer.new()
	controls_container.add_child(pitch_container)
	pitch_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	pitch_label = Label.new()
	pitch_label.text = "PITCH: 1.0x"
	pitch_label.add_theme_font_size_override("font_size", 10)
	pitch_label.add_theme_color_override("font_color", Color.GRAY)
	pitch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pitch_container.add_child(pitch_label)
	
	# Pitch controls sub-container: [slider] [1/2] [1x] [x2]
	var pitch_controls = HBoxContainer.new()
	pitch_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	pitch_controls.add_theme_constant_override("separation", 2)
	pitch_container.add_child(pitch_controls)
	
	# Pitch slider first
	pitch_slider = HSlider.new()
	pitch_slider.min_value = 0.000001  # Extreme slow-down for detailed analysis
	pitch_slider.max_value = 4.0       # Keep existing maximum
	pitch_slider.value = 1.0
	pitch_slider.step = 0.000001       # Fine-grained control for extreme values
	pitch_slider.custom_minimum_size = Vector2(100, 20)
	pitch_controls.add_child(pitch_slider)
	
	# Octave down button (1/2)
	pitch_half_button = Button.new()
	pitch_half_button.text = "1/2"
	pitch_half_button.custom_minimum_size = Vector2(25, 20)
	pitch_half_button.add_theme_font_size_override("font_size", 8)
	pitch_half_button.tooltip_text = "Octave down (halve pitch/speed)"
	pitch_controls.add_child(pitch_half_button)
	
	# Reset pitch button
	pitch_reset_button = Button.new()
	pitch_reset_button.text = "1x"
	pitch_reset_button.custom_minimum_size = Vector2(25, 20)
	pitch_reset_button.add_theme_font_size_override("font_size", 9)
	pitch_reset_button.tooltip_text = "Reset pitch to normal speed (1.0x)"
	pitch_controls.add_child(pitch_reset_button)
	
	# Octave up button (x2)
	pitch_double_button = Button.new()
	pitch_double_button.text = "x2"
	pitch_double_button.custom_minimum_size = Vector2(25, 20)
	pitch_double_button.add_theme_font_size_override("font_size", 9)
	pitch_double_button.tooltip_text = "Octave up (double pitch/speed)"
	pitch_controls.add_child(pitch_double_button)

func setup_status_bar():
	status_label = Label.new()
	main_container.add_child(status_label)
	status_label.text = "Ready - Professional Audio Player | Keys: +/- or PageUp/PageDown for octave changes"
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	status_label.custom_minimum_size = Vector2(0, 25)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func connect_signals():
	play_button.pressed.connect(_on_play_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	loop_button.toggled.connect(_on_loop_toggled)
	loop_type_button.pressed.connect(_on_loop_type_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	pitch_slider.value_changed.connect(_on_pitch_changed)
	pitch_reset_button.pressed.connect(_on_pitch_reset_pressed)
	pitch_half_button.pressed.connect(_on_pitch_half_pressed)
	pitch_double_button.pressed.connect(_on_pitch_double_pressed)
	load_button.pressed.connect(_on_load_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	audio_player.finished.connect(_on_audio_finished)

func _draw_professional_waveform():
	if not waveform_samples or waveform_samples.size() == 0:
		return
	
	var rect = waveform_display.get_rect()
	var center_y = rect.size.y / 2.0
	
	# Dark background
	waveform_display.draw_rect(rect, Color(0.1, 0.1, 0.1, 1.0))
	
	# Grid lines for professional look
	_draw_waveform_grid(rect)
	
	# Waveform
	_draw_waveform_data(rect, center_y)
	
	# Loop region highlight
	if is_looping:
		_draw_loop_region(rect)
	
	# Playback position
	_draw_playback_position(rect)
	
	# Loop handles
	_draw_loop_handles(rect)

func _draw_waveform_grid(rect: Rect2):
	# Vertical grid lines (time markers)
	var grid_color = Color(0.3, 0.3, 0.3, 0.5)
	var time_step = 0.5  # Every 0.5 seconds
	var steps = int(total_duration / time_step) + 1
	
	for i in range(steps):
		var time_pos = i * time_step
		var x = (time_pos / total_duration) * rect.size.x
		waveform_display.draw_line(
			Vector2(x, 0),
			Vector2(x, rect.size.y),
			grid_color, 1.0
		)
	
	# Center line
	waveform_display.draw_line(
		Vector2(0, rect.size.y / 2),
		Vector2(rect.size.x, rect.size.y / 2),
		Color(0.5, 0.5, 0.5, 0.8), 1.0
	)

func _draw_waveform_data(rect: Rect2, center_y: float):
	var samples_per_pixel = max(1, waveform_samples.size() / int(rect.size.x))
	var waveform_color = Color(0.2, 0.8, 1.0, 0.9)  # Bright cyan
	
	for x in range(int(rect.size.x)):
		var sample_index = x * samples_per_pixel
		if sample_index >= waveform_samples.size():
			break
		
		# Get peak value for this pixel column
		var peak = 0.0
		var end_index = min(sample_index + samples_per_pixel, waveform_samples.size())
		
		for i in range(sample_index, end_index):
			peak = max(peak, abs(waveform_samples[i]))
		
		var wave_height = peak * center_y * 0.9
		
		# Draw as filled rectangle for solid look
		var top_y = center_y - wave_height
		var bottom_y = center_y + wave_height
		
		waveform_display.draw_line(
			Vector2(x, top_y),
			Vector2(x, bottom_y),
			waveform_color, 1.0
		)

func _draw_loop_region(rect: Rect2):
	var start_x = (loop_start / total_duration) * rect.size.x
	var end_x = (loop_end / total_duration) * rect.size.x
	var loop_rect = Rect2(start_x, 0, end_x - start_x, rect.size.y)
	
	# Highlight region
	waveform_display.draw_rect(loop_rect, Color(1.0, 1.0, 0.0, 0.1))
	
	# Border lines
	waveform_display.draw_line(
		Vector2(start_x, 0), Vector2(start_x, rect.size.y),
		Color(0.0, 1.0, 0.0, 0.8), 2.0
	)
	waveform_display.draw_line(
		Vector2(end_x, 0), Vector2(end_x, rect.size.y),
		Color(1.0, 0.0, 0.0, 0.8), 2.0
	)

func _draw_playback_position(rect: Rect2):
	if total_duration > 0:
		var pos_x = (playback_position / total_duration) * rect.size.x
		waveform_display.draw_line(
			Vector2(pos_x, 0),
			Vector2(pos_x, rect.size.y),
			Color.WHITE, 3.0
		)

func _draw_loop_handles(rect: Rect2):
	var start_x = (loop_start / total_duration) * rect.size.x
	var end_x = (loop_end / total_duration) * rect.size.x
	
	# Draw extended visual area for better visibility
	var extended_handle_size = handle_size + 4.0
	
	# Loop start handle (green) - positioned at TOP for IN point
	var start_handle = Rect2(start_x - handle_size/2, 5, handle_size, handle_size)
	var start_color = Color.GREEN
	if handle_hover == "start":
		start_color = Color.LIME_GREEN  # Brighter when hovered
		# Draw larger hover indicator
		var hover_rect = Rect2(start_x - extended_handle_size/2, 0, extended_handle_size, extended_handle_size)
		waveform_display.draw_rect(hover_rect, Color(0.0, 1.0, 0.0, 0.3))
	if dragging_handle == "start":
		start_color = Color.YELLOW  # Yellow when dragging
	
	waveform_display.draw_rect(start_handle, start_color)
	
	# Add a visual indicator line extending down from top
	waveform_display.draw_line(
		Vector2(start_x, handle_size + 10),
		Vector2(start_x, rect.size.y),
		Color(0.0, 1.0, 0.0, 0.6), 2.0
	)
	
	# Loop end handle (red) - positioned at BOTTOM for OUT point
	var end_handle = Rect2(end_x - handle_size/2, rect.size.y - handle_size - 5, handle_size, handle_size)
	var end_color = Color.RED
	if handle_hover == "end":
		end_color = Color.ORANGE_RED  # Brighter when hovered
		# Draw larger hover indicator
		var hover_rect = Rect2(end_x - extended_handle_size/2, rect.size.y - extended_handle_size - 5, extended_handle_size, extended_handle_size)
		waveform_display.draw_rect(hover_rect, Color(1.0, 0.0, 0.0, 0.3))
	if dragging_handle == "end":
		end_color = Color.YELLOW  # Yellow when dragging
	
	waveform_display.draw_rect(end_handle, end_color)
	
	# Add a visual indicator line extending up from bottom
	waveform_display.draw_line(
		Vector2(end_x, 0),
		Vector2(end_x, rect.size.y - handle_size - 10),
		Color(1.0, 0.0, 0.0, 0.6), 2.0
	)
	
	# Loop region handle (blue) - positioned below the red handle for moving both points
	var region_center_x = (start_x + end_x) / 2.0
	var region_handle = Rect2(region_center_x - handle_size/2, rect.size.y - handle_size - 35, handle_size, handle_size)
	var region_color = Color.BLUE
	if handle_hover == "region":
		region_color = Color.CYAN  # Brighter when hovered
		# Draw larger hover indicator
		var hover_rect = Rect2(region_center_x - extended_handle_size/2, rect.size.y - extended_handle_size - 35, extended_handle_size, extended_handle_size)
		waveform_display.draw_rect(hover_rect, Color(0.0, 0.0, 1.0, 0.3))
	if dragging_handle == "region":
		region_color = Color.YELLOW  # Yellow when dragging
	
	waveform_display.draw_rect(region_handle, region_color)
	
	# Add visual connection lines to show region relationship
	waveform_display.draw_line(
		Vector2(start_x, rect.size.y - handle_size - 20),
		Vector2(region_center_x - handle_size/2, rect.size.y - handle_size - 25),
		Color(0.0, 0.0, 1.0, 0.4), 1.0
	)
	waveform_display.draw_line(
		Vector2(end_x, rect.size.y - handle_size - 20),
		Vector2(region_center_x + handle_size/2, rect.size.y - handle_size - 25),
		Color(0.0, 0.0, 1.0, 0.4), 1.0
	)
	
	# Add text labels for better accessibility
	if total_duration > 0:
		# Draw time labels near handles
		var start_time_text = "IN: %.3fs" % loop_start
		var end_time_text = "OUT: %.3fs" % loop_end
		var region_time_text = "REGION"
		
		# Simple text representation (in production, you'd use proper font rendering)
		var char_width = 6.0
		var char_height = 8.0
		
		# Draw background for start time (at top)
		var start_text_width = start_time_text.length() * char_width
		var start_text_rect = Rect2(start_x - start_text_width/2, handle_size + 15, start_text_width, char_height)
		waveform_display.draw_rect(start_text_rect, Color(0.0, 0.0, 0.0, 0.7))
		
		# Draw background for end time (at bottom)
		var end_text_width = end_time_text.length() * char_width
		var end_text_rect = Rect2(end_x - end_text_width/2, rect.size.y - handle_size - 60, end_text_width, char_height)
		waveform_display.draw_rect(end_text_rect, Color(0.0, 0.0, 0.0, 0.7))
		
		# Draw background for region label
		var region_text_width = region_time_text.length() * char_width
		var region_text_rect = Rect2(region_center_x - region_text_width/2, rect.size.y - handle_size - 50, region_text_width, char_height)
		waveform_display.draw_rect(region_text_rect, Color(0.0, 0.0, 0.0, 0.7))

func _on_waveform_mouse_entered():
	# Enable mouse tracking for better handle interaction
	pass

func _on_waveform_mouse_exited():
	# Clear hover state when mouse leaves waveform
	handle_hover = ""
	waveform_display.queue_redraw()

func _get_handle_at_position(mouse_pos: Vector2, rect: Rect2) -> String:
	var start_x = (loop_start / total_duration) * rect.size.x
	var end_x = (loop_end / total_duration) * rect.size.x
	var region_center_x = (start_x + end_x) / 2.0
	
	# Expanded hit area for better accessibility
	var expanded_size = handle_size + 10.0
	
	# Check region handle first (highest priority when overlapping)
	var region_handle = Rect2(region_center_x - expanded_size/2, rect.size.y - handle_size - 45, expanded_size, handle_size + 20)
	if region_handle.has_point(mouse_pos):
		return "region"
	
	# Check start handle (at top)
	var start_handle = Rect2(start_x - expanded_size/2, 0, expanded_size, handle_size + 20)
	if start_handle.has_point(mouse_pos):
		return "start"
	
	# Check end handle (at bottom)
	var end_handle = Rect2(end_x - expanded_size/2, rect.size.y - handle_size - 15, expanded_size, handle_size + 20)
	if end_handle.has_point(mouse_pos):
		return "end"
	
	return ""

func _on_waveform_input(event: InputEvent):
	var rect = waveform_display.get_rect()
	
	if event is InputEventMouseMotion:
		# Update hover state
		var old_hover = handle_hover
		handle_hover = _get_handle_at_position(event.position, rect)
		
		# Change cursor for better UX
		if handle_hover != "":
			if handle_hover == "region":
				waveform_display.mouse_default_cursor_shape = Control.CURSOR_MOVE
			else:
				waveform_display.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		else:
			waveform_display.mouse_default_cursor_shape = Control.CURSOR_ARROW
		
		# Redraw if hover state changed
		if old_hover != handle_hover:
			waveform_display.queue_redraw()
		
		# Handle dragging
		if dragging_handle != "":
			var click_time = (event.position.x / rect.size.x) * total_duration
			click_time = clamp(click_time, 0.0, total_duration)
			
			# Calculate minimum separation (ensure at least 1ms or 2 samples)
			var sample_rate = wav_stream.mix_rate if wav_stream else 44100
			var min_separation = max(0.001, 2.0 / sample_rate)  # At least 1ms or 2 samples
			
			if dragging_handle == "start":
				loop_start = clamp(click_time, 0.0, loop_end - min_separation)
				status_label.text = "Dragging IN point: %.3fs" % loop_start
				status_label.add_theme_color_override("font_color", Color.GREEN)
			elif dragging_handle == "end":
				loop_end = clamp(click_time, loop_start + min_separation, total_duration)
				status_label.text = "Dragging OUT point: %.3fs" % loop_end
				status_label.add_theme_color_override("font_color", Color.RED)
			elif dragging_handle == "region":
				# Move both points maintaining their relative distance
				var region_center = click_time
				var half_width = loop_region_width / 2.0
				
				# Ensure minimum width
				if loop_region_width < min_separation:
					loop_region_width = min_separation
					half_width = loop_region_width / 2.0
				
				# Calculate new positions
				var new_start = region_center - half_width
				var new_end = region_center + half_width
				
				# Clamp to valid range while maintaining width
				if new_start < 0.0:
					new_start = 0.0
					new_end = new_start + loop_region_width
				elif new_end > total_duration:
					new_end = total_duration
					new_start = new_end - loop_region_width
				
				# Final validation
				if new_start < 0.0:
					new_start = 0.0
					new_end = min(new_start + loop_region_width, total_duration)
				
				loop_start = new_start
				loop_end = new_end
				status_label.text = "Moving loop region: %.3fs - %.3fs" % [loop_start, loop_end]
				status_label.add_theme_color_override("font_color", Color.BLUE)
			
			# Update loop points if currently looping
			if is_looping:
				_update_loop_points()
			
			waveform_display.queue_redraw()
	
	elif event is InputEventMouseButton:
		if event.pressed:
			# Check if clicking on a handle
			var clicked_handle = _get_handle_at_position(event.position, rect)
			
			if clicked_handle != "" and event.button_index == MOUSE_BUTTON_LEFT:
				# Start dragging
				dragging_handle = clicked_handle
				drag_offset = event.position
				
				if dragging_handle == "start":
					status_label.text = "Dragging IN point..."
					status_label.add_theme_color_override("font_color", Color.GREEN)
				elif dragging_handle == "end":
					status_label.text = "Dragging OUT point..."
					status_label.add_theme_color_override("font_color", Color.RED)
				elif dragging_handle == "region":
					# Store the current loop region width
					loop_region_width = loop_end - loop_start
					# Ensure minimum width
					var sample_rate = wav_stream.mix_rate if wav_stream else 44100
					var min_separation = max(0.001, 2.0 / sample_rate)
					if loop_region_width < min_separation:
						loop_region_width = min_separation
					status_label.text = "Moving loop region..."
					status_label.add_theme_color_override("font_color", Color.BLUE)
				
				waveform_display.queue_redraw()
				
			elif event.button_index == MOUSE_BUTTON_LEFT:
				# Regular seek if not clicking on handle
				var click_time = (event.position.x / rect.size.x) * total_duration
				seek_to_time(click_time)
				
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				# Set loop points with right-click (keep existing functionality)
				var click_time = (event.position.x / rect.size.x) * total_duration
				
				# Calculate minimum separation (ensure at least 1ms or 2 samples)
				var sample_rate = wav_stream.mix_rate if wav_stream else 44100
				var min_separation = max(0.001, 2.0 / sample_rate)
				
				if event.shift_pressed:
					# Shift + right-click sets loop end
					loop_end = clamp(click_time, loop_start + min_separation, total_duration)
					status_label.text = "OUT point set to %.3fs" % loop_end
					status_label.add_theme_color_override("font_color", Color.RED)
				else:
					# Right-click sets loop start
					loop_start = clamp(click_time, 0.0, loop_end - min_separation)
					status_label.text = "IN point set to %.3fs" % loop_start
					status_label.add_theme_color_override("font_color", Color.GREEN)
				
				# Update loop points if currently looping
				if is_looping:
					_update_loop_points()
				
				waveform_display.queue_redraw()
				print("🎯 Loop points: %.3fs - %.3fs" % [loop_start, loop_end])
		else:
			# Stop dragging
			if dragging_handle != "":
				status_label.text = "Loop points: %.3fs - %.3fs" % [loop_start, loop_end]
				status_label.add_theme_color_override("font_color", Color.YELLOW)
				dragging_handle = ""
				waveform_display.queue_redraw()

func _update_loop_points():
	"""Helper function to update loop points in the audio stream"""
	if not wav_stream:
		return
	
	var sample_rate = wav_stream.mix_rate
	var total_samples = waveform_samples.size() if waveform_samples.size() > 0 else int(total_duration * sample_rate)
	
	# Convert time to samples with proper validation
	var loop_begin_sample = int(loop_start * sample_rate)
	var loop_end_sample = int(loop_end * sample_rate)
	
	# Ensure minimum loop size (at least 2 samples for valid playback)
	var min_loop_samples = max(2, int(0.001 * sample_rate))  # At least 1ms or 2 samples
	
	# Clamp to valid bounds
	loop_begin_sample = clamp(loop_begin_sample, 0, total_samples - min_loop_samples)
	loop_end_sample = clamp(loop_end_sample, loop_begin_sample + min_loop_samples, total_samples - 1)
	
	# Ensure loop end is always greater than loop begin
	if loop_end_sample <= loop_begin_sample:
		loop_end_sample = loop_begin_sample + min_loop_samples
		if loop_end_sample >= total_samples:
			loop_end_sample = total_samples - 1
			loop_begin_sample = max(0, loop_end_sample - min_loop_samples)
	
	wav_stream.loop_begin = loop_begin_sample
	wav_stream.loop_end = loop_end_sample
	
	# Update the time values to match the corrected sample values
	loop_start = float(loop_begin_sample) / sample_rate
	loop_end = float(loop_end_sample) / sample_rate
	
	print("🔄 Loop points updated: %d-%d samples (%.3fs-%.3fs)" % [
		loop_begin_sample, loop_end_sample, loop_start, loop_end
	])

func _draw_time_ruler():
	var rect = time_ruler.get_rect()
	
	# Background
	time_ruler.draw_rect(rect, Color(0.15, 0.15, 0.15, 1.0))
	
	# Time markers
	var time_step = 0.5
	var steps = int(total_duration / time_step) + 1
	
	for i in range(steps):
		var time_pos = i * time_step
		var x = (time_pos / total_duration) * rect.size.x
		
		# Time text
		var time_text = "%.1fs" % time_pos
		# Note: In production, you'd use a font resource here
		
		# Tick mark
		time_ruler.draw_line(
			Vector2(x, rect.size.y - 5),
			Vector2(x, rect.size.y),
			Color.WHITE, 1.0
		)

func _on_play_pressed():
	if is_playing:
		_on_stop_pressed()
	else:
		audio_player.play(playback_position)
		is_playing = true
		play_button.text = "⏸"
		status_label.text = "Playing..."
		status_label.add_theme_color_override("font_color", Color.GREEN)

func _on_stop_pressed():
	audio_player.stop()
	is_playing = false
	playback_position = 0.0
	play_button.text = "▶"
	status_label.text = "Stopped"
	status_label.add_theme_color_override("font_color", Color.GRAY)
	waveform_display.queue_redraw()

func _on_loop_type_pressed():
	# Cycle through loop types: Forward -> PingPong -> Forward -> ...
	current_loop_type = (current_loop_type + 1) % 2  # Only cycle between 0 and 1
	
	# Update button appearance and apply loop type
	_update_loop_type_display()
	
	# Apply the loop settings if loop is currently enabled
	if is_looping:
		_apply_current_loop_type()
	
	print("🔄 Loop type changed to: %s" % _get_loop_type_name())

func _update_loop_type_display():
	match current_loop_type:
		0:  # Forward Loop
			loop_type_button.text = "🔄"
			loop_type_button.remove_theme_color_override("font_color")
			status_label.text = "Loop type: Forward"
		1:  # Ping-Pong Loop
			loop_type_button.text = "↔️"
			loop_type_button.add_theme_color_override("font_color", Color.ORANGE)
			status_label.text = "Loop type: Ping-Pong"
	
	status_label.add_theme_color_override("font_color", Color.CYAN)

func _apply_current_loop_type():
	match current_loop_type:
		0:  # Forward Loop
			wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		1:  # Ping-Pong Loop
			wav_stream.loop_mode = AudioStreamWAV.LOOP_PINGPONG
	
	_update_loop_points()

func _get_loop_type_name() -> String:
	match current_loop_type:
		0:
			return "Forward"
		1:
			return "Ping-Pong"
		_:
			return "Unknown"

func _on_loop_toggled(pressed: bool):
	is_looping = pressed
	if pressed:
		# Apply current loop type
		_apply_current_loop_type()
		
		# Validate and update loop points before enabling
		_update_loop_points()
		
		# If current playback position is outside loop bounds, seek to loop start
		if wav_stream:
			var sample_rate = wav_stream.mix_rate
			var current_sample = int(playback_position * sample_rate)
			
			if current_sample < wav_stream.loop_begin or current_sample >= wav_stream.loop_end:
				seek_to_time(float(wav_stream.loop_begin) / sample_rate)
				print("🎯 Seeked to loop start: %.3fs" % playback_position)
		
		loop_button.add_theme_color_override("font_color", Color.YELLOW)
		status_label.text = "%s Loop: %.3fs - %.3fs" % [_get_loop_type_name(), loop_start, loop_end]
		status_label.add_theme_color_override("font_color", Color.GREEN)
		
		print("🔄 %s Loop enabled: %.3fs-%.3fs (%d-%d samples)" % [
			_get_loop_type_name(), loop_start, loop_end, wav_stream.loop_begin, wav_stream.loop_end
		])
	else:
		wav_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
		loop_button.remove_theme_color_override("font_color")
		status_label.text = "Loop disabled"
		status_label.add_theme_color_override("font_color", Color.GRAY)
		print("🔄 Loop disabled")
	
	waveform_display.queue_redraw()

func _on_volume_changed(value: float):
	audio_player.volume_db = value
	volume_label.text = "VOL: %ddB" % int(value)

func _on_pitch_changed(value: float):
	audio_player.pitch_scale = value
	# Format display based on value size for better readability
	if value >= 0.01:
		pitch_label.text = "PITCH: %.2fx" % value
	elif value >= 0.001:
		pitch_label.text = "PITCH: %.3fx" % value
	else:
		pitch_label.text = "PITCH: %.6fx" % value

func _on_pitch_reset_pressed():
	# Reset pitch to normal speed
	pitch_slider.value = 1.0
	_on_pitch_changed(1.0)
	status_label.text = "Pitch reset to normal speed (1.0x)"
	status_label.add_theme_color_override("font_color", Color.WHITE)
	print("🎵 Pitch reset to 1.0x")

func _on_pitch_half_pressed():
	# Octave down - halve the speed (clamp to minimum)
	var new_value = max(pitch_slider.value * 0.5, pitch_slider.min_value)
	pitch_slider.value = new_value
	_on_pitch_changed(new_value)
	status_label.text = "Octave DOWN - Speed: %.6fx" % new_value
	status_label.add_theme_color_override("font_color", Color.ORANGE)
	print("🎵 Octave DOWN: %.6fx" % new_value)

func _on_pitch_double_pressed():
	# Octave up - double the speed (clamp to maximum)
	var new_value = min(pitch_slider.value * 2.0, pitch_slider.max_value)
	pitch_slider.value = new_value
	_on_pitch_changed(new_value)
	status_label.text = "Octave UP - Speed: %.6fx" % new_value
	status_label.add_theme_color_override("font_color", Color.CYAN)
	print("🎵 Octave UP: %.6fx" % new_value)

func _on_load_pressed():
	if OS.has_feature("web"):
		status_label.text = "File loading on web requires drag & drop"
		status_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		file_dialog.popup_centered_ratio(0.8)

func _on_file_selected(path: String):
	print("🎵 Loading file: %s" % path)
	
	# Stop current playback
	if is_playing:
		_on_stop_pressed()
	
	# Remove old audio player
	if audio_player:
		audio_player.queue_free()
	
	# Create completely new audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Set playback mode
	if OS.has_feature("web"):
		audio_player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
	else:
		audio_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	
	# Load the new audio file
	var loaded_stream = AudioStreamWAV.load_from_file(path)
	if loaded_stream:
		print("🎵 File loaded successfully")
		
		# Replace the stream completely
		wav_stream = loaded_stream
		audio_player.stream = wav_stream
		
		# Extract waveform data from the new stream
		extract_waveform_data()
		
		# Update everything for the new audio
		update_for_new_audio()
		
		# Reconnect the audio finished signal
		audio_player.finished.connect(_on_audio_finished)
		
		# Update file info display
		file_info.text = "%s | %.1fkHz %dbit" % [
			path.get_file(),
			wav_stream.mix_rate / 1000.0,
			16 if wav_stream.format == AudioStreamWAV.FORMAT_16_BITS else 8
		]
		
		status_label.text = "Loaded: " + path.get_file()
		status_label.add_theme_color_override("font_color", Color.GREEN)
		
		print("🎵 New audio properties:")
		print("  - Duration: %.2fs" % total_duration)
		print("  - Sample rate: %d Hz" % wav_stream.mix_rate)
		print("  - Samples: %d" % waveform_samples.size())
		print("  - Format: %d" % wav_stream.format)
	else:
		status_label.text = "Failed to load: " + path.get_file()
		status_label.add_theme_color_override("font_color", Color.RED)
		print("❌ Failed to load file: %s" % path)

func _on_audio_finished():
	if not is_looping:
		_on_stop_pressed()
		print("🎵 Audio playback finished")

func extract_waveform_data():
	print("🎵 Extracting waveform data...")
	
	if not wav_stream or not wav_stream.data:
		print("❌ No WAV stream or data available")
		waveform_samples = PackedFloat32Array()
		return
	
	var data = wav_stream.data
	var sample_count = 0
	var channels = 2 if wav_stream.stereo else 1
	
	print("🎵 Audio format: %d, Data size: %d bytes, Stereo: %s" % [wav_stream.format, data.size(), str(wav_stream.stereo)])
	
	# Handle different audio formats properly
	match wav_stream.format:
		AudioStreamWAV.FORMAT_8_BITS:
			sample_count = data.size() / channels
			waveform_samples = PackedFloat32Array()
			waveform_samples.resize(sample_count)
			for i in range(sample_count):
				if wav_stream.stereo:
					# For stereo, average left and right channels
					var left = (float(data[i * 2]) - 128.0) / 128.0
					var right = (float(data[i * 2 + 1]) - 128.0) / 128.0
					waveform_samples[i] = (left + right) / 2.0
				else:
					var sample_8bit = data[i]
					waveform_samples[i] = (float(sample_8bit) - 128.0) / 128.0
			print("🎵 Processed %d 8-bit samples (%d channels)" % [sample_count, channels])
		
		AudioStreamWAV.FORMAT_16_BITS:
			var bytes_per_sample = 2 * channels
			sample_count = data.size() / bytes_per_sample
			waveform_samples = PackedFloat32Array()
			waveform_samples.resize(sample_count)
			
			for i in range(sample_count):
				if wav_stream.stereo:
					# For stereo, read left and right channels and average them
					var left_pos = i * 4  # 2 bytes per channel * 2 channels
					var right_pos = left_pos + 2
					
					if right_pos + 1 < data.size():
						var left_16bit = data[left_pos] | (data[left_pos + 1] << 8)
						var right_16bit = data[right_pos] | (data[right_pos + 1] << 8)
						
						if left_16bit > 32767:
							left_16bit -= 65536
						if right_16bit > 32767:
							right_16bit -= 65536
						
						var left_sample = float(left_16bit) / 32767.0
						var right_sample = float(right_16bit) / 32767.0
						waveform_samples[i] = (left_sample + right_sample) / 2.0
					else:
						waveform_samples[i] = 0.0
				else:
					# For mono, read single channel
					var byte_pos = i * 2
					if byte_pos + 1 < data.size():
						var sample_16bit = data[byte_pos] | (data[byte_pos + 1] << 8)
						if sample_16bit > 32767:
							sample_16bit -= 65536
						waveform_samples[i] = float(sample_16bit) / 32767.0
					else:
						waveform_samples[i] = 0.0
			
			print("🎵 Processed %d 16-bit samples (%d channels)" % [sample_count, channels])
		
		AudioStreamWAV.FORMAT_IMA_ADPCM, AudioStreamWAV.FORMAT_QOA:
			# For compressed formats, we can't easily extract samples
			# Use the stream's own length calculation if available
			if wav_stream.get_length() > 0:
				var duration = wav_stream.get_length()
				sample_count = int(duration * wav_stream.mix_rate)
			else:
				# Fallback estimate
				sample_count = int(3.0 * wav_stream.mix_rate)
			
			waveform_samples = PackedFloat32Array()
			waveform_samples.resize(sample_count)
			
			# Create a placeholder waveform
			for i in range(sample_count):
				var t = float(i) / wav_stream.mix_rate
				waveform_samples[i] = sin(2.0 * PI * 440.0 * t) * 0.3
			
			print("⚠️ Compressed format detected, using placeholder waveform (%d samples)" % sample_count)
		
		_:
			print("⚠️ Unknown audio format: %d" % wav_stream.format)
			waveform_samples = PackedFloat32Array()
			return
	
	print("🎵 Waveform extraction complete: %d samples" % waveform_samples.size())

func update_for_new_audio():
	print("🎵 Updating for new audio...")
	
	# For compressed formats, use the stream's built-in length
	if wav_stream.format in [AudioStreamWAV.FORMAT_IMA_ADPCM, AudioStreamWAV.FORMAT_QOA]:
		total_duration = wav_stream.get_length()
		print("🎵 Using stream length for compressed format: %.2fs" % total_duration)
	else:
		# Calculate duration from samples and sample rate
		if waveform_samples.size() > 0 and wav_stream.mix_rate > 0:
			total_duration = float(waveform_samples.size()) / float(wav_stream.mix_rate)
		else:
			total_duration = 0.0
			print("⚠️ Warning: Invalid sample data or sample rate")
	
	# Reset playback state
	loop_start = 0.0
	loop_end = total_duration
	playback_position = 0.0
	is_playing = false
	play_button.text = "▶"
	
	# Reset loop state when loading new audio
	is_looping = false
	loop_button.button_pressed = false
	loop_button.remove_theme_color_override("font_color")
	
	# CRITICAL: Set loop points to span the entire audio
	# For compressed formats, use time-based calculation
	if wav_stream.format in [AudioStreamWAV.FORMAT_IMA_ADPCM, AudioStreamWAV.FORMAT_QOA]:
		wav_stream.loop_begin = 0
		wav_stream.loop_end = int(total_duration * wav_stream.mix_rate) - 1
	else:
		# For uncompressed formats, use actual sample count
		if waveform_samples.size() > 0:
			wav_stream.loop_begin = 0
			wav_stream.loop_end = waveform_samples.size() - 1
		else:
			wav_stream.loop_begin = 0
			wav_stream.loop_end = int(total_duration * wav_stream.mix_rate) - 1
	
	# Ensure loop mode is disabled initially
	wav_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	# Force UI refresh
	waveform_display.queue_redraw()
	time_ruler.queue_redraw()
	
	status_label.text = "Ready - New audio loaded (%.1fs)" % total_duration
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	
	print("🎵 Audio update complete:")
	print("  - Duration: %.2fs" % total_duration)
	print("  - Sample rate: %d Hz" % wav_stream.mix_rate)
	print("  - Stereo: %s" % str(wav_stream.stereo))
	print("  - Format: %d" % wav_stream.format)
	print("  - Loop points: %d - %d samples" % [wav_stream.loop_begin, wav_stream.loop_end])
	print("  - Loop mode: %d (disabled)" % wav_stream.loop_mode)
	print("  - Actual stream length: %.2fs" % wav_stream.get_length())

func seek_to_time(time: float):
	playback_position = clamp(time, 0.0, total_duration)
	
	# If we're seeking within a loop region, ensure position is valid
	if is_looping and wav_stream:
		var sample_rate = wav_stream.mix_rate
		var seek_sample = int(playback_position * sample_rate)
		
		# If seeking outside loop bounds, snap to loop start
		if seek_sample < wav_stream.loop_begin or seek_sample >= wav_stream.loop_end:
			playback_position = float(wav_stream.loop_begin) / sample_rate
			print("🎯 Seek adjusted to loop bounds: %.3fs" % playback_position)
	
	if is_playing:
		audio_player.stop()
		audio_player.play(playback_position)
	waveform_display.queue_redraw()

func update_playback_display():
	if is_playing:
		playback_position = audio_player.get_playback_position()
		
		# Validate playback position when looping
		if is_looping and wav_stream:
			var sample_rate = wav_stream.mix_rate
			var current_sample = int(playback_position * sample_rate)
			
			# Check if we've gone out of bounds (this can happen with very small loops)
			if current_sample >= wav_stream.loop_end or current_sample < wav_stream.loop_begin:
				print("⚠️ Playback position out of loop bounds, correcting...")
				playback_position = float(wav_stream.loop_begin) / sample_rate
				
				# Restart playback from loop beginning
				audio_player.stop()
				audio_player.play(playback_position)
				print("🔄 Restarted playback at loop beginning: %.3fs" % playback_position)
			
			# Additional safety check for total duration
			if playback_position >= total_duration:
				print("⚠️ Playback position beyond audio duration, restarting loop...")
				playback_position = float(wav_stream.loop_begin) / sample_rate
				audio_player.stop()
				audio_player.play(playback_position)
		
		waveform_display.queue_redraw()
	
	# Update time display
	time_display.text = "%s / %s" % [format_time(playback_position), format_time(total_duration)]

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var centiseconds = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, centiseconds]
