extends Control

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var inv_slots: Array = $NinePatchRect/inv_slots.get_children()
@onready var hotbar_slots: Array = $NinePatchRect/hotbar_slots.get_children()

var slots = []
var currently_dragging: InventorySlotUI = null

func _ready() -> void:
	player_inv.update.connect(update_slots)
	player_inv.item_dropped.connect(_on_item_dropped)
	
	# Initialize all slots
	slots = hotbar_slots + inv_slots
	for i in range(min(player_inv.slots.size(), slots.size())):
		# Cast to InventorySlotUI if using the enhanced version
		if slots[i] is InventorySlotUI:
			slots[i].setup(i, player_inv, self)
	
	update_slots()

func update_slots() -> void:
	"""Update all slot visuals"""
	slots = hotbar_slots + inv_slots
	
	for i in range(min(player_inv.slots.size(), slots.size())):
		slots[i].update(player_inv.slots[i])

func _on_item_dropped(item: InvItem, amount: int) -> void:
	"""Handle item drop signal - spawn item in world"""
	# TODO: Spawn item drop in world at player position
	# Example:
	# var drop_scene = preload("res://inventory/scenes/item_drop.tscn")
	# var drop = drop_scene.instantiate()
	# drop.setup(item, amount)
	# get_tree().current_scene.add_child(drop)
	print("Item dropped: ", item.name, " x", amount)

func _input(event: InputEvent) -> void:
	"""Handle inventory shortcuts"""
	
	# Press 'Q' to drop selected/hovered item
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		if currently_dragging:
			var index = slots.find(currently_dragging)
			if index != -1:
				player_inv.drop_item(index, 1)
	
	# Press 'Shift+Q' to drop entire stack
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		if Input.is_action_pressed("ui_shift"):
			if currently_dragging:
				var index = slots.find(currently_dragging)
				if index != -1:
					var slot = player_inv.get_slot_by_index(index)
					if slot:
						player_inv.drop_item(index, slot.amount)

# Optional: Helper methods for inventory management

func add_item_to_inventory(item: InvItem, amount: int = 1) -> bool:
	"""Public method to add items to player inventory"""
	var initial_count = player_inv.count_item(item.id)
	player_inv.insert(item, amount)
	var final_count = player_inv.count_item(item.id)
	return final_count > initial_count

func remove_item_from_inventory(item_id: String, amount: int = 1) -> bool:
	"""Public method to remove items from player inventory"""
	var item = _find_item_resource(item_id)
	if item:
		player_inv.remove(item, amount)
		return true
	return false

func move_item_between_slots(from_index: int, to_index: int) -> bool:
	"""Public method to move items programmatically"""
	return player_inv.move_slot(from_index, to_index)

func swap_items_in_slots(index_a: int, index_b: int) -> bool:
	"""Public method to swap items programmatically"""
	return player_inv.swap_slot(index_a, index_b)

func get_inventory() -> Inventory:
	"""Get reference to player inventory"""
	return player_inv

func _find_item_resource(item_id: String) -> InvItem:
	"""Find item resource by ID"""
	# Load from your items directory
	var path = "res://inventory/resources/inventory_items/"
	# This is a simple lookup - adjust based on your naming convention
	if ResourceLoader.exists(path + item_id + ".tres"):
		return load(path + item_id + ".tres")
	return null
