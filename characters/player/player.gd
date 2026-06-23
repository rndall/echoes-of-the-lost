class_name Player
extends CharacterBody2D

@export var speed: float = 100.0

@onready var hurt: AudioStreamPlayer2D = $Hurt
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var state_machine: StateMachine = $StateMachine
@onready var inv: Inventory = preload("res://inventory/resources/player_inv.tres")

func _ready() -> void:
	health_component.health = GameManager.player_health
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_death)
	
	animation_tree.set_active(true)
	
	animation_tree.set("parameters/Idle/blend_position", Vector2.DOWN)


func _on_health_changed(current_health: float, _attack: Attack) -> void:
	GameManager.player_health = current_health
	Events.player_health_changed.emit(current_health)
	
	if GameManager.player_health > 0:
		hurt.play()


func _on_death() -> void:
	print("dead")
	#queue_free()
	pass

func collect(item):
	inv.insert(item)
