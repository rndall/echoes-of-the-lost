class_name HitboxComponent
extends Area2D

@export var attack_damage: float = 1.0
@export var knockback_force: float


func _process(_delta: float) -> void:
	if not monitoring:
		return
	
	for area in get_overlapping_areas():
		if area is HurtboxComponent:
			var hurtbox: HurtboxComponent = area
			
			if hurtbox.health_component and hurtbox.health_component.can_take_damage:
				attack_hurtbox(hurtbox) 


func attack_hurtbox(hurtbox: HurtboxComponent) -> void:
	var attack = Attack.new()
	attack.attack_damage = attack_damage
	attack.knockback_force = knockback_force
	attack.attack_position = get_owner().global_position
	
	hurtbox.damage(attack)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		attack_hurtbox(area)
