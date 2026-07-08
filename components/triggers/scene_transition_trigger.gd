extends Area2D

@export var target_map: Events.Map
@export var target_spawn: String

var target_scene: Dictionary[Events.Map, String] = {
	Events.Map.HOUSE: "uid://3s5rfvjydnns", 
	Events.Map.OUTSIDE: "uid://c5g3ll83gblw0", 
}


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().current_scene.switch_map(target_scene[target_map], target_spawn)
		await Events.scene_load_finished
		Events.map_changed.emit(target_map)
