extends Area2D

@export var bridge_uncomplete: TileMapLayer
@export var bridge_finished: TileMapLayer


func _build_bridge() -> void:
	bridge_uncomplete.enabled = false
	bridge_finished.enabled = true


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bridge"):
		_build_bridge()
		
		area.queue_free()
		queue_free()
