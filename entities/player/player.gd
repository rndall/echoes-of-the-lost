class_name Player
extends CharacterBody2D

@export var speed: float = 100.0

var last_direction: Vector2 = Vector2.DOWN

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _ready() -> void:
	animation_tree.set_active(true)


func update_blend_positions(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/Walk/blend_position", direction)
	animation_tree.set("parameters/Attack/blend_position", direction)
