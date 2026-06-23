extends Control

class_name HotbarUI

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var hotbar_slots: Array = $hotbar_items/GridContainer.get_children()

const HOTBAR_SLOT_COUNT = 6

func _ready() -> void:
	# Connect to inventory updates
	player_inv.update.connect(update_hotbar)
	
	# Initialize all hotbar slots
	for i in range(min(HOTBAR_SLOT_COUNT, hotbar_slots.size())):
		var slot_ui = hotbar_slots[i]
		
		# Call update() on each slot if it has the method
		if slot_ui.has_method("update"):
			var slot = player_inv.get_slot_by_index(i)
			if slot:
				slot_ui.update(slot)
	
	# Wait for InventoryUI to finish loading
	await get_tree().process_frame
	
	# Register hotbar slots with InventoryUI
	var inventory_ui = get_tree().root.find_child("InventoryUI", true, false)
	if inventory_ui and inventory_ui.has_meta("slots_initialized"):
		# InventoryUI already initialized, add hotbar slots to it
		for i in range(min(HOTBAR_SLOT_COUNT, hotbar_slots.size())):
			inventory_ui.slots[i] = hotbar_slots[i]
		print("HotbarUI: Registered ", HOTBAR_SLOT_COUNT, " hotbar slots with InventoryUI")
	else:
		print("HotbarUI: Could not find InventoryUI or it wasn't ready")
	
	update_hotbar()

func update_hotbar() -> void:
	"""Update all hotbar slot visuals from inventory"""
	for i in range(min(HOTBAR_SLOT_COUNT, hotbar_slots.size())):
		var slot_ui = hotbar_slots[i]
		var inv_slot = player_inv.get_slot_by_index(i)
		
		if slot_ui and slot_ui.has_method("update") and inv_slot:
			slot_ui.update(inv_slot)

func get_hotbar_slots() -> Array:
	"""Return array of hotbar slot UI nodes for InventoryUI to find"""
	return hotbar_slots

func get_hotbar_item(slot_index: int) -> InvItem:
	"""Get item in hotbar slot"""
	if slot_index >= 0 and slot_index < HOTBAR_SLOT_COUNT:
		var slot = player_inv.get_slot_by_index(slot_index)
		if slot:
			return slot.item
	return null
