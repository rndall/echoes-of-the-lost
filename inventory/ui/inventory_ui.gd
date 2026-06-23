extends Control

@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")
@onready var weapon_inv: Inventory = preload("res://inventory/resources/weapon_inv.tres")
@onready var inv_slots: Array = $NinePatchRect/inv_slots.get_children()
@onready var hotbar_slots: Array = $NinePatchRect/hotbar_slots.get_children()
@onready var weapon_slot_ui = $NinePatchRect/weapon_slot_ui  # Reference to weapon slot

var slots: Array = []

func _ready() -> void:
	# hotbar_slots map to indices 0-5 (player_inv)
	# inv_slots map to indices 6-17 (player_inv)
	# weapon_slot_ui is a single slot for weapon_inv
	slots = hotbar_slots + inv_slots
	
	# Setup regular inventory slots (hotbar + inventory)
	for i in range(mini(player_inv.slots.size(), slots.size())):
		if slots[i] is InventorySlotUI:
			slots[i].setup(i, player_inv)

	# Setup weapon slot
	if weapon_slot_ui and weapon_slot_ui is WeaponSlotUI:
		weapon_slot_ui.setup(0, weapon_inv)  # Index 0 for the single weapon slot

	# Connect update signals
	player_inv.update.connect(_update_slots)
	weapon_inv.update.connect(_update_weapon_slot)
	player_inv.item_dropped.connect(_on_item_dropped)
	weapon_inv.item_dropped.connect(_on_item_dropped)
	
	_update_slots()
	_update_weapon_slot()

func _update_slots() -> void:
	"""Update regular inventory and hotbar slots"""
	for i in range(mini(player_inv.slots.size(), slots.size())):
		slots[i].update(player_inv.slots[i])

func _update_weapon_slot() -> void:
	"""Update weapon slot"""
	if weapon_slot_ui and weapon_slot_ui is WeaponSlotUI:
		weapon_slot_ui.update(weapon_inv.get_slot_by_index(0))

func _on_item_dropped(item: InvItem, amount: int) -> void:
	pass
	#print("Item dropped: ", item.name, " x", amount)

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and event.keycode == KEY_Q):
		return

	# Find whichever slot the mouse is currently over
	var hovered = SlotRegistry.find_slot_at(get_global_mouse_position())
	if hovered == null:
		return

	# Handle drops for both inventories
	if hovered.inventory == player_inv:
		var index = hovered.slot_index
		if Input.is_action_pressed("ui_shift"):
			var slot = player_inv.get_slot_by_index(index)
			if slot:
				player_inv.drop_item(index, slot.amount)
		else:
			player_inv.drop_item(index, 1)
	elif hovered.inventory == weapon_inv:
		var index = hovered.slot_index
		var slot = weapon_inv.get_slot_by_index(index)
		if slot:
			weapon_inv.drop_item(index, slot.amount)

# ── Public helpers ─────────────────────────────────────────────────────────────

func get_inventory() -> Inventory:
	return player_inv

func get_weapon_inventory() -> Inventory:
	return weapon_inv

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

func equip_weapon(item: InvItem) -> bool:
	"""Try to equip a weapon. Returns true if successful"""
	if item.item_type != InvItem.ItemType.WEAPON:
		return false
	
	var slot = weapon_inv.get_slot_by_index(0)
	if slot:
		slot.item = item
		slot.amount = 1
		weapon_inv.update.emit()
		return true
	return false

func get_equipped_weapon() -> InvItem:
	"""Get the currently equipped weapon, or null if none"""
	var slot = weapon_inv.get_slot_by_index(0)
	if slot and slot.item:
		return slot.item
	return null

func move_item_between_slots(from_index: int, to_index: int) -> bool:
	return player_inv.move_slot(from_index, to_index)

func swap_items_in_slots(index_a: int, index_b: int) -> bool:
	return player_inv.swap_slot(index_a, index_b)

func _find_item_resource(item_id: String) -> InvItem:
	var path = "res://inventory/resources/inventory_items/" + item_id + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	return null
