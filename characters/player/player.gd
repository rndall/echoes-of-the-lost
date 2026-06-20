class_name Player
extends CharacterBody2D

@export var speed: float = 100.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _ready() -> void:
	animation_tree.set_active(true)


func _physics_process(_delta: float) -> void:
	move_and_slide()
