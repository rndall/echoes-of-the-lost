extends Area2D

@export var item: InvItem = preload("res://inventory/resources/inventory_items/axe.tres")

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	player = body
	player.collect(item)
	queue_free()
