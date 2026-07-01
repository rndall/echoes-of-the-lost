# DragGhost.gd - autoload this as "DragGhost"
extends Node

var ghost: TextureRect = null
var canvas: CanvasLayer

func _ready() -> void:
	canvas = CanvasLayer.new()
	canvas.layer = 100  # renders on top of everything
	add_child(canvas)

func start(texture: Texture2D, pos: Vector2) -> void:
	if ghost:
		stop()
	ghost = TextureRect.new()
	ghost.texture = texture
	ghost.size = Vector2(32, 32)          # match your item icon size
	ghost.pivot_offset = ghost.size / 2   # center it on cursor
	ghost.modulate = Color(1, 1, 1, 0.75) # slightly transparent
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ghost)
	ghost.global_position = pos - ghost.pivot_offset

func stop() -> void:
	if ghost:
		ghost.queue_free()
		ghost = null


# Spawns a standalone icon at `from_pos` that flies to `to_pos`, shrinking and
# fading out on arrival, then frees itself. Independent of the cursor-following
# `ghost` above — used for "item was crafted, here it goes into your inventory"
# feedback rather than drag-and-drop.
func fly_to(texture: Texture2D, from_pos: Vector2, to_pos: Vector2, duration: float = 1.0) -> void:
	var flying_ghost := TextureRect.new()
	flying_ghost.texture = texture
	flying_ghost.size = Vector2(32, 32)
	flying_ghost.pivot_offset = flying_ghost.size / 2
	flying_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(flying_ghost)
	flying_ghost.global_position = from_pos - flying_ghost.pivot_offset

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(flying_ghost, "global_position", to_pos - flying_ghost.pivot_offset, duration)
	tween.tween_property(flying_ghost, "scale", Vector2(0.4, 0.4), duration)
	tween.chain().tween_property(flying_ghost, "modulate:a", 0.0, 0.1)
	tween.chain().tween_callback(flying_ghost.queue_free)


func _process(_delta: float) -> void:
	if ghost:
		ghost.global_position = ghost.get_global_mouse_position() - ghost.pivot_offset
