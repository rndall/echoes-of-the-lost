extends Node

@export var items: Array[InvItem] = []


func get_all_items() -> Array[InvItem]:
	return items


func get_item_by_id(id: String) -> InvItem:
	for item in items:
		if item.id == id:
			return item
	return null
