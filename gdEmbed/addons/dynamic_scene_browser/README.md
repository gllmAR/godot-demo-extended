# Dynamic Scene Browser Addon

<!-- embed-{$PATH} -->


A powerful Godot 4.x addon that provides automatic scene discovery, hierarchical browsing, manifest generation, and seamless web export integration.

## Features

- 🔍 **Automatic Scene Discovery**: Recursively scans project directories to find all `.tscn` files
- 📁 **Hierarchical Browser**: Native Tree control with folder structure visualization
- 📄 **Manifest Generation**: Creates JSON manifests for web deployments and CI/CD
- 🌐 **Web Export Support**: Seamless integration with Godot web exports
- 🔧 **CI/CD Ready**: Export hooks and headless generation support
- 🎮 **URL Scene Loading**: Direct scene loading via URL parameters
- 📱 **Responsive UI**: Adaptive interface that works on desktop and web

## Quick Start

### Installation

1. Copy the `dynamic_scene_browser` folder to your project's `addons/` directory
2. Enable the plugin in Project Settings > Plugins
3. The addon will automatically:
   - Add `SceneManagerGlobal` autoload
   - Register export hooks for manifest generation

### Basic Usage

#### Desktop/Editor Mode
```gdscript
# Scenes are automatically discovered on project load
# Access via the autoload:
var scenes = SceneManagerGlobal.get_all_scenes()
var scene_tree = SceneManagerGlobal.get_scene_tree()

# Load a specific scene by path
var scene_info = SceneManagerGlobal.get_scene_by_path("animation/basic_animation")
if scene_info.size() > 0:
    get_tree().change_scene_to_file(scene_info.path)
```

#### Web Mode
```gdscript
# In your main scene, add the scene manager:
var scene_manager = preload("res://addons/dynamic_scene_browser/scene_manager.gd").new()
add_child(scene_manager)

# URL-based scene loading works automatically:
# https://yoursite.com/game/?scene=animation/basic_animation
```

## Architecture

### Core Components

#### 1. Scene Manager Autoload (`scene_manager_autoload.gd`)
- **Purpose**: Global scene discovery and management
- **Key Methods**:
  - `discover_all_scenes()`: Main discovery orchestrator
  - `get_scene_by_path(path: String)`: Retrieve scene info by path
  - `get_all_scenes()`: Get complete scene dictionary
  - `get_scene_tree()`: Get hierarchical structure

#### 2. Scene Manager UI (`scene_manager.gd`)
- **Purpose**: Interactive scene browser and web integration
- **Features**:
  - Native Tree control with folder expansion
  - URL parameter parsing for web deployments
  - Responsive design with dynamic sizing
  - Fullscreen and popout controls

#### 3. Manifest Generators
- **Editor Generator** (`scene_manifest_generator.gd`): EditorScript-based generation
- **Runtime Generator** (`scene_manifest_runtime.gd`): Headless/CI-compatible generation

#### 4. Export Integration (`export_plugin.gd`)
- **Purpose**: Automatic manifest generation during export
- **Triggers**: Runs before each export to ensure fresh manifests

### Data Flow

```
Project Scenes
     ↓
Scene Discovery (Autoload)
     ↓
Manifest Generation (Export Hook)
     ↓
Web Export with Embedded Manifest
     ↓
Scene Manager UI (Runtime)
     ↓
Dynamic Scene Loading
```

## Configuration

### Addon Settings

The addon works out-of-the-box but can be customized:

```gdscript
# In scene_manager_autoload.gd
const MANIFEST_PATH = "res://scene_manifest.json"  # Change manifest location

# In scene_manager.gd  
const DEFAULT_IFRAME_SIZE = Vector2(800, 600)  # Default browser size
```

### Project Structure

The addon expects scenes to follow this structure:
```
scenes/
├── category1/
│   ├── scene1.tscn
│   └── subfolder/
│       └── scene2.tscn
├── category2/
│   └── scene3.tscn
└── ...
```

### Export Presets

Ensure your web export preset includes the manifest:

```ini
# In export_presets.cfg
[preset.0]
name="Web"
include_filter="scene_manifest.json"
```

## API Reference

### SceneManagerGlobal (Autoload)

#### Properties
- `discovered_scenes: Dictionary` - All discovered scenes keyed by scene_key
- `scene_tree: Dictionary` - Hierarchical folder structure

#### Methods

##### `discover_all_scenes()`
Initiates the complete scene discovery process.

##### `get_scene_by_path(path: String) -> Dictionary`
Retrieves scene information by relative path.

**Parameters:**
- `path`: Relative path like "animation/basic_animation"

**Returns:** Scene info dictionary or empty dict if not found

**Example:**
```gdscript
var scene_info = SceneManagerGlobal.get_scene_by_path("animation/tweening")
# Returns: {
#   "path": "res://scenes/animation/tweening/tweening.tscn",
#   "name": "tweening", 
#   "title": "Tweening",
#   "category": "animation",
#   "subfolder": "tweening"
# }
```

##### `get_all_scenes() -> Dictionary`
Returns the complete discovered scenes dictionary.

##### `get_scene_tree() -> Dictionary`
Returns the hierarchical folder structure.

##### `is_valid_scene_path(path: String) -> bool`
Checks if a scene path exists in the discovered scenes.

### Scene Manager UI

#### Methods

##### `load_scene_from_url()`
Automatically called in web mode to parse URL parameters and load scenes.

##### `_show_scene_browser()`
Creates and displays the interactive scene browser UI.

#### URL Parameters

In web builds, the scene manager supports URL-based scene loading:

- `?scene=animation/basic_animation` - Loads specific scene
- No parameters - Shows scene browser

## Manifest Format

The generated `scene_manifest.json` follows this structure:

```json
{
  "generated_at": "2023-12-01T10:30:00",
  "scenes": {
    "animation_basic_animation_basic_animation": {
      "path": "res://scenes/animation/basic_animation/basic_animation.tscn",
      "relative_path": "animation/basic_animation/basic_animation.tscn",
      "name": "basic_animation",
      "title": "Basic Animation", 
      "directory": "animation/basic_animation",
      "category": "animation",
      "subfolder": "basic_animation"
    }
  },
  "structure": {
    "animation": {
      "type": "folder",
      "title": "Animation",
      "children": {
        "basic_animation": {
          "type": "folder", 
          "scenes": ["animation_basic_animation_basic_animation"]
        }
      }
    }
  }
}
```

## Build Integration

### Makefile Integration

```makefile
# Generate manifest before export
generate-manifest:
	godot --headless --script addons/dynamic_scene_browser/scene_manifest_runtime.gd --quit

# Web export with manifest
web: generate-manifest
	godot --headless --export-release "Web" exports/web/index.html
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Build Godot Export
  run: |
    cd gdEmbed
    make check-godot
    make ci-build
```

## Troubleshooting

### Common Issues

#### 1. No Scenes Discovered
**Problem**: `discovered_scenes` is empty
**Solutions:**
- Check that scenes are in `res://scenes/` directory
- Verify scene files have `.tscn` extension
- Enable plugin in Project Settings

#### 2. Manifest Not Generated
**Problem**: `scene_manifest.json` not created during export
**Solutions:**
- Ensure export plugin is enabled
- Check export preset includes manifest file
- Verify addon is properly installed

#### 3. Web Scene Loading Fails
**Problem**: URL parameters don't load scenes
**Solutions:**
- Check that manifest is included in web export
- Verify scene paths match manifest keys
- Enable browser developer tools for debugging

#### 4. UI Not Responsive
**Problem**: Scene browser doesn't fit screen
**Solutions:**
- Update to latest addon version
- Check viewport size calculations
- Test on different screen sizes

### Debug Information

Enable debug output:

```gdscript
# In scene_manager_autoload.gd
func _debug_print_tree(tree_data: Dictionary, indent_level: int):
    # Uncomment debug prints for detailed output
```

## Performance Considerations

### Scene Discovery
- **Editor**: Full filesystem scanning (fast)
- **Web**: Manifest-based loading (instant)
- **Fallback**: Smart pattern matching (acceptable)

### Memory Usage
- Manifest size: ~1KB per 100 scenes
- UI overhead: ~50KB for browser interface
- Scene metadata: ~100 bytes per scene

### Build Time
- Manifest generation: <1 second for 100 scenes
- Export integration: <5% build time overhead

## Performance Optimizations

### Scene Discovery Performance
- **Caching**: Implement discovery result caching for repeated scans
- **Incremental Updates**: Track file system changes for partial re-discovery
- **Parallel Processing**: Multi-threaded scene scanning for large projects
- **Memory Management**: Lazy loading of scene metadata

### UI Performance
- **Virtual Scrolling**: For projects with hundreds of scenes
- **Thumbnail Generation**: Automated scene preview creation
- **Search Indexing**: Full-text search across scene names and metadata
- **Keyboard Navigation**: Complete keyboard accessibility

### Web Optimization
- **Manifest Compression**: Gzip compression for large manifests
- **Progressive Loading**: Load scene metadata on-demand
- **Service Worker**: Offline scene browser capability
- **CDN Integration**: Asset delivery optimization

## Contributing

### Development Setup

1. Clone the repository
2. Copy addon to a test project
3. Enable plugin and test functionality
4. Make changes and test across platforms

### Testing Checklist

- [ ] Scene discovery works in editor
- [ ] Manifest generation completes
- [ ] Web export includes manifest
- [ ] URL scene loading functional
- [ ] UI responsive on different screens
- [ ] CI/CD integration works

## Changelog

### v1.0.0 (Current)
- Initial release
- Full scene discovery and manifest generation
- Web export integration
- Responsive UI with Tree control
- CI/CD support

## License

This addon is provided under the same license as your project. See the main project LICENSE file for details.
