extends Node2D

@onready var animated_square = $AnimatedSquare
@onready var ui = $UI
@onready var play_button = $UI/ControlPanel/VBoxContainer/PlayButton
@onready var stop_button = $UI/ControlPanel/VBoxContainer/StopButton
@onready var loop_checkbox = $UI/ControlPanel/VBoxContainer/LoopContainer/LoopCheckbox
@onready var speed_slider = $UI/ControlPanel/VBoxContainer/SpeedContainer/SpeedSlider
@onready var speed_label = $UI/ControlPanel/VBoxContainer/SpeedContainer/SpeedLabel
@onready var animation_selector = $UI/ControlPanel/VBoxContainer/AnimationContainer/AnimationSelector
@onready var status_label = $UI/StatusPanel/VBoxContainer/StatusLabel
@onready var frame_label = $UI/StatusPanel/VBoxContainer/FrameLabel
@onready var time_label = $UI/StatusPanel/VBoxContainer/TimeLabel

var tween: Tween
var animation_speed = 1.0
var is_playing = false
var current_animation = "bounce"
var animation_time = 0.0

# Animation definitions
var animations = {
	"bounce": {
		"duration": 2.0,
		"loop": true,
		"keyframes": [
			{"time": 0.0, "position": Vector2(100, 300), "scale": Vector2.ONE, "rotation": 0.0, "color": Color.CYAN},
			{"time": 0.5, "position": Vector2(300, 150), "scale": Vector2(1.2, 0.8), "rotation": 0.0, "color": Color.YELLOW},
			{"time": 1.0, "position": Vector2(500, 300), "scale": Vector2.ONE, "rotation": 0.0, "color": Color.MAGENTA},
			{"time": 1.5, "position": Vector2(300, 450), "scale": Vector2(0.8, 1.2), "rotation": 0.0, "color": Color.GREEN},
			{"time": 2.0, "position": Vector2(100, 300), "scale": Vector2.ONE, "rotation": 0.0, "color": Color.CYAN}
		]
	},
	"spin": {
		"duration": 3.0,
		"loop": true,
		"keyframes": [
			{"time": 0.0, "position": Vector2(400, 300), "scale": Vector2.ONE, "rotation": 0.0, "color": Color.RED},
			{"time": 1.0, "position": Vector2(400, 300), "scale": Vector2(1.5, 1.5), "rotation": PI, "color": Color.BLUE},
			{"time": 2.0, "position": Vector2(400, 300), "scale": Vector2(0.5, 0.5), "rotation": PI * 2, "color": Color.GREEN},
			{"time": 3.0, "position": Vector2(400, 300), "scale": Vector2.ONE, "rotation": PI * 3, "color": Color.RED}
		]
	},
	"figure8": {
		"duration": 4.0,
		"loop": true,
		"keyframes": [
			{"time": 0.0, "position": Vector2(400, 200), "scale": Vector2.ONE, "rotation": 0.0, "color": Color.ORANGE},
			{"time": 1.0, "position": Vector2(300, 250), "scale": Vector2(0.8, 1.2), "rotation": PI/4, "color": Color.PURPLE},
			{"time": 2.0, "position": Vector2(400, 300), "scale": Vector2.ONE, "rotation": PI/2, "color": Color.LIME_GREEN},
			{"time": 3.0, "position": Vector2(500, 250), "scale": Vector2(1.2, 0.8), "rotation": 3*PI/4, "color": Color.PINK},
			{"time": 4.0, "position": Vector2(400, 200), "scale": Vector2.ONE, "rotation": PI, "color": Color.ORANGE}
		]
	}
}

func _ready():
	_setup_ui()
	_setup_animated_object()
	
func _setup_ui():
	# Setup animation selector
	for anim_name in animations.keys():
		animation_selector.add_item(anim_name.capitalize())
	animation_selector.selected = 0
	animation_selector.item_selected.connect(_on_animation_selected)
	
	# Setup controls
	play_button.pressed.connect(_on_play_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	loop_checkbox.toggled.connect(_on_loop_toggled)
	speed_slider.value_changed.connect(_on_speed_changed)
	
	speed_slider.value = animation_speed
	loop_checkbox.button_pressed = true
	_update_speed_label()

func _setup_animated_object():
	# Position the animated square
	animated_square.position = Vector2(400, 300)

func _process(delta):
	if is_playing:
		animation_time += delta * animation_speed
		var anim_data = animations[current_animation]
		
		if loop_checkbox.button_pressed:
			animation_time = fmod(animation_time, anim_data.duration)
		elif animation_time >= anim_data.duration:
			animation_time = anim_data.duration
			_stop_animation()
		
		_apply_animation_frame()
	
	_update_status_ui()

func _apply_animation_frame():
	var anim_data = animations[current_animation]
	var keyframes = anim_data.keyframes
	
	# Find the current frame and next frame
	var current_frame = null
	var next_frame = null
	
	for i in range(keyframes.size()):
		var frame = keyframes[i]
		if frame.time <= animation_time:
			current_frame = frame
			if i < keyframes.size() - 1:
				next_frame = keyframes[i + 1]
			else:
				next_frame = keyframes[0] if loop_checkbox.button_pressed else frame
		else:
			break
	
	if current_frame == null:
		current_frame = keyframes[0]
		next_frame = keyframes[1] if keyframes.size() > 1 else keyframes[0]
	
	# Interpolate between frames
	var t = 0.0
	if next_frame and next_frame != current_frame:
		var frame_duration = next_frame.time - current_frame.time
		if next_frame.time < current_frame.time:  # Loop wrap
			frame_duration = (anim_data.duration - current_frame.time) + next_frame.time
		if frame_duration > 0:
			t = (animation_time - current_frame.time) / frame_duration
			t = clamp(t, 0.0, 1.0)
	
	# Apply interpolated values
	animated_square.position = current_frame.position.lerp(next_frame.position, t)
	animated_square.scale = current_frame.scale.lerp(next_frame.scale, t)
	animated_square.rotation = lerp_angle(current_frame.rotation, next_frame.rotation, t)
	animated_square.modulate = current_frame.color.lerp(next_frame.color, t)

func _on_play_pressed():
	if not is_playing:
		_start_animation()

func _on_stop_pressed():
	_stop_animation()

func _start_animation():
	is_playing = true
	play_button.disabled = true
	stop_button.disabled = false

func _stop_animation():
	is_playing = false
	animation_time = 0.0
	play_button.disabled = false
	stop_button.disabled = true
	
	# Reset to first frame
	var first_frame = animations[current_animation].keyframes[0]
	animated_square.position = first_frame.position
	animated_square.scale = first_frame.scale
	animated_square.rotation = first_frame.rotation
	animated_square.modulate = first_frame.color

func _on_animation_selected(index):
	var anim_names = animations.keys()
	current_animation = anim_names[index]
	_stop_animation()

func _on_loop_toggled(button_pressed):
	# Loop setting is handled automatically in _process
	pass

func _on_speed_changed(value):
	animation_speed = value
	_update_speed_label()

func _update_speed_label():
	speed_label.text = "Speed: %.1fx" % animation_speed

func _update_status_ui():
	var anim_data = animations[current_animation]
	
	status_label.text = "Status: " + ("Playing" if is_playing else "Stopped")
	time_label.text = "Time: %.2f / %.2f s" % [animation_time, anim_data.duration]
	
	# Calculate current frame
	var frame_index = 0
	for i in range(anim_data.keyframes.size()):
		if anim_data.keyframes[i].time <= animation_time:
			frame_index = i
	
	frame_label.text = "Frame: %d / %d" % [frame_index + 1, anim_data.keyframes.size()]
