extends ColorRect

# Adaptive piano key color handler with improved touch/click feedback

@onready var parent = get_parent()

func _gui_input(input_event: InputEvent) -> void:
	# Handle both mouse and touch input
	if input_event is InputEventMouseButton:
		if input_event.pressed:
			parent.activate()
			# Provide haptic feedback on mobile if available
			_provide_haptic_feedback()
	elif input_event is InputEventScreenTouch:
		if input_event.pressed:
			parent.activate()
			_provide_haptic_feedback()

func _provide_haptic_feedback() -> void:
	# Provide haptic feedback on mobile devices
	if OS.has_feature("mobile"):
		# Note: Godot 4.x doesn't have direct haptic feedback API
		# This would be implemented via plugin for actual mobile deployment
		pass
