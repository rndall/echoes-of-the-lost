extends Control

class_name MainQuestListUI

signal section_toggled(section: Control, is_open: bool)

@onready var header: Button = $Header
@onready var body_clip: Control = $BodyClip

var is_open: bool = false
var open_height: float = 0.0
var toggle_tween: Tween

const TOGGLE_DURATION: float = 0.25

func _ready() -> void:
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.gui_input.connect(_on_header_gui_input)

	body_clip.clip_contents = true
	open_height = body_clip.size.y
	body_clip.size.y = open_height if is_open else 0.0

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_open(!is_open)
		section_toggled.emit(self, is_open)

func set_open(value: bool, animate: bool = true) -> void:
	is_open = value
	var target_height: float = open_height if is_open else 0.0

	if toggle_tween and toggle_tween.is_valid():
		toggle_tween.kill()

	if not animate:
		body_clip.size.y = target_height
		return

	toggle_tween = create_tween()
	toggle_tween.set_trans(Tween.TRANS_CUBIC)
	toggle_tween.set_ease(Tween.EASE_OUT)
	toggle_tween.tween_property(body_clip, "size:y", target_height, TOGGLE_DURATION)
	
	print(["set_open_main", is_open])

func _is_open() -> bool:
	return is_open
