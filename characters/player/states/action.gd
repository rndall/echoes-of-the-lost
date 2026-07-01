extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	if GameManager.player_weapon.target == WeaponItem.Target.ENEMY:
		player.animation_state.travel("Attack")
		player.animation_tree.set("parameters/Attack/blend_position", player.facing_direction)

	elif GameManager.player_weapon.target == WeaponItem.Target.OBJECT:
		player.animation_state.travel("Chop")
		player.animation_tree.set("parameters/Chop/blend_position", player.facing_direction)


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	finished.emit(IDLE)
