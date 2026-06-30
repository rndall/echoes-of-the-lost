extends PlayerState

@export var hurtbox_component: HurtboxComponent


func enter(_previous_state_path: String, _data := {}) -> void:
	hurtbox_component.set_deferred("monitorable", false)
