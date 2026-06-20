extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.animation_state.travel("Attack")


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	finished.emit(IDLE)
