extends CharacterBody2D

@export var speed: float = 300.0
var input_buffer = []
var buffer_size = 5
var time_since_last_input = 0.0

# Web platform gamepad detection
var gamepads_detected = {}
var gamepad_detection_shown = false

func _ready():
	print("Input System Player Ready!")
	
	# Show web-specific gamepad info if needed
	if OS.has_feature("web"):
		_show_web_gamepad_info()

func _show_web_gamepad_info():
	if not gamepad_detection_shown:
		var info_label = get_node_or_null("../UI/WebGamepadInfo")
		if info_label:
			info_label.text = "🌐 Web: Press any gamepad button to detect controller"
			info_label.modulate = Color.YELLOW

func _physics_process(delta):
	time_since_last_input += delta
	
	var input_vector = Vector2.ZERO
	var input_detected = false
	
	# Enhanced input detection with buffering
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		input_detected = true
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
		input_detected = true
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		input_detected = true
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
		input_detected = true
	
	# Store input in buffer for analysis
	if input_detected:
		time_since_last_input = 0.0
		input_buffer.append(input_vector)
		if input_buffer.size() > buffer_size:
			input_buffer.pop_front()
	
	input_vector = input_vector.normalized()
	
	# Enhanced input response - more sensitive and immediate
	if input_vector != Vector2.ZERO:
		# Immediate response with enhanced sensitivity
		position += input_vector * speed * delta * 1.5
		
		# Visual feedback for input responsiveness
		var input_intensity = input_buffer.size() / float(buffer_size)
		modulate = Color.GREEN.lerp(Color.YELLOW, input_intensity)
		
		# Show input direction with rotation
		rotation = lerp_angle(rotation, input_vector.angle() + PI/2, delta * 12.0)
		
		# Scale based on input frequency
		var scale_factor = 1.0 + input_intensity * 0.2
		scale = Vector2(scale_factor, scale_factor)
	else:
		# Fade back to neutral when no input
		modulate = modulate.lerp(Color.GREEN, delta * 3.0)
		rotation = lerp_angle(rotation, 0.0, delta * 5.0)
		scale = scale.lerp(Vector2.ONE, delta * 5.0)
		
		# Clear buffer over time
		if time_since_last_input > 0.5:
			input_buffer.clear()
	
	# Reset position
	if Input.is_action_just_pressed("ui_reset"):
		position = Vector2(400, 300)
		rotation = 0.0
		scale = Vector2.ONE
		modulate = Color.GREEN
		input_buffer.clear()
	
	# Keep within screen bounds
	position.x = clamp(position.x, 50, 750)
	position.y = clamp(position.y, 50, 550)
	
	# Log significant inputs for debugging/learning
	if input_vector.length() > 0.5:
		print("Strong input detected: ", input_vector)

func _input(event):
	# Handle gamepad detection for web platform
	if event is InputEventJoypadButton:
		var device = event.device
		if not device in gamepads_detected:
			gamepads_detected[device] = true
			gamepad_detection_shown = true
			print("🎮 Gamepad detected: ", device)
			
			var info_label = get_node_or_null("../UI/WebGamepadInfo")
			if info_label:
				info_label.text = "🎮 Gamepad %d detected!" % device
				info_label.modulate = Color.GREEN
	
	# Enhanced input event logging for learning purposes
	if event is InputEventKey:
		print("Key event: ", event.as_text(), " pressed: ", event.pressed)
	elif event is InputEventMouseButton:
		print("Mouse button: ", event.button_index, " pressed: ", event.pressed)
	elif event is InputEventJoypadButton:
		print("Gamepad button: ", event.button_index, " pressed: ", event.pressed, " device: ", event.device)
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.1:  # Only log significant axis movement
			print("Gamepad axis: ", event.axis, " value: ", "%.2f" % event.axis_value, " device: ", event.device)
