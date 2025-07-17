extends CharacterBody2D

@export var speed: float = 200.0
@export var movement_type: int = 1  # 1=Direct, 2=Velocity, 3=Interpolated

var target_position: Vector2
var movement_types = ["Direct", "Velocity", "Interpolated"]
var time_counter: float = 0.0  # Internal timer for animations

func _ready():
	target_position = position
	print("Player Ready!")

func _process(_delta):
	_handle_movement_demo_ui()

func _handle_movement_demo_ui():
	# Display current movement type
	var ui_node = get_node_or_null("../UI/MovementTypeLabel")
	if ui_node:
		ui_node.text = "Movement Type: " + movement_types[movement_type - 1]
	
	# Handle input for movement type switching
	if Input.is_action_just_pressed("ui_1"):
		movement_type = 1
	elif Input.is_action_just_pressed("ui_2"):
		movement_type = 2
	elif Input.is_action_just_pressed("ui_3"):
		movement_type = 3
	elif Input.is_action_just_pressed("ui_reset"):
		position = Vector2(400, 300)
		target_position = position

func _physics_process(delta):
	time_counter += delta  # Update our internal timer
	
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	
	input_vector = input_vector.normalized()
	
	# Handle movement based on movement type
	match movement_type:
		1:  # Direct movement
			_direct_movement(input_vector, delta)
		2:  # Velocity-based movement
			_velocity_movement(input_vector)
		3:  # Interpolated movement
			_interpolated_movement(input_vector, delta)
	
	# Keep within screen bounds
	position.x = clamp(position.x, 50, 750)
	position.y = clamp(position.y, 50, 550)

func _direct_movement(input_vector: Vector2, delta: float):
	if input_vector != Vector2.ZERO:
		position += input_vector * speed * delta

func _velocity_movement(input_vector: Vector2):
	velocity = input_vector * speed
	move_and_slide()

func _interpolated_movement(input_vector: Vector2, delta: float):
	if input_vector != Vector2.ZERO:
		target_position += input_vector * speed * delta
	
	# Smooth interpolation to target
	position = position.lerp(target_position, 5.0 * delta)
	
	# Keep target within bounds too
	target_position.x = clamp(target_position.x, 50, 750)
	target_position.y = clamp(target_position.y, 50, 550)
