extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.animation_state.travel("Idle")


func physics_update(_delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", 
			"move_up", "move_down")
	
	if Input.is_action_just_pressed("action"):
		finished.emit(ACTION)
	elif input_direction != Vector2.ZERO:
		finished.emit(WALKING)
