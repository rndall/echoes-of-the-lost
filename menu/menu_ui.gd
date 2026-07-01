extends Control

@export var hotbar_ui: Control

var current_tab: String = "inventory"
var is_open: bool = false

@onready var artifact_inv: Inventory = preload("res://inventory/resources/artifact_inv.tres")
@onready var artifact_slot_nodes: Array = $inventory/artifact_slots.get_children()
@onready var inventory_tab = $tabs/inventory
@onready var crafting_tab = $tabs/crafting
#@onready var unknown_tab = $tabs/
@onready var settings_tab = $tabs/settings
@onready var inv_ui = $inventory
@onready var crafting_ui = $crafting
@onready var settings_ui = $settings
@onready var recipe_list_ui: RecipeListUI = $crafting/recipe_list_ui
@onready var crafting_display: CraftingUI = $crafting/crafting_ui
@onready var animation_player: AnimationPlayer = $inventory/player_view/AnimationPlayer


func _ready() -> void:
	if hotbar_ui == null:
		var nodes = get_tree().get_nodes_in_group("hotbar")
		if nodes.size() > 0:
			hotbar_ui = nodes[0]
	
	Events.player_state_changed.connect(_on_player_state_changed)
	
	_setup_artifact_slots()
	_setup_tabs()
	recipe_list_ui.recipe_selected.connect(crafting_display.display_recipe)
	crafting_display.item_crafted.connect(_on_item_crafted)
	
	close()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()


# ────────────────────────────────────────────────────────────────────────────
# Player State Sync
# ────────────────────────────────────────────────────────────────────────────

func _on_player_state_changed(state: PlayerState) -> void:
	match state.name:
		PlayerState.IDLE:
			animation_player.play("idle")
		PlayerState.WALKING:
			animation_player.play("walk")
		PlayerState.ACTION:
			animation_player.play("attack")
		_:
			animation_player.play("idle")


# ────────────────────────────────────────────────────────────────────────────
# Crafting feedback
# ────────────────────────────────────────────────────────────────────────────

func _on_item_crafted(product: InvItem, from_pos: Vector2) -> void:
	# Only show the fly-to-inventory ghost when the crafting tab is the one
	# currently open; if items ever get crafted through some other flow while
	# this tab isn't visible, stay quiet.
	if current_tab != "crafting" or not product or not product.texture:
		return

	var target_pos: Vector2 = inventory_tab.get_global_transform_with_canvas().origin + inventory_tab.size * inventory_tab.get_global_transform_with_canvas().get_scale() / 2.0
	DragGhost.fly_to(product.texture, from_pos, target_pos)


# ────────────────────────────────────────────────────────────────────────────
# Menu Open/Close
# ────────────────────────────────────────────────────────────────────────────

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


# ────────────────────────────────────────────────────────────────────────────
# Tab Management
# ────────────────────────────────────────────────────────────────────────────

func _setup_tabs() -> void:
	inventory_tab.gui_input.connect(_on_tab_clicked.bindv([inventory_tab, "inventory"]))
	crafting_tab.gui_input.connect(_on_tab_clicked.bindv([crafting_tab, "crafting"]))
	#unknown_tab.gui_input.connect(_on_tab_clicked.bindv([unknown_tab, "unknown"]))
	settings_tab.gui_input.connect(_on_tab_clicked.bindv([settings_tab, "settings"]))

func _on_tab_clicked(event: InputEvent, _tab: Panel, tab_name: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		switch_tabs(tab_name)

func switch_tabs(tab_name: String) -> void:
	if current_tab == tab_name:
		return
	
	print("Switching to tab: %s" % tab_name)
	current_tab = tab_name
	if current_tab == "inventory":
		inv_ui.visible = true
		crafting_ui.visible = false
		settings_ui.visible = false
	elif current_tab == "crafting":
		inv_ui.visible = false
		crafting_ui.visible = true
		settings_ui.visible = false
	elif current_tab == "settings":
		inv_ui.visible = false
		crafting_ui.visible = false
		settings_ui.visible = true


# ────────────────────────────────────────────────────────────────────────────
# Artifact slot setup
# ────────────────────────────────────────────────────────────────────────────

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
