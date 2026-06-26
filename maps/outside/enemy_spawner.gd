extends Node2D

@export var enemy_scene: PackedScene
@export var tilemap_layer: TileMapLayer # Drag your ground TileMapLayer here!
@export var spawn_interval: float = 5.0 # Seconds between single spawns
@export var max_enemies: int = 5 # Maximum enemies allowed alive at once
@export var spawn_margin: float = 150.0 

var player: Player
var spawned_enemies: Dictionary = {}
var unique_id_counter: int = 0
var spawn_timer: Timer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# Create and configure our interval timer dynamically
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Check phase and reconstruct existing persistent enemies immediately
	_manage_spawner_state()
	
	Events.map_changed.connect(func(_map): _manage_spawner_state())
	Events.time_tick.connect(func(_d, _h, _m): _manage_spawner_state())


func _manage_spawner_state() -> void:
	if GameManager.phase == GameManager.PHASE.NIGHT:
		# 1. If we just loaded the scene, check if there are saved enemies to restore
		if spawned_enemies.is_empty():
			_restore_saved_enemies()
			
		# 2. Start the timer if it isn't running and we haven't hit the cap
		if spawn_timer.is_stopped() and spawned_enemies.size() < max_enemies:
			spawn_timer.start()
	
	elif GameManager.phase == GameManager.PHASE.DAY:
		# Stop spawning and clear out the night enemies
		if not spawn_timer.is_stopped():
			spawn_timer.stop()
		if not spawned_enemies.is_empty():
			despawn_all_enemies()


func _restore_saved_enemies() -> void:
	if not enemy_scene:
		return
		
	# Loop through up to your max cap to check if data entries exist in the GameManager dictionary
	for i in range(1, max_enemies + 1):
		var check_id = "night_enemy_%s_%d" % [get_tree().current_scene.name, i]
		
		# If this specific slot has a saved position, it means they are alive in file storage!
		if GameManager.has_data_value(check_id, "pos"):
			# Set the counter to match the highest index found so far
			unique_id_counter = i
			_instantiate_enemy_at_pos(check_id, Vector2.ZERO, true)


func _on_spawn_timer_timeout() -> void:
	if spawned_enemies.size() >= max_enemies:
		spawn_timer.stop()
		return
		
	spawn_single_enemy()


func spawn_single_enemy() -> void:
	if not enemy_scene or not player:
		return
		
	var spawn_pos = get_valid_tilemap_position()
	if spawn_pos == Vector2.ZERO:
		return # Try again next interval tick
		
	unique_id_counter += 1
	var spawn_id = "night_enemy_%s_%d" % [get_tree().current_scene.name, unique_id_counter]
	
	_instantiate_enemy_at_pos(spawn_id, spawn_pos, false)


# Helper function to smoothly handle the instantiation boilerplate
func _instantiate_enemy_at_pos(spawn_id: String, spawn_pos: Vector2, use_saved_pos: bool) -> void:
	var enemy_instance = enemy_scene.instantiate() as CharacterBody2D
	enemy_instance.instance_id = spawn_id
	
	var health_comp = enemy_instance.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.instance_id = spawn_id
		
	if use_saved_pos:
		# Fallback just in case, but its actual location will be overwritten by its own _enter_tree()
		enemy_instance.global_position = GameManager.get_data_value(spawn_id, "pos")
	else:
		enemy_instance.global_position = spawn_pos
	
	enemy_instance.tree_exited.connect(func():
		spawned_enemies.erase(spawn_id)
		if is_inside_tree() and GameManager.phase == GameManager.PHASE.NIGHT and spawn_timer.is_stopped():
			spawn_timer.start()
	)
	
	spawned_enemies[spawn_id] = enemy_instance
	add_child(enemy_instance)


func despawn_all_enemies() -> void:
	for spawn_id in spawned_enemies.keys():
		var enemy = spawned_enemies[spawn_id]
		if is_instance_valid(enemy):
			enemy.queue_free() 
	spawned_enemies.clear()


func get_valid_tilemap_position() -> Vector2:
	for attempt in range(10):
		var target_pos = get_outside_viewport_position()
		if not tilemap_layer:
			return target_pos
			
		var tile_coord = tilemap_layer.local_to_map(tilemap_layer.to_local(target_pos))
		var tile_data = tilemap_layer.get_cell_tile_data(tile_coord)
		if tile_data != null:
			#print(target_pos)
			return target_pos
			
	return Vector2.ZERO


func get_outside_viewport_position() -> Vector2:
	var camera = get_viewport().get_camera_2d()
	var viewport_size = get_viewport_rect().size
	var visible_size = viewport_size / camera.zoom
	var min_distance = max(visible_size.x, visible_size.y) / 2.0
	var max_distance = min_distance + spawn_margin
	var random_distance = randf_range(min_distance, max_distance)
	var random_angle = randf_range(0.0, 2.0 * PI)
	var direction = Vector2.RIGHT.rotated(random_angle)
	return player.global_position + (direction * random_distance)
