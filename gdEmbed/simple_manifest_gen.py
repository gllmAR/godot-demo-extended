#!/usr/bin/env python3
"""
Simple scene manifest generator for Godot projects
Scans the scenes directory and creates a JSON manifest
"""

import os
import json
from datetime import datetime
from pathlib import Path

def generate_title(name):
    """Generate a nice title from a scene name"""
    words = name.split('_')
    return ' '.join(word.capitalize() for word in words if word)

def scan_scenes_directory(scenes_path):
    """Scan the scenes directory for .tscn files"""
    scenes = {}
    structure = {}
    
    scenes_dir = Path(scenes_path)
    if not scenes_dir.exists():
        print(f"❌ Scenes directory not found: {scenes_path}")
        return scenes, structure
    
    for tscn_file in scenes_dir.rglob('*.tscn'):
        # Get relative path from scenes directory
        rel_path = tscn_file.relative_to(scenes_dir)
        rel_path_str = str(rel_path).replace('\\', '/')
        
        # Create scene key
        scene_key = str(rel_path.with_suffix('')).replace('/', '_').replace('\\', '_')
        scene_name = tscn_file.stem
        directory = str(rel_path.parent).replace('\\', '/') if rel_path.parent != Path('.') else ""
        
        # Create scene entry
        scenes[scene_key] = {
            "path": f"res://scenes/{rel_path_str}",
            "relative_path": rel_path_str,
            "name": scene_name,
            "title": generate_title(scene_name),
            "directory": directory,
            "category": directory.split('/')[0] if directory else "",
            "subfolder": directory.split('/')[1] if '/' in directory else ""
        }
        
        # Add to structure
        if directory:
            if directory not in structure:
                structure[directory] = {
                    "type": "folder",
                    "path": directory,
                    "children": [],
                    "scenes": []
                }
            structure[directory]["scenes"].append(scene_key)
        
        print(f"✅ Found scene: {rel_path_str} (key: {scene_key})")
    
    return scenes, structure

def main():
    print("🔍 Python scene manifest generator starting...")
    
    # Find scenes directory
    scenes_path = "scenes"
    if not os.path.exists(scenes_path):
        print(f"❌ Scenes directory not found: {scenes_path}")
        exit(1)
    
    # Generate manifest
    scenes, structure = scan_scenes_directory(scenes_path)
    
    manifest = {
        "generated_at": datetime.now().isoformat(),
        "scenes": scenes,
        "structure": structure
    }
    
    # Write manifest
    with open("scene_manifest.json", "w") as f:
        json.dump(manifest, f, indent=2)
    
    print(f"✅ Scene manifest generated with {len(scenes)} scenes")
    print(f"📊 Written to scene_manifest.json")

if __name__ == "__main__":
    main()
