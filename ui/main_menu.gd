extends Control

@export_file("*.tscn") var start_level_path: String


func _on_play_button_pressed() -> void:
	pass


func _on_exit_button_pressed() -> void:
	get_tree().quit()
