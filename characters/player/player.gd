class_name Player
extends CharacterBody2D

@export var speed: float = 100.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_death)
	
	animation_tree.set_active(true)
	
	animation_tree.set("parameters/Idle/blend_position", Vector2.DOWN)


func _on_health_changed(current_health: float, _attack: Attack) -> void:
	GameManager.player_health = current_health


func _on_death() -> void:
	print("dead")
	#queue_free()
	pass
