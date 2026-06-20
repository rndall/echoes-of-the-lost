extends Area2D

@export_file("*.tscn") var target_scene: String

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_process_mode(PROCESS_MODE_DISABLED)
		SceneLoader.load_scene(target_scene)
