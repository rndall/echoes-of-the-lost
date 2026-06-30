extends Control

var is_open: bool = false
var current_tab: String = "inventory"

@export var hotbar_ui: Control

@onready var artifact_inv: Inventory = preload("res://inventory/resources/artifact_inv.tres")
@onready var artifact_slot_nodes: Array = $inventory/artifact_slots.get_children()
@onready var inventory_tab = $tabs/inventory
@onready var crafting_tab = $tabs/crafting
#@onready var unknown_tab = $tabs/
@onready var settings_tab = $tabs/settings

func _ready() -> void:
	if hotbar_ui == null:
		var nodes = get_tree().get_nodes_in_group("hotbar")
		if nodes.size() > 0:
			hotbar_ui = nodes[0]

	_setup_artifact_slots()
	_setup_tabs()

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

# ── Tab Management ────────────────────────────────────────────────────────

func _setup_tabs() -> void:
	inventory_tab.gui_input.connect(_on_tab_clicked.bindv([inventory_tab, "inventory"]))
	crafting_tab.gui_input.connect(_on_tab_clicked.bindv([crafting_tab, "crafting"]))
	#unknown_tab.gui_input.connect(_on_tab_clicked.bindv([unknown_tab, "unknown"]))
	settings_tab.gui_input.connect(_on_tab_clicked.bindv([settings_tab, "settings"]))

func _on_tab_clicked(event: InputEvent, tab: Panel, tab_name: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		switch_tabs(tab_name)

func switch_tabs(tab_name: String) -> void:
	if current_tab == tab_name:
		return
	
	print("Switching to tab: %s" % tab_name)
	current_tab = tab_name
	
	# For now, just print the tab name
	# Later, show/hide the appropriate content

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
