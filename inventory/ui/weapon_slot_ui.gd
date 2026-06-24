extends InventorySlotUI

class_name WeaponSlotUI


# Weapon slot UI: only accepts WEAPON items, enforces max amount 1
# Inherits drag/drop behavior from InventorySlotUI with these overrides:
# - Rejects non-weapons in update()
# - Enforces amount = 1
# - Doesn't show amount label

func update(slot: InvSlot) -> void:
	# Safety: clear invalid items (non-weapons)
	if slot and slot.item and slot.item.item_type != InvItem.ItemType.WEAPON:
		slot.clear()
	
	# Safety: enforce max amount = 1 (redundant with max_stack, but defensive)
	if slot and slot.item and slot.amount > 1:
		slot.amount = 1
	
	# Null check: wait for _ready() to initialize visuals
	if item_visual == null or amount_text == null:
		return
	
	item_visual.visible = false
	amount_text.visible = false
	
	
	if slot and slot.item:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		GameManager.player_weapon = slot.item
		Events.player_weapon_equipped.emit(slot.item)
	else:
		GameManager.player_weapon = null
		# Never show amount for weapon slot (always 1)
