# Dynamic Scene Browser - Examples

This document provides practical examples of using the Dynamic Scene Browser addon in various scenarios.

## Table of Contents

1. [Basic Scene Discovery](#basic-scene-discovery)
2. [Custom Scene Loading](#custom-scene-loading)
3. [Web Integration](#web-integration)
4. [Custom UI Integration](#custom-ui-integration)
5. [CI/CD Examples](#cicd-examples)
6. [Advanced Patterns](#advanced-patterns)

## Basic Scene Discovery

### Listing All Scenes

```gdscript
# Get all discovered scenes
var all_scenes = SceneManagerGlobal.get_all_scenes()

print("Found", all_scenes.size(), "scenes:")
for scene_key in all_scenes.keys():
    var scene_info = all_scenes[scene_key]
    print("- ", scene_info.title, " (", scene_info.relative_path, ")")
```

**Output:**
```
Found 17 scenes:
- Mouse Input (input/mouse_input/mouse_input.tscn)
- Basic Animation (animation/basic_animation/basic_animation.tscn)
- Tweening (animation/tweening/tweening.tscn)
...
```

### Scene Tree Navigation

```gdscript
# Get hierarchical structure
var scene_tree = SceneManagerGlobal.get_scene_tree()

# Navigate the tree
if scene_tree.has("animation"):
    var animation_folder = scene_tree["animation"]
    print("Animation folder has", animation_folder.scenes.size(), "direct scenes")
    
    # Check for subfolders
    if animation_folder.children.has("basic_animation"):
        var subfolder = animation_folder.children["basic_animation"]
        print("Basic animation subfolder has", subfolder.scenes.size(), "scenes")
```

## Custom Scene Loading

### Simple Scene Loader

```gdscript
extends Node

func load_scene_by_name(scene_name: String):
    """Load a scene by its display name"""
    var all_scenes = SceneManagerGlobal.get_all_scenes()
    
    for scene_key in all_scenes.keys():
        var scene_info = all_scenes[scene_key]
        if scene_info.name == scene_name or scene_info.title == scene_name:
            print("Loading scene:", scene_info.title)
            get_tree().change_scene_to_file(scene_info.path)
            return true
    
    print("Scene not found:", scene_name)
    return false

# Usage
func _ready():
    load_scene_by_name("basic_animation")  # Loads animation/basic_animation scene
```

### Category-Based Loader

```gdscript
extends Node

func get_scenes_in_category(category: String) -> Array:
    """Get all scenes in a specific category"""
    var category_scenes = []
    var all_scenes = SceneManagerGlobal.get_all_scenes()
    
    for scene_key in all_scenes.keys():
        var scene_info = all_scenes[scene_key]
        if scene_info.category == category:
            category_scenes.append(scene_info)
    
    return category_scenes

func load_random_scene_from_category(category: String):
    """Load a random scene from a category"""
    var scenes = get_scenes_in_category(category)
    if scenes.size() > 0:
        var random_scene = scenes[randi() % scenes.size()]
        get_tree().change_scene_to_file(random_scene.path)

# Usage
func _ready():
    load_random_scene_from_category("animation")  # Random animation scene
```

## Web Integration

### Custom Web Scene Manager

```gdscript
extends Node2D

func _ready():
    if OS.has_feature("web"):
        handle_web_navigation()
    else:
        show_desktop_browser()

func handle_web_navigation():
    """Handle web-specific scene loading"""
    var scene_param = get_url_parameter("scene")
    var demo_mode = get_url_parameter("demo") == "true"
    
    if scene_param:
        load_scene_with_fallback(scene_param, demo_mode)
    else:
        show_scene_selection()

func get_url_parameter(param_name: String) -> String:
    """Extract URL parameter using JavaScript"""
    var js_code = """
    (function() {
        var urlParams = new URLSearchParams(window.location.search);
        return urlParams.get('%s') || '';
    })();
    """ % param_name
    
    return JavaScriptBridge.eval(js_code)

func load_scene_with_fallback(scene_path: String, demo_mode: bool):
    """Load scene with multiple fallback strategies"""
    var scene_info = SceneManagerGlobal.get_scene_by_path(scene_path)
    
    if scene_info.size() > 0:
        if demo_mode:
            setup_demo_mode(scene_info)
        get_tree().change_scene_to_file(scene_info.path)
    else:
        # Fallback: try partial matches
        var partial_match = find_partial_match(scene_path)
        if partial_match.size() > 0:
            get_tree().change_scene_to_file(partial_match.path)
        else:
            show_error_page(scene_path)

func find_partial_match(search_path: String) -> Dictionary:
    """Find scenes that partially match the search path"""
    var all_scenes = SceneManagerGlobal.get_all_scenes()
    var path_parts = search_path.split("/")
    
    for scene_key in all_scenes.keys():
        var scene_info = all_scenes[scene_key]
        var matches = 0
        
        for part in path_parts:
            if scene_key.contains(part) or scene_info.relative_path.contains(part):
                matches += 1
        
        if matches >= path_parts.size() - 1:  # Allow one mismatch
            return scene_info
    
    return {}
```

### URL-Based Scene Router

```gdscript
extends Node

# Scene routing table
var route_mappings = {
    "home": "menu/main_menu",
    "play": "gameplay/level_01", 
    "demo": "animation/basic_animation",
    "settings": "ui/settings_menu"
}

func _ready():
    if OS.has_feature("web"):
        setup_web_routing()

func setup_web_routing():
    """Setup automatic routing based on URL hash"""
    # Listen for hash changes
    var js_listener = """
    window.addEventListener('hashchange', function() {
        var hash = window.location.hash.substring(1);
        godot_route_changed(hash);
    });
    
    // Initial route
    var initial_hash = window.location.hash.substring(1) || 'home';
    godot_route_changed(initial_hash);
    """
    
    JavaScriptBridge.eval(js_listener)

# This will be called from JavaScript
func godot_route_changed(route: String):
    """Handle route changes from web navigation"""
    print("Route changed to:", route)
    
    if route_mappings.has(route):
        var scene_path = route_mappings[route]
        var scene_info = SceneManagerGlobal.get_scene_by_path(scene_path)
        
        if scene_info.size() > 0:
            get_tree().change_scene_to_file(scene_info.path)
    else:
        # Try direct scene loading
        var scene_info = SceneManagerGlobal.get_scene_by_path(route)
        if scene_info.size() > 0:
            get_tree().change_scene_to_file(scene_info.path)
```

## Custom UI Integration

### Minimal Scene Selector

```gdscript
extends Control

var scene_list: ItemList

func _ready():
    setup_simple_ui()
    populate_scene_list()

func setup_simple_ui():
    """Create a simple list-based scene selector"""
    var vbox = VBoxContainer.new()
    add_child(vbox)
    
    var title = Label.new()
    title.text = "Select Scene"
    title.add_theme_font_size_override("font_size", 24)
    vbox.add_child(title)
    
    scene_list = ItemList.new()
    scene_list.custom_minimum_size = Vector2(400, 300)
    scene_list.item_selected.connect(_on_scene_selected)
    vbox.add_child(scene_list)

func populate_scene_list():
    """Populate the list with discovered scenes"""
    var all_scenes = SceneManagerGlobal.get_all_scenes()
    var sorted_scenes = []
    
    # Sort scenes by category and title
    for scene_key in all_scenes.keys():
        var scene_info = all_scenes[scene_key]
        sorted_scenes.append(scene_info)
    
    sorted_scenes.sort_custom(func(a, b): return a.category + "/" + a.title < b.category + "/" + b.title)
    
    # Add to list
    for scene_info in sorted_scenes:
        var display_text = scene_info.category.capitalize() + " > " + scene_info.title
        scene_list.add_item(display_text)
        scene_list.set_item_metadata(scene_list.get_item_count() - 1, scene_info)

func _on_scene_selected(index: int):
    """Handle scene selection"""
    var scene_info = scene_list.get_item_metadata(index)
    get_tree().change_scene_to_file(scene_info.path)
```

### Category Tabs Interface

```gdscript
extends Control

var tab_container: TabContainer
var categories = {}

func _ready():
    setup_tabbed_ui()
    populate_categories()

func setup_tabbed_ui():
    """Create tabbed interface for scene categories"""
    tab_container = TabContainer.new()
    tab_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(tab_container)

func populate_categories():
    """Create tabs for each scene category"""
    var all_scenes = SceneManagerGlobal.get_all_scenes()
    
    # Group scenes by category
    for scene_key in all_scenes.keys():
        var scene_info = all_scenes[scene_key]
        var category = scene_info.category.capitalize()
        
        if not categories.has(category):
            categories[category] = []
        categories[category].append(scene_info)
    
    # Create tabs
    for category in categories.keys():
        var tab = create_category_tab(category, categories[category])
        tab_container.add_child(tab)

func create_category_tab(category_name: String, scenes: Array) -> Control:
    """Create a tab for a specific category"""
    var tab = ScrollContainer.new()
    tab.name = category_name
    
    var vbox = VBoxContainer.new()
    tab.add_child(vbox)
    
    for scene_info in scenes:
        var button = Button.new()
        button.text = scene_info.title
        button.custom_minimum_size.y = 40
        button.pressed.connect(func(): get_tree().change_scene_to_file(scene_info.path))
        vbox.add_child(button)
    
    return tab
```

## CI/CD Examples

### GitHub Actions Integration

```yaml
# .github/workflows/godot-build.yml
name: Build Godot Project

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Godot
      run: |
        wget https://github.com/godotengine/godot-builds/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
        unzip Godot_v4.4.1-stable_linux.x86_64.zip
        chmod +x Godot_v4.4.1-stable_linux.x86_64
        sudo mv Godot_v4.4.1-stable_linux.x86_64 /usr/local/bin/godot

    - name: Generate Scene Manifest
      run: |
        cd project
        godot --headless --script addons/dynamic_scene_browser/scene_manifest_runtime.gd --quit
        
    - name: Verify Manifest
      run: |
        if [ ! -f "project/scene_manifest.json" ]; then
          echo "❌ Manifest generation failed"
          exit 1
        fi
        echo "✅ Manifest generated successfully"
        jq . project/scene_manifest.json | head -10

    - name: Export for Web
      run: |
        cd project
        godot --headless --export-release "Web" exports/web/index.html
        
    - name: Upload Web Build
      uses: actions/upload-artifact@v3
      with:
        name: web-build
        path: project/exports/web/
```

### Docker Build Example

```dockerfile
# Dockerfile
FROM barichello/godot-ci:4.4.1

WORKDIR /app
COPY . .

# Generate manifest
RUN godot --headless --script addons/dynamic_scene_browser/scene_manifest_runtime.gd --quit

# Export for web
RUN godot --headless --export-release "Web" exports/web/index.html

# Serve the build
FROM nginx:alpine
COPY --from=0 /app/exports/web /usr/share/nginx/html
```

### Custom Build Script

```bash
#!/bin/bash
# build.sh - Complete build script with scene discovery

set -e

PROJECT_DIR="$(dirname "$0")"
cd "$PROJECT_DIR"

echo "🔍 Starting Godot build with scene discovery..."

# Check Godot installation
if ! command -v godot &> /dev/null; then
    echo "❌ Godot not found in PATH"
    exit 1
fi

echo "✅ Using Godot: $(godot --version)"

# Generate scene manifest
echo "📄 Generating scene manifest..."
godot --headless --script addons/dynamic_scene_browser/scene_manifest_runtime.gd --quit

# Verify manifest was created
if [ ! -f "scene_manifest.json" ]; then
    echo "❌ Scene manifest generation failed"
    exit 1
fi

SCENE_COUNT=$(jq '.scenes | length' scene_manifest.json)
echo "✅ Scene manifest generated with $SCENE_COUNT scenes"

# Export for different platforms
echo "🔨 Exporting for Web..."
mkdir -p exports/web
godot --headless --export-release "Web" exports/web/index.html

echo "📊 Build summary:"
echo "  - Scenes discovered: $SCENE_COUNT"
echo "  - Web export size: $(du -h exports/web/index.pck | cut -f1)"
echo "  - Total web files: $(find exports/web -type f | wc -l)"

echo "🎉 Build completed successfully!"
```

## Advanced Patterns

### Dynamic Scene Preloading

```gdscript
extends Node

var preloaded_scenes = {}
var loading_queue = []

func _ready():
    preload_critical_scenes()

func preload_critical_scenes():
    """Preload important scenes for faster transitions"""
    var critical_paths = [
        "menu/main_menu",
        "gameplay/player",
        "ui/pause_menu"
    ]
    
    for path in critical_paths:
        var scene_info = SceneManagerGlobal.get_scene_by_path(path)
        if scene_info.size() > 0:
            queue_scene_load(scene_info.path)

func queue_scene_load(scene_path: String):
    """Queue a scene for background loading"""
    if not preloaded_scenes.has(scene_path):
        loading_queue.append(scene_path)
        _load_next_scene()

func _load_next_scene():
    """Load the next scene in the queue"""
    if loading_queue.size() > 0:
        var scene_path = loading_queue.pop_front()
        var resource_loader = ResourceLoader.load_threaded_request(scene_path)
        
        # Check loading status periodically
        var timer = Timer.new()
        timer.wait_time = 0.1
        timer.timeout.connect(_check_loading_status.bind(scene_path))
        add_child(timer)
        timer.start()

func _check_loading_status(scene_path: String):
    """Check if scene loading is complete"""
    var status = ResourceLoader.load_threaded_get_status(scene_path)
    
    if status == ResourceLoader.THREAD_LOAD_LOADED:
        var loaded_scene = ResourceLoader.load_threaded_get(scene_path)
        preloaded_scenes[scene_path] = loaded_scene
        print("✅ Preloaded scene:", scene_path)
        
        # Continue loading queue
        _load_next_scene()

func instant_scene_change(scene_path: String):
    """Instantly change to a preloaded scene, or load normally"""
    if preloaded_scenes.has(scene_path):
        get_tree().change_scene_to_packed(preloaded_scenes[scene_path])
    else:
        get_tree().change_scene_to_file(scene_path)
```

### Scene Analytics Integration

```gdscript
extends Node

var scene_analytics = {}

func _ready():
    track_scene_usage()

func track_scene_usage():
    """Track which scenes are being used"""
    get_tree().node_added.connect(_on_scene_changed)

func _on_scene_changed(node: Node):
    """Log scene transitions"""
    if node == get_tree().current_scene:
        var scene_path = node.scene_file_path
        log_scene_access(scene_path)

func log_scene_access(scene_path: String):
    """Log scene access for analytics"""
    var scene_key = scene_path.get_file().get_basename()
    
    if not scene_analytics.has(scene_key):
        scene_analytics[scene_key] = {
            "access_count": 0,
            "first_access": Time.get_datetime_string_from_system(),
            "last_access": ""
        }
    
    scene_analytics[scene_key].access_count += 1
    scene_analytics[scene_key].last_access = Time.get_datetime_string_from_system()
    
    print("📊 Scene accessed:", scene_key, "(", scene_analytics[scene_key].access_count, "times )")

func get_scene_usage_report() -> String:
    """Generate a usage report"""
    var report = "Scene Usage Report:\n"
    var sorted_scenes = []
    
    for scene_key in scene_analytics.keys():
        sorted_scenes.append([scene_key, scene_analytics[scene_key].access_count])
    
    sorted_scenes.sort_custom(func(a, b): return a[1] > b[1])
    
    for item in sorted_scenes:
        report += "- %s: %d accesses\n" % [item[0], item[1]]
    
    return report
```

## Performance Monitoring Examples

### Scene Discovery Profiler

```gdscript
extends Node

class SceneDiscoveryProfiler:
    var start_time: float
    var scene_count: int = 0
    var discovery_stats: Dictionary = {}
    
    func start_profiling():
        start_time = Time.get_time_dict_from_system().values().reduce(func(a, b): return a + b)
        scene_count = 0
        discovery_stats.clear()
    
    func profile_scene_discovery(path: String):
        scene_count += 1
        var current_time = Time.get_time_dict_from_system().values().reduce(func(a, b): return a + b)
        var category = path.split("/")[0] if "/" in path else "root"
        
        if not discovery_stats.has(category):
            discovery_stats[category] = {"count": 0, "total_time": 0.0}
        
        discovery_stats[category].count += 1
        discovery_stats[category].total_time += (current_time - start_time)
    
    func get_performance_report() -> Dictionary:
        var total_time = Time.get_time_dict_from_system().values().reduce(func(a, b): return a + b) - start_time
        return {
            "total_scenes": scene_count,
            "total_time": total_time,
            "scenes_per_second": scene_count / total_time if total_time > 0
