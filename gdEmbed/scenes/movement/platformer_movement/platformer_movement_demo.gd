extends Node2D

@onready var player = $Player
@onready var ui = $UI
@onready var gravity_slider = $UI/ParameterPanel/VBoxContainer/GravityContainer/GravitySlider
@onready var jump_slider = $UI/ParameterPanel/VBoxContainer/JumpContainer/JumpSlider
@onready var speed_slider = $UI/ParameterPanel/VBoxContainer/SpeedContainer/SpeedSlider
@onready var gravity_label = $UI/ParameterPanel/VBoxContainer/GravityContainer/GravityLabel
@onready var jump_label = $UI/ParameterPanel/VBoxContainer/JumpContainer/JumpLabel
@onready var speed_label = $UI/ParameterPanel/VBoxContainer/SpeedContainer/SpeedLabel
@onready var velocity_label = $UI/StatusPanel/VBoxContainer/VelocityLabel
@onready var state_label = $UI/StatusPanel/VBoxContainer/StateLabel
@onready var ground_label = $UI/StatusPanel/VBoxContainer/GroundLabel

var gravity = 980.0  # Pixels per second squared
var jump_velocity = -400.0  # Negative because Y-axis is flipped
var horizontal_speed = 200.0
var velocity = Vector2.ZERO
var is_grounded = false
var coyote_time = 0.1  # Time window to jump after leaving ground
var coyote_timer = 0.0
var jump_buffer_time = 0.1  # Time window to buffer jump input
var jump_buffer_timer = 0.0

# Platforms
var platforms = []

func _ready():
	_setup_ui()
	_setup_platforms()
	_setup_player()

func _setup_ui():
	gravity_slider.value = gravity
	jump_slider.value = abs(jump_velocity)
	speed_slider.value = horizontal_speed
	
	gravity_slider.value_changed.connect(_on_gravity_changed)
	jump_slider.value_changed.connect(_on_jump_changed)
	speed_slider.value_changed.connect(_on_speed_changed)
	
	_update_parameter_labels()

func _setup_platforms():
	# Create some platforms for demonstration
	var platform_data = [
		{"pos": Vector2(400, 500), "size": Vector2(200, 20)},  # Ground
		{"pos": Vector2(200, 400), "size": Vector2(150, 20)},  # Left platform
		{"pos": Vector2(600, 350), "size": Vector2(150, 20)},  # Right platform
		{"pos": Vector2(400, 250), "size": Vector2(100, 20)},  # Top platform
	]
	
	for data in platform_data:
		var platform = StaticBody2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		var visual = ColorRect.new()
		
		shape.size = data.size
		collision.shape = shape
		
		visual.size = data.size
		visual.position = -data.size / 2
		visual.color = Color(0.4, 0.4, 0.4)
		
		platform.add_child(collision)
		platform.add_child(visual)
		platform.position = data.pos
		
		add_child(platform)
		platforms.append(platform)

func _setup_player():
	# Set up player collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 40)
	collision.shape = shape
	player.add_child(collision)
	
	player.position = Vector2(400, 200)

func _process(delta):
	_handle_input(delta)
	_update_physics(delta)
	_update_ui()

func _handle_input(delta):
	# Horizontal movement
	var horizontal_input = 0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		horizontal_input -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		horizontal_input += 1
	
	velocity.x = horizontal_input * horizontal_speed
	
	# Jump input with buffering
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		jump_buffer_timer = jump_buffer_time
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		# Can jump if grounded or within coyote time
		if is_grounded or coyote_timer > 0:
			velocity.y = jump_velocity
			jump_buffer_timer = 0
			coyote_timer = 0

func _update_physics(delta):
	# Store previous grounded state
	var was_grounded = is_grounded
	
	# Apply gravity
	if not is_grounded:
		velocity.y += gravity * delta
	
	# Move player
	player.velocity = velocity
	player.move_and_slide()
	velocity = player.velocity
	
	# Check if grounded
	is_grounded = player.is_on_floor()
	
	# Update coyote timer
	if was_grounded and not is_grounded:
		coyote_timer = coyote_time
	elif is_grounded:
		coyote_timer = 0
	else:
		coyote_timer -= delta
	
	# Keep player on screen horizontally
	var screen_size = get_viewport().get_visible_rect().size
	player.position.x = clamp(player.position.x, 20, screen_size.x - 20)
	
	# Reset if player falls too far
	if player.position.y > screen_size.y + 100:
		player.position = Vector2(400, 200)
		velocity = Vector2.ZERO

func _update_ui():
	velocity_label.text = "Velocity: (%.1f, %.1f)" % [velocity.x, velocity.y]
	
	var state = "Falling"
	if is_grounded:
		state = "Grounded"
		if abs(velocity.x) > 10:
			state = "Running"
		else:
			state = "Idle"
	elif velocity.y < 0:
		state = "Jumping"
	
	state_label.text = "State: " + state
	ground_label.text = "Grounded: " + ("Yes" if is_grounded else "No")
	
	if coyote_timer > 0 and not is_grounded:
		ground_label.text += " (Coyote: %.2fs)" % coyote_timer

func _on_gravity_changed(value):
	gravity = value
	_update_parameter_labels()

func _on_jump_changed(value):
	jump_velocity = -value  # Negative for upward
	_update_parameter_labels()

func _on_speed_changed(value):
	horizontal_speed = value
	_update_parameter_labels()

func _update_parameter_labels():
	gravity_label.text = "Gravity: %d px/s²" % gravity
	jump_label.text = "Jump: %d px/s" % abs(jump_velocity)
	speed_label.text = "Speed: %d px/s" % horizontal_speed
