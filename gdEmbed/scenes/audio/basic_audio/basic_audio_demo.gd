extends Control

# Simple Basic Audio Demo
# Shows fundamental audio playback with simple controls

var audio_player: AudioStreamPlayer
var wav_stream: AudioStreamWAV

# Simple UI Elements
var main_vbox: VBoxContainer
var title_label: Label
var info_label: Label
var button_container: HBoxContainer
var play_button: Button
var stop_button: Button
var volume_slider: HSlider
var volume_label: Label

# Audio properties
var is_playing: bool = false

func _ready():
	print("🎵 Basic Audio Demo starting...")
	setup_simple_ui()
	setup_audio()
	connect_signals()
	print("🎵 Basic Audio Demo ready!")

func setup_simple_ui():
	# Ensure we fill the viewport for navigation compatibility
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Main container
	main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 30)
	
	# Title
	title_label = Label.new()
	title_label.text = "🎵 Basic Audio Demo"
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title_label)
	
	# Info
	info_label = Label.new()
	info_label.text = "Simple audio playback with volume control"
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.add_theme_color_override("font_color", Color.GRAY)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(info_label)
	
	# Button container
	button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	main_vbox.add_child(button_container)
	
	# Play button
	play_button = Button.new()
	play_button.text = "▶ Play"
	play_button.custom_minimum_size = Vector2(100, 50)
	play_button.add_theme_font_size_override("font_size", 18)
	button_container.add_child(play_button)
	
	# Stop button
	stop_button = Button.new()
	stop_button.text = "⏹ Stop"
	stop_button.custom_minimum_size = Vector2(100, 50)
	stop_button.add_theme_font_size_override("font_size", 18)
	button_container.add_child(stop_button)
	
	# Volume control
	var volume_container = VBoxContainer.new()
	volume_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(volume_container)
	
	volume_label = Label.new()
	volume_label.text = "Volume: 50%"
	volume_label.add_theme_font_size_override("font_size", 14)
	volume_label.add_theme_color_override("font_color", Color.WHITE)
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	volume_container.add_child(volume_label)
	
	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.value = 0.5
	volume_slider.step = 0.1
	volume_slider.custom_minimum_size = Vector2(200, 30)
	volume_container.add_child(volume_slider)

func setup_audio():
	# Create audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Create simple demo audio
	create_demo_audio()
	
	# Set initial volume
	audio_player.volume_db = linear_to_db(0.5)

func create_demo_audio():
	print("🎵 Creating demo audio...")
	wav_stream = AudioStreamWAV.new()
	
	var sample_rate = 44100
	var duration = 2.0
	var sample_count = int(sample_rate * duration)
	
	var byte_data = PackedByteArray()
	byte_data.resize(sample_count * 2)  # 16-bit = 2 bytes per sample
	
	# Create a simple melody
	for i in range(sample_count):
		var t = float(i) / sample_rate
		var sample_value = 0.0
		
		# Simple melody with envelope
		var frequency = 440.0  # A4 note
		if t > 0.5:
			frequency = 523.25  # C5 note
		if t > 1.0:
			frequency = 659.25  # E5 note
		if t > 1.5:
			frequency = 440.0   # Back to A4
		
		sample_value = sin(2.0 * PI * frequency * t)
		
		# Add envelope
		var envelope = sin(PI * t / duration)
		sample_value *= envelope * 0.3
		
		# Convert to 16-bit
		var sample_16bit = int(clamp(sample_value * 32767.0, -32768.0, 32767.0))
		byte_data[i * 2] = sample_16bit & 0xFF
		byte_data[i * 2 + 1] = (sample_16bit >> 8) & 0xFF
	
	wav_stream.data = byte_data
	wav_stream.format = AudioStreamWAV.FORMAT_16_BITS
	wav_stream.mix_rate = sample_rate
	wav_stream.stereo = false
	wav_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	audio_player.stream = wav_stream
	print("🎵 Demo audio created: %.1fs melody" % duration)

func connect_signals():
	play_button.pressed.connect(_on_play_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	audio_player.finished.connect(_on_audio_finished)

func _on_play_pressed():
	if not is_playing:
		audio_player.play()
		is_playing = true
		play_button.text = "⏸ Pause"
		info_label.text = "Playing simple melody..."
		info_label.add_theme_color_override("font_color", Color.GREEN)
		print("🎵 Audio started")
	else:
		# Pause functionality
		audio_player.stream_paused = not audio_player.stream_paused
		if audio_player.stream_paused:
			play_button.text = "▶ Resume"
			info_label.text = "Paused"
			info_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			play_button.text = "⏸ Pause"
			info_label.text = "Playing simple melody..."
			info_label.add_theme_color_override("font_color", Color.GREEN)

func _on_stop_pressed():
	audio_player.stop()
	is_playing = false
	play_button.text = "▶ Play"
	info_label.text = "Stopped"
	info_label.add_theme_color_override("font_color", Color.GRAY)
	print("🎵 Audio stopped")

func _on_volume_changed(value: float):
	audio_player.volume_db = linear_to_db(value)
	volume_label.text = "Volume: %d%%" % int(value * 100)

func _on_audio_finished():
	is_playing = false
	play_button.text = "▶ Play"
	info_label.text = "Finished - Click play to hear again"
	info_label.add_theme_color_override("font_color", Color.CYAN)
	print("🎵 Audio finished")
