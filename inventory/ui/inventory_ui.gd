extends Control

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var inv_slots: Array = $NinePatchRect/inv_slots.get_children()
@onready var hotbar_slots: Array = $NinePatchRect/hotbar_slots.get_children()

var slots = []

func _ready() -> void:
	player_inv.update.connect(update_slots)
	update_slots()
	
func update_slots():
	slots = hotbar_slots + inv_slots
	
	for i in range(min(player_inv.slots.size(), slots.size())):
			slots[i].update(player_inv.slots[i])
