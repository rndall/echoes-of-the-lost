extends Panel

class_name InventorySlotUI

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

var slot_index: int = -1
var inventory: Inventory
var inv_ui: Control  # Reference to parent inventory UI

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)

func setup(index: int, inv: Inventory, parent_ui: Control) -> void:
	"""Setup slot with inventory reference and index"""
	slot_index = index
	inventory = inv
	inv_ui = parent_ui

func update(slot: InvSlot) -> void:
	"""Update visual representation of slot"""
	item_visual.visible = false
	amount_text.visible = false
	
	if slot.item:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)

func _on_gui_input(event: InputEvent) -> void:
	var slot = inventory.get_slot_by_index(slot_index)
	
	if slot == null or slot.item == null:
		return
	
	# Left click - drag to move/swap
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = get_local_mouse_position()
			modulate = Color(1.2, 1.2, 1.2)  # Highlight when dragging
		else:
			if is_dragging:
				is_dragging = false
				modulate = Color.WHITE
				_handle_drop_on_slot()
	
	# Right click - quick actions
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_handle_right_click()

func _on_mouse_entered() -> void:
	"""Visual feedback on hover"""
	if is_dragging:
		modulate = Color(1.3, 1.3, 1.3)

func _handle_drop_on_slot() -> void:
	"""Handle dropping dragged item onto another slot"""
	var mouse_pos = get_global_mouse_position()
	var space_state = get_tree().root.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	var result = space_state.intersect_point(query, 1)
	
	# Alternative: Check if mouse is over another slot
	for slot_ui in inv_ui.slots:
		if slot_ui == self:
			continue
		
		var slot_rect = slot_ui.get_global_rect()
		if slot_rect.has_point(mouse_pos):
			var target_index = inv_ui.slots.find(slot_ui)
			_perform_slot_action(target_index)
			return

func _perform_slot_action(target_index: int) -> void:
	"""Perform move/swap/stack action based on item and modifiers"""
	if target_index == slot_index:
		return
	
	var source_slot = inventory.get_slot_by_index(slot_index)
	var target_slot = inventory.get_slot_by_index(target_index)
	
	if source_slot == null or source_slot.item == null:
		return
	
	# Shift+drag = swap slots
	if Input.is_action_pressed("ui_shift"):
		inventory.swap_slot(slot_index, target_index)
		return
	
	# Ctrl+drag = move only half
	if Input.is_action_pressed("ui_select"):
		_partial_move(target_index, source_slot.amount / 2)
		return
	
	# Default = smart move (stack if same item, swap if different)
	inventory.move_slot(slot_index, target_index)

func _partial_move(target_index: int, amount: int) -> void:
	"""Move partial amount to another slot"""
	if amount <= 0:
		return
	
	var source_slot = inventory.get_slot_by_index(slot_index)
	var target_slot = inventory.get_slot_by_index(target_index)
	
	if source_slot == null or source_slot.item == null:
		return
	
	# If target is empty, move partial amount
	if target_slot.item == null:
		target_slot.item = source_slot.item
		target_slot.amount = amount
		source_slot.amount -= amount
		
		if source_slot.amount <= 0:
			source_slot.clear()
	
	# If target has same item, stack
	elif target_slot.item.id == source_slot.item.id:
		var space = source_slot.item.max_stack - target_slot.amount
		var transfer = mini(space, amount)
		target_slot.amount += transfer
		source_slot.amount -= transfer
		
		if source_slot.amount <= 0:
			source_slot.clear()
	
	# If different item, swap
	else:
		inventory.swap_slot(slot_index, target_index)
	
	inventory.update.emit()

func _handle_right_click() -> void:
	"""Right click menu - drop item"""
	var slot = inventory.get_slot_by_index(slot_index)
	
	if slot == null or slot.item == null:
		return
	
	# Drop single item
	inventory.drop_item(slot_index, 1)

func split_stack() -> void:
	"""Split stack in half (use with custom UI)"""
	var slot = inventory.get_slot_by_index(slot_index)
	
	if slot == null or slot.item == null or slot.amount <= 1:
		return
	
	var half = slot.amount / 2
	slot.amount -= half
	
	# Create ghost item or return to hand
	inventory.update.emit()

func quick_move_to_hotbar() -> void:
	"""Move item to first available hotbar slot (if applicable)"""
	# Implement based on your hotbar setup
	pass
