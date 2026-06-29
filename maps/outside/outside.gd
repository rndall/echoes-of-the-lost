extends Node2D

@export var anting_anting_scene: PackedScene = preload("res://inventory/scenes/pickup_items/anting_anting.tscn")

const MIN_DIST_FROM_OBSTACLES = 48.0
const RAYCAST_LENGTH = 100.0  # How far to raycast downward
@onready var ground_layer: TileMapLayer = $Layers/Ground
@onready var soil_layer: TileMapLayer = $Layers/Soil
@onready var objects_node: Node2D = $Objects
@onready var trees_node: Node2D = $Trees
@onready var player_spawn: Marker2D = $Spawns/DefaultStartPoint
@onready var item_drop_manager: ItemDropManager = $item_drop_manager

func _ready() -> void:
	if GameManager.anting_anting_collected:
		print("[Spawn] Anting-anting already collected. Skipping spawn.")
		return
		
	if GameManager.anting_anting_saved_pos != Vector2.ZERO:
		_instantiate_item(GameManager.anting_anting_saved_pos)
		print("[Spawn] Restored anting_anting at saved pos: ", GameManager.anting_anting_saved_pos)
	else:
		_spawn_anting_anting()
	
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		_connect_inventory_signals(player.inv)
	else:
		push_error("[Outside] Player not found — inventory drop signal not connected")


func _spawn_anting_anting() -> void:
	var valid_cells = soil_layer.get_used_cells() + ground_layer.get_used_cells()
	if valid_cells.is_empty():
		push_warning("No valid cells found!")
		return

	var obstacle_positions: Array[Vector2] = []
	for child in objects_node.get_children():
		obstacle_positions.append(child.global_position)
	for child in trees_node.get_children():
		obstacle_positions.append(child.global_position)
	obstacle_positions.append(player_spawn.position)

	var filtered_cells: Array = []
	for cell in valid_cells:
		var world_pos = soil_layer.map_to_local(cell)
		if _is_clear(world_pos, obstacle_positions) and _is_on_ground(world_pos):
			filtered_cells.append(world_pos)

	if filtered_cells.is_empty():
		push_warning("No valid spawn positions after filtering!")
		return

	var spawn_pos: Vector2 = filtered_cells[randi() % filtered_cells.size()]

	GameManager.anting_anting_saved_pos = spawn_pos
	
	_instantiate_item(spawn_pos)
	print("[Spawn] First time setup. Spawned and saved at: ", spawn_pos)
	print("[Spawn] Total valid cells: ", filtered_cells.size())


func _instantiate_item(pos: Vector2) -> void:
	var item = anting_anting_scene.instantiate()
	item.position = pos
	objects_node.add_child(item)


func _is_clear(pos: Vector2, obstacles: Array[Vector2]) -> bool:
	for obs_pos in obstacles:
		if pos.distance_to(obs_pos) < MIN_DIST_FROM_OBSTACLES:
			return false
	return true


func _is_on_ground(pos: Vector2) -> bool:
	# Use a raycast query to check if there's ground below this position
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(pos, pos + Vector2.DOWN * RAYCAST_LENGTH)
	
	# Optional: set collision mask to only check certain layers (adjust if needed)
	# query.collision_mask = 1  # e.g., layer 1 for ground colliders
	
	var result = space_state.intersect_ray(query)
	
	# If the raycast hits something below, it's valid ground
	return result != null


func _on_axe_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
	
func _connect_inventory_signals(player_inventory: Inventory) -> void:
	player_inventory.item_dropped.connect(_on_item_dropped)
	var weapon_inv: Inventory = load("res://inventory/resources/weapon_inv.tres")
	weapon_inv.item_dropped.connect(_on_item_dropped)

func _on_item_dropped(item: InvItem, amount: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	print(player.global_position)
	var offset = Vector2(randf_range(-32, 32), randf_range(-32, 32)).normalized() * randf_range(24, 40)
	item_drop_manager.spawn_item_drop(item, amount, player.global_position + offset)
