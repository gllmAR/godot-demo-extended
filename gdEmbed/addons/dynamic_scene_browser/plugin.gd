@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("SceneManagerGlobal", "res://addons/dynamic_scene_browser/scene_manager_autoload.gd")
	add_export_plugin(preload("res://addons/dynamic_scene_browser/export_plugin.gd").new())
	_add_project_settings()

	# Project settings for configuration
func _add_project_settings():
	# Configurable paths and behavior
	ProjectSettings.set_setting("dynamic_scene_browser/base_path", "res://scenes/")
	ProjectSettings.set_setting("dynamic_scene_browser/auto_generate_manifests", true)
	ProjectSettings.set_setting("dynamic_scene_browser/default_scene", "")
	ProjectSettings.set_setting("dynamic_scene_browser/show_browser_on_empty_scene", true)
	ProjectSettings.save()
