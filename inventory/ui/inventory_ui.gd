extends Control

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready() -> void:
	player_inv.update.connect(update_slots)
	update_slots()
	
func update_slots():
	for i in range(min(player_inv.slots.size(), slots.size())):
		slots[i].update(player_inv.slots[i])
