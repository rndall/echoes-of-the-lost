extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.animation_state.travel("Walk")


func physics_update(_delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", 
			"move_up", "move_down")
	
	if Input.is_action_just_pressed("action") and GameManager.player_weapon:
		finished.emit(ACTION)
		return
	
	if input_direction == Vector2.ZERO:
		finished.emit(IDLE)
		return
	
	player.velocity = input_direction * player.speed
	
	player.animation_tree.set("parameters/Idle/blend_position", input_direction)
	player.animation_tree.set("parameters/Walk/blend_position", input_direction)
	player.animation_tree.set("parameters/Attack/blend_position", input_direction)
	player.animation_tree.set("parameters/Chop/blend_position", input_direction)
	
	player.move_and_slide()
