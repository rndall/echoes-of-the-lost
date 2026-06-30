extends PlayerState

const TILE_SIZE: float = 24

var last_position: Vector2


func enter(_previous_state_path: String, _data := {}) -> void:
	last_position = player.global_position
	
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
	
	player.facing_direction = input_direction
	player.velocity = input_direction * player.speed
	
	player.animation_tree.set("parameters/Idle/blend_position", player.facing_direction)
	player.animation_tree.set("parameters/Walk/blend_position", player.facing_direction)
	player.animation_tree.set("parameters/Attack/blend_position", player.facing_direction)
	player.animation_tree.set("parameters/Chop/blend_position", player.facing_direction)
	
	player.move_and_slide()
	
	handle_walk_task()


func handle_walk_task() -> void:
	var step = player.global_position.distance_to(last_position)
	player.walk_distance_accum += step
	last_position = player.global_position

	while player.walk_distance_accum >= TILE_SIZE:
		DailyTaskManager.update_task_progress("4", 1)
		player.walk_distance_accum -= TILE_SIZE
