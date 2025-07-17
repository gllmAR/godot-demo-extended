extends Node2D

@onready var ui = $UI
@onready var tween_info = $UI/TweeningPanel/VBoxContainer/TweenInfo
@onready var easing_info = $UI/TweeningPanel/VBoxContainer/EasingInfo
@onready var transition_info = $UI/TweeningPanel/VBoxContainer/TransitionInfo
@onready var duration_slider = $UI/ControlPanel/VBoxContainer/DurationContainer/DurationSlider
@onready var duration_label = $UI/ControlPanel/VBoxContainer/DurationContainer/DurationLabel
@onready var easing_option = $UI/ControlPanel/VBoxContainer/EasingContainer/EasingOption
@onready var transition_option = $UI/ControlPanel/VBoxContainer/TransitionContainer/TransitionOption
@onready var player = $Player

var current_tween: Tween
var tween_duration = 1.0
var is_tweening = false
var target_positions = [
	Vector2(150, 150),
	Vector2(650, 150), 
	Vector2(650, 450),
	Vector2(150, 450),
	Vector2(400, 300)  # Center
]
var current_target_index = 0

# Easing and transition types for educational purposes
var easing_types = [
	Tween.EASE_IN,
	Tween.EASE_OUT,
	Tween.EASE_IN_OUT,
	Tween.EASE_OUT_IN
]

var transition_types = [
	Tween.TRANS_LINEAR,
	Tween.TRANS_SINE,
	Tween.TRANS_QUART,
	Tween.TRANS_QUINT,
	Tween.TRANS_EXPO,
	Tween.TRANS_CIRC,
	Tween.TRANS_BACK,
	Tween.TRANS_ELASTIC,
	Tween.TRANS_BOUNCE
]

var easing_names = ["Ease In", "Ease Out", "Ease In-Out", "Ease Out-In"]
var transition_names = ["Linear", "Sine", "Quart", "Quint", "Expo", "Circ", "Back", "Elastic", "Bounce"]

var current_easing = 0
var current_transition = 0

func _ready():
	_setup_ui()
	_setup_player()

func _setup_ui():
	duration_slider.value = tween_duration
	duration_slider.value_changed.connect(_on_duration_changed)
	_update_duration_label()
	
	# Populate dropdown options
	for name in easing_names:
		easing_option.add_item(name)
	for name in transition_names:
		transition_option.add_item(name)
	
	easing_option.selected = current_easing
	transition_option.selected = current_transition
	
	easing_option.item_selected.connect(_on_easing_changed)
	transition_option.item_selected.connect(_on_transition_changed)
	
	_update_info_displays()

func _setup_player():
	player.add_to_group("player")
	player.position = Vector2(400, 300)

func _process(delta):
	_handle_input()
	_update_info_displays()

func _handle_input():
	# Start tween on click or spacebar
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_reset"):
		if not is_tweening:
			_start_position_tween()
	
	# Demonstrate different tween types with number keys
	if Input.is_action_just_pressed("ui_1"):
		_demo_scale_tween()
	elif Input.is_action_just_pressed("ui_2"):
		_demo_rotation_tween()
	elif Input.is_action_just_pressed("ui_3"):
		_demo_color_tween()
	elif Input.is_action_just_pressed("ui_4"):
		_demo_complex_tween()

func _start_position_tween():
	if current_tween:
		current_tween.kill()
	
	var target_pos = target_positions[current_target_index]
	current_target_index = (current_target_index + 1) % target_positions.size()
	
	current_tween = create_tween()
	current_tween.set_ease(easing_types[current_easing])
	current_tween.set_trans(transition_types[current_transition])
	
	is_tweening = true
	
	# Tween position with callback
	current_tween.tween_property(player, "position", target_pos, tween_duration)
	current_tween.tween_callback(_on_tween_finished)

func _demo_scale_tween():
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(easing_types[current_easing])
	current_tween.set_trans(transition_types[current_transition])
	
	is_tweening = true
	
	# Scale up and down
	current_tween.tween_property(player, "scale", Vector2(2.0, 2.0), tween_duration * 0.5)
	current_tween.tween_property(player, "scale", Vector2.ONE, tween_duration * 0.5)
	current_tween.tween_callback(_on_tween_finished)

func _demo_rotation_tween():
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(easing_types[current_easing])
	current_tween.set_trans(transition_types[current_transition])
	
	is_tweening = true
	
	# Rotate 360 degrees
	var target_rotation = player.rotation + TAU
	current_tween.tween_property(player, "rotation", target_rotation, tween_duration)
	current_tween.tween_callback(_on_tween_finished)

func _demo_color_tween():
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(easing_types[current_easing])
	current_tween.set_trans(transition_types[current_transition])
	
	is_tweening = true
	
	# Cycle through colors
	current_tween.tween_property(player, "modulate", Color.RED, tween_duration * 0.25)
	current_tween.tween_property(player, "modulate", Color.GREEN, tween_duration * 0.25)
	current_tween.tween_property(player, "modulate", Color.BLUE, tween_duration * 0.25)
	current_tween.tween_property(player, "modulate", Color.WHITE, tween_duration * 0.25)
	current_tween.tween_callback(_on_tween_finished)

func _demo_complex_tween():
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(easing_types[current_easing])
	current_tween.set_trans(transition_types[current_transition])
	
	# Parallel tweens for complex animation
	current_tween.set_parallel(true)
	
	is_tweening = true
	
	# Multiple properties animating simultaneously
	var center = Vector2(400, 300)
	var offset = Vector2(100, 0)
	
	current_tween.tween_property(player, "position", center + offset, tween_duration * 0.5)
	current_tween.tween_property(player, "scale", Vector2(1.5, 1.5), tween_duration * 0.5)
	current_tween.tween_property(player, "rotation", PI, tween_duration * 0.5)
	current_tween.tween_property(player, "modulate", Color.CYAN, tween_duration * 0.5)
	
	# Return to normal (sequential after parallel)
	current_tween.tween_delay(tween_duration * 0.1)
	current_tween.tween_property(player, "position", center, tween_duration * 0.4)
	current_tween.tween_property(player, "scale", Vector2.ONE, tween_duration * 0.4)
	current_tween.tween_property(player, "rotation", 0.0, tween_duration * 0.4)
	current_tween.tween_property(player, "modulate", Color.WHITE, tween_duration * 0.4)
	
	current_tween.tween_callback(_on_tween_finished)

func _on_tween_finished():
	is_tweening = false

func _update_info_displays():
	if is_tweening:
		tween_info.text = "Status: 🟢 Tweening..."
		tween_info.modulate = Color.GREEN
	else:
		tween_info.text = "Status: ⚪ Ready (Press SPACE)"
		tween_info.modulate = Color.WHITE
	
	easing_info.text = "Easing: " + easing_names[current_easing]
	transition_info.text = "Transition: " + transition_names[current_transition]

func _on_duration_changed(value):
	tween_duration = value
	_update_duration_label()

func _update_duration_label():
	duration_label.text = "Duration: %.1fs" % tween_duration

func _on_easing_changed(index):
	current_easing = index

func _on_transition_changed(index):
	current_transition = index

# Draw visual helpers
func _draw():
	# Draw target positions
	for i in range(target_positions.size()):
		var pos = target_positions[i]
		var color = Color.YELLOW if i == current_target_index else Color(1, 1, 1, 0.3)
		draw_circle(pos, 15, color)
		
		# Draw number
		var font = ThemeDB.fallback_font
		var text = str(i + 1)
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		draw_string(font, pos - text_size / 2, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.BLACK)
	
	# Draw path between positions
	if target_positions.size() > 1:
		for i in range(target_positions.size() - 1):
			draw_line(target_positions[i], target_positions[i + 1], Color(1, 1, 1, 0.2), 2.0)
	
	# Always redraw for smooth visuals
	queue_redraw()
