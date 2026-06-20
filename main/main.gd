extends Node

@export_file("*.tscn") var initial_scene: String

func _ready() -> void:
	SceneLoader.load_scene(initial_scene)
