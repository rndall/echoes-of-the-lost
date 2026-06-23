extends Resource

class_name Inventory

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	for slot in slots:
		if slot.item.id == item.id and slot.amount < item.max_stack:
			slot.amount += 1
			update.emit()
			return

	for slot in slots:
		if slot.item == null:
			slot.item = item
			slot.amount = 1
			update.emit()
			return

func remove(item: InvItem, amount: int = 1):
	for slot in slots:
		if slot.item == item:
			slot.amount -= amount

			if slot.amount <= 0:
				slot.item = null
				slot.amount = 0

			update.emit()
			return

func move_slot():
	pass

func swap_slot():
	pass
