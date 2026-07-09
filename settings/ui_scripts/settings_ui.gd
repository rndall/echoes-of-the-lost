extends Control

## Node paths for the three slot panels, matching settings_ui.tscn.
const PANEL_PATHS: Array[String] = [
	"NinePatchRect2/VBoxContainer/Panel",
	"NinePatchRect2/VBoxContainer/Panel2",
	"NinePatchRect2/VBoxContainer/Panel3",
]

var _slot_nodes: Array[Dictionary] = []


func _ready() -> void:
	for panel_path: String in PANEL_PATHS:
		_slot_nodes.append(_collect_slot_nodes(panel_path))

	for slot_index in _slot_nodes.size():
		var nodes: Dictionary = _slot_nodes[slot_index]
		nodes.save_button.pressed.connect(_on_save_pressed.bind(slot_index))
		nodes.load_button.pressed.connect(_on_load_pressed.bind(slot_index))

	_refresh_all_slots()


func _collect_slot_nodes(panel_path: String) -> Dictionary:
	var panel: Panel = get_node(panel_path)
	return {
		"slot_label": panel.get_node("save_slot") as Label,
		"time_label": panel.get_node("save_time") as Label,
		"save_button": panel.get_node("save_button") as TextureButton,
		"load_button": panel.get_node("load_button") as TextureButton,
	}


func _refresh_all_slots() -> void:
	for slot_index in _slot_nodes.size():
		_refresh_slot(slot_index)


func _refresh_slot(slot_index: int) -> void:
	var nodes: Dictionary = _slot_nodes[slot_index]
	var info: Dictionary = SaveManager.get_save_info(slot_index)

	nodes.slot_label.text = "SLOT %d" % (slot_index + 1)

	if info.is_empty():
		nodes.time_label.text = "Empty"
		nodes.load_button.disabled = true
		nodes.load_button.modulate.a = 0.5
	else:
		var day: int = info.get("day", 0)
		var time_string: String = info.get("time_string", "")
		nodes.time_label.text = (
			"Day %d %s" % [day, time_string] if time_string != "" else "Day %d" % day
		)
		nodes.load_button.disabled = false
		nodes.load_button.modulate.a = 1.0


func _on_save_pressed(slot_index: int) -> void:
	SaveManager.save_game(slot_index)
	_refresh_slot(slot_index)


func _on_load_pressed(slot_index: int) -> void:
	if not SaveManager.has_save(slot_index):
		return
	SaveManager.load_game(slot_index)
	# Closing the pause menu on a successful load is handled by menu_ui,
	# which listens for SaveManager.game_loaded — hiding this node directly
	# would only hide the settings panel's own content, not the menu itself,
	# and would leave it permanently hidden the next time this tab is opened.
