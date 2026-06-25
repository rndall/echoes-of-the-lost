extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent


func _exit_tree() -> void:
	GameManager.store_data_entry(get_path(), 
			{ 
				"hp": health_component.health, 
				"pos": global_position, 
				"frame": sprite_2d.frame
			}
	)


func _ready() -> void:
	health_component.died.connect(_on_died)
	
	var value = GameManager.get_data_entry(get_path())
	if not value:
		sprite_2d.frame = randi_range(0, 1)
		return
	
	health_component.health = value["hp"]
	global_position = value["pos"]
	sprite_2d.frame = value["frame"]
	
	if health_component.health <= 0:
		health_component.die()


func _on_died() -> void:
	queue_free()
