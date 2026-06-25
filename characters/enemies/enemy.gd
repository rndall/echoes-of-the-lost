class_name Enemy
extends CharacterBody2D

var instance_id: String

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine


func _enter_tree() -> void:
	if instance_id.is_empty():
		return
	
	var value = GameManager.get_data_value(instance_id, "pos")
	if not value:
		return
	
	global_position = value


func _exit_tree() -> void:
	if not instance_id.is_empty() and not is_queued_for_deletion():
		GameManager.store_data_value(instance_id, "pos", global_position)


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_death)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_health_changed(_current_health: float, _attack: Attack) -> void:
	pass


func _on_death() -> void:
	print("dead")
	GameManager.remove_data_entry(instance_id)
	health_component.instance_id = ""
	instance_id = ""
	queue_free()
	pass
