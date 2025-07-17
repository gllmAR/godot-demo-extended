# Godot Export Makefile
# Uses the existing export_presets.cfg file for configuration

# Variables
GODOT_EXECUTABLE := godot
GODOT_VERSION := 4.4.1-stable
GODOT_TEMPLATE_VERSION := 4.4.1.stable
PROJECT_DIR := .
EXPORT_DIR := exports
WEB_EXPORT_DIR := $(EXPORT_DIR)/web
PRESET_NAME := Web

# Source files that trigger a rebuild
SOURCE_FILES := $(wildcard *.gd *.tscn *.godot scenes/**/*.gd scenes/**/*.tscn)
EXPORT_PRESET_FILE := export_presets.cfg
PROJECT_FILE := project.godot

# Output files
WEB_OUTPUT := $(WEB_EXPORT_DIR)/index.html
WEB_WASM := $(WEB_EXPORT_DIR)/index.wasm
WEB_PCK := $(WEB_EXPORT_DIR)/index.pck
WEB_JS := $(WEB_EXPORT_DIR)/index.js

# Default target
.PHONY: all
all: web

# Generate scene manifest using addon version with Python fallback
.PHONY: generate-manifest
generate-manifest:
	@echo "Generating scene manifest..."
	@rm -f scene_manifest.json
	@echo "Trying Godot-based generation..."
	@timeout 20s $(GODOT_EXECUTABLE) --headless --script addons/dynamic_scene_browser/scene_manifest_runtime.gd --quit 2>/dev/null || \
	(echo "⚠️ Godot generation failed, using Python fallback..." && \
	 python3 simple_manifest_gen.py 2>/dev/null || \
	 (echo "⚠️ Python not available, creating minimal manifest..." && \
	  echo '{"generated_at":"'$$(date -Iseconds)'","scenes":{},"structure":{}}' > scene_manifest.json))
	@if [ -f "scene_manifest.json" ]; then \
		echo "✅ Manifest generated successfully"; \
		echo "📊 Manifest size: $$(wc -c < scene_manifest.json) bytes"; \
		head -3 scene_manifest.json; \
	else \
		echo "❌ All manifest generation methods failed"; \
		exit 1; \
	fi

$(WEB_OUTPUT): $(SOURCE_FILES) $(EXPORT_PRESET_FILE) $(PROJECT_FILE) scene_manifest.json
	@echo "Exporting Godot project for Web..."
	@mkdir -p $(WEB_EXPORT_DIR)
	$(GODOT_EXECUTABLE) --headless --export-release "$(PRESET_NAME)" $(WEB_OUTPUT)
	@echo "Web export completed: $(WEB_OUTPUT)"

# Web export target with manifest generation
.PHONY: web
web: generate-manifest $(WEB_OUTPUT)
	@echo "Verifying web export..."
	@if [ -f "$(WEB_OUTPUT)" ] && [ -f "$(WEB_PCK)" ] && [ -f "$(WEB_JS)" ]; then \
		echo "✅ Web export files present:"; \
		echo "  HTML: $(WEB_OUTPUT) ($$(wc -c < $(WEB_OUTPUT)) bytes)"; \
		echo "  PCK:  $(WEB_PCK) ($$(wc -c < $(WEB_PCK)) bytes)"; \
		echo "  JS:   $(WEB_JS) ($$(wc -c < $(WEB_JS)) bytes)"; \
		echo "📦 Manifest should be packed inside the PCK file"; \
		echo "🌐 Ready for web deployment!"; \
	else \
		echo "❌ Web export incomplete"; \
		exit 1; \
	fi

# Debug web export with manifest
.PHONY: web-debug
web-debug: generate-manifest
	@echo "Exporting Godot project for Web (Debug)..."
	@mkdir -p $(WEB_EXPORT_DIR)
	$(GODOT_EXECUTABLE) --headless --export-debug "$(PRESET_NAME)" $(WEB_OUTPUT)
	@echo "Web debug export completed: $(WEB_OUTPUT)"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning export directory..."
	rm -rf $(EXPORT_DIR)
	@echo "Clean completed"

# Verify export preset configuration
.PHONY: check-preset
check-preset:
	@echo "Checking export preset configuration..."
	@if [ ! -f "$(EXPORT_PRESET_FILE)" ]; then \
		echo "Error: $(EXPORT_PRESET_FILE) not found!"; \
		exit 1; \
	fi
	@if ! grep -q 'name="$(PRESET_NAME)"' $(EXPORT_PRESET_FILE); then \
		echo "Error: Preset '$(PRESET_NAME)' not found in $(EXPORT_PRESET_FILE)"; \
		echo "Available presets:"; \
		grep '^name=' $(EXPORT_PRESET_FILE) || echo "No presets found"; \
		exit 1; \
	fi
	@echo "Export preset '$(PRESET_NAME)' found and configured"
	@echo "Export path: $$(grep -A 20 'name="$(PRESET_NAME)"' $(EXPORT_PRESET_FILE) | grep 'export_path=' | head -1)"

# Check Godot installation and export templates
.PHONY: check-godot
check-godot:
	@echo "Checking Godot installation..."
	@$(GODOT_EXECUTABLE) --version || (echo "Error: Godot executable not found or not working"; exit 1)
	@echo "Checking export templates..."
	@if [ -d "$$HOME/.local/share/godot/export_templates/$(GODOT_TEMPLATE_VERSION)" ]; then \
		echo "✅ Export templates found for $(GODOT_TEMPLATE_VERSION)"; \
		ls -la "$$HOME/.local/share/godot/export_templates/$(GODOT_TEMPLATE_VERSION)/" | head -5; \
	elif [ -d "$$HOME/Library/Application Support/Godot/export_templates/$(GODOT_TEMPLATE_VERSION)" ]; then \
		echo "✅ Export templates found for $(GODOT_TEMPLATE_VERSION) (macOS)"; \
		ls -la "$$HOME/Library/Application Support/Godot/export_templates/$(GODOT_TEMPLATE_VERSION)/" | head -5; \
	else \
		echo "⚠️  Export templates not found for $(GODOT_TEMPLATE_VERSION)"; \
		echo "Available template versions (Linux):"; \
		ls -la "$$HOME/.local/share/godot/export_templates/" 2>/dev/null || echo "  No Linux templates directory found"; \
		echo "Available template versions (macOS):"; \
		ls -la "$$HOME/Library/Application Support/Godot/export_templates/" 2>/dev/null || echo "  No macOS templates directory found"; \
		echo ""; \
		echo "💡 To install export templates:"; \
		echo "  1. Open Godot Editor"; \
		echo "  2. Go to Editor > Manage Export Templates"; \
		echo "  3. Download templates for version $(GODOT_TEMPLATE_VERSION)"; \
		echo "  OR run: make install-templates (if implemented)"; \
	fi

# List available make targets
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              - Build all exports (default: web)"
	@echo "  web              - Generate manifest and export for Web (release)"
	@echo "  web-debug        - Generate manifest and export for Web (debug)"
	@echo "  generate-manifest- Generate scene manifest file"
	@echo "  clean            - Remove all build artifacts"
	@echo "  check-preset     - Verify export preset configuration"
	@echo "  check-godot      - Check Godot installation and export templates"
	@echo "  ci-build         - CI-specific clean rebuild for deployment"
	@echo "  status           - Show current build status"
	@echo "  force            - Force complete rebuild"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "The build uses the existing export_presets.cfg file"
	@echo "Configure exports in Godot UI, then use this Makefile to automate builds"

# Show file status for debugging
.PHONY: status
status:
	@echo "=== Build Status ==="
	@echo "Project file: $(PROJECT_FILE) $(if $(wildcard $(PROJECT_FILE)),✓,✗)"
	@echo "Export preset: $(EXPORT_PRESET_FILE) $(if $(wildcard $(EXPORT_PRESET_FILE)),✓,✗)"
	@echo "Export directory: $(WEB_EXPORT_DIR) $(if $(wildcard $(WEB_EXPORT_DIR)),✓,✗)"
	@echo "Web output: $(WEB_OUTPUT) $(if $(wildcard $(WEB_OUTPUT)),✓,✗)"
	@echo "WASM file: $(WEB_WASM) $(if $(wildcard $(WEB_WASM)),✓,✗)"
	@echo "PCK file: $(WEB_PCK) $(if $(wildcard $(WEB_PCK)),✓,✗)"
	@echo "JS file: $(WEB_JS) $(if $(wildcard $(WEB_JS)),✓,✗)"
	@echo ""
	@echo "Source files that trigger rebuild:"
	@for file in $(SOURCE_FILES); do echo "  $$file"; done

# Force rebuild (ignore dependencies)
.PHONY: force
force:
	@echo "Force rebuilding..."
	$(MAKE) clean
	$(MAKE) web

# CI-specific target that always rebuilds for deployment
.PHONY: ci-build
ci-build:
	@echo "🔨 CI Build: Clean rebuild for deployment..."
	$(MAKE) clean
	$(MAKE) web
	@echo "✅ CI build completed - files ready for deployment"
