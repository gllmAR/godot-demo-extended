extends CharacterBody2D

@export var speed: float = 200.0

# Performance optimization: Cache frequently accessed nodes and values
var sprite_node: Sprite2D
var initial_scale: Vector2

func _ready():
	print("Physics Player Ready!")
	
	# Cache sprite node for performance
	sprite_node = $Sprite2D if has_node("Sprite2D") else null
	if sprite_node:
		initial_scale = sprite_node.scale
	
	# Optimize physics settings for 60 FPS
	Engine.max_fps = 60
	Engine.physics_ticks_per_second = 60

func _physics_process(delta):
	# Performance optimization: Early exit if delta is too large (lag spike)
	if delta > 0.02: # Cap at 50 FPS equivalent
		delta = 0.02
	
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
	
	# Advanced physics-based movement with realistic momentum and friction
	var acceleration = 800.0
	var friction = 600.0
	var max_speed = speed * 1.2
	
	if input_vector != Vector2.ZERO:
		# Apply acceleration in input direction
		velocity += input_vector * acceleration * delta
		
		# Add slight sliding effect - reduce control when moving fast
		var speed_factor = 1.0 - (velocity.length() / max_speed) * 0.3
		velocity = velocity.move_toward(input_vector * velocity.length(), acceleration * delta * speed_factor)
		
		# Visual feedback for speed
		var speed_intensity = clamp(velocity.length() / max_speed, 0.3, 1.0)
		modulate = Color.RED.lerp(Color.ORANGE, speed_intensity)
		
		# Add slight rotation based on velocity direction
		if velocity.length() > 50:
			var target_rotation = velocity.angle() + PI/2
			rotation = lerp_angle(rotation, target_rotation, delta * 3.0)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# Return to neutral visuals
		modulate = modulate.lerp(Color.RED, delta * 3.0)
		rotation = lerp_angle(rotation, 0.0, delta * 2.0)
	
	# Limit maximum speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	move_and_slide()
	
	# Add bounce effect when hitting walls
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var bounce_factor = 0.3
		velocity = velocity.bounce(collision.get_normal()) * bounce_factor
		
		# Visual feedback for collision
		modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.2)
	
	# Reset position
	if Input.is_action_just_pressed("ui_reset"):
		position = Vector2(400, 300)
		velocity = Vector2.ZERO
		rotation = 0.0
		modulate = Color.RED
	
	# Keep within screen bounds
	position.x = clamp(position.x, 50, 750)
	position.y = clamp(position.y, 50, 550)
