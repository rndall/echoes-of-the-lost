extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.health_component.is_blocking = true
	player.animation_state.travel("Block")
	player.animation_tree.set("parameters/Block/blend_position", player.facing_direction)


func physics_update(_delta: float) -> void:
	if Input.is_action_just_released("block"):
		finished.emit(IDLE)


func exit() -> void:
	player.health_component.is_blocking = false
