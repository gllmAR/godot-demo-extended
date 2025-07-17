@tool
extends RefCounted

# Simple manifest generator that just runs and exits
const MANIFEST_PATH = "res://scene_manifest.json"

static func run():
	print("🔍 Starting simple manifest generation...")
	
	var generator = new()
	generator.generate_scene_manifest()
	
	# Force exit
	OS.kill(OS.get_process_id())

func generate_scene_manifest():
	print("🔍 Generating scene manifest...")
	
	var manifest = {
		"generated_at": Time.get_datetime_string_from_system(),
		"scenes": {},
		"structure": {}
	}
	
	var scenes_path = "res://scenes/"
	_scan_directory_recursive(scenes_path, "", manifest.scenes, manifest.structure)
	
	# Save manifest
	var file = FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(manifest, "\t")
		file.store_string(json_string)
		file.close()
		print("✅ Scene manifest generated: " + MANIFEST_PATH)
		print("📊 Found " + str(manifest.scenes.size()) + " scenes")
	else:
		print("❌ Failed to write manifest file")

func _scan_directory_recursive(path: String, relative_path: String, scenes: Dictionary, structure: Dictionary):
	var dir = DirAccess.open(path)
	if not dir:
		print("❌ Could not open directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not file_name.begins_with("."):
			var full_path = path + file_name
			var new_relative = relative_path + "/" + file_name if relative_path != "" else file_name
			
			if dir.current_is_dir():
				# Create folder entry
				var folder_key = new_relative.trim_prefix("/")
				if not structure.has(folder_key):
					structure[folder_key] = {
						"type": "folder",
						"path": folder_key,
						"children": [],
						"scenes": []
					}
				
				# Recurse
				_scan_directory_recursive(full_path + "/", new_relative, scenes, structure)
				
			elif file_name.ends_with(".tscn"):
				# Found scene
				if ResourceLoader.exists(full_path):
					var scene_relative_path = new_relative.trim_prefix("/")
					var scene_key = scene_relative_path.replace(".tscn", "").replace("/", "_")
					var scene_name = file_name.get_basename()
					var directory = scene_relative_path.get_base_dir()
					
					scenes[scene_key] = {
						"path": full_path,
						"relative_path": scene_relative_path,
						"name": scene_name,
						"title": _generate_title(scene_name),
						"directory": directory,
						"category": directory.get_slice("/", 0) if directory != "" else "",
						"subfolder": directory.get_slice("/", 1) if directory.get_slice_count("/") > 1 else ""
					}
					
					# Add to structure
					if directory != "":
						if not structure.has(directory):
							structure[directory] = {
								"type": "folder",
								"path": directory,
								"children": [],
								"scenes": []
							}
						structure[directory]["scenes"].append(scene_key)
					
					print("✅ Found scene: " + scene_relative_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _generate_title(name: String) -> String:
	var words = name.split("_")
	var title_words = []
	
	for word in words:
		if word.length() > 0:
			title_words.append(word[0].to_upper() + word.substr(1).to_lower())
	
	return " ".join(title_words)
