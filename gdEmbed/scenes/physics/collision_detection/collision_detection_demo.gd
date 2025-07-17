extends Node2D

@onready var ui = $UI
@onready var collision_info = $UI/CollisionPanel/VBoxContainer/CollisionInfo
@onready var detection_info = $UI/CollisionPanel/VBoxContainer/DetectionInfo
@onready var method_info = $UI/CollisionPanel/VBoxContainer/MethodInfo
@onready var performance_info = $UI/StatusPanel/VBoxContainer/PerformanceInfo
@onready var player = $Player

# Collision objects
var collision_objects = []
var detection_method = 0  # 0=Area2D, 1=RayCasting, 2=Shape queries
var method_names = ["Area Detection", "Ray Casting", "Shape Queries"]

# Collision tracking
var current_collisions = []
var collision_count = 0
var last_collision_time = 0.0

# Ray casting
var ray_directions = [
	Vector2.UP,
	Vector2.DOWN, 
	Vector2.LEFT,
	Vector2.RIGHT,
	Vector2.UP + Vector2.RIGHT,
	Vector2.UP + Vector2.LEFT,
	Vector2.DOWN + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT
]
var ray_length = 100.0
var ray_hits = []

# Shape queries
var detection_radius = 60.0
var shape_query: PhysicsShapeQueryParameters2D
var circle_shape: CircleShape2D

func _ready():
	_setup_ui()
	_setup_player()
	_setup_collision_objects()
	_setup_detection_systems()

func _setup_ui():
	collision_info.text = "Collisions: None detected"
	detection_info.text = "Active objects: 0"
	method_info.text = "Method: " + method_names[detection_method]
	performance_info.text = "Performance: Ready"

func _setup_player():
	player.add_to_group("player")
	player.position = Vector2(400, 300)

func _setup_collision_objects():
	# Create various collision objects
	var object_data = [
		{"pos": Vector2(200, 200), "size": Vector2(80, 80), "color": Color.RED, "type": "static"},
		{"pos": Vector2(600, 200), "size": Vector2(60, 120), "color": Color.GREEN, "type": "static"},
		{"pos": Vector2(200, 400), "size": Vector2(100, 60), "color": Color.BLUE, "type": "moving"},
		{"pos": Vector2(600, 400), "size": Vector2(70, 70), "color": Color.YELLOW, "type": "rotating"},
		{"pos": Vector2(400, 150), "size": Vector2(120, 40), "color": Color.PURPLE, "type": "static"}
	]
	
	for data in object_data:
		var obj = _create_collision_object(data)
		collision_objects.append(obj)
		add_child(obj)

func _create_collision_object(data: Dictionary) -> RigidBody2D:
	var obj = RigidBody2D.new()
	obj.gravity_scale = 0  # No gravity for demo objects
	obj.lock_rotation = true if data.type != "rotating" else false
	
	# Visual representation
	var sprite = ColorRect.new()
	sprite.size = data.size
	sprite.position = -data.size / 2
	sprite.color = data.color
	obj.add_child(sprite)
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = data.size
	collision.shape = shape
	obj.add_child(collision)
	
	# Area for detection (if using area method)
	var area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	area_collision.shape = shape
	area.add_child(area_collision)
	obj.add_child(area)
	
	# Store metadata
	obj.set_meta("object_type", data.type)
	obj.set_meta("original_pos", data.pos)
	obj.position = data.pos
	
	return obj

func _setup_detection_systems():
	# Setup shape query for method 2
	circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.shape = circle_shape
	shape_query.collision_mask = 1  # Default layer

func _process(delta):
	_update_moving_objects(delta)
	_perform_collision_detection()
	_handle_input()
	_update_ui()

func _update_moving_objects(delta):
	for obj in collision_objects:
		var type = obj.get_meta("object_type")
		
		match type:
			"moving":
				# Oscillate back and forth
				var original_pos = obj.get_meta("original_pos")
				obj.position.x = original_pos.x + sin(Time.get_ticks_msec() / 1000.0) * 100
			"rotating":
				# Rotate continuously
				obj.rotation += delta * 2.0

func _perform_collision_detection():
	current_collisions.clear()
	ray_hits.clear()
	
	match detection_method:
		0:
			_detect_with_areas()
		1:
			_detect_with_raycasting()
		2:
			_detect_with_shape_queries()

func _detect_with_areas():
	# Check overlaps using Area2D (simplest method)
	for obj in collision_objects:
		var area = obj.get_child(2)  # Area2D is 3rd child
		if area.has_overlapping_bodies():
			var overlapping = area.get_overlapping_bodies()
			for body in overlapping:
				if body == player:
					current_collisions.append(obj)
					break

func _detect_with_raycasting():
	# Cast rays in multiple directions from player
	var space_state = get_world_2d().direct_space_state
	
	for direction in ray_directions:
		var query = PhysicsRayQueryParameters2D.new()
		query.from = player.position
		query.to = player.position + direction * ray_length
		query.exclude = [player]
		
		var result = space_state.intersect_ray(query)
		if result:
			ray_hits.append({
				"position": result.position,
				"normal": result.normal,
				"collider": result.collider,
				"direction": direction
			})
			
			if not result.collider in current_collisions:
				current_collisions.append(result.collider)

func _detect_with_shape_queries():
	# Use shape queries for area-based detection
	var space_state = get_world_2d().direct_space_state
	
	shape_query.transform = Transform2D(0, player.position)
	var results = space_state.intersect_shape(shape_query)
	
	for result in results:
		var collider = result.collider
		if collider != player and not collider in current_collisions:
			current_collisions.append(collider)

func _handle_input():
	# Switch detection methods with number keys
	if Input.is_action_just_pressed("ui_1"):
		detection_method = 0
	elif Input.is_action_just_pressed("ui_2"):
		detection_method = 1
	elif Input.is_action_just_pressed("ui_3"):
		detection_method = 2
	
	# Move player
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	
	if input_vector != Vector2.ZERO:
		player.position += input_vector.normalized() * 200 * get_process_delta_time()
	
	# Reset position
	if Input.is_action_just_pressed("ui_reset"):
		player.position = Vector2(400, 300)
	
	# Keep player in bounds
	player.position.x = clamp(player.position.x, 50, 750)
	player.position.y = clamp(player.position.y, 50, 550)

func _update_ui():
	# Update collision info
	if current_collisions.is_empty():
		collision_info.text = "Collisions: None detected"
		collision_info.modulate = Color.WHITE
		player.modulate = Color.WHITE
	else:
		collision_info.text = "Collisions: %d objects" % current_collisions.size()
		collision_info.modulate = Color.RED
		player.modulate = Color.RED
		
		# Update collision counter
		collision_count += 1
		last_collision_time = Time.get_ticks_msec() / 1000.0
	
	# Update detection info
	detection_info.text = "Active objects: %d" % collision_objects.size()
	
	# Update method info
	method_info.text = "Method: " + method_names[detection_method] + " (Press 1-3)"
	
	# Update performance info
	var fps = Engine.get_frames_per_second()
	performance_info.text = "FPS: %d | Collisions found: %d" % [fps, collision_count]

# Draw collision visualization
func _draw():
	# Draw detection method visualization
	match detection_method:
		0:
			# Area detection - show detection circles around objects
			for obj in collision_objects:
				draw_circle(obj.position, 40, Color(1, 1, 1, 0.1))
		1:
			# Ray casting - show rays
			for direction in ray_directions:
				var end_pos = player.position + direction * ray_length
				var color = Color.YELLOW
				
				# Check if this ray hit something
				for hit in ray_hits:
					if hit.direction == direction:
						end_pos = hit.position
						color = Color.RED
						# Draw impact normal
						var normal_end = hit.position + hit.normal * 30
						draw_line(hit.position, normal_end, Color.CYAN, 3.0)
						break
				
				draw_line(player.position, end_pos, color, 2.0)
		2:
			# Shape queries - show detection area
			draw_circle(player.position, detection_radius, Color(0, 1, 0, 0.2))
			draw_circle(player.position, detection_radius, Color.GREEN, 2.0, false)
	
	# Draw collision indicators
	for obj in current_collisions:
		draw_circle(obj.position, 50, Color(1, 0, 0, 0.3))
	
	# Draw player bounds
	draw_circle(player.position, 25, Color.WHITE, 2.0, false)
	
	# Draw method legend
	var legend_pos = Vector2(50, 480)
	var font = ThemeDB.fallback_font
	var methods = ["1: Area Detection", "2: Ray Casting", "3: Shape Queries"]
	
	for i in range(methods.size()):
		var color = Color.YELLOW if i == detection_method else Color.WHITE
		draw_string(font, legend_pos + Vector2(0, i * 20), methods[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
	
	# Always redraw for smooth visuals
	queue_redraw()
