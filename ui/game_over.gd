extends Control

var win: bool

@onready var label: Label = $VBoxContainer/Label


func _ready() -> void:
	label.text = "You Win!" if win else "You Died"


func _process(_delta: float) -> void:
	pass


func _on_replay_button_pressed() -> void:
	Events.replay.emit()
	await Events.scene_load_finished
	queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
