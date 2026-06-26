extends Area2D

@export var item: InvItem = preload("res://inventory/resources/inventory_items/apple.tres")

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	player = body
	player.collect(item)
	var tree_save_path := str(get_meta("tree_save_path", ""))
	var drop_id := str(get_meta("drop_id", ""))
	if tree_save_path != "" and drop_id != "":
		var tree_data = GameManager.get_data_entry(tree_save_path)
		if tree_data.has("drops"):
			var remaining_drops: Array = []
			for drop in tree_data["drops"]:
				if drop.has("id") and drop["id"] == drop_id:
					continue
				remaining_drops.append(drop)

			if remaining_drops.size() > 0:
				GameManager.store_data_value(tree_save_path, "drops", remaining_drops)
			else:
				GameManager.remove_data_value(tree_save_path, "drops")
	queue_free()
