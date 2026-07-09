extends Camera2D


func _ready() -> void:
	Events.map_changed.connect(_on_map_changed)

func _on_map_changed(map: Events.Map) -> void:
	match map:
		Events.Map.OUTSIDE:
			limit_left = 3
			limit_top = 3
			limit_right = 1405
