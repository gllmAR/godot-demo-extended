extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var speed_label = $UI/ParameterPanel/VBoxContainer/SpeedContainer/SpeedLabel
@onready var speed_slider = $UI/ParameterPanel/VBoxContainer/SpeedContainer/SpeedSlider
@onready var normalize_checkbox = $UI/ParameterPanel/VBoxContainer/NormalizeContainer/NormalizeCheckbox
@onready var velocity_label = $UI/StatusPanel/VBoxContainer/VelocityLabel
@onready var position_label = $UI/StatusPanel/VBoxContainer/PositionLabel
@onready var input_label = $UI/StatusPanel/VBoxContainer/InputLabel
@onready var direction_label = $UI/StatusPanel/VBoxContainer/DirectionLabel
@onready var trail = $Player/Trail2D

var movement_speed = 200.0
var velocity = Vector2.ZERO
var current_input = Vector2.ZERO
var normalize_diagonal = true
var input_history = []
var max_history = 60  # 1 second at 60fps

func _ready():
	_setup_ui()
	_setup_player()
	_setup_environment()

func _setup_ui():
	speed_slider.value = movement_speed
	speed_slider.value_changed.connect(_on_speed_changed)
	normalize_checkbox.button_pressed = normalize_diagonal
	normalize_checkbox.toggled.connect(_on_normalize_toggled)
	_update_speed_label()

func _setup_player():
	# Set up player visual
	player.add_to_group("player")
	
	# Set up trail for visual feedback
	if trail:
		trail.width = 4.0
		trail.default_color = Color.ORANGE
		trail.length = 80

func _setup_environment():
	# Create grid background for better spatial reference
	_create_grid_background()
	
	# Create boundary walls
	_create_boundaries()

func _create_grid_background():
	# Visual grid to help understand 8-directional movement
	var grid_lines = Node2D.new()
	grid_lines.name = "GridLines"
	add_child(grid_lines)
	grid_lines.z_index = -10
	
	# Draw grid lines
	for x in range(0, 801, 50):
		var line = Line2D.new()
		line.add_point(Vector2(x, 0))
		line.add_point(Vector2(x, 600))
		line.default_color = Color(0.3, 0.3, 0.4, 0.3)
		line.width = 1
		grid_lines.add_child(line)
	
	for y in range(0, 601, 50):
		var line = Line2D.new()
		line.add_point(Vector2(0, y))
		line.add_point(Vector2(800, y))
		line.default_color = Color(0.3, 0.3, 0.4, 0.3)
		line.width = 1
		grid_lines.add_child(line)

func _create_boundaries():
	# Create invisible walls at screen edges
	var boundaries = [
		{"pos": Vector2(400, -10), "size": Vector2(800, 20)},  # Top
		{"pos": Vector2(400, 610), "size": Vector2(800, 20)},  # Bottom
		{"pos": Vector2(-10, 300), "size": Vector2(20, 600)},  # Left
		{"pos": Vector2(810, 300), "size": Vector2(20, 600)}   # Right
	]
	
	for data in boundaries:
		var wall = StaticBody2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		
		shape.size = data.size
		collision.shape = shape
		wall.position = data.pos
		wall.add_child(collision)
		add_child(wall)

func _process(delta):
	_handle_input()
	_update_movement(delta)
	_update_input_history()
	_update_ui()

func _handle_input():
	# Get raw input
	current_input = Vector2.ZERO
	
	# 8-directional input
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		current_input.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		current_input.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		current_input.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		current_input.y += 1
	
	# Normalize diagonal movement (key educational concept)
	if normalize_diagonal and current_input.length() > 1.0:
		current_input = current_input.normalized()

func _update_movement(delta):
	# Apply movement
	velocity = current_input * movement_speed
	player.position += velocity * delta
	
	# Keep player on screen
	var screen_size = get_viewport().get_visible_rect().size
	player.position.x = clamp(player.position.x, 50, screen_size.x - 50)
	player.position.y = clamp(player.position.y, 50, screen_size.y - 50)

func _update_input_history():
	# Track input for analysis
	input_history.append(current_input)
	if input_history.size() > max_history:
		input_history.pop_front()

func _update_ui():
	velocity_label.text = "Velocity: (%.1f, %.1f)" % [velocity.x, velocity.y]
	position_label.text = "Position: (%.1f, %.1f)" % [player.position.x, player.position.y]
	
	# Input direction analysis
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
	
	# Direction and magnitude analysis
	if current_input.length() > 0:
		var angle_degrees = rad_to_deg(current_input.angle())
		var magnitude = current_input.length()
		var speed_actual = velocity.length()
		
		direction_label.text = "Direction: %.1f° | Magnitude: %.2f | Speed: %.1f px/s" % [angle_degrees, magnitude, speed_actual]
		
		# Show normalization effect
		if not normalize_diagonal and magnitude > 1.0:
			direction_label.text += " [DIAGONAL FASTER!]"
			direction_label.modulate = Color.RED
		else:
			direction_label.modulate = Color.WHITE
	else:
		direction_label.text = "Direction: N/A | Magnitude: 0.00 | Speed: 0.0 px/s"
		direction_label.modulate = Color.WHITE

func _on_speed_changed(value):
	movement_speed = value
	_update_speed_label()

func _update_speed_label():
	speed_label.text = "Speed: %d px/s" % movement_speed

func _on_normalize_toggled(button_pressed):
	normalize_diagonal = button_pressed
