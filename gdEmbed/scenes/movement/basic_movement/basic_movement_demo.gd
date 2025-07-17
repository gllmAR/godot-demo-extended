extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var speed_label = $UI/ParameterPanel/VBoxContainer/SpeedContainer/SpeedLabel
@onready var speed_slider = $UI/ParameterPanel/VBoxContainer/SpeedContainer/SpeedSlider
@onready var velocity_label = $UI/StatusPanel/VBoxContainer/VelocityLabel
@onready var position_label = $UI/StatusPanel/VBoxContainer/PositionLabel
@onready var input_label = $UI/StatusPanel/VBoxContainer/InputLabel
@onready var trail = $Trail2D

var movement_speed = 200.0
var velocity = Vector2.ZERO
var current_input = Vector2.ZERO

func _ready():
	_setup_ui()
	_setup_player()

func _setup_ui():
	speed_slider.value = movement_speed
	speed_slider.value_changed.connect(_on_speed_changed)
	_update_speed_label()

func _setup_player():
	# Set up player visual
	player.add_to_group("player")
	
	# Set up trail for visual feedback
	if trail:
		trail.width = 3.0
		trail.default_color = Color.CYAN
		# Initialize trail with player's starting position
		trail.add_point(player.position)

func _process(delta):
	_handle_input()
	_update_movement(delta)
	_update_ui()
	_update_trail()

func _handle_input():
	# Get raw input
	current_input = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		current_input.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		current_input.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		current_input.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		current_input.y += 1
	
	# Normalize diagonal movement
	if current_input.length() > 1.0:
		current_input = current_input.normalized()

func _update_movement(delta):
	# Apply movement
	velocity = current_input * movement_speed
	player.position += velocity * delta
	
	# Keep player on screen
	var screen_size = get_viewport().get_visible_rect().size
	player.position.x = clamp(player.position.x, 50, screen_size.x - 50)
	player.position.y = clamp(player.position.y, 50, screen_size.y - 150)

func _update_ui():
	velocity_label.text = "Velocity: (%.1f, %.1f)" % [velocity.x, velocity.y]
	position_label.text = "Position: (%.1f, %.1f)" % [player.position.x, player.position.y]
	
	var input_text = "Input: "
	if current_input == Vector2.ZERO:
		input_text += "None"
	else:
		var dirs = []
		if current_input.x < 0: dirs.append("LEFT")
		if current_input.x > 0: dirs.append("RIGHT")
		if current_input.y < 0: dirs.append("UP")
		if current_input.y > 0: dirs.append("DOWN")
		input_text += " + ".join(dirs)
	
	input_label.text = input_text

func _on_speed_changed(value):
	movement_speed = value
	_update_speed_label()

func _update_speed_label():
	speed_label.text = "Speed: %d px/s" % movement_speed

func _update_trail():
	# Update trail with player position (center of the player)
	if trail:
		trail.add_point(player.position)
		
		# Keep trail length manageable (show last 50 positions)
		if trail.get_point_count() > 50:
			trail.remove_point(0)
		
		# Fade the trail over time by adjusting alpha
		var point_count = trail.get_point_count()
		if point_count > 1:
			# Make older points more transparent
			for i in range(point_count):
				var alpha = float(i) / float(point_count - 1)
				# We can't modify individual point colors in Line2D easily,
				# so we'll just use the default_color with some transparency
				var color = trail.default_color
				color.a = 1.0 - alpha # Invert alpha for fading effect
				trail.set_point_color(i, color)
