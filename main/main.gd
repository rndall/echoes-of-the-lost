extends Node

@export_file("*.tscn") var initial_scene: String

@onready var world_container: Node2D = $WorldContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	canvas_layer.visible = true
	
	SceneLoader.scene_container = world_container
	SceneLoader.load_scene(initial_scene)
