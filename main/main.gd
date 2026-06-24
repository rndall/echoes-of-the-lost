extends Node

@export_file("*.tscn") var initial_scene: String

@onready var world_container: Node2D = $WorldContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var sound_machine: Node = $SoundMachine
@onready var ui: Control = $CanvasLayer/DayNightCycleUI
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

func _ready() -> void:
	canvas_layer.visible = true
	
	SceneLoader.scene_container = world_container
	SceneLoader.load_scene(initial_scene)
