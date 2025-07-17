extends CommonTutorial

# Enhanced Particle Systems Demo
# Interactive demonstration of Godot's particle system capabilities

# Particle systems
var particle_fire: GPUParticles2D
var particle_smoke: GPUParticles2D
var particle_stars: GPUParticles2D
var particle_explosion: GPUParticles2D

# UI Controls
var effect_buttons: Array = []
var intensity_slider: HSlider
var size_slider: HSlider
var speed_slider: HSlider
var lifetime_slider: HSlider
var emission_toggle: Button

# Current effect
var current_effect = 0
var effect_names = ["Fire", "Smoke", "Stars", "Explosion"]
var active_particles: GPUParticles2D

# Challenge tracking
var explosion_triggered = false

func get_demo_title() -> String:
	return "🎆 Particle Systems"

func get_demo_description() -> String:
	return "Master visual effects with interactive particle systems including fire, smoke, stars, and explosions."

func get_demo_category() -> String:
	return "visual_effects"

func setup_demo_specific():
	_setup_particle_systems()
	_create_particle_controls()
	_setup_particle_presets()
	_setup_challenges()

func reset_demo():
	# Reset all particles
	for particles in [particle_fire, particle_smoke, particle_stars, particle_explosion]:
		if particles:
			particles.emitting = false
	
	# Reset to first effect
	_on_effect_selected(0)
	
	# Reset UI controls
	if intensity_slider:
		intensity_slider.value = 1.0
	if size_slider:
		size_slider.value = 1.0
	if speed_slider:
		speed_slider.value = 1.0
	if lifetime_slider:
		lifetime_slider.value = 2.0

func _setup_challenges():
	add_challenge("Fire Effect", "Create and activate the fire particle effect", 
		func(): return particle_fire and particle_fire.emitting)
	add_challenge("Smoke Effect", "Switch to and activate the smoke effect", 
		func(): return particle_smoke and particle_smoke.emitting)
	add_challenge("Star Effect", "Create magical sparkles with the stars effect", 
		func(): return particle_stars and particle_stars.emitting)
	add_challenge("Explosion", "Trigger the explosive particle effect", 
		func(): return particle_explosion and particle_explosion.emitting)

func _setup_particle_systems():
	# Fire particles
	particle_fire = GPUParticles2D.new()
	demo_area.add_child(particle_fire)
	particle_fire.position = Vector2(100, 150)
	particle_fire.emitting = false
	_setup_fire_particles()
	
	# Smoke particles  
	particle_smoke = GPUParticles2D.new()
	demo_area.add_child(particle_smoke)
	particle_smoke.position = Vector2(250, 150)
	particle_smoke.emitting = false
	_setup_smoke_particles()
	
	# Stars particles
	particle_stars = GPUParticles2D.new()
	demo_area.add_child(particle_stars)
	particle_stars.position = Vector2(400, 150)
	particle_stars.emitting = false
	_setup_stars_particles()
	
	# Explosion particles
	particle_explosion = GPUParticles2D.new()
	demo_area.add_child(particle_explosion)
	particle_explosion.position = Vector2(275, 250)
	particle_explosion.emitting = false
	_setup_explosion_particles()
	
	# Start with fire effect
	active_particles = particle_fire

func _create_particle_controls():
	# Add particle-specific controls to the UI container
	var control_panel = VBoxContainer.new()
	ui_container.add_child(control_panel)
	
	# Effect selection section
	var effect_section = create_info_label("Select Particle Effect:", theme_primary_color)
	control_panel.add_child(effect_section)
	
	var button_grid = GridContainer.new()
	button_grid.columns = 2
	control_panel.add_child(button_grid)
	
	for i in range(effect_names.size()):
		var button = create_button(effect_names[i], _on_effect_selected.bind(i))
		effect_buttons.append(button)
		button_grid.add_child(button)
	
	# Parameter controls section
	var params_section = create_info_label("Adjust Parameters:", theme_primary_color)
	control_panel.add_child(params_section)
	
	# Intensity control
	var intensity_container = create_labeled_slider("Intensity", 1.0, 5.0, 1.0, _on_intensity_changed)
	control_panel.add_child(intensity_container)
	intensity_slider = intensity_container.get_child(1)
	
	# Size control  
	var size_container = create_labeled_slider("Size", 0.1, 3.0, 1.0, _on_size_changed)
	control_panel.add_child(size_container)
	size_slider = size_container.get_child(1)
	
	# Speed control
	var speed_container = create_labeled_slider("Speed", 0.1, 3.0, 1.0, _on_speed_changed)
	control_panel.add_child(speed_container)
	speed_slider = speed_container.get_child(1)
	
	# Lifetime control
	var lifetime_container = create_labeled_slider("Lifetime", 0.5, 10.0, 2.0, _on_lifetime_changed)
	control_panel.add_child(lifetime_container)
	lifetime_slider = lifetime_container.get_child(1)
	
	# Control buttons
	emission_toggle = create_button("▶ Start Emission", _on_emission_toggled)
	control_panel.add_child(emission_toggle)
	
	var explosion_btn = create_button("💥 EXPLODE!", _trigger_explosion)
	explosion_btn.modulate = theme_warning_color
	control_panel.add_child(explosion_btn)

func _process(_delta):
	check_current_challenge()

func _setup_fire_particles():
	var material = ParticleProcessMaterial.new()
	
	# Fire characteristics
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.angular_velocity_min = -90.0
	material.angular_velocity_max = 90.0
	
	# Gravity and physics
	material.gravity = Vector3(0, -200, 0)
	material.scale_min = 0.5
	material.scale_max = 1.5
	
	# Color and appearance
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.YELLOW)
	gradient.add_point(0.3, Color.ORANGE) 
	gradient.add_point(0.7, Color.RED)
	gradient.add_point(1.0, Color.TRANSPARENT)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	# Emission settings
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(20, 5, 0)
	
	particle_fire.process_material = material
	particle_fire.amount = 50
	particle_fire.lifetime = 2.0
	particle_fire.texture = _create_circle_texture(16, Color.WHITE)

func _setup_smoke_particles():
	var material = ParticleProcessMaterial.new()
	
	# Smoke characteristics
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 40.0
	
	# Wind effect
	material.gravity = Vector3(30, -50, 0)
	material.scale_min = 0.3
	material.scale_max = 2.0
	
	# Color and transparency
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.8, 0.8, 0.8, 0.8))
	gradient.add_point(0.5, Color(0.6, 0.6, 0.6, 0.4))
	gradient.add_point(1.0, Color.TRANSPARENT)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	# Emission settings
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(15, 3, 0)
	
	particle_smoke.process_material = material
	particle_smoke.amount = 30
	particle_smoke.lifetime = 4.0
	particle_smoke.texture = _create_soft_circle_texture(24)

func _setup_stars_particles():
	var material = ParticleProcessMaterial.new()
	
	# Magical sparkle characteristics
	material.direction = Vector3(0, 0, 0)
	material.initial_velocity_min = 5.0
	material.initial_velocity_max = 25.0
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	
	# Floating behavior
	material.gravity = Vector3(0, -10, 0)
	material.scale_min = 0.2
	material.scale_max = 1.0
	
	# Twinkling colors
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.CYAN)
	gradient.add_point(0.3, Color.WHITE)
	gradient.add_point(0.6, Color.YELLOW)
	gradient.add_point(1.0, Color.BLUE)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	# Random emission area
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 50.0
	
	particle_stars.process_material = material
	particle_stars.amount = 100
	particle_stars.lifetime = 3.0
	particle_stars.texture = _create_star_texture()

func _setup_explosion_particles():
	var material = ParticleProcessMaterial.new()
	
	# Explosive characteristics
	material.direction = Vector3(0, 0, 0)
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 300.0
	material.angular_velocity_min = -360.0
	material.angular_velocity_max = 360.0
	
	# Radial explosion
	material.gravity = Vector3(0, 200, 0)
	material.scale_min = 0.5
	material.scale_max = 2.0
	
	# Explosion colors
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.WHITE)
	gradient.add_point(0.2, Color.YELLOW)
	gradient.add_point(0.5, Color.ORANGE)
	gradient.add_point(0.8, Color.RED)
	gradient.add_point(1.0, Color.TRANSPARENT)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	# Point emission
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	
	particle_explosion.process_material = material
	particle_explosion.amount = 200
	particle_explosion.lifetime = 1.5
	particle_explosion.emitting = false
	particle_explosion.texture = _create_circle_texture(12, Color.WHITE)

func _create_circle_texture(size: int, color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2, size / 2)
	var radius = size / 2 - 1
	
	for x in range(size):
		for y in range(size):
			var distance = Vector2(x, y).distance_to(center)
			if distance <= radius:
				var alpha = 1.0 - (distance / radius)
				image.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _create_soft_circle_texture(size: int) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2, size / 2)
	var radius = size / 2 - 1
	
	for x in range(size):
		for y in range(size):
			var distance = Vector2(x, y).distance_to(center)
			if distance <= radius:
				var alpha = 1.0 - pow(distance / radius, 0.5)  # Softer falloff
				image.set_pixel(x, y, Color(1, 1, 1, alpha * 0.6))
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _create_star_texture() -> ImageTexture:
	var size = 16
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2, size / 2)
	
	# Create a simple star shape
	for x in range(size):
		for y in range(size):
			var pos = Vector2(x, y) - center
			var distance = pos.length()
			var angle = pos.angle()
			
			# Star pattern using sine waves
			var star_factor = sin(angle * 5.0) * 0.3 + 0.7
			var max_distance = (size / 2 - 1) * star_factor
			
			if distance <= max_distance:
				var alpha = 1.0 - (distance / max_distance)
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _setup_particle_presets():
	_on_effect_selected(0)

# Control callbacks
func _on_effect_selected(effect_index: int):
	# Stop all particles
	for particles in [particle_fire, particle_smoke, particle_stars, particle_explosion]:
		if particles:
			particles.emitting = false
	
	# Update button states
	for i in range(effect_buttons.size()):
		effect_buttons[i].modulate = Color.WHITE if i != effect_index else theme_success_color
	
	current_effect = effect_index
	
	# Set active particles
	match effect_index:
		0: active_particles = particle_fire
		1: active_particles = particle_smoke
		2: active_particles = particle_stars
		3: active_particles = particle_explosion
	
	print("Selected: " + effect_names[effect_index])

func _on_intensity_changed(value: float):
	if active_particles:
		var base_amount = 50 if current_effect == 0 else (30 if current_effect == 1 else (100 if current_effect == 2 else 200))
		active_particles.amount = int(base_amount * value)

func _on_size_changed(value: float):
	if active_particles and active_particles.process_material:
		var material = active_particles.process_material as ParticleProcessMaterial
		var base_min = 0.5 if current_effect == 0 else (0.3 if current_effect == 1 else (0.2 if current_effect == 2 else 0.5))
		var base_max = 1.5 if current_effect == 0 else (2.0 if current_effect == 1 else (1.0 if current_effect == 2 else 2.0))
		material.scale_min = base_min * value
		material.scale_max = base_max * value

func _on_speed_changed(value: float):
	if active_particles and active_particles.process_material:
		var material = active_particles.process_material as ParticleProcessMaterial
		var base_min = 50.0 if current_effect == 0 else (20.0 if current_effect == 1 else (5.0 if current_effect == 2 else 100.0))
		var base_max = 100.0 if current_effect == 0 else (40.0 if current_effect == 1 else (25.0 if current_effect == 2 else 300.0))
		material.initial_velocity_min = base_min * value
		material.initial_velocity_max = base_max * value

func _on_lifetime_changed(value: float):
	if active_particles:
		active_particles.lifetime = value

func _on_emission_toggled():
	if active_particles:
		active_particles.emitting = !active_particles.emitting
		emission_toggle.text = "⏸ Stop Emission" if active_particles.emitting else "▶ Start Emission"

func _trigger_explosion():
	particle_explosion.emitting = false
	await get_tree().process_frame
	particle_explosion.restart()
	particle_explosion.emitting = true
	explosion_triggered = true
	print("💥 BOOM! Explosion triggered!")
