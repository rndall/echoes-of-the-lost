extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite_2d.frame = randi_range(0, 1)
	print(sprite_2d.frame)
