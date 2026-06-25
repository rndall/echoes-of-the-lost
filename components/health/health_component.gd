class_name HealthComponent
extends Node2D

signal health_changed(current_health: float, attack: Attack)
signal died

@export var sprite_2d: Sprite2D
@export var max_health: float = 10.0
@export var instance_id: String

var health: float
var can_take_damage: bool = true


func _enter_tree() -> void:
	if instance_id.is_empty():
		return
	
	var value = GameManager.get_data_value(instance_id, "hp")
	if not value:
		return
	
	health = value
	if health <= 0:
		die()


func _exit_tree() -> void:
	if instance_id.is_empty():
		return
	
	GameManager.store_data_value(instance_id, "hp", health)


func _ready() -> void:
	if not health:
		health = max_health


func damage(attack: Attack, invincible_time: float = 0.0, 
		ignore_invincible: bool = false) -> void:
	if not can_take_damage and not ignore_invincible:
		return
	
	health -= attack.attack_damage
	print(instance_id, health)
	health_changed.emit(health, attack)
	
	if health <= 0:
		die()
		return
	
	if invincible_time > 0.0:
		can_take_damage = false
		
		var invincible_tween = create_tween().set_trans(Tween.TRANS_SINE)
		var flash_step = invincible_time / 4.0
		
		# Flash red on hit
		invincible_tween.tween_property(sprite_2d, "modulate", 
				Color(1, 0.2, 0.2), flash_step)
		invincible_tween.tween_property(sprite_2d, "modulate", 
				Color(1, 1, 1), flash_step)
		
		invincible_tween.tween_property(sprite_2d, "modulate", 
				Color(1, 0.2, 0.2), flash_step)
		invincible_tween.tween_property(sprite_2d, "modulate", 
				Color(1, 1, 1), flash_step)
		
		invincible_tween.finished.connect(func(): can_take_damage = true)
		
		# Flicker opacity on hit
		#invincible_tween.tween_property(sprite_2d, "modulate:a", 0.5, 
				#flash_step)
		#invincible_tween.chain().tween_property(sprite_2d, "modulate:a", 1.0, 
				#flash_step)
		#invincible_tween.chain().chain().tween_property(sprite_2d, 
				#"modulate:a", 0.5, flash_step)
		#invincible_tween.chain().chain().chain().tween_property(sprite_2d, 
				#"modulate:a", 1.0, flash_step).finished.connect(
						#func(): can_take_damage = true
				#)


func die() -> void:
	var dead_tween = create_tween().set_trans(Tween.TRANS_SINE)
	dead_tween.tween_property(sprite_2d, "modulate:a", 0.0, 0.2)
	await dead_tween.parallel().tween_property(sprite_2d, "scale", 
			Vector2.ZERO, 0.2).finished
	get_owner().set_physics_process(false)
	died.emit()
