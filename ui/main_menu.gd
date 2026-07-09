extends Control

@export var hud: CanvasLayer


func _on_play_button_pressed() -> void:
	# Get map from save if implemented
	var map = Events.Map.OUTSIDE
	get_tree().current_scene.switch_map(map)
	await Events.scene_load_finished
	hud.show()
	queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
