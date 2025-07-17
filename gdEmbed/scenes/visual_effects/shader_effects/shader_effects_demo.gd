extends CommonTutorial

# Enhanced Shader Effects Demo
# Interactive demonstration of various shader techniques

@onready var shader_display = ColorRect.new()
@onready var shader_material = ShaderMaterial.new()

# UI Controls
var effect_buttons: Array[Button] = []
var time_speed_slider: HSlider
var intensity_slider: HSlider
var color_picker: ColorPicker

# Shader effects
var current_shader = 0
var shader_names = ["Wave Distortion", "Color Shift", "Glow Effect", "Noise Pattern"]
var shader_sources = []

# Challenge tracking
var wave_created = false
var color_created = false
var glow_created = false
var noise_created = false

func get_demo_title() -> String:
	return "✨ Shader Effects"

func get_demo_description() -> String:
	return "Explore the power of GPU shaders with interactive visual effects and real-time parameter control."

func get_demo_category() -> String:
	return "visual_effects"

func setup_demo_specific():
	_create_shader_display()
	_create_shader_sources()
	_create_enhanced_controls()
	_setup_initial_shader()
	_setup_shader_challenges()

func reset_demo():
	# Reset to first shader
	_on_shader_selected(0)
	
	# Reset UI controls
	if time_speed_slider:
		time_speed_slider.value = 1.0
	if intensity_slider:
		intensity_slider.value = 1.0
	if color_picker:
		color_picker.color = Color.CYAN

func _setup_shader_challenges():
	add_challenge("Wave Master", "Create mesmerizing wave distortions", 
		func(): return current_shader == 0 and wave_created)
	add_challenge("Color Alchemist", "Master color shifting techniques", 
		func(): return current_shader == 1 and color_created)
	add_challenge("Glow Artist", "Add stunning glow effects", 
		func(): return current_shader == 2 and glow_created)
	add_challenge("Noise Engineer", "Generate procedural noise patterns", 
		func(): return current_shader == 3 and noise_created)

func _create_shader_display():
	# Shader display area in demo area - use TextureRect instead of ColorRect for texture support
	var texture_rect = TextureRect.new()
	demo_area.add_child(texture_rect)
	texture_rect.position = Vector2(50, 50)
	texture_rect.size = Vector2(400, 400)
	texture_rect.material = shader_material
	texture_rect.texture = _create_background_texture()
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	
	# Store reference
	shader_display = texture_rect

func _create_shader_sources():
	# Wave distortion shader
	var wave_shader = """
shader_type canvas_item;

uniform float time_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_intensity : hint_range(0.0, 0.1) = 0.02;
uniform vec4 base_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);

void fragment() {
	vec2 wave_uv = UV;
	wave_uv.x += sin(UV.y * 10.0 + TIME * time_speed) * wave_intensity;
	wave_uv.y += cos(UV.x * 8.0 + TIME * time_speed * 0.8) * wave_intensity;
	
	vec4 tex_color = texture(TEXTURE, wave_uv);
	COLOR = mix(tex_color, base_color, 0.3);
}
"""
	
	# Color shift shader
	var color_shift_shader = """
shader_type canvas_item;

uniform float time_speed : hint_range(0.1, 5.0) = 1.0;
uniform float shift_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 shift_color : source_color = vec4(1.0, 0.5, 0.8, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	float time_cycle = sin(TIME * time_speed) * 0.5 + 0.5;
	vec4 shifted_color = mix(tex_color, shift_color, time_cycle * shift_intensity);
	
	COLOR = shifted_color;
}
"""
	
	# Glow effect shader
	var glow_shader = """
shader_type canvas_item;

uniform float time_speed : hint_range(0.1, 5.0) = 1.0;
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	float glow_pulse = sin(TIME * time_speed) * 0.5 + 0.5;
	vec4 glow_effect = glow_color * glow_pulse * glow_intensity * 0.3;
	
	COLOR = tex_color + glow_effect;
}
"""
	
	# Noise pattern shader
	var noise_shader = """
shader_type canvas_item;

uniform float time_speed : hint_range(0.1, 5.0) = 1.0;
uniform float noise_scale : hint_range(1.0, 20.0) = 10.0;
uniform vec4 noise_color : source_color = vec4(0.8, 0.2, 1.0, 1.0);

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 noise_uv = UV * noise_scale + TIME * time_speed;
	float noise_value = noise(noise_uv);
	
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = mix(tex_color, noise_color, noise_value * 0.5);
}
"""
	
	shader_sources = [wave_shader, color_shift_shader, glow_shader, noise_shader]

func _create_enhanced_controls():
	# Shader control section
	var shader_section = create_info_label("Select Shader Effect:", theme_primary_color)
	ui_container.add_child(shader_section)
	
	# Effect selection buttons
	var button_grid = GridContainer.new()
	button_grid.columns = 2
	ui_container.add_child(button_grid)
	
	for i in range(shader_names.size()):
		var button = create_button(shader_names[i], _on_shader_selected.bind(i))
		effect_buttons.append(button)
		button_grid.add_child(button)
	
	# Parameter controls section
	var params_section = create_info_label("Adjust Parameters:", theme_primary_color)
	ui_container.add_child(params_section)
	
	# Time speed control
	var time_container = create_labeled_slider("Time Speed", 0.1, 5.0, 1.0, _on_time_speed_changed)
	ui_container.add_child(time_container)
	time_speed_slider = time_container.get_child(1)
	
	# Intensity control
	var intensity_container = create_labeled_slider("Intensity", 0.0, 2.0, 1.0, _on_intensity_changed)
	ui_container.add_child(intensity_container)
	intensity_slider = intensity_container.get_child(1)
	
	# Color picker section
	var color_section = create_info_label("Effect Color:", theme_primary_color)
	ui_container.add_child(color_section)
	
	color_picker = ColorPicker.new()
	color_picker.custom_minimum_size = Vector2(260, 150)
	color_picker.color_changed.connect(_on_color_changed)
	color_picker.color = Color.CYAN
	ui_container.add_child(color_picker)

func _setup_initial_shader():
	_on_shader_selected(0)

func _process(_delta):
	check_current_challenge()

# Control callbacks
func _on_shader_selected(shader_index: int):
	current_shader = shader_index
	
	# Update button states
	for i in range(effect_buttons.size()):
		effect_buttons[i].modulate = Color.WHITE if i != shader_index else theme_success_color
	
	# Create and apply shader
	var shader = Shader.new()
	shader.code = shader_sources[shader_index]
	shader_material.shader = shader
	
	# Set default parameters
	_update_shader_parameters()
	
	# Mark shader as created for challenges
	match shader_index:
		0: wave_created = true
		1: color_created = true
		2: glow_created = true
		3: noise_created = true
	
	print("Selected: " + shader_names[shader_index])

func _on_time_speed_changed(value: float):
	_update_shader_parameters()

func _on_intensity_changed(value: float):
	_update_shader_parameters()

func _on_color_changed(color: Color):
	_update_shader_parameters()

func _update_shader_parameters():
	if not shader_material.shader:
		return
	
	# Set common parameters
	shader_material.set_shader_parameter("time_speed", time_speed_slider.value)
	
	# Set effect-specific parameters
	match current_shader:
		0:  # Wave
			shader_material.set_shader_parameter("wave_intensity", intensity_slider.value * 0.05)
			shader_material.set_shader_parameter("base_color", color_picker.color)
		1:  # Color shift
			shader_material.set_shader_parameter("shift_intensity", intensity_slider.value * 0.5)
			shader_material.set_shader_parameter("shift_color", color_picker.color)
		2:  # Glow
			shader_material.set_shader_parameter("glow_intensity", intensity_slider.value)
			shader_material.set_shader_parameter("glow_color", color_picker.color)
		3:  # Noise
			shader_material.set_shader_parameter("noise_scale", intensity_slider.value * 10.0)
			shader_material.set_shader_parameter("noise_color", color_picker.color)

func _create_background_texture() -> ImageTexture:
	# Create a simple gradient texture for the shader to work with
	var size = 256
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	for x in range(size):
		for y in range(size):
			var u = float(x) / size
			var v = float(y) / size
			var color = Color(u, v, 0.5, 1.0)
			image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture
