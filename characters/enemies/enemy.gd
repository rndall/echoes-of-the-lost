class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	health_component.died.connect(_on_death)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_death() -> void:
	print("dead")
	queue_free()
	pass
