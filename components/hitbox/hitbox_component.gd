class_name HitboxComponent
extends Area2D

@export var attack_damage: float = 10
@export var knockback_force: float = 100


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = get_owner().global_position
		
		hurtbox.damage(attack)
