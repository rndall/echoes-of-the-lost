extends Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt: AudioStreamPlayer2D = $Hurt


func _physics_process(delta: float) -> void:
	super(delta)
	
	if velocity == Vector2.ZERO:
		return
	
	if velocity.y > 0:
		animation_player.play("fly_down")
	else:
		animation_player.play("fly_up")


func _on_health_changed(current_health: float, attack: Attack) -> void:
	if attack.attack_damage <= 0:
		return
	
	if current_health > 0:
		hurt.play(0.25)


func _on_death() -> void:
	DailyTaskManager.update_task_progress("2", 1)
	super()
