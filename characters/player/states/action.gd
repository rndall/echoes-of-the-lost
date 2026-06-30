extends PlayerState


func enter(_previous_state_path: String, _data := {}) -> void:
	player.notify_state_change("action")
	
	if GameManager.player_weapon.target == WeaponItem.Target.ENEMY:
		player.animation_state.travel("Attack")
	elif GameManager.player_weapon.target == WeaponItem.Target.OBJECT:
		player.animation_state.travel("Chop")


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	finished.emit(IDLE)
