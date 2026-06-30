class_name HealthComponent
extends Node2D

signal health_changed(current_health: float, attack: Attack)
signal died

@export var sprite_2d: Sprite2D
@export var max_health: float = 10.0

var health: float
var can_take_damage: bool = true
var dead: bool = false


func _ready() -> void:
	health = max_health


func damage(attack: Attack, invincible_time: float = 0.0,
		ignore_invincible: bool = false) -> void:
	if dead:
		return
	if not can_take_damage and not ignore_invincible:
		return

	health -= attack.attack_damage
	health_changed.emit(health, attack)

	if health <= 0:
		die()
		return

	if invincible_time > 0.0:
		_apply_invincibility(invincible_time)


func _apply_invincibility(duration: float) -> void:
	can_take_damage = false
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	var step = duration / 4.0

	tween.tween_property(sprite_2d, "modulate", Color(1, 0.2, 0.2), step)
	tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1), step)
	tween.tween_property(sprite_2d, "modulate", Color(1, 0.2, 0.2), step)
	tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1), step)
	tween.finished.connect(func(): can_take_damage = true)


func die() -> void:
	dead = true
	can_take_damage = false
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "modulate:a", 0.0, 0.2)
	await tween.parallel().tween_property(sprite_2d, "scale", Vector2.ZERO, 0.2).finished
	get_owner().set_physics_process(false)
	died.emit()
