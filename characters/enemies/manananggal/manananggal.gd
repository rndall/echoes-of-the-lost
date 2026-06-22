extends Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	super(delta)
	
	if velocity == Vector2.ZERO:
		return
	
	if velocity.y > 0:
		animation_player.play("fly_down")
	else:
		animation_player.play("fly_up")
