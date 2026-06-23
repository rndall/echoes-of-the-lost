extends Node

var loading_screen: PackedScene = preload("uid://da3fy45kwnqqm")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

var scene_container: Node


func _ready() -> void:
	set_process(false)


func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
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
