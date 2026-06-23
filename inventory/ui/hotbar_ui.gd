extends Control

# Attach this script to the hotbar_ui scene root.
# It mirrors inventory slots 0-5 (the designated hotbar range) and is
# hidden automatically when the inventory menu is open.

const HOTBAR_SLOT_COUNT = 6

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")

# Expects the GridContainer children to have HotbarSlotUI scripts attached.
@onready var slot_nodes: Array = $hotbar_items/GridContainer.get_children()

func _ready() -> void:
	player_inv.update.connect(_update_slots)
	_update_slots()

func _update_slots() -> void:
	"""Sync each HUD slot to its corresponding inventory slot (indices 0-5)"""
	for i in range(mini(HOTBAR_SLOT_COUNT, slot_nodes.size())):
		var inv_slot = player_inv.get_slot_by_index(i)
		if slot_nodes[i] is HotbarSlotUI:
			slot_nodes[i].update(inv_slot)
