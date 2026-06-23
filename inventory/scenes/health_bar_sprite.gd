class_name HealthBar
extends Sprite2D

const TOTAL_FRAMES = 6


func _ready() -> void:
	Events.player_health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(GameManager.player_health)


func _on_player_health_changed(current_health: float) -> void:
	if GameManager.MAX_PLAYER_HEALTH <= 0:
		return
	
	var health_percent = clampf(
		current_health / GameManager.MAX_PLAYER_HEALTH,
		0.0,
		1.0
	)
	
	var target_frame = int((1.0 - health_percent) * (TOTAL_FRAMES - 1))
	
	frame = target_frame
