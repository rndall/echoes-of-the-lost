class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine


func _enter_tree() -> void:
	var value = GameManager.get_data_value(get_path(), "pos")
	if not value:
		return
	
	global_position = value


func _exit_tree() -> void:
	GameManager.store_data_value(get_path(), "pos", global_position)


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_death)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_health_changed(_current_health: float, _attack: Attack) -> void:
	pass


func _on_death() -> void:
	print("dead")
	queue_free()
	pass
