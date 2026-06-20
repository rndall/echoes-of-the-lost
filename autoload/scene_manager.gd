extends Node

func travel_to(map_path: String, entry_point: String) -> void:
	EventBus.scene_transition_requested.emit(map_path, entry_point)
	
	SceneLoader.load_scene(map_path)
