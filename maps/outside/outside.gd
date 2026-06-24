extends Node2D

@export var anting_anting_scene: PackedScene = preload("res://inventory/scenes/pickup_items/anting_anting.tscn")

const MIN_DIST_FROM_OBSTACLES = 48.0

@onready var ground_layer: TileMapLayer = $Layers/Ground
@onready var soil_layer: TileMapLayer = $Layers/Soil
@onready var objects_node: Node2D = $Objects
@onready var trees_node: Node2D = $Trees

func _ready() -> void:
	_spawn_anting_anting()

func _spawn_anting_anting() -> void:
	var random_layer = [ground_layer, soil_layer].pick_random()
	var valid_cells = random_layer.get_used_cells()
	if valid_cells.is_empty():
		push_warning("No soil cells found!")
		return

	var obstacle_positions: Array[Vector2] = []
	for child in objects_node.get_children():
		obstacle_positions.append(child.global_position)
	for child in trees_node.get_children():
		obstacle_positions.append(child.global_position)

	var filtered_cells: Array = []
	for cell in valid_cells:
		var world_pos = soil_layer.map_to_local(cell)
		if _is_clear(world_pos, obstacle_positions):
			filtered_cells.append(world_pos)

	if filtered_cells.is_empty():
		push_warning("No valid spawn positions after filtering!")
		return

	var spawn_pos: Vector2 = filtered_cells[randi() % filtered_cells.size()]

	var item = anting_anting_scene.instantiate()
	item.position = spawn_pos
	objects_node.add_child(item)

	print("[Spawn] anting_anting spawned at: ", spawn_pos)
	print("[Spawn] Total valid cells: ", filtered_cells.size())

func _is_clear(pos: Vector2, obstacles: Array[Vector2]) -> bool:
	for obs_pos in obstacles:
		if pos.distance_to(obs_pos) < MIN_DIST_FROM_OBSTACLES:
			return false
	return true
