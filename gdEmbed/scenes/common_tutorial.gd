extends Node2D
class_name CommonTutorial

# Common Tutorial Base Class
# Unified base class for all interactive demos with consistent UI and navigation

# Node references
var ui_container: VBoxContainer
var demo_area: Node2D
var info_panel: VBoxContainer
var navigation_panel: HBoxContainer

# Demo metadata
var demo_title: String = "Demo"
var demo_description: String = "Interactive demonstration"
var demo_category: String = "general"

# Challenge system
var challenges: Array = []
var current_challenge_index: int = 0
var completed_challenges: Array = []

# UI Theme
var theme_primary_color: Color = Color(0.2, 0.4, 0.8)
var theme_secondary_color: Color = Color(0.3, 0.3, 0.3)
var theme_success_color: Color = Color(0.2, 0.8, 0.2)
var theme_warning_color: Color = Color(0.8, 0.6, 0.2)

func _ready():
	print("🎮 Initializing CommonTutorial: " + get_demo_title())
	
	# Setup common structure
	_create_base_structure()
	_setup_info_panel()
	_setup_navigation()
	
	# Call demo-specific setup
	setup_demo_specific()
	
	print("✅ " + get_demo_title() + " Ready!")

func _create_base_structure():
	# Create main UI container on the left side
	ui_container = VBoxContainer.new()
	ui_container.name = "UIContainer"
	ui_container.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	ui_container.custom_minimum_size = Vector2(300, 0)
	ui_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(ui_container)
	
	# Create demo area for interactive content
	demo_area = Node2D.new()
	demo_area.name = "DemoArea"
	demo_area.position = Vector2(350, 0)  # Offset from UI panel
	add_child(demo_area)

func _setup_info_panel():
	# Create info panel
	info_panel = VBoxContainer.new()
	info_panel.name = "InfoPanel"
	ui_container.add_child(info_panel)
	
	# Title
	var title_label = Label.new()
	title_label.text = get_demo_title()
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = theme_primary_color
	info_panel.add_child(title_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = get_demo_description()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(280, 0)
	info_panel.add_child(desc_label)
	
	# Separator
	var separator = HSeparator.new()
	info_panel.add_child(separator)

func _setup_navigation():
	# Create navigation panel
	navigation_panel = HBoxContainer.new()
	navigation_panel.name = "NavigationPanel"
	ui_container.add_child(navigation_panel)
	
	# Back to categories button
	var back_button = create_button("← Categories", _on_back_to_categories)
	back_button.modulate = theme_secondary_color
	navigation_panel.add_child(back_button)
	
	# Reset demo button
	var reset_button = create_button("🔄 Reset", _on_reset_demo)
	reset_button.modulate = theme_warning_color
	navigation_panel.add_child(reset_button)

# Virtual methods to be overridden by specific demos
func get_demo_title() -> String:
	return demo_title

func get_demo_description() -> String:
	return demo_description

func get_demo_category() -> String:
	return demo_category

func setup_demo_specific():
	# Override this in specific demo classes
	pass

func reset_demo():
	# Override this in specific demo classes
	pass

# Utility functions for creating UI elements
func create_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	button.custom_minimum_size = Vector2(80, 30)
	return button

func create_labeled_slider(label_text: String, min_val: float, max_val: float, initial_val: float, callback: Callable) -> VBoxContainer:
	var container = VBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text + ": " + str(initial_val)
	container.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = initial_val
	slider.step = 0.1
	slider.custom_minimum_size = Vector2(200, 20)
	
	slider.value_changed.connect(func(value):
		label.text = label_text + ": " + str(value)
		callback.call(value)
	)
	
	container.add_child(slider)
	return container

func create_progress_bar(max_value: int = 100) -> ProgressBar:
	var progress = ProgressBar.new()
	progress.max_value = max_value
	progress.value = 0
	progress.custom_minimum_size = Vector2(200, 20)
	return progress

func create_info_label(text: String, color: Color = Color.WHITE) -> Label:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(280, 0)
	return label

# Challenge system methods
func add_challenge(title: String, description: String, check_function: Callable):
	var challenge = {
		"title": title,
		"description": description,
		"check_function": check_function,
		"completed": false
	}
	challenges.append(challenge)

func check_current_challenge():
	if current_challenge_index < challenges.size():
		var challenge = challenges[current_challenge_index]
		if not challenge.completed and challenge.check_function.call():
			_complete_challenge(current_challenge_index)

func _complete_challenge(index: int):
	if index < challenges.size():
		challenges[index].completed = true
		completed_challenges.append(index)
		_show_challenge_completion(challenges[index].title)
		
		# Move to next challenge
		current_challenge_index += 1
		if current_challenge_index >= challenges.size():
			_show_all_challenges_complete()

func _show_challenge_completion(challenge_title: String):
	print("🎉 Challenge Complete: " + challenge_title)
	# Could add visual feedback here

func _show_all_challenges_complete():
	print("🏆 All challenges complete! Well done!")
	# Could add visual feedback here

# Navigation callbacks
func _on_back_to_categories():
	print("📂 Navigating back to categories...")
	# Try to find scene manager
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.has_method("show_file_navigator"):
		scene_manager.show_file_navigator()
	else:
		# Fallback - try to load main scene
		get_tree().change_scene_to_file("res://main.tscn")

func _on_reset_demo():
	print("🔄 Resetting demo...")
	reset_demo()
	
	# Reset challenges
	current_challenge_index = 0
	completed_challenges.clear()
	for challenge in challenges:
		challenge.completed = false

# Input handling
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_on_back_to_categories()
			KEY_R:
				_on_reset_demo()

# Cleanup
func _exit_tree():
	print("🧹 Cleaning up " + get_demo_title())
