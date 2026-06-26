extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent

@export var log_scene: PackedScene = preload("res://inventory/scenes/pickup_items/log.tscn")
@export var apple_scene: PackedScene = preload("res://inventory/scenes/pickup_items/apple.tscn")
@export var spawn_radius: float = 50.0

var has_died: bool = false
var _hovered: bool = false

func _exit_tree() -> void:
	GameManager.store_data_entry(get_path(), 
			{ 
				"hp": health_component.health, 
				"pos": global_position, 
				"frame": sprite_2d.frame
			}
	)

func _ready() -> void:
	$interaction_area.input_event.connect(_on_input_event)
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
	
	var log_count = randi_range(1,2)
	var apple_count = randi_range(3,5)
	
	for i in range(log_count):
		var angle = randf() * TAU
		var distance = randf_range(20.0, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance

		var log_instance = log_scene.instantiate()
		get_parent().add_child(log_instance)
		log_instance.global_position = global_position + offset
		
	for i in range(apple_count):
		var angle = randf() * TAU
		var distance = randf_range(20.0, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance

		var apple_instance = apple_scene.instantiate()
		get_parent().add_child(apple_instance)
		apple_instance.global_position = global_position + offset

	queue_free()
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		_try_collect()
		
func _try_collect() -> void:
	var _item: InvItem = load("res://inventory/resources/inventory_items/apple.tres")
	var _inv: Inventory = load("res://inventory/resources/player_inv.tres")
	var collected_amount = randi_range(1, 2)
	
	if _item == null or _inv == null:
		push_warning("apple: missing item or inventory resource.")
		return
	
	_inv.insert(_item, collected_amount)
	
func _on_mouse_entered() -> void:
	_hovered = true
	# Brighten the sprite slightly so the player knows it's clickable.
	modulate = Color(1.4, 1.4, 1.4)

func _on_mouse_exited() -> void:
	_hovered = false
	modulate = Color.WHITE
