@tool
extends EditorExportPlugin

func _get_name():
	return "Scene Manifest Generator"

func _export_begin(features, is_debug, path, flags):
	print("🔍 Export started - generating scene manifest...")
	
	# Ensures fresh manifest for every export
	var generator_script = load("res://addons/dynamic_scene_browser/scene_manifest_runtime.gd")
	var generator = generator_script.new()
	generator.generate_scene_manifest()

func _export_end():
	print("✅ Export completed with scene manifest")
