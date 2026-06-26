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
		get_tree().paused = true
		
		SceneLoader.load_scene(target_scene[target_map], spawn_points[target_map])
		await Events.scene_load_finished
		
		get_tree().paused = false
		
		Events.map_changed.emit(target_map)
