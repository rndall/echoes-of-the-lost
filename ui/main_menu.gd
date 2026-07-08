extends Control

const MAPS = {
	"outside": "uid://c5g3ll83gblw0",
	"house": "uid://3s5rfvjydnns"
}


func _on_play_button_pressed() -> void:
	var map = MAPS["outside"]
	get_tree().current_scene.switch_map(map)
	await Events.scene_load_finished
	queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
