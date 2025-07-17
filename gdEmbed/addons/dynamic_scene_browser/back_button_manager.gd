extends Node

# Global back button manager for scenes loaded from browser
var back_button_ui: Control
var came_from_browser = false

func _ready():
	# Check if we should show back button
	# This will be set by the scene manager when loading from browser
	if should_show_back_button():
		create_back_button()

func should_show_back_button() -> bool:
	# Show back button if:
	# - User navigated from the scene browser (came_from_browser = true)
	# - NOT when loaded directly via URL parameter (came_from_browser = false)
	# This works for both native and web builds
	return came_from_browser

func set_came_from_browser(value: bool):
	came_from_browser = value
	if value:
		create_back_button()
	else:
		remove_back_button()

func create_back_button():
	if back_button_ui:
		return  # Already exists
	
	print("🔙 Creating global back button")
	
	# Find the main scene's root node
	var main_scene = get_tree().current_scene
	if not main_scene:
		return
	
	# Create overlay container
	back_button_ui = Control.new()
	back_button_ui.name = "BackButtonOverlay"
	back_button_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back_button_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_scene.add_child(back_button_ui)
	
	# Create back button
	var back_button = Button.new()
	back_button.text = "← Back to Browser"
	back_button.size = Vector2(160, 40)
	back_button.position = Vector2(20, 20)
	
	# Style the button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.3, 0.5, 0.9)
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.4, 0.5, 0.7)
	button_style.corner_radius_top_left = 8
	button_style.corner_radius_top_right = 8
	button_style.corner_radius_bottom_left = 8
	button_style.corner_radius_bottom_right = 8
	back_button.add_theme_stylebox_override("normal", button_style)
	
	# Hover style
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.4, 0.6, 0.95)
	back_button.add_theme_stylebox_override("hover", hover_style)
	
	# Text styling
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.add_theme_font_size_override("font_size", 14)
	
	# Make button clickable
	back_button.mouse_filter = Control.MOUSE_FILTER_STOP
	back_button.pressed.connect(_on_back_button_pressed)
	
	back_button_ui.add_child(back_button)
	
	print("✅ Global back button created")

func _on_back_button_pressed():
	print("🔙 Back button pressed, returning to scene browser")
	came_from_browser = false
	remove_back_button()
	get_tree().change_scene_to_file("res://main.tscn")

func remove_back_button():
	if back_button_ui:
		back_button_ui.queue_free()
		back_button_ui = null
		print("🔙 Back button removed")

# Called when scene changes
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		remove_back_button()
