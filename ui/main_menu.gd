extends Control

@export var hud: CanvasLayer


func _on_play_button_pressed() -> void:
	# Get map from save if implemented
	var map = Events.Map.OUTSIDE
	get_tree().current_scene.switch_map(map)
	await Events.scene_load_finished
	hud.show()
	# Hide rather than queue_free(): Main.quit_to_main_menu() re-shows this
	# same node later, so it needs to still exist in the tree.
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
