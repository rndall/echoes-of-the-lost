class_name EnemyFollow
extends EnemyState

@export var speed: float = 40.0
@export var max_range: float = 120

var player: Player


func enter(_previous_state_path: String, _data := {}) -> void:
	player = get_tree().get_first_node_in_group("player")


func physics_update(_delta: float) -> void:
	var direction = player.global_position - enemy.global_position
	
	enemy.velocity = direction.normalized() * speed
	
	if direction.length() > max_range:
		finished.emit(WANDER)
