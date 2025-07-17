extends Node2D

@onready var ui = $UI
@onready var key_display = $UI/KeyboardPanel/VBoxContainer/KeyDisplay
@onready var combo_display = $UI/KeyboardPanel/VBoxContainer/ComboDisplay
@onready var input_buffer = $UI/StatusPanel/VBoxContainer/BufferDisplay
@onready var timing_display = $UI/StatusPanel/VBoxContainer/TimingDisplay
@onready var player = $Player

var pressed_keys = {}
var key_combinations = []
var input_history = []
var last_input_time = 0.0
var combo_timeout = 0.5  # Seconds
var max_history = 10

# Common key combinations to detect
var known_combos = {
	"WASD": ["W", "A", "S", "D"],
	"Ctrl+C": ["Ctrl", "C"],
	"Ctrl+V": ["Ctrl", "V"],
	"Shift+Space": ["Shift", "Space"],
	"Alt+Tab": ["Alt", "Tab"]
}

func _ready():
	_setup_ui()
	_setup_player()

func _setup_ui():
	key_display.text = "Press any keys..."
	combo_display.text = "Try key combinations!"
	input_buffer.text = "Input Buffer: Empty"
	timing_display.text = "Timing: Ready"

func _setup_player():
	# Set up visual feedback for input
	player.add_to_group("player")

func _process(delta):
	_update_timing_display(delta)
	_check_key_combinations()
	_update_player_feedback()

func _input(event):
	if event is InputEventKey:
		var key_name = _get_key_name(event)
		
		if event.pressed and not event.echo:
			_handle_key_press(key_name, event)
		elif not event.pressed:
			_handle_key_release(key_name)

func _get_key_name(event: InputEventKey) -> String:
	# Convert keycode to readable name
	var key_string = ""
	
	# Check for modifier keys first
	if event.ctrl_pressed:
		key_string += "Ctrl+"
	if event.alt_pressed:
		key_string += "Alt+"
	if event.shift_pressed and event.keycode != KEY_SHIFT:
		key_string += "Shift+"
	
	# Get the main key
	match event.keycode:
		KEY_SPACE:
			key_string += "Space"
		KEY_ENTER:
			key_string += "Enter"
		KEY_ESCAPE:
			key_string += "Esc"
		KEY_TAB:
			key_string += "Tab"
		KEY_BACKSPACE:
			key_string += "Backspace"
		KEY_DELETE:
			key_string += "Delete"
		KEY_LEFT:
			key_string += "←"
		KEY_RIGHT:
			key_string += "→"
		KEY_UP:
			key_string += "↑"
		KEY_DOWN:
			key_string += "↓"
		KEY_SHIFT:
			key_string += "Shift"
		KEY_CTRL:
			key_string += "Ctrl"
		KEY_ALT:
			key_string += "Alt"
		_:
			# For regular keys, use the character
			if event.keycode >= KEY_A and event.keycode <= KEY_Z:
				key_string += char(event.keycode)
			elif event.keycode >= KEY_0 and event.keycode <= KEY_9:
				key_string += char(event.keycode)
			else:
				key_string += "Key" + str(event.keycode)
	
	return key_string

func _handle_key_press(key_name: String, event: InputEventKey):
	pressed_keys[key_name] = Time.get_ticks_msec() / 1000.0
	last_input_time = Time.get_ticks_msec() / 1000.0
	
	# Add to input history
	input_history.append({
		"key": key_name,
		"time": last_input_time,
		"type": "press"
	})
	
	if input_history.size() > max_history:
		input_history.pop_front()
	
	_update_key_display()
	_update_buffer_display()
	
	# Visual feedback
	_flash_player(Color.GREEN)

func _handle_key_release(key_name: String):
	if pressed_keys.has(key_name):
		var hold_time = Time.get_ticks_msec() / 1000.0 - pressed_keys[key_name]
		pressed_keys.erase(key_name)
		
		# Add release to history
		input_history.append({
			"key": key_name,
			"time": Time.get_ticks_msec() / 1000.0,
			"type": "release",
			"hold_time": hold_time
		})
		
		if input_history.size() > max_history:
			input_history.pop_front()
	
	_update_key_display()
	_update_buffer_display()
	
	# Visual feedback
	_flash_player(Color.RED)

func _update_key_display():
	if pressed_keys.is_empty():
		key_display.text = "Press any keys..."
		key_display.modulate = Color.WHITE
	else:
		var keys_text = "Pressed: " + ", ".join(pressed_keys.keys())
		key_display.text = keys_text
		key_display.modulate = Color.YELLOW

func _check_key_combinations():
	var current_keys = pressed_keys.keys()
	
	if current_keys.size() > 1:
		# Check for known combinations
		for combo_name in known_combos.keys():
			var combo_keys = known_combos[combo_name]
			if _has_all_keys(current_keys, combo_keys):
				combo_display.text = "🎉 Combo: " + combo_name
				combo_display.modulate = Color.LIME_GREEN
				_flash_player(Color.CYAN)
				return
		
		# Unknown combination
		combo_display.text = "Custom combo: " + ", ".join(current_keys)
		combo_display.modulate = Color.ORANGE
	else:
		combo_display.text = "Try key combinations!"
		combo_display.modulate = Color.WHITE

func _has_all_keys(current_keys: Array, required_keys: Array) -> bool:
	for key in required_keys:
		if not key in current_keys:
			return false
	return true

func _update_buffer_display():
	if input_history.is_empty():
		input_buffer.text = "Input Buffer: Empty"
	else:
		var recent = input_history.slice(-3)  # Last 3 inputs
		var buffer_text = "Recent: "
		for entry in recent:
			var type_symbol = "↓" if entry.type == "press" else "↑"
			buffer_text += entry.key + type_symbol + " "
		input_buffer.text = buffer_text

func _update_timing_display(delta):
	var time_since_input = Time.get_ticks_msec() / 1000.0 - last_input_time
	
	if time_since_input < 0.1:
		timing_display.text = "Timing: ACTIVE 🔥"
		timing_display.modulate = Color.RED
	elif time_since_input < 0.5:
		timing_display.text = "Timing: Recent (%.2fs ago)" % time_since_input
		timing_display.modulate = Color.YELLOW
	else:
		timing_display.text = "Timing: Idle (%.1fs ago)" % time_since_input
		timing_display.modulate = Color.GRAY

func _update_player_feedback():
	# Change player color based on input activity
	var time_since_input = Time.get_ticks_msec() / 1000.0 - last_input_time
	
	if time_since_input < 0.1:
		player.modulate = Color.YELLOW
		player.scale = Vector2(1.2, 1.2)
	elif time_since_input < 0.5:
		player.modulate = Color.WHITE
		player.scale = Vector2.ONE
	else:
		player.modulate = Color(0.7, 0.7, 0.7, 1)
		player.scale = Vector2(0.9, 0.9)

func _flash_player(color: Color):
	var tween = create_tween()
	tween.tween_property(player, "modulate", color, 0.1)
	tween.tween_property(player, "modulate", Color.WHITE, 0.2)
