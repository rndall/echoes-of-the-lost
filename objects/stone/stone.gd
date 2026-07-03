class_name Stone
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var stone_item: InvItem = preload("res://inventory/resources/inventory_items/stone.tres")
@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")

func _ready() -> void:
	if GameManager.get_data_value(name, "dead") == true:
		queue_free()
		return

	health_component.died.connect(_on_death)


func _on_death() -> void:
	GameManager.store_data_value(name, "dead", true)

	var stone_count = randi_range(1, 2)
	player_inv.insert(stone_item, stone_count)
	DailyTaskManager.update_task_progress("5", stone_count)
	queue_free()
