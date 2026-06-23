extends Control

var is_open: bool = false

# Assign this in the Inspector to your hotbar_ui node,
# or find it via group (add hotbar_ui to the "hotbar" group).
@export var hotbar_ui: Control

func _ready() -> void:
	# Fallback: find hotbar by group if not assigned in the Inspector
	if hotbar_ui == null:
		var nodes = get_tree().get_nodes_in_group("hotbar")
		if nodes.size() > 0:
			hotbar_ui = nodes[0]

	close()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func open() -> void:
	visible = true
	is_open = true
	if hotbar_ui:
		hotbar_ui.visible = false

func close() -> void:
	visible = false
	is_open = false
	if hotbar_ui:
		hotbar_ui.visible = true
