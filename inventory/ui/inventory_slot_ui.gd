extends Panel

class_name InventorySlotUI

var item_visual: Sprite2D
var amount_text: Label

var slot_index: int = -1
var inventory: Inventory

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var animated_sprite: AnimatedSprite2D = null
static var currently_selected: InventorySlotUI = null

func _ready() -> void:
	animated_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	# inventory_slot_ui.tscn names the sprite "item_display";
	# hotbar_slot_ui.tscn names it "Sprite2D".
	var panel = $CenterContainer/Panel
	item_visual = panel.get_node_or_null("item_display") as Sprite2D
	if item_visual == null:
		item_visual = panel.get_node_or_null("Sprite2D") as Sprite2D
	amount_text = panel.get_node("Label") as Label

	SlotRegistry.register(self)
	tree_exiting.connect(func(): SlotRegistry.unregister(self))

	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	
	if animated_sprite:
		animated_sprite.play("default")

func setup(index: int, inv: Inventory) -> void:
	slot_index = index
	inventory = inv

func update(slot: InvSlot) -> void:
	item_visual.visible = false
	amount_text.visible = false

	if slot and slot.item:
		item_visual.visible = true
		item_visual.texture = slot.item.texture

		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_select()

			var slot = inventory.get_slot_by_index(slot_index)
			if slot == null or slot.item == null:
				return
			
			is_dragging = true
			drag_offset = get_local_mouse_position()
			modulate = Color(1.2, 1.2, 1.2)
			
			DragGhost.start(slot.item.texture, get_global_mouse_position())
		else:
			if is_dragging:
				is_dragging = false
				modulate = Color.WHITE
				DragGhost.stop()
				_handle_drop()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var slot = inventory.get_slot_by_index(slot_index)
		if slot == null or slot.item == null:
			return
		_handle_right_click()

func _on_mouse_entered() -> void:
	if is_dragging:
		modulate = Color(1.3, 1.3, 1.3)

func _handle_drop() -> void:
	var target = SlotRegistry.find_slot_at(get_global_mouse_position(), self)
	if target == null:
		return
	
	# Validate if dropping to a weapon slot
	if target is WeaponSlotUI:
		var source_slot = inventory.get_slot_by_index(slot_index)
		if source_slot == null or source_slot.item == null:
			_deselect()
			return
			
		# Only WEAPON items can be dropped on weapon slots
		if source_slot.item.item_type != InvItem.ItemType.WEAPON:
			_deselect()
			return
	
	_perform_slot_action(target.slot_index, target.inventory)
	
	_deselect()
	target._select()

func _perform_slot_action(target_index: int, target_inventory: Inventory) -> void:
	if target_inventory == inventory and target_index == slot_index:
		return

	var source_slot = inventory.get_slot_by_index(slot_index)
	if source_slot == null or source_slot.item == null:
		return

	# Cross-inventory drag: move item to the target inventory's slot
	if target_inventory != inventory:
		_cross_inventory_move(target_index, target_inventory)
		return

	if Input.is_action_pressed("ui_shift"):
		inventory.swap_slot(slot_index, target_index)
		return

	if Input.is_action_pressed("ui_select"):
		_partial_move(target_index, source_slot.amount / 2)
		return

	inventory.move_slot(slot_index, target_index)

func _cross_inventory_move(target_index: int, target_inventory: Inventory) -> void:
	var source_slot = inventory.get_slot_by_index(slot_index)
	var target_slot = target_inventory.get_slot_by_index(target_index)

	if source_slot == null or source_slot.item == null:
		return

	# Check if target is a weapon inventory (single slot = weapon inventory)
	var is_weapon_target = target_inventory.slots.size() == 1
	
	if is_weapon_target and source_slot.item.item_type != InvItem.ItemType.WEAPON:
		# Reject non-weapon items to weapon inventory
		return

	if target_slot.item == null:
		target_slot.item = source_slot.item
		target_slot.amount = source_slot.amount
		source_slot.clear()
	elif target_slot.item.id == source_slot.item.id:
		var space = source_slot.item.max_stack - target_slot.amount
		var transfer = mini(space, source_slot.amount)
		target_slot.amount += transfer
		source_slot.amount -= transfer
		if source_slot.amount <= 0:
			source_slot.clear()
	else:
		# Swap across inventories
		var tmp_item = target_slot.item
		var tmp_amount = target_slot.amount
		target_slot.item = source_slot.item
		target_slot.amount = source_slot.amount
		source_slot.item = tmp_item
		source_slot.amount = tmp_amount

	inventory.update.emit()
	target_inventory.update.emit()

func _partial_move(target_index: int, amount: int) -> void:
	if amount <= 0:
		return

	var source_slot = inventory.get_slot_by_index(slot_index)
	var target_slot = inventory.get_slot_by_index(target_index)

	if source_slot == null or source_slot.item == null:
		return

	if target_slot.item == null:
		target_slot.item = source_slot.item
		target_slot.amount = amount
		source_slot.amount -= amount
		if source_slot.amount <= 0:
			source_slot.clear()
	elif target_slot.item.id == source_slot.item.id:
		var space = source_slot.item.max_stack - target_slot.amount
		var transfer = mini(space, amount)
		target_slot.amount += transfer
		source_slot.amount -= transfer
		if source_slot.amount <= 0:
			source_slot.clear()
	else:
		inventory.swap_slot(slot_index, target_index)

	inventory.update.emit()

func _handle_right_click() -> void:
	var slot = inventory.get_slot_by_index(slot_index)
	if slot == null or slot.item == null:
		return
	inventory.drop_item(slot_index, 1)

func split_stack() -> void:
	var slot = inventory.get_slot_by_index(slot_index)
	if slot == null or slot.item == null or slot.amount <= 1:
		return
	slot.amount -= slot.amount / 2
	inventory.update.emit()
	
func _deselect() -> void:
	if animated_sprite:
		animated_sprite.play("default")

func _select() -> void:
	if currently_selected and currently_selected != self:
		currently_selected._deselect()
	currently_selected = self
	if animated_sprite:
		animated_sprite.play("selected")
