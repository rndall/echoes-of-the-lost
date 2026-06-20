extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.animation_state.travel("Walk")


func physics_update(_delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", 
			"move_up", "move_down")
	
	if Input.is_action_just_pressed("action"):
		finished.emit(ATTACKING)
		return
	
	if input_direction == Vector2.ZERO:
		finished.emit(IDLE)
		return
	
	player.velocity = input_direction * player.speed
	player.last_direction = input_direction 
	player.update_blend_positions(input_direction)
	
	player.move_and_slide()
	
