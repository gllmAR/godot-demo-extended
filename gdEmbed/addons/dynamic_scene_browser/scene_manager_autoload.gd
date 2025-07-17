extends Node

# Lean hierarchical scene discovery - uses generated manifest for true dynamic discovery
var discovered_scenes: Dictionary = {}
var scene_tree: Dictionary = {}

# Performance tracking variables
var _discovery_cache: Dictionary = {}
var _start_time: float = 0.0

const MANIFEST_PATH = "res://scene_manifest.json"

func _ready():
	_start_time = Time.get_time_dict_from_system().values().reduce(func(a, b): return a + b)
	discover_all_scenes()
	print("🔍 SceneManager discovered %d scenes total" % discovered_scenes.size())

# Multi-strategy discovery system
func discover_all_scenes():
	if _load_scene_manifest():        # Strategy 1: Manifest-based (web optimized)
		print("✅ Loaded scenes from manifest")
	else:
		_fallback_discovery()         # Strategy 2: Runtime scanning (desktop)
	
	_build_scene_tree()               # Strategy 3: Hierarchical organization

func _load_scene_manifest() -> bool:
	"""Load scenes from the generated manifest file"""
	if not ResourceLoader.exists(MANIFEST_PATH):
		return false
	
	var file = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("❌ Failed to parse scene manifest JSON")
		return false
	
	var manifest = json.data
	if not manifest.has("scenes"):
		print("❌ Invalid manifest format")
		return false
	
	discovered_scenes = manifest.scenes
	print("✅ Loaded " + str(discovered_scenes.size()) + " scenes from manifest")
	print("📅 Manifest generated at: " + str(manifest.get("generated_at", "unknown")))
	
	return true

func _fallback_discovery():
	"""Fallback to runtime discovery if manifest is not available"""
	var scenes_path = "res://scenes/"
	
	if OS.has_feature("web"):
		print("🔍 Web fallback: Limited discovery mode")
		# Even in fallback, try to be smarter than before
		_discover_scenes_web_smart_fallback()
	else:
		print("🔍 Desktop fallback: Directory scanning")
		_discover_scenes_recursive(scenes_path, "")

func _discover_scenes_web_smart_fallback():
	"""Minimal web fallback - web builds should use manifest"""
	print("🔍 Web fallback: Manifest should be available in web builds")
	print("❌ No scenes discovered - manifest generation may have failed")
	print("💡 Ensure 'make generate-manifest' runs before 'make web'")
	
	# Don't try to guess - the web platform can't do filesystem discovery
	# The manifest should always be available in proper web builds

func _discover_scenes_recursive(path: String, relative_path: String = ""):
	# Desktop/editor version - use directory scanning
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
				# Recurse into subdirectory
				_discover_scenes_recursive(full_path + "/", new_relative)
			elif file_name.ends_with(".tscn"):
				# Found a scene file
				var scene_path = full_path
				if ResourceLoader.exists(scene_path):
					# Create scene key without .tscn extension
					var scene_key = new_relative.trim_prefix("/").replace(".tscn", "").replace("/", "_")
					var scene_name = file_name.get_basename()
					
					discovered_scenes[scene_key] = {
						"path": scene_path,
						"relative_path": new_relative.trim_prefix("/"),
						"name": scene_name,
						"title": _generate_title(scene_name),
						"directory": new_relative.get_base_dir().trim_prefix("/")
					}
					
					print("✅ Found scene: " + scene_path + " (key: " + scene_key + ")")
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Add caching mechanism
	var cache_key = path.hash()
	if not _discovery_cache.has(cache_key):
		_discovery_cache[cache_key] = discovered_scenes.duplicate()
	
	# Add performance metrics
	var current_time = Time.get_time_dict_from_system().values().reduce(func(a, b): return a + b)
	var discovery_time = current_time - _start_time
	print("🔍 Scene discovery completed in " + str(discovery_time) + " seconds")

# Scene tree building with path analysis
func _build_scene_tree():
	for scene_key in discovered_scenes.keys():
		var scene_info = discovered_scenes[scene_key]
		var path_parts = scene_info.relative_path.split("/")
		
		# Handle different nesting levels:
		# - Root level: direct scenes
		# - Category level: scenes/category/scene.tscn  
		# - Nested level: scenes/category/subfolder/scene.tscn
		
		# Creates navigable folder structure for UI
		# Remove .tscn extension from the last part (the filename)
		if path_parts.size() > 0:
			path_parts[path_parts.size() - 1] = path_parts[path_parts.size() - 1].replace(".tscn", "")
		
		# Handle different path structures
		if path_parts.size() == 1:
			# Root level scene (shouldn't happen with current structure, but handle it)
			if not scene_tree.has("_root_scenes"):
				scene_tree["_root_scenes"] = []
			scene_tree["_root_scenes"].append(scene_key)
			print("✅ Added root scene: " + scene_key)
			
		elif path_parts.size() == 2:
			# Scene directly in category folder (e.g., input/input_player.tscn)
			var category = path_parts[0]
			
			if not scene_tree.has(category):
				scene_tree[category] = {
					"type": "folder",
					"title": _generate_title(category),
					"path": category,
					"children": {},
					"scenes": []
				}
				print("🔍 Created category folder: " + category)
			
			scene_tree[category]["scenes"].append(scene_key)
			print("✅ Added scene to category: " + scene_key + " -> " + category)
			
		elif path_parts.size() >= 3:
			# Scene in nested structure (e.g., input/mouse_input/mouse_input.tscn)
			var current_level = scene_tree
			
			# Create all folder levels
			for i in range(path_parts.size() - 1):  # Exclude the scene file itself
				var part = path_parts[i]
				
				if not current_level.has(part):
					current_level[part] = {
						"type": "folder",
						"title": _generate_title(part),
						"path": part,
						"children": {},
						"scenes": []
					}
					print("🔍 Created folder: " + part)
				
				# For the last folder level, add the scene
				if i == path_parts.size() - 2:
					current_level[part]["scenes"].append(scene_key)
					print("✅ Added scene to nested folder: " + scene_key + " -> " + part)
					break
				else:
					# Move to children for next level
					current_level = current_level[part]["children"]
	
	# Debug: Print the tree structure
	print("🔍 Scene tree structure:")
	_debug_print_tree(scene_tree, 0)
	print("🔍 Tree building complete!")

func _debug_print_tree(tree_data: Dictionary, indent_level: int):
	var indent = ""
	for i in range(indent_level):
		indent += "  "
	
	var sorted_keys = tree_data.keys()
	sorted_keys.sort()
	
	for key in sorted_keys:
		if key == "_root_scenes":
			print(indent + "📁 ROOT SCENES: " + str(tree_data[key]))
		elif tree_data[key].has("type") and tree_data[key].type == "folder":
			var folder = tree_data[key]
			print(indent + "📁 " + folder.title + " (scenes: " + str(folder.scenes.size()) + " - " + str(folder.scenes) + ")")
			if folder.children.size() > 0:
				_debug_print_tree(folder.children, indent_level + 1)
		else:
			print(indent + "❓ Unknown item: " + key + " -> " + str(tree_data[key]))

func _generate_title(name: String) -> String:
	var words = name.split("_")
	var title_words = []
	
	for word in words:
		if word.length() > 0:
			title_words.append(word[0].to_upper() + word.substr(1).to_lower())
	
	return " ".join(title_words)

func get_scene_by_path(path: String) -> Dictionary:
	"""Get scene info by relative path (e.g., 'animation/basic_animation')"""
	print("Looking for scene with path: " + path)
	
	# Try direct scene key lookup first
	var scene_key = path.replace("/", "_")
	if discovered_scenes.has(scene_key):
		print("Found scene by direct key: " + scene_key)
		return discovered_scenes[scene_key]
	
	# Try all discovered scenes and match by constructed path
	for key in discovered_scenes.keys():
		var scene_info = discovered_scenes[key]
		
		# Construct the expected path from directory and name
		var constructed_path = ""
		if scene_info.directory != "":
			constructed_path = scene_info.directory + "/" + scene_info.name
		else:
			constructed_path = scene_info.name
		
		if constructed_path == path:
			print("Found scene by constructed path: " + key + " (" + constructed_path + ")")
			return scene_info
		
		# Also try without directory (just scene name)
		if scene_info.name == path:
			print("Found scene by name: " + key + " (" + scene_info.name + ")")
			return scene_info
	
	print("Scene not found for path: " + path)
	print("Available paths:")
	for key in discovered_scenes.keys():
		var info = discovered_scenes[key]
		var info_path = info.directory + "/" + info.name if info.directory != "" else info.name
		print("  - " + key + ": " + info_path)
	
	return {}

func get_all_scenes() -> Dictionary:
	return discovered_scenes

func get_scene_tree() -> Dictionary:
	return scene_tree

func is_valid_scene_path(path: String) -> bool:
	var scene_key = path.replace("/", "_")
	return discovered_scenes.has(scene_key)