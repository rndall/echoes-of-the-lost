extends Node

@onready var player: Player = $Player
@onready var day_night_cycle_ui: Control = $CanvasLayer/DayNightCycleUI
@onready var day_night_cycle: CanvasModulate = $DayNightCycle
@onready var world_container = $WorldContainer

var next_spawn: String = "Default"


func _ready() -> void:
	player.hide()
	player.set_physics_process(false)
	day_night_cycle_ui.hide()
	day_night_cycle.hide()
	day_night_cycle.process_mode = Node.PROCESS_MODE_DISABLED
	
	Events.scene_load_finished.connect(_on_scene_load_finished)


func switch_map(new_map_path: String, spawn_name: String = "Default") -> void:
	next_spawn = spawn_name
	get_tree().paused = true
	SceneLoader.load_scene(new_map_path)


func _position_player(current_map: Node2D) -> void:
	var spawn_container: Node2D = current_map.get_node_or_null("Spawns")
	
	if not spawn_container:
		return
	
	var target_spawn: Marker2D = spawn_container.get_node_or_null(next_spawn)
	
	if not target_spawn:
		return
	
	player.global_position = target_spawn.global_position


func _on_scene_load_finished(loaded_map: PackedScene) -> void:
	for child in world_container.get_children():
		child.queue_free()
		
	var new_map_instance = loaded_map.instantiate()
	world_container.add_child(new_map_instance)
	
	_position_player(new_map_instance)
	
	player.show()
	player.set_physics_process(true)
	day_night_cycle_ui.show()
	day_night_cycle.show()
	day_night_cycle.process_mode = Node.PROCESS_MODE_INHERIT
	
	get_tree().paused = false
