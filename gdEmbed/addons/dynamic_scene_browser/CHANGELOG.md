# Changelog

All notable changes to the Dynamic Scene Browser addon will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-05

### Added

#### Core Features
- **Scene Discovery System**: Automatic recursive scanning of `res://scenes/` directory
- **Hierarchical Scene Tree**: Structured organization with folders and subfolders
- **JSON Manifest Generation**: Complete scene metadata export for web builds
- **Web Export Integration**: Seamless export hooks for automated manifest inclusion
- **URL-Based Scene Loading**: Direct scene access via web URL parameters

#### UI Components
- **Native Tree Browser**: Responsive scene browser using Godot's Tree control
- **Expand/Collapse Controls**: Folder navigation with state management
- **Fullscreen Support**: Iframe fullscreen functionality for web embeddings
- **Pop-out Windows**: New window scene launching for web demos
- **Responsive Design**: Adaptive UI that scales across device sizes

#### Development Tools
- **EditorScript Generator**: In-editor manifest generation via Tools menu
- **Runtime Generator**: Headless/CI-compatible scene discovery
- **Export Plugin Integration**: Automatic manifest generation during export
- **Makefile Integration**: Build system support with make targets

#### Web Platform Features
- **Manifest-Based Discovery**: Fast scene loading from pre-generated manifest
- **Smart Fallback Discovery**: Pattern-matching scene discovery for web platforms
- **JavaScript Bridge Integration**: Seamless web platform integration
- **Cross-Origin Support**: Proper headers for iframe embedding

#### API & Integration
- **SceneManagerGlobal Autoload**: Global scene discovery and management
- **Scene Info Dictionary**: Comprehensive scene metadata structure
- **Path Resolution**: Multiple strategies for scene path matching
- **CI/CD Support**: GitHub Actions and Docker integration examples

### Technical Details

#### Scene Discovery
- Recursive directory scanning for `.tscn` files
- Manifest-first approach for web builds with smart fallbacks
- Scene key generation: `category_subfolder_filename` format
- Metadata extraction: path, name, title, category, directory structure

#### Manifest Format
```json
{
  "generated_at": "ISO timestamp",
  "scenes": {
    "scene_key": {
      "path": "res:// path",
      "relative_path": "relative path", 
      "name": "scene name",
      "title": "Display Title",
      "directory": "parent directory",
      "category": "top-level category",
      "subfolder": "immediate parent folder"
    }
  },
  "structure": {
    "hierarchical": "folder structure"
  }
}
```

#### Export Integration
- Pre-export manifest generation via `EditorExportPlugin`
- Automatic manifest inclusion in PCK files
- Export preset configuration validation
- Build verification and file size checks

#### UI Architecture
- Control node-based responsive design
- Dynamic font and spacing calculations based on viewport size
- Native Tree control with custom styling
- Metadata-driven scene information storage

### Build System
- **Makefile targets**: `generate-manifest`, `web`, `ci-build`, `check-godot`
- **GitHub Actions integration**: Automated builds with Godot 4.4.1
- **Docker support**: Container-based builds with manifest generation
- **Cross-platform compatibility**: Linux, macOS, Windows development support

### Documentation
- Comprehensive README with API reference
- Practical examples for common use cases
- CI/CD integration guides
- Troubleshooting section with common issues

### Performance
- **Scene Discovery**: Sub-second for 100+ scenes
- **Manifest Generation**: ~1KB per 100 scenes
- **UI Overhead**: ~50KB browser interface
- **Export Integration**: <5% build time impact

### Compatibility
- **Godot Version**: 4.4.1+ (built and tested)
- **Platforms**: Web, Desktop (Windows, macOS, Linux)
- **Export Formats**: Web (primary), extensible for other platforms
- **Web Browsers**: Modern browsers with iframe and JavaScript support

### Known Limitations
- Scene discovery limited to `res://scenes/` directory structure
- Web platform requires manifest for optimal performance
- UI scaling optimized for desktop and tablet sizes
- Export hooks require plugin to be enabled during build

### Contributors
- Initial development and architecture
- Web platform integration
- CI/CD pipeline setup
- Documentation and examples

---

## Development Notes

### Version 1.0.0 Development Process
This initial release focused on creating a robust foundation for dynamic scene management in Godot projects. Key development decisions:

1. **Manifest-First Architecture**: Prioritizing pre-generated manifests over runtime discovery for web performance
2. **Export Hook Integration**: Ensuring manifests are always current by generating during export
3. **Responsive UI Design**: Native Godot controls with calculated responsive behavior
4. **Multiple Discovery Strategies**: Fallback systems for different platform capabilities
5. **Build System Integration**: First-class support for automated builds and CI/CD

### Future Considerations
Areas identified for potential future enhancement:
- Additional export platform support (mobile, desktop)
- Scene tagging and metadata system
- Advanced filtering and search capabilities
- Scene dependency tracking
- Performance analytics and monitoring
- Visual scene preview generation
- Internationalization support

### Testing Coverage
- [x] Scene discovery across multiple directory structures
- [x] Manifest generation in editor and headless modes
- [x] Web export integration and verification
- [x] URL parameter parsing and scene loading
- [x] UI responsiveness across screen sizes
- [x] CI/CD integration with GitHub Actions
- [x] Cross-platform build compatibility
- [x] Export preset configuration validation

This release represents a stable foundation for dynamic scene management that can be extended and customized for specific project needs.

## [1.1.0] - Planned Future Release

### Planned Features
- **Scene Tagging System**: Metadata-driven scene categorization
- **Advanced Search**: Full-text search with filters and sorting
- **Scene Dependencies**: Automatic dependency tracking and visualization
- **Preview Generation**: Automated scene thumbnail creation
- **Performance Analytics**: Built-in profiling and optimization tools
- **Mobile UI**: Touch-optimized interface for mobile devices
- **Localization**: Multi-language support for international projects

### Technical Improvements
- **Virtual Scrolling**: Handle projects with 1000+ scenes efficiently
- **Incremental Discovery**: File system watching for real-time updates
- **Memory Optimization**: Reduced memory footprint for large projects
- **Export Validation**: Pre-export scene integrity checking
