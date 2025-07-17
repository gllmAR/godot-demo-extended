extends Node2D

@onready var ui = $UI
@onready var mouse_pos_label = $UI/MousePanel/VBoxContainer/MousePosLabel
@onready var button_status_label = $UI/MousePanel/VBoxContainer/ButtonStatusLabel
@onready var click_counter_label = $UI/MousePanel/VBoxContainer/ClickCounterLabel
@onready var drag_info_label = $UI/StatusPanel/VBoxContainer/DragInfoLabel
@onready var sensitivity_slider = $UI/ControlPanel/VBoxContainer/SensitivityContainer/SensitivitySlider
@onready var sensitivity_label = $UI/ControlPanel/VBoxContainer/SensitivityContainer/SensitivityLabel
@onready var player = $Player

var mouse_position = Vector2.ZERO
var mouse_buttons_pressed = {}
var click_counts = {"left": 0, "right": 0, "middle": 0}
var last_click_times = {}
var is_dragging = false
var drag_start_pos = Vector2.ZERO
var sensitivity = 1.0
var mouse_trail = []
var max_trail_length = 50

# Visual elements for interaction
var click_effects = []
var hover_zones = []

func _ready():
	_setup_ui()
	_setup_player()
	_setup_hover_zones()

func _setup_ui():
	sensitivity_slider.value = sensitivity
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	_update_sensitivity_label()
	
	mouse_pos_label.text = "Mouse: (0, 0)"
	button_status_label.text = "Buttons: None"
	click_counter_label.text = "Clicks: L:0 R:0 M:0"
	drag_info_label.text = "Drag: Not dragging"

func _setup_player():
	# Player will follow mouse with sensitivity
	player.add_to_group("player")

func _setup_hover_zones():
	# Create interactive zones
	var zones = [
		{"pos": Vector2(150, 150), "color": Color.RED, "name": "Red Zone"},
		{"pos": Vector2(650, 150), "color": Color.GREEN, "name": "Green Zone"},
		{"pos": Vector2(150, 450), "color": Color.BLUE, "name": "Blue Zone"},
		{"pos": Vector2(650, 450), "color": Color.YELLOW, "name": "Yellow Zone"}
	]
	
	for zone_data in zones:
		var zone = ColorRect.new()
		zone.size = Vector2(120, 80)
		zone.position = zone_data.pos - zone.size / 2
		zone.color = zone_data.color
		zone.color.a = 0.3
		zone.name = zone_data.name
		add_child(zone)
		hover_zones.append(zone)

func _process(delta):
	_update_mouse_tracking()
	_update_player_movement(delta)
	_update_trail()
	_update_hover_zones()
	_cleanup_click_effects(delta)

func _input(event):
	if event is InputEventMouse:
		mouse_position = event.position
		
		if event is InputEventMouseButton:
			_handle_mouse_button(event)
		elif event is InputEventMouseMotion:
			_handle_mouse_motion(event)

func _handle_mouse_button(event: InputEventMouseButton):
	var button_name = _get_button_name(event.button_index)
	
	if event.pressed:
		mouse_buttons_pressed[button_name] = Time.get_ticks_msec() / 1000.0
		click_counts[button_name] += 1
		last_click_times[button_name] = Time.get_ticks_msec() / 1000.0
		
		# Start dragging on left click
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
			drag_start_pos = event.position
		
		# Create click effect
		_create_click_effect(event.position, _get_button_color(button_name))
		
	else:
		if mouse_buttons_pressed.has(button_name):
			var hold_time = Time.get_ticks_msec() / 1000.0 - mouse_buttons_pressed[button_name]
			mouse_buttons_pressed.erase(button_name)
			
			# End dragging
			if event.button_index == MOUSE_BUTTON_LEFT:
				is_dragging = false
	
	_update_button_display()

func _handle_mouse_motion(event: InputEventMouseMotion):
	# Add to trail
	mouse_trail.append(event.position)
	if mouse_trail.size() > max_trail_length:
		mouse_trail.pop_front()

func _get_button_name(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "left"
		MOUSE_BUTTON_RIGHT:
			return "right"
		MOUSE_BUTTON_MIDDLE:
			return "middle"
		MOUSE_BUTTON_WHEEL_UP:
			return "wheel_up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "wheel_down"
		_:
			return "unknown"

func _get_button_color(button_name: String) -> Color:
	match button_name:
		"left":
			return Color.CYAN
		"right":
			return Color.MAGENTA
		"middle":
			return Color.ORANGE
		_:
			return Color.WHITE

func _update_mouse_tracking():
	mouse_pos_label.text = "Mouse: (%.0f, %.0f)" % [mouse_position.x, mouse_position.y]

func _update_button_display():
	if mouse_buttons_pressed.is_empty():
		button_status_label.text = "Buttons: None"
		button_status_label.modulate = Color.WHITE
	else:
		var buttons_text = "Buttons: " + ", ".join(mouse_buttons_pressed.keys())
		button_status_label.text = buttons_text
		button_status_label.modulate = Color.YELLOW
	
	click_counter_label.text = "Clicks: L:%d R:%d M:%d" % [
		click_counts.left, click_counts.right, click_counts.middle
	]
	
	# Update drag info
	if is_dragging:
		var drag_distance = mouse_position.distance_to(drag_start_pos)
		drag_info_label.text = "Drag: %.1f pixels from (%.0f, %.0f)" % [
			drag_distance, drag_start_pos.x, drag_start_pos.y
		]
		drag_info_label.modulate = Color.LIME_GREEN
	else:
		drag_info_label.text = "Drag: Not dragging"
		drag_info_label.modulate = Color.WHITE

func _update_player_movement(delta):
	# Player follows mouse with sensitivity
	var target_pos = mouse_position
	var current_pos = player.position
	var move_distance = current_pos.distance_to(target_pos)
	
	if move_distance > 5:  # Dead zone
		var direction = (target_pos - current_pos).normalized()
		var move_speed = move_distance * sensitivity * 2
		player.position += direction * move_speed * delta
	
	# Change player color based on mouse activity
	var time_since_click = 999.0
	for button in last_click_times.keys():
		var time_diff = Time.get_ticks_msec() / 1000.0 - last_click_times[button]
		time_since_click = min(time_since_click, time_diff)
	
	if time_since_click < 0.5:
		player.modulate = Color.YELLOW
		player.scale = Vector2(1.3, 1.3)
	else:
		player.modulate = Color.WHITE
		player.scale = Vector2.ONE

func _update_trail():
	# Remove old trail points
	var fade_time = 2.0
	for i in range(mouse_trail.size() - 1, -1, -1):
		# In a real implementation, you'd track timestamps
		# For now, just limit size
		pass

func _update_hover_zones():
	for zone in hover_zones:
		var zone_rect = Rect2(zone.position, zone.size)
		if zone_rect.has_point(mouse_position):
			zone.color.a = 0.7
			zone.modulate = Color.WHITE
		else:
			zone.color.a = 0.3
			zone.modulate = Color(0.8, 0.8, 0.8)

func _create_click_effect(pos: Vector2, color: Color):
	var effect = {
		"position": pos,
		"color": color,
		"time": 0.0,
		"max_time": 0.5
	}
	click_effects.append(effect)

func _cleanup_click_effects(delta):
	for i in range(click_effects.size() - 1, -1, -1):
		click_effects[i].time += delta
		if click_effects[i].time >= click_effects[i].max_time:
			click_effects.remove_at(i)

func _draw():
	# Draw mouse trail
	if mouse_trail.size() > 1:
		for i in range(1, mouse_trail.size()):
			var alpha = float(i) / float(mouse_trail.size())
			var color = Color(1, 1, 1, alpha * 0.5)
			draw_line(mouse_trail[i-1], mouse_trail[i], color, 2.0)
	
	# Draw click effects
	for effect in click_effects:
		var progress = effect.time / effect.max_time
		var radius = 20 * (1 - progress)
		var alpha = 1 - progress
		var color = effect.color
		color.a = alpha
		draw_circle(effect.position, radius, color)
	
	# Always trigger redraw for animations
	queue_redraw()

func _on_sensitivity_changed(value):
	sensitivity = value
	_update_sensitivity_label()

func _update_sensitivity_label():
	sensitivity_label.text = "Sensitivity: %.1fx" % sensitivity
