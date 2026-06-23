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

func _process(_delta: float) -> void:
	if ghost:
		ghost.global_position = ghost.get_global_mouse_position() - ghost.pivot_offset
