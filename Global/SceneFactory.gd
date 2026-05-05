extends Node

var _cache : Dictionary = {}

func get_scene(scene_or_path):
	if scene_or_path is PackedScene:
		return scene_or_path
	
	if scene_or_path is String:
		if not _cache.has(scene_or_path):
			_cache[scene_or_path] = load(scene_or_path)
		
		return _cache[scene_or_path]
	
	return null

func spawn(scene_or_path, parent : Node = null, position = null):
	var scene : PackedScene = get_scene(scene_or_path)
	var instance = scene.instantiate()
	
	if position != null:
		if "position" in instance:
			instance.position = position
		elif instance is Node3D:
			instance.global_position = position
			
	if parent != null:
		parent.add_child(instance)
	
	return instance
