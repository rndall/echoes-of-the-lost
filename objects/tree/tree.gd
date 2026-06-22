extends StaticBody2D

@export var tree_type: int = 0

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite_2d.frame = tree_type
