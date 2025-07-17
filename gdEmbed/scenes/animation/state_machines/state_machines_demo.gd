extends Node2D

@onready var ui = $UI
@onready var state_info = $UI/StatePanel/VBoxContainer/StateInfo
@onready var previous_state_info = $UI/StatePanel/VBoxContainer/PreviousStateInfo
@onready var transition_info = $UI/StatePanel/VBoxContainer/TransitionInfo
@onready var timer_info = $UI/StatePanel/VBoxContainer/TimerInfo
@onready var cooldown_info = $UI/StatePanel/VBoxContainer/CooldownInfo
@onready var defense_info = $UI/StatePanel/VBoxContainer/DefenseInfo
@onready var stun_info = $UI/StatePanel/VBoxContainer/StunInfo
@onready var controls_info = $UI/StatusPanel/VBoxContainer/ControlsInfo
@onready var player = $Player

# State machine implementation
enum State {
	IDLE,
	MOVING,
	JUMPING,
	ATTACKING,
	DEFENDING,
	STUNNED
}

var current_state = State.IDLE
var previous_state = State.IDLE
var state_timer = 0.0
var state_duration = 0.0

# State-specific variables
var velocity = Vector2.ZERO
var is_grounded = true
var attack_cooldown = 0.0
var stun_duration = 0.0
var defense_charge = 0.0

# State names for display
var state_names = {
	State.IDLE: "Idle",
	State.MOVING: "Moving", 
	State.JUMPING: "Jumping",
	State.ATTACKING: "Attacking",
	State.DEFENDING: "Defending",
	State.STUNNED: "Stunned"
}

# State colors for visual feedback
var state_colors = {
	State.IDLE: Color.WHITE,
	State.MOVING: Color.CYAN,
	State.JUMPING: Color.YELLOW,
	State.ATTACKING: Color.RED,
	State.DEFENDING: Color.BLUE,
	State.STUNNED: Color.PURPLE
}

func _ready():
	_setup_ui()
	_setup_player()
	_change_state(State.IDLE)

func _setup_ui():
	controls_info.text = "Arrow Keys: Move | SPACE: Jump | 1: Attack | 2: Defend"

func _setup_player():
	player.add_to_group("player")
	player.position = Vector2(400, 300)

func _process(delta):
	state_timer += delta
	_update_state_machine(delta)
	_update_ui()

func _update_state_machine(delta):
	# Process current state
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.MOVING:
			_state_moving(delta)
		State.JUMPING:
			_state_jumping(delta)
		State.ATTACKING:
			_state_attacking(delta)
		State.DEFENDING:
			_state_defending(delta)
		State.STUNNED:
			_state_stunned(delta)
	
	# Update cooldowns
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if stun_duration > 0:
		stun_duration -= delta

func _state_idle(delta):
	# Visual: Gentle breathing animation
	var breath_scale = 1.0 + sin(state_timer * 3.0) * 0.05
	player.scale = Vector2(breath_scale, breath_scale)
	player.modulate = state_colors[State.IDLE]
	
	# Transition conditions
	if _get_movement_input() != Vector2.ZERO:
		_change_state(State.MOVING)
	elif Input.is_action_just_pressed("ui_accept"):  # Space
		_change_state(State.JUMPING)
	elif Input.is_action_just_pressed("ui_1") and attack_cooldown <= 0:  # 1 key
		_change_state(State.ATTACKING)
	elif Input.is_action_pressed("ui_2"):  # 2 key
		_change_state(State.DEFENDING)

func _state_moving(delta):
	var movement = _get_movement_input()
	
	if movement != Vector2.ZERO:
		# Move player
		velocity = movement * 200
		player.position += velocity * delta
		
		# Visual: Fast walking animation
		var walk_scale = 1.0 + sin(state_timer * 8.0) * 0.1
		player.scale = Vector2(walk_scale, walk_scale)
		player.rotation = lerp_angle(player.rotation, movement.angle() + PI/2, delta * 5.0)
	
	player.modulate = state_colors[State.MOVING]
	
	# Transition conditions
	if movement == Vector2.ZERO:
		_change_state(State.IDLE)
	elif Input.is_action_just_pressed("ui_accept"):
		_change_state(State.JUMPING)
	elif Input.is_action_just_pressed("ui_1") and attack_cooldown <= 0:
		_change_state(State.ATTACKING)
	elif Input.is_action_pressed("ui_2"):
		_change_state(State.DEFENDING)

func _state_jumping(delta):
	# Visual: Jump animation with arc
	var jump_progress = state_timer / 0.8  # 0.8 second jump
	var jump_height = sin(jump_progress * PI) * 50
	
	player.position.y = 300 - jump_height  # Assuming 300 is ground level
	player.scale = Vector2(1.2 - jump_progress * 0.2, 1.2 - jump_progress * 0.2)
	player.modulate = state_colors[State.JUMPING]
	
	# Continue moving during jump
	var movement = _get_movement_input()
	if movement != Vector2.ZERO:
		player.position.x += movement.x * 150 * delta
	
	# Transition: Land after jump duration
	if state_timer >= 0.8:
		_change_state(State.IDLE)

func _state_attacking(delta):
	# Visual: Attack animation with scale and rotation
	var attack_progress = state_timer / 0.4  # 0.4 second attack
	
	if attack_progress < 0.5:
		# Wind up
		var scale_factor = 1.0 + attack_progress * 0.8
		player.scale = Vector2(scale_factor, scale_factor)
		player.rotation += delta * 10.0
	else:
		# Strike
		var scale_factor = 1.4 - (attack_progress - 0.5) * 0.8
		player.scale = Vector2(scale_factor, scale_factor)
		player.rotation -= delta * 15.0
	
	player.modulate = state_colors[State.ATTACKING]
	
	# Transition: Finish attack
	if state_timer >= 0.4:
		attack_cooldown = 1.0  # 1 second cooldown
		_change_state(State.IDLE)

func _state_defending(delta):
	defense_charge += delta
	
	# Visual: Defensive posture with shield effect
	player.scale = Vector2(0.8, 1.2)  # Crouch
	var shield_intensity = min(defense_charge / 2.0, 1.0)
	player.modulate = state_colors[State.DEFENDING].lerp(Color.WHITE, shield_intensity)
	
	# Defensive rotation
	player.rotation = sin(state_timer * 8.0) * 0.1
	
	# Transition conditions
	if not Input.is_action_pressed("ui_2"):
		defense_charge = 0.0
		_change_state(State.IDLE)
	elif defense_charge >= 3.0:  # Overcharged defense leads to stun
		stun_duration = 1.5
		_change_state(State.STUNNED)

func _state_stunned(delta):
	# Visual: Shaking and disorientation
	player.position.x += sin(state_timer * 20.0) * 3.0
	player.rotation = sin(state_timer * 15.0) * 0.3
	player.scale = Vector2(0.9, 1.1)
	player.modulate = state_colors[State.STUNNED]
	
	# Transition: Recover from stun
	if stun_duration <= 0:
		_change_state(State.IDLE)

func _get_movement_input() -> Vector2:
	var input = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input.x += 1
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_down"):
		input.y += 1
	if Input.is_action_pressed("ui_up"):
		input.y -= 1
	
	return input.normalized()

func _change_state(new_state: State):
	# Exit previous state
	_exit_state(current_state)
	
	# Record transition
	previous_state = current_state
	current_state = new_state
	state_timer = 0.0
	
	# Enter new state
	_enter_state(new_state)

func _enter_state(state: State):
	match state:
		State.IDLE:
			player.rotation = 0.0
			state_duration = -1  # Indefinite
		State.MOVING:
			state_duration = -1  # Indefinite
		State.JUMPING:
			state_duration = 0.8
		State.ATTACKING:
			state_duration = 0.4
		State.DEFENDING:
			state_duration = -1  # Until released
		State.STUNNED:
			state_duration = stun_duration

func _exit_state(state: State):
	match state:
		State.DEFENDING:
			defense_charge = 0.0
		State.JUMPING:
			player.position.y = 300  # Reset to ground
		_:
			pass

func _update_ui():
	# Update state display
	state_info.text = "State: " + state_names[current_state]
	state_info.modulate = state_colors[current_state]
	
	# Update previous state info
	if previous_state != current_state:
		previous_state_info.text = "Previous: " + state_names[previous_state]
	else:
		previous_state_info.text = "Previous: None"
	
	# Update transition info
	if previous_state != current_state:
		transition_info.text = "Transition: " + state_names[previous_state] + " → " + state_names[current_state]
	else:
		transition_info.text = "Transition: None"
	
	# Update timer info
	if state_duration > 0:
		var remaining = state_duration - state_timer
		timer_info.text = "Time: %.1fs remaining" % max(0, remaining)
	else:
		timer_info.text = "Time: %.1fs elapsed" % state_timer
	
	# Update cooldown info
	if attack_cooldown > 0:
		cooldown_info.text = "Attack Cooldown: %.1fs" % attack_cooldown
	else:
		cooldown_info.text = "Attack Cooldown: Ready"
	
	# Update defense info
	if current_state == State.DEFENDING:
		defense_info.text = "Defense Charge: %.1f/3.0" % defense_charge
	else:
		defense_info.text = "Defense Charge: 0.0"
	
	# Update stun info
	if stun_duration > 0:
		stun_info.text = "Stun Duration: %.1fs" % stun_duration
	else:
		stun_info.text = "Stun Duration: None"
	
	# Keep player in bounds
	player.position.x = clamp(player.position.x, 50, 750)
	player.position.y = clamp(player.position.y, 50, 550)

# Draw state machine visualization
func _draw():
	# Draw state transition diagram in corner
	var diagram_pos = Vector2(50, 50)
	var state_radius = 25
	var connection_color = Color(1, 1, 1, 0.3)
	
	# Draw states in a circle
	var states = [State.IDLE, State.MOVING, State.JUMPING, State.ATTACKING, State.DEFENDING, State.STUNNED]
	for i in range(states.size()):
		var angle = (i / float(states.size())) * TAU
		var state_pos = diagram_pos + Vector2(cos(angle), sin(angle)) * 80
		
		var color = state_colors[states[i]]
		if states[i] == current_state:
			color = color.lightened(0.3)
			draw_circle(state_pos, state_radius + 5, color)
		
		draw_circle(state_pos, state_radius, color)
		
		# Draw state name
		var font = ThemeDB.fallback_font
		var text = state_names[states[i]]
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
		draw_string(font, state_pos - text_size / 2, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.BLACK)
	
	# Draw status bars
	var bar_y = 520
	
	# Attack cooldown bar
	if attack_cooldown > 0:
		var cooldown_rect = Rect2(50, bar_y, (attack_cooldown / 1.0) * 200, 10)
		draw_rect(cooldown_rect, Color.RED)
		draw_string(ThemeDB.fallback_font, Vector2(50, bar_y - 5), "Attack Cooldown", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	# Defense charge bar
	if current_state == State.DEFENDING:
		var charge_rect = Rect2(300, bar_y, (defense_charge / 3.0) * 200, 10)
		var charge_color = Color.BLUE.lerp(Color.YELLOW, defense_charge / 3.0)
		draw_rect(charge_rect, charge_color)
		draw_string(ThemeDB.fallback_font, Vector2(300, bar_y - 5), "Defense Charge", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	# Stun duration bar
	if stun_duration > 0:
		var stun_rect = Rect2(550, bar_y, (stun_duration / 1.5) * 200, 10)
		draw_rect(stun_rect, Color.PURPLE)
		draw_string(ThemeDB.fallback_font, Vector2(550, bar_y - 5), "Stun Duration", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	# Always redraw for smooth animations
	queue_redraw()
