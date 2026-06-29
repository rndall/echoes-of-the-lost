extends Node

class_name ItemDropManager

func spawn_item_drop(item: InvItem, amount: int, position: Vector2) -> void:
	var packed = ItemSceneRegistry.get_scene(item)
	if packed == null:
		push_error("No pickup scene registered for item: ", item.name)
		return

	var drop = packed.instantiate()

	if drop.has_method("setup"):
		drop.setup(item, amount)

	drop.global_position = position
	get_tree().current_scene.add_child(drop)
