extends Control

class_name InventoryUI

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var inv_slots: Array = $NinePatchRect/inv_slots.get_children()

const HOTBAR_SLOT_COUNT = 6  # Hotbar uses slots 0-5, inventory uses 6+

var slots = []
var currently_dragging: InventorySlotUI = null

func _ready() -> void:
	player_inv.update.connect(update_slots)
	player_inv.item_dropped.connect(_on_item_dropped)
	
	# Initialize slots array with empty placeholders for hotbar (will be filled by HotbarUI)
	slots = []
	for i in range(HOTBAR_SLOT_COUNT):
		slots.append(null)  # Placeholder for hotbar slots 0-5
	
	# Add inventory slots at positions 6-17
	for i in range(inv_slots.size()):
		var actual_slot_index = i + HOTBAR_SLOT_COUNT  # Offset by hotbar count
		slots.append(inv_slots[i])
		
		# Cast to InventorySlotUI if using the enhanced version
		if inv_slots[i] is InventorySlotUI:
			inv_slots[i].setup(actual_slot_index, player_inv, self)
	
	update_slots()

func update_slots() -> void:
	"""Update all inventory slot visuals"""
	for i in range(slots.size()):
		# Skip placeholder positions for hotbar slots
		if slots[i] == null:
			continue
		
		var inv_slot = player_inv.get_slot_by_index(i)  # Use direct index, hotbar handles 0-5
		
		if inv_slot and slots[i].has_method("update"):
			slots[i].update(inv_slot)

func _on_item_dropped(item: InvItem, amount: int) -> void:
	"""Handle item drop signal - spawn item in world"""
	print("Item dropped: ", item.name, " x", amount)
	# TODO: Spawn item drop in world at player position

func _input(event: InputEvent) -> void:
	"""Handle inventory shortcuts"""
	
	# Press 'Q' to drop selected/hovered item
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		if currently_dragging:
			var slot_ui = currently_dragging
			# Find index in our slots array (already matches inventory slot indices)
			var idx = slots.find(slot_ui)
			if idx != -1:
				player_inv.drop_item(idx, 1)
	
	# Press 'Shift+Q' to drop entire stack
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		if Input.is_action_pressed("ui_shift"):
			if currently_dragging:
				var slot_ui = currently_dragging
				var idx = slots.find(slot_ui)
				if idx != -1:
					var slot = player_inv.get_slot_by_index(idx)
					if slot:
						player_inv.drop_item(idx, slot.amount)

# Helper methods for inventory management

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
	var path = "res://inventory/resources/inventory_items/"
	if ResourceLoader.exists(path + item_id + ".tres"):
		return load(path + item_id + ".tres")
	return null
