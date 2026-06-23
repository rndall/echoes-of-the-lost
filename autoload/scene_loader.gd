extends Node

var loading_screen: PackedScene = preload("uid://da3fy45kwnqqm")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

var scene_container: Node
var target_spawn_name: String = ""


func _ready() -> void:
	set_process(false)


func load_scene(_scene_path: String, _target_spawn_name: String = "") -> void:
	scene_path = _scene_path
	target_spawn_name = _target_spawn_name
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	
	await new_load_screen.loading_screen_ready
	
	start_load()


func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)


func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	Events.scene_progress_changed.emit(progress[0])
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false) # Stop processing
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			
			_switch_scene_in_container()
			Events.scene_load_finished.emit()


func _switch_scene_in_container() -> void:
	# Fallback: If no container is set, use the scene tree root
	var target_node = scene_container if scene_container else get_tree().root
	
	# 1. Remove old level/scene children from the container
	for child in target_node.get_children():
		# Optional: Ensure we don't accidentally delete the loading screen if it's there
		if child != self and not child.is_queued_for_deletion():
			child.queue_free()
	
	# 2. Instance the new scene and add it
	var new_scene = loaded_resource.instantiate()
	target_node.add_child(new_scene)
	
	_reposition_player(new_scene)


func _reposition_player(new_map: Node) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if target_spawn_name != "":
		var spawn_point = new_map.get_node_or_null(target_spawn_name)
		if spawn_point:
			player.global_position = spawn_point.global_position
		else:
			push_warning("Spawn point " + target_spawn_name + " not found in new map!")
			
		target_spawn_name = "" 
		
	# Game Start (No specific door was passed)
	else:
		var default_start = new_map.get_node_or_null("Spawns/DefaultStartPoint")
		if default_start:
			player.global_position = default_start.global_position
