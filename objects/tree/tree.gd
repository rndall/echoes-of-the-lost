extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent

@export var log_scene: PackedScene = preload("res://inventory/scenes/pickup_items/log.tscn")
@export var log_spawn_radius: float = 50.0

var has_died: bool = false

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
	if has_died:
		return
	has_died = true
	
	var log_count = randi_range(1,3)
	
	for i in range(log_count):
		var angle = randf() * TAU
		var distance = randf_range(20.0, log_spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance

		var log_instance = log_scene.instantiate()
		get_parent().add_child(log_instance)
		log_instance.global_position = global_position + offset

	queue_free()
