@tool
extends EditorExportPlugin

func _get_name():
	return "Scene Manifest Generator"

func _export_begin(features, is_debug, path, flags):
	print("🔍 Export started - generating scene manifest...")
	
	# Generate the manifest before export using runtime version
	var generator_script = load("res://scene_manifest_runtime.gd")
	var generator = generator_script.new()
	
	# Call the generation method directly
	generator.generate_scene_manifest()

func _export_end():
	print("✅ Export completed with scene manifest")
