extends Node

enum PHASE {NIGHT, DAY}

const MAX_PLAYER_HEALTH: float = 10

var data: Dictionary

var player_health: float = 10

var anting_anting_saved_pos: Vector2
var anting_anting_collected: bool = false

var player_weapon: WeaponItem
var phase: PHASE
var map: Events.Map


func _generated_entry_name(node_path_identifier: String) -> String:
	return str(get_tree().current_scene.get_path(), "/", node_path_identifier)


func has_data_entry(node_path_identifier: String) -> bool:
	return data.has(_generated_entry_name(node_path_identifier))


func has_data_value(node_path_identifier: String, value_name: String) -> bool:
	if not has_data_entry(node_path_identifier):
		return false
	return get_data_entry(node_path_identifier).has(value_name)


func get_data_entry(node_path_identifier: String) -> Dictionary:
	if not has_data_entry(node_path_identifier):
		return {}
	return data[_generated_entry_name(node_path_identifier)]


func get_data_value(node_path_identifier: String, value_name: String):
	if not has_data_value(node_path_identifier, value_name):
		return null
	return get_data_entry(node_path_identifier)[value_name]


func store_data_entry(node_path_identifier: String, value: Dictionary) -> void:
	data[_generated_entry_name(node_path_identifier)] = value


func store_data_value(node_path_identifier: String, value_name: String, value) -> void:
	if has_data_entry(node_path_identifier):
		get_data_entry(node_path_identifier)[value_name] = value
	else:
		store_data_entry(node_path_identifier, { value_name: value })


func remove_data_entry(node_path_identifier: String) -> void:
	if not has_data_entry(node_path_identifier):
		return
	data.erase(_generated_entry_name(node_path_identifier))


func remove_data_value(node_path_identifier: String, value_name: String) -> void:
	if not has_data_value(node_path_identifier, value_name):
		return
	get_data_entry(node_path_identifier).erase(value_name)
	if get_data_entry(node_path_identifier).size() == 0:
		remove_data_entry(node_path_identifier)


func clear_all_data() -> void:
	data.clear()
