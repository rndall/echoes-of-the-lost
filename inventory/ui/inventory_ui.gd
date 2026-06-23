extends Control

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var inv_slots: Array = $NinePatchRect/inv_slots.get_children()
@onready var hotbar_slots: Array = $NinePatchRect/hotbar_slots.get_children()

var slots: Array = []

func _ready() -> void:
	# hotbar_slots map to indices 0-5, inv_slots to 6-17
	slots = hotbar_slots + inv_slots

	for i in range(mini(player_inv.slots.size(), slots.size())):
		if slots[i] is InventorySlotUI:
			slots[i].setup(i, player_inv)

	player_inv.update.connect(_update_slots)
	player_inv.item_dropped.connect(_on_item_dropped)
	_update_slots()

func _update_slots() -> void:
	for i in range(mini(player_inv.slots.size(), slots.size())):
		slots[i].update(player_inv.slots[i])

func _on_item_dropped(item: InvItem, amount: int) -> void:
	pass
	#print("Item dropped: ", item.name, " x", amount)

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and event.keycode == KEY_Q):
		return

	# Find whichever slot the mouse is currently over
	var hovered = SlotRegistry.find_slot_at(get_global_mouse_position())
	if hovered == null or hovered.inventory != player_inv:
		return

	var index = hovered.slot_index
	if Input.is_action_pressed("ui_shift"):
		var slot = player_inv.get_slot_by_index(index)
		if slot:
			player_inv.drop_item(index, slot.amount)
	else:
		player_inv.drop_item(index, 1)

# ── Public helpers ─────────────────────────────────────────────────────────────

func get_inventory() -> Inventory:
	return player_inv

func add_item_to_inventory(item: InvItem, amount: int = 1) -> bool:
	var before = player_inv.count_item(item.id)
	player_inv.insert(item, amount)
	return player_inv.count_item(item.id) > before

func remove_item_from_inventory(item_id: String, amount: int = 1) -> bool:
	var item = _find_item_resource(item_id)
	if item:
		player_inv.remove(item, amount)
		return true
	return false

func move_item_between_slots(from_index: int, to_index: int) -> bool:
	return player_inv.move_slot(from_index, to_index)

func swap_items_in_slots(index_a: int, index_b: int) -> bool:
	return player_inv.swap_slot(index_a, index_b)

func _find_item_resource(item_id: String) -> InvItem:
	var path = "res://inventory/resources/inventory_items/" + item_id + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	return null
