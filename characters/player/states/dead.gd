extends PlayerState

@export var hurtbox_component: HurtboxComponent


func enter(previous_state_path: String, _data := {}) -> void:
	super(previous_state_path)
	hurtbox_component.set_deferred("monitorable", false)
