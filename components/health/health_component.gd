class_name HealthComponent
extends Node2D

signal health_changed(current_health: float)
signal died

@export var max_health: float = 10.0
var health: float


func _ready():
	health = max_health


func damage(attack: Attack):
	health -= attack.attack_damage
	print(health)
	health_changed.emit(health)
	
	if health <= 0:
		died.emit()
