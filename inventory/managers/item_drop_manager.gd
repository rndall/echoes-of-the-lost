extends Node
 
class_name ItemDropManager
 
@export var item_drop_scene_path: String = "res://inventory/scenes/item_drop.tscn"
 
func spawn_item_drop(item: InvItem, amount: int, position: Vector2) -> void:
	"""Spawn item drop in world"""
	if not ResourceLoader.exists(item_drop_scene_path):
		push_error("Item drop scene not found at: ", item_drop_scene_path)
		return
	
	var drop_scene = load(item_drop_scene_path)
	var drop = drop_scene.instantiate()
	
	# Try to call setup if it exists
	if drop and drop.has_method("setup"):
		drop.setup(item, amount)
	
	drop.global_position = position
	get_parent().add_child(drop)
