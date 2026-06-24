extends InventorySlotUI

class_name ArtifactSlotUI

# Artifact slot UI: only accepts ARTIFACT items.
# Once an artifact is placed, the slot is permanently locked —
# the item cannot be dragged out, dropped (right-click / Q), or swapped.
# Clicking the slot still selects it (reserved for future item-info display).

## True once an artifact has been committed to this slot.
var is_locked: bool = false

func update(slot: InvSlot) -> void:
	# Safety: clear invalid items (non-artifacts) — should never happen in
	# normal play, but guards against editor mistakes.
	if slot and slot.item and slot.item.item_type != InvItem.ItemType.ARTIFACT:
		slot.clear()

	# Null-guard: _ready() may not have run yet on the first call.
	if item_visual == null or amount_text == null:
		return

	item_visual.visible = false
	amount_text.visible = false  # Artifacts are max_stack 1; label never needed.

	if slot and slot.item:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		# Lock permanently once an artifact is in the slot.
		is_locked = true

# ── Input overrides ───────────────────────────────────────────────────────────

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Always allow selection (for future item-info panel).
			_select()

			# Block dragging if locked or empty.
			if is_locked:
				return

			var slot = inventory.get_slot_by_index(slot_index)
			if slot == null or slot.item == null:
				return

			# Only allow dragging FROM this slot if it's not yet locked.
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

	# Right-click: fully blocked (no drop/remove).
	# We intentionally do nothing here.

# ── Drop target overrides ─────────────────────────────────────────────────────

func _handle_drop() -> void:
	# This slot is locked — can't drag anything out.
	if is_locked:
		return

	var target = SlotRegistry.find_slot_at(get_global_mouse_position(), self)
	if target == null:
		return

	# Only allow dropping onto another artifact slot (pre-lock).
	if target is not ArtifactSlotUI:
		_deselect()
		return

	_perform_slot_action(target.slot_index, target.inventory)
	_deselect()
	target._select()

# Override to validate incoming drops FROM other slot types.
# Called by the SOURCE slot's _perform_slot_action when it targets us.
func _accept_drop_from(source: InventorySlotUI) -> void:
	# Locked slots reject everything.
	if is_locked:
		return

	var source_slot = source.inventory.get_slot_by_index(source.slot_index)
	if source_slot == null or source_slot.item == null:
		return

	# Only ARTIFACT items are accepted.
	if source_slot.item.item_type != InvItem.ItemType.ARTIFACT:
		return

	_cross_inventory_move_from(source)

func _cross_inventory_move_from(source: InventorySlotUI) -> void:
	var source_slot = source.inventory.get_slot_by_index(source.slot_index)
	var target_slot = inventory.get_slot_by_index(slot_index)

	if source_slot == null or source_slot.item == null or target_slot == null:
		return

	if target_slot.item != null:
		# Slot already occupied — reject.
		return

	target_slot.item = source_slot.item
	target_slot.amount = source_slot.amount
	source_slot.clear()

	source.inventory.update.emit()
	inventory.update.emit()

# ── Block Q-drop from inventory_ui._input ────────────────────────────────────
# inventory_ui.gd checks hovered.inventory; artifact_inv is a separate
# resource so the Q-drop branch there won't match it. No extra override needed
# unless you later route artifact_inv through inventory_ui's _input handler.

# ── Block right-click drop ───────────────────────────────────────────────────
func _handle_right_click() -> void:
	# Intentionally empty — no dropping from artifact slots.
	pass
