extends Node2D

@onready var ui = $UI
@onready var physics_info = $UI/PhysicsPanel/VBoxContainer/PhysicsInfo
@onready var bodies_info = $UI/PhysicsPanel/VBoxContainer/BodiesInfo
@onready var forces_info = $UI/PhysicsPanel/VBoxContainer/ForcesInfo
@onready var gravity_slider = $UI/ControlPanel/VBoxContainer/GravityContainer/GravitySlider
@onready var gravity_label = $UI/ControlPanel/VBoxContainer/GravityContainer/GravityLabel
@onready var mass_slider = $UI/ControlPanel/VBoxContainer/MassContainer/MassSlider
@onready var mass_label = $UI/ControlPanel/VBoxContainer/MassContainer/MassLabel
@onready var damping_slider = $UI/ControlPanel/VBoxContainer/DampingContainer/DampingSlider
@onready var damping_label = $UI/ControlPanel/VBoxContainer/DampingContainer/DampingLabel
@onready var reset_button = $UI/ControlPanel/VBoxContainer/ResetButton
@onready var spawn_button = $UI/ControlPanel/VBoxContainer/SpawnButton
@onready var clear_button = $UI/ControlPanel/VBoxContainer/ClearButton

# Physics settings
var gravity_strength = 500.0
var world_gravity = Vector2(0, 500)
var default_mass = 5.0
var linear_damping = 0.5

# Rigid body management
var rigid_bodies = []
var total_kinetic_energy = 0.0
var collision_count = 0
var force_applied = Vector2.ZERO

# Body types and colors
var body_types = ["Box", "Circle", "Capsule"]
var body_colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.PURPLE, Color.ORANGE]
var current_body_type = 0

# Spawn settings
var spawn_position = Vector2(400, 100)
var max_bodies = 15

func _ready():
	_setup_ui()
	_setup_world_physics()
	_connect_signals()
	_spawn_initial_bodies()

func _setup_ui():
	physics_info.text = "Physics: Gravity enabled"
	bodies_info.text = "Bodies: 0"
	forces_info.text = "Forces: None"
	
	# Setup sliders
	gravity_slider.min_value = 0.0
	gravity_slider.max_value = 1500.0
	gravity_slider.value = gravity_strength
	gravity_slider.step = 50.0
	
	mass_slider.min_value = 0.5
	mass_slider.max_value = 20.0
	mass_slider.value = default_mass
	mass_slider.step = 0.5
	
	damping_slider.min_value = 0.0
	damping_slider.max_value = 5.0
	damping_slider.value = linear_damping
	damping_slider.step = 0.1

func _setup_world_physics():
	# Configure world physics
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity_strength)
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, world_gravity.normalized())

func _connect_signals():
	gravity_slider.value_changed.connect(_on_gravity_changed)
	mass_slider.value_changed.connect(_on_mass_changed)
	damping_slider.value_changed.connect(_on_damping_changed)
	reset_button.pressed.connect(_reset_simulation)
	spawn_button.pressed.connect(_spawn_random_body)
	clear_button.pressed.connect(_clear_all_bodies)

func _spawn_initial_bodies():
	# Spawn a few initial bodies to demonstrate
	for i in range(3):
		_spawn_random_body()

func _process(delta):
	_update_physics_simulation(delta)
	_handle_input()
	_update_ui()

func _update_physics_simulation(delta):
	# Calculate total kinetic energy
	total_kinetic_energy = 0.0
	
	for body in rigid_bodies:
		if is_instance_valid(body):
			var kinetic = 0.5 * body.mass * body.linear_velocity.length_squared()
			total_kinetic_energy += kinetic

func _handle_input():
	# Mouse interaction with bodies
	if Input.is_action_just_pressed("ui_accept"):
		var mouse_pos = get_global_mouse_position()
		_apply_force_at_position(mouse_pos, Vector2.UP * 300)
	
	# Spawn new body with mouse click
	if Input.is_action_just_pressed("ui_2"):  # Right click or X key
		var mouse_pos = get_global_mouse_position()
		_spawn_body_at_position(mouse_pos)
	
	# Cycle body type
	if Input.is_action_just_pressed("ui_1"):
		current_body_type = (current_body_type + 1) % body_types.size()
	
	# Apply explosion force
	if Input.is_action_just_pressed("ui_3"):
		_apply_explosion_force(get_global_mouse_position(), 1000.0, 200.0)

func _spawn_random_body():
	if rigid_bodies.size() >= max_bodies:
		return
	
	var position = Vector2(
		randf_range(100, 700),
		randf_range(50, 200)
	)
	_spawn_body_at_position(position)

func _spawn_body_at_position(pos: Vector2):
	if rigid_bodies.size() >= max_bodies:
		return
	
	var body = RigidBody2D.new()
	body.position = pos
	body.mass = default_mass
	body.linear_damp = linear_damping
	body.gravity_scale = 1.0
	
	# Create collision shape based on type
	var collision = CollisionShape2D.new()
	var shape
	var visual
	
	match body_types[current_body_type]:
		"Box":
			shape = RectangleShape2D.new()
			shape.size = Vector2(40, 40)
			visual = _create_box_visual(40, 40)
		"Circle":
			shape = CircleShape2D.new()
			shape.radius = 20
			visual = _create_circle_visual(20)
		"Capsule":
			shape = CapsuleShape2D.new()
			shape.radius = 15
			shape.height = 40
			visual = _create_capsule_visual(15, 40)
	
	collision.shape = shape
	body.add_child(collision)
	body.add_child(visual)
	
	# Set random color
	var color = body_colors[rigid_bodies.size() % body_colors.size()]
	visual.modulate = color
	
	# Add physics properties
	body.set_meta("body_type", body_types[current_body_type])
	body.set_meta("spawn_time", Time.get_ticks_msec() / 1000.0)
	
	# Connect collision signal - note: RigidBody2D doesn't have body_entered
	# We'll use a different approach for collision detection
	
	rigid_bodies.append(body)
	add_child(body)
	
	# Apply initial random velocity
	var initial_velocity = Vector2(
		randf_range(-100, 100),
		randf_range(-50, 50)
	)
	body.linear_velocity = initial_velocity

func _create_box_visual(width: float, height: float) -> ColorRect:
	var rect = ColorRect.new()
	rect.size = Vector2(width, height)
	rect.position = Vector2(-width/2, -height/2)
	rect.color = Color.WHITE
	return rect

func _create_circle_visual(radius: float) -> Control:
	var control = Control.new()
	control.custom_minimum_size = Vector2(radius * 2, radius * 2)
	control.position = Vector2(-radius, -radius)
	control.draw.connect(_draw_circle_visual.bind(control, radius))
	return control

func _draw_circle_visual(control: Control, radius: float):
	control.draw_circle(Vector2(radius, radius), radius, Color.WHITE)

func _create_capsule_visual(radius: float, height: float) -> Control:
	var control = Control.new()
	control.custom_minimum_size = Vector2(radius * 2, height)
	control.position = Vector2(-radius, -height/2)
	control.draw.connect(_draw_capsule_visual.bind(control, radius, height))
	return control

func _draw_capsule_visual(control: Control, radius: float, height: float):
	# Draw capsule as rectangle with rounded ends
	var rect = Rect2(0, radius, radius * 2, height - radius * 2)
	control.draw_rect(rect, Color.WHITE)
	control.draw_circle(Vector2(radius, radius), radius, Color.WHITE)
	control.draw_circle(Vector2(radius, height - radius), radius, Color.WHITE)

func _apply_force_at_position(pos: Vector2, force: Vector2):
	# Find nearest body and apply force
	var nearest_body = null
	var nearest_distance = 100.0  # Maximum interaction distance
	
	for body in rigid_bodies:
		if is_instance_valid(body):
			var distance = body.position.distance_to(pos)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_body = body
	
	if nearest_body:
		nearest_body.apply_central_impulse(force)
		force_applied = force
		
		# Visual feedback
		nearest_body.get_child(1).modulate = Color.YELLOW
		var tween = create_tween()
		tween.tween_method(_reset_body_color.bind(nearest_body), 1.0, 0.0, 0.5)

func _apply_explosion_force(center: Vector2, force_strength: float, radius: float):
	for body in rigid_bodies:
		if is_instance_valid(body):
			var distance = body.position.distance_to(center)
			if distance < radius:
				var direction = (body.position - center).normalized()
				var falloff = 1.0 - (distance / radius)
				var impulse = direction * force_strength * falloff
				body.apply_central_impulse(impulse)
				
				# Visual feedback
				body.get_child(1).modulate = Color.RED
				var tween = create_tween()
				tween.tween_method(_reset_body_color.bind(body), 1.0, 0.0, 0.8)

func _reset_body_color(body: RigidBody2D, progress: float):
	if is_instance_valid(body):
		var original_color = body_colors[rigid_bodies.find(body) % body_colors.size()]
		var current_color = body.get_child(1).modulate
		body.get_child(1).modulate = current_color.lerp(original_color, 1.0 - progress)

func _on_gravity_changed(value: float):
	gravity_strength = value
	world_gravity = Vector2(0, gravity_strength)
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity_strength)
	gravity_label.text = "Gravity: %.0f" % gravity_strength

func _on_mass_changed(value: float):
	default_mass = value
	mass_label.text = "Mass: %.1f" % default_mass
	
	# Update existing bodies
	for body in rigid_bodies:
		if is_instance_valid(body):
			body.mass = default_mass

func _on_damping_changed(value: float):
	linear_damping = value
	damping_label.text = "Damping: %.1f" % linear_damping
	
	# Update existing bodies
	for body in rigid_bodies:
		if is_instance_valid(body):
			body.linear_damp = linear_damping

func _reset_simulation():
	_clear_all_bodies()
	collision_count = 0
	_spawn_initial_bodies()

func _clear_all_bodies():
	for body in rigid_bodies:
		if is_instance_valid(body):
			body.queue_free()
	rigid_bodies.clear()

func _update_ui():
	# Update physics info
	physics_info.text = "Energy: %.1f | Gravity: %.0f" % [total_kinetic_energy, gravity_strength]
	
	# Update bodies info
	var active_bodies = 0
	for body in rigid_bodies:
		if is_instance_valid(body):
			active_bodies += 1
	
	bodies_info.text = "Bodies: %d/%d | Type: %s" % [active_bodies, max_bodies, body_types[current_body_type]]
	
	# Update forces info
	var force_magnitude = force_applied.length()
	if force_magnitude > 0:
		forces_info.text = "Last Force: %.1f" % force_magnitude
		force_applied = force_applied.move_toward(Vector2.ZERO, 500 * get_process_delta_time())
	else:
		forces_info.text = "Forces: Click to apply | X for explosion"
	
	# Update labels
	gravity_label.text = "Gravity: %.0f" % gravity_strength
	mass_label.text = "Mass: %.1f" % default_mass
	damping_label.text = "Damping: %.1f" % linear_damping

# Draw physics visualization
func _draw():
	# Draw ground line
	draw_line(Vector2(0, 500), Vector2(800, 500), Color.WHITE, 2.0)
	
	# Draw velocity vectors for bodies
	for body in rigid_bodies:
		if is_instance_valid(body) and body.linear_velocity.length() > 10:
			var start = body.position
			var end = start + body.linear_velocity.normalized() * 50
			draw_line(start, end, Color.CYAN, 3.0)
			
			# Draw arrow head
			var arrow_size = 8
			var arrow_angle = 0.5
			var v1 = end + Vector2(cos(body.linear_velocity.angle() + PI - arrow_angle), sin(body.linear_velocity.angle() + PI - arrow_angle)) * arrow_size
			var v2 = end + Vector2(cos(body.linear_velocity.angle() + PI + arrow_angle), sin(body.linear_velocity.angle() + PI + arrow_angle)) * arrow_size
			draw_line(end, v1, Color.CYAN, 3.0)
			draw_line(end, v2, Color.CYAN, 3.0)
	
	# Draw force application indicator
	if force_applied.length() > 0:
		var mouse_pos = get_global_mouse_position()
		draw_circle(mouse_pos, 20, Color(1, 1, 0, 0.3))
	
	# Draw legend
	var legend_pos = Vector2(50, 520)
	var font = ThemeDB.fallback_font
	var instructions = [
		"Enter/Space: Apply force at mouse",
		"X: Spawn body at mouse",
		"Z: Change body type (" + body_types[current_body_type] + ")",
		"C: Explosion at mouse"
	]
	
	for i in range(instructions.size()):
		draw_string(font, legend_pos + Vector2(0, i * 20), instructions[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.YELLOW)
	
	# Always redraw for smooth visuals
	queue_redraw()
