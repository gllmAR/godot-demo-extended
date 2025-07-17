extends Node2D

@onready var ui = $UI
@onready var gamepad_status = $UI/GamepadPanel/VBoxContainer/GamepadStatus
@onready var analog_info = $UI/GamepadPanel/VBoxContainer/AnalogStatus
@onready var right_analog_info = $UI/GamepadPanel/VBoxContainer/RightAnalogStatus
@onready var trigger_info = $UI/GamepadPanel/VBoxContainer/TriggerStatus
@onready var button_status = $UI/GamepadPanel/VBoxContainer/ButtonStatus
@onready var deadzone_info = $UI/GamepadPanel/VBoxContainer/DeadzoneInfo
@onready var vibration_info = $UI/GamepadPanel/VBoxContainer/VibrationInfo
@onready var deadzone_slider = $UI/ControlPanel/VBoxContainer/DeadzoneContainer/DeadzoneSlider
@onready var deadzone_label = $UI/ControlPanel/VBoxContainer/DeadzoneContainer/DeadzoneLabel
@onready var web_gamepad_info = $UI/WebGamepadInfo
@onready var player = $Player

var connected_gamepads = {}
var active_gamepad = -1
var deadzone = 0.2
var analog_positions = {"left": Vector2.ZERO, "right": Vector2.ZERO}
var pressed_buttons = []
var trigger_values = {"left": 0.0, "right": 0.0}
var last_vibration_time = 0.0

# Button mapping for different controllers
var button_names = {
	JOY_BUTTON_A: "A/Cross",
	JOY_BUTTON_B: "B/Circle", 
	JOY_BUTTON_X: "X/Square",
	JOY_BUTTON_Y: "Y/Triangle",
	JOY_BUTTON_LEFT_SHOULDER: "L1/LB",
	JOY_BUTTON_RIGHT_SHOULDER: "R1/RB",
	JOY_BUTTON_BACK: "Back/Select",
	JOY_BUTTON_START: "Start/Menu",
	JOY_BUTTON_LEFT_STICK: "L3",
	JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_DPAD_UP: "D-Up",
	JOY_BUTTON_DPAD_DOWN: "D-Down",
	JOY_BUTTON_DPAD_LEFT: "D-Left",
	JOY_BUTTON_DPAD_RIGHT: "D-Right"
}

func _ready():
	_setup_ui()
	_setup_player()
	_check_connected_gamepads()
	
	# Connect gamepad signals
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _setup_ui():
	deadzone_slider.value = deadzone
	deadzone_slider.value_changed.connect(_on_deadzone_changed)
	_update_deadzone_label()
	
	gamepad_status.text = "🎮 No gamepad connected"
	analog_info.text = "Left: (0.0, 0.0)"
	right_analog_info.text = "Right: (0.0, 0.0)"
	trigger_info.text = "Triggers: L:0.0 R:0.0"
	button_status.text = "Buttons: None pressed"
	deadzone_info.text = "Deadzone: Movement below threshold ignored"
	vibration_info.text = "Vibration: Press A/Cross to test"
	
	if OS.has_feature("web"):
		web_gamepad_info.visible = true
		web_gamepad_info.text = "🌐 Web: Press any gamepad button to detect"

func _setup_player():
	player.add_to_group("player")

func _check_connected_gamepads():
	var connected = Input.get_connected_joypads()
	if connected.size() > 0:
		_on_gamepad_connected(connected[0])

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		_on_gamepad_connected(device_id)
	else:
		_on_gamepad_disconnected(device_id)

func _process(delta):
	if active_gamepad >= 0:
		_update_analog_input()
		_update_button_input()
		_update_player_movement(delta)
		_check_special_actions()
	else:
		# Check for new gamepad connections
		_check_for_gamepad_input()

func _check_for_gamepad_input():
	# Check if any gamepad input is detected
	for device_id in range(4):
		if Input.get_connected_joypads().has(device_id):
			# Check for any significant input to activate this gamepad
			var left_stick = Vector2(
				Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
				Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
			)
			
			if left_stick.length() > deadzone:
				_on_gamepad_connected(device_id)
				break
			
			# Check buttons
			for button in button_names.keys():
				if Input.is_joy_button_pressed(device_id, button):
					_on_gamepad_connected(device_id)
					break

func _update_analog_input():
	# Left analog stick
	analog_positions.left = Vector2(
		Input.get_joy_axis(active_gamepad, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(active_gamepad, JOY_AXIS_LEFT_Y)
	)
	
	# Right analog stick  
	analog_positions.right = Vector2(
		Input.get_joy_axis(active_gamepad, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(active_gamepad, JOY_AXIS_RIGHT_Y)
	)
	
	# Apply deadzone
	if analog_positions.left.length() < deadzone:
		analog_positions.left = Vector2.ZERO
	if analog_positions.right.length() < deadzone:
		analog_positions.right = Vector2.ZERO
	
	# Update triggers
	trigger_values.left = Input.get_joy_axis(active_gamepad, JOY_AXIS_TRIGGER_LEFT)
	trigger_values.right = Input.get_joy_axis(active_gamepad, JOY_AXIS_TRIGGER_RIGHT)
	
	# Update UI
	analog_info.text = "Left: (%.2f, %.2f)" % [analog_positions.left.x, analog_positions.left.y]
	right_analog_info.text = "Right: (%.2f, %.2f)" % [analog_positions.right.x, analog_positions.right.y]
	trigger_info.text = "Triggers: L:%.2f R:%.2f" % [abs(trigger_values.left), abs(trigger_values.right)]

func _update_button_input():
	pressed_buttons.clear()
	
	for button in button_names.keys():
		if Input.is_joy_button_pressed(active_gamepad, button):
			pressed_buttons.append(button_names[button])
	
	if pressed_buttons.is_empty():
		button_status.text = "Buttons: None pressed"
		button_status.modulate = Color.WHITE
	else:
		button_status.text = "Buttons: " + ", ".join(pressed_buttons)
		button_status.modulate = Color.YELLOW

func _update_player_movement(delta):
	# Use left stick for movement
	var movement_input = analog_positions.left
	
	if movement_input != Vector2.ZERO:
		player.position += movement_input * 200 * delta
		
		# Visual feedback
		player.modulate = Color.CYAN
		player.scale = Vector2(1.2, 1.2)
		
		# Rotate based on right stick
		if analog_positions.right.length() > 0.1:
			var target_rotation = analog_positions.right.angle()
			player.rotation = lerp_angle(player.rotation, target_rotation, delta * 5.0)
	else:
		# Return to neutral
		player.modulate = Color.WHITE
		player.scale = Vector2.ONE
		player.rotation = lerp_angle(player.rotation, 0.0, delta * 3.0)
	
	# Keep within bounds
	player.position.x = clamp(player.position.x, 50, 750)
	player.position.y = clamp(player.position.y, 50, 550)

func _check_special_actions():
	# Test vibration on A/Cross button
	if Input.is_joy_button_pressed(active_gamepad, JOY_BUTTON_A):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_vibration_time > 0.5:  # Prevent spam
			_test_vibration()
			last_vibration_time = current_time
	
	# Reset position on Start/Menu
	if Input.is_joy_button_pressed(active_gamepad, JOY_BUTTON_START):
		player.position = Vector2(400, 300)
		player.rotation = 0.0

func _test_vibration():
	# Test rumble if supported
	Input.start_joy_vibration(active_gamepad, 0.5, 0.5, 0.3)
	vibration_info.text = "Vibration: Testing rumble..."
	vibration_info.modulate = Color.GREEN
	
	# Reset vibration info after a delay
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_reset_vibration_info)

func _reset_vibration_info():
	vibration_info.text = "Vibration: Press A/Cross to test"
	vibration_info.modulate = Color.WHITE

func _on_gamepad_connected(device_id: int):
	active_gamepad = device_id
	connected_gamepads[device_id] = true
	
	var gamepad_name = Input.get_joy_name(device_id)
	gamepad_status.text = "🎮 Gamepad %d: %s" % [device_id, gamepad_name]
	gamepad_status.modulate = Color.GREEN
	
	if OS.has_feature("web"):
		web_gamepad_info.text = "🎮 Gamepad %d detected!" % device_id
		web_gamepad_info.modulate = Color.GREEN
	
	print("Gamepad connected: %s (ID: %d)" % [gamepad_name, device_id])

func _on_gamepad_disconnected(device_id: int):
	if device_id in connected_gamepads:
		connected_gamepads.erase(device_id)
	
	if device_id == active_gamepad:
		active_gamepad = -1
		gamepad_status.text = "🎮 No gamepad connected"
		gamepad_status.modulate = Color.WHITE
		
		# Reset displays
		analog_info.text = "Left: (0.0, 0.0)"
		right_analog_info.text = "Right: (0.0, 0.0)"
		trigger_info.text = "Triggers: L:0.0 R:0.0"
		button_status.text = "Buttons: None pressed"
		
		if OS.has_feature("web"):
			web_gamepad_info.text = "🌐 Web: Press any gamepad button to detect"
			web_gamepad_info.modulate = Color.YELLOW
	
	print("Gamepad disconnected: ID %d" % device_id)

func _input(event):
	# Handle gamepad connection events
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var device_id = event.device
		
		# Check if this is a new gamepad
		if not device_id in connected_gamepads and active_gamepad == -1:
			_on_gamepad_connected(device_id)

func _on_deadzone_changed(value):
	deadzone = value
	_update_deadzone_label()

func _update_deadzone_label():
	deadzone_label.text = "Deadzone: %.2f" % deadzone
	deadzone_info.text = "Deadzone: Movement below %.2f ignored" % deadzone

# Draw visual feedback for analog sticks
func _draw():
	if active_gamepad >= 0:
		# Draw deadzone circles
		var deadzone_radius = deadzone * 100
		var left_center = Vector2(150, 450)
		var right_center = Vector2(650, 450)
		
		# Draw deadzone boundaries
		draw_circle(left_center, deadzone_radius, Color(1, 1, 1, 0.2))
		draw_circle(right_center, deadzone_radius, Color(1, 1, 1, 0.2))
		
		# Draw analog stick positions
		var left_pos = left_center + analog_positions.left * 100
		var right_pos = right_center + analog_positions.right * 100
		
		draw_circle(left_pos, 10, Color.CYAN)
		draw_circle(right_pos, 10, Color.MAGENTA)
		
		# Draw trigger bars
		var trigger_width = 200
		var trigger_height = 20
		var trigger_y = 520
		
		# Left trigger
		var left_trigger_rect = Rect2(50, trigger_y, trigger_width * abs(trigger_values.left), trigger_height)
		draw_rect(left_trigger_rect, Color.ORANGE)
		
		# Right trigger  
		var right_trigger_rect = Rect2(550, trigger_y, trigger_width * abs(trigger_values.right), trigger_height)
		draw_rect(right_trigger_rect, Color.PURPLE)
	
	# Always redraw for smooth animations
	queue_redraw()
