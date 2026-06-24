extends Control

var is_open: bool = false

# Assign this in the Inspector to your hotbar_ui node,
# or find it via group (add hotbar_ui to the "hotbar" group).
@export var hotbar_ui: Control

@onready var artifact_inv: Inventory = preload("res://inventory/resources/artifact_inv.tres")
@onready var artifact_slot_nodes: Array = $NinePatchRect/artifact_slots.get_children()


func _ready() -> void:
	# Fallback: find hotbar by group if not assigned in the Inspector.
	if hotbar_ui == null:
		var nodes = get_tree().get_nodes_in_group("hotbar")
		if nodes.size() > 0:
			hotbar_ui = nodes[0]

	_setup_artifact_slots()

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

# ── Artifact slot setup ───────────────────────────────────────────────────────

func _setup_artifact_slots() -> void:
	for i in range(mini(artifact_inv.slots.size(), artifact_slot_nodes.size())):
		var slot_node = artifact_slot_nodes[i]
		if slot_node is ArtifactSlotUI:
			slot_node.setup(i, artifact_inv)

	artifact_inv.update.connect(_update_artifact_slots)
	_update_artifact_slots()

func _update_artifact_slots() -> void:
	for i in range(mini(artifact_inv.slots.size(), artifact_slot_nodes.size())):
		var slot_node = artifact_slot_nodes[i]
		if slot_node is ArtifactSlotUI:
			slot_node.update(artifact_inv.get_slot_by_index(i))
