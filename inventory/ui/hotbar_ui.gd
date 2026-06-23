extends Control

# Attach to hotbar_ui scene root.
# Slots 0-5 of player_inv are the designated hotbar slots — the same
# indices used by the in-menu hotbar_slots GridContainer.

const HOTBAR_SLOT_COUNT = 6

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var slot_nodes: Array = $hotbar_items/GridContainer.get_children()

func _ready() -> void:
	for i in range(mini(HOTBAR_SLOT_COUNT, slot_nodes.size())):
		var slot_ui: InventorySlotUI = slot_nodes[i]
		slot_ui.setup(i, player_inv)

	player_inv.update.connect(_update_slots)
	_update_slots()

func _update_slots() -> void:
	for i in range(mini(HOTBAR_SLOT_COUNT, slot_nodes.size())):
		slot_nodes[i].update(player_inv.get_slot_by_index(i))
