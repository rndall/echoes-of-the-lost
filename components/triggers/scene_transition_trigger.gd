extends Area2D

@export var target_map: Events.Map

var target_scene: Dictionary[Events.Map, String] = {
	Events.Map.HOUSE: "uid://3s5rfvjydnns", 
	Events.Map.OUTSIDE: "uid://c5g3ll83gblw0", 
}

var spawn_points: Dictionary[Events.Map, String] = {
	Events.Map.HOUSE: "ExitDoorSpawn", 
	Events.Map.OUTSIDE: "Spawns/HouseEntranceSpawn", 
}


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_process_mode(PROCESS_MODE_DISABLED)
		SceneLoader.load_scene(target_scene[target_map], spawn_points[target_map])
		await Events.scene_load_finished
		body.set_process_mode(PROCESS_MODE_INHERIT)
		Events.map_changed.emit(target_map)
