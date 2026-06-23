extends Node
 
# Autoload this as "SlotRegistry".
# Every InventorySlotUI registers itself here so that drag-and-drop works
# across separate UI scenes (inventory menu + hotbar HUD).
 
var _slots: Array[InventorySlotUI] = []
 
func register(slot: InventorySlotUI) -> void:
	if slot not in _slots:
		_slots.append(slot)
 
func unregister(slot: InventorySlotUI) -> void:
	_slots.erase(slot)
 
func get_all() -> Array[InventorySlotUI]:
	return _slots
 
func find_slot_at(global_pos: Vector2, exclude: InventorySlotUI = null) -> InventorySlotUI:
	for slot in _slots:
		if slot == exclude:
			continue
		if slot.get_global_rect().has_point(global_pos):
			return slot
	return null
 
