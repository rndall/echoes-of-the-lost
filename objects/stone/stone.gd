class_name Stone
extends StaticBody2D

const MIN_SCALE: int = 1
const MAX_SCALE: int = 3

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var stone_item: InvItem = preload("res://inventory/resources/inventory_items/stone.tres")
@onready var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")

var scale_factor: float = 1.0

func _ready() -> void:
	if GameManager.get_data_value(name, "dead") == true:
		queue_free()
		return

	_randomize_scale()
	health_component.died.connect(_on_death)


func _randomize_scale() -> void:
	scale_factor = randi_range(MIN_SCALE, MAX_SCALE)
	scale = Vector2.ONE * scale_factor

	# HealthComponent's _ready() already ran (children ready before parents),
	# so health is already set to the base max_health. Scale both values now.
	var base_max_health = health_component.max_health
	health_component.max_health = base_max_health * scale_factor
	health_component.health = health_component.max_health


func _on_death() -> void:
	GameManager.store_data_value(name, "dead", true)

	# Bigger stones drop more loot: base 1-2, plus bonus per scale tier above 1.0
	var bonus_loot = int(scale_factor) - 1
	var stone_count = randi_range(1, 2) + bonus_loot

	player_inv.insert(stone_item, stone_count)
	DailyTaskManager.update_task_progress("5", stone_count)
	queue_free()
