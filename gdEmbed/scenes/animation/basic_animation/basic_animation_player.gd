extends CharacterBody2D

@export var speed: float = 250.0
var time_counter: float = 0.0

func _ready():
	print("Animation Player Ready!")

func _physics_process(delta):
	time_counter += delta
	
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
	
	# Advanced animated movement
	if input_vector != Vector2.ZERO:
		# Add smooth rotation while moving
		var target_rotation = input_vector.angle() + PI/2
		rotation = lerp_angle(rotation, target_rotation, delta * 8.0)
		
		# Bouncy movement with scale animation
		var move_scale = 1.0 + sin(time_counter * 10.0) * 0.1
		scale = Vector2(move_scale, move_scale)
		
		# Trail effect - change color while moving
		var hue = fmod(time_counter * 0.5, 1.0)
		modulate = Color.from_hsv(hue, 0.8, 1.0)
		
		velocity = input_vector * speed
		move_and_slide()
	else:
		# Return to neutral state when not moving
		rotation = lerp_angle(rotation, 0.0, delta * 5.0)
		scale = scale.lerp(Vector2.ONE, delta * 5.0)
		modulate = modulate.lerp(Color.BLUE, delta * 2.0)
	
	# Reset position
	if Input.is_action_just_pressed("ui_reset"):
		position = Vector2(400, 300)
		rotation = 0.0
		scale = Vector2.ONE
		modulate = Color.BLUE
	
	# Keep within screen bounds
	position.x = clamp(position.x, 50, 750)
	position.y = clamp(position.y, 50, 550)
