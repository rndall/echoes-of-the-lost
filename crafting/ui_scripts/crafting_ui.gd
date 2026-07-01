extends Control

class_name CraftingUI

const IngredientUIScene: PackedScene = preload("res://crafting/scenes/ingredient_ui.tscn")

const MAX_INGREDIENT_COLUMNS := 3

@onready var product_display: Sprite2D = $NinePatchRect/product_ui/CenterContainer/item_display
@onready var ingredients_grid: GridContainer = $NinePatchRect/ingredients_grid
@onready var craft_button: TextureButton = $NinePatchRect/craft_button

var player_inv: Inventory = preload("res://inventory/resources/player_inv.tres")

var current_recipe: Recipe


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	craft_button.pressed.connect(_craft)
	player_inv.update.connect(_on_player_inv_update)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func display_recipe(recipe: Recipe) -> void:
	current_recipe = recipe

	if not recipe:
		return

	if recipe.product:
		product_display.texture = recipe.product.texture

	_populate_ingredients(recipe.ingredients)


func _populate_ingredients(ingredients: Array[Ingredient]) -> void:
	var existing_slots := ingredients_grid.get_children()

	for i in range(existing_slots.size()):
		var slot := existing_slots[i] as IngredientUI
		if not slot:
			continue
		if i < ingredients.size():
			_update_ingredient_slot(slot, ingredients[i])
			slot.visible = true
		else:
			slot.visible = false

	# In case a recipe has more ingredients than there are slots in the grid.
	for i in range(existing_slots.size(), ingredients.size()):
		var new_slot: IngredientUI = IngredientUIScene.instantiate()
		ingredients_grid.add_child(new_slot)
		_update_ingredient_slot(new_slot, ingredients[i])

	ingredients_grid.columns = clampi(ingredients.size(), 1, MAX_INGREDIENT_COLUMNS)
	_center_ingredients_grid()


func _update_ingredient_slot(slot: IngredientUI, ingredient: Ingredient) -> void:
	var has_amount := player_inv.count_item(ingredient.material.id) if ingredient.material else 0
	slot.set_ingredient(ingredient, has_amount)


func _center_ingredients_grid() -> void:
	# ingredients_grid's parent isn't a layout Container, so its box doesn't
	# auto-shrink to fit its children. Resize it to its content's minimum
	# width and re-center it within the parent each time the column count
	# (and therefore the grid's width) changes.
	var grid_width: float = ingredients_grid.get_combined_minimum_size().x
	var grid_height: float = ingredients_grid.get_combined_minimum_size().y
	var parent_width: float = ingredients_grid.get_parent().size.x
	var center_x: float = parent_width / 2.0

	ingredients_grid.offset_left = center_x - grid_width / 2.0
	ingredients_grid.offset_right = center_x + grid_width / 2.0
	ingredients_grid.offset_bottom = ingredients_grid.offset_top + grid_height


func _on_player_inv_update() -> void:
	# Keep the displayed x/y counts and opacity in sync with the player's
	# inventory (e.g. items picked up or used elsewhere while this is open).
	if current_recipe:
		_populate_ingredients(current_recipe.ingredients)


func _can_craft(recipe: Recipe) -> bool:
	if not recipe:
		return false

	for ingredient in recipe.ingredients:
		if not ingredient.material:
			continue
		if player_inv.count_item(ingredient.material.id) < ingredient.amount:
			return false

	return true


func _craft() -> void:
	print("crafting")
	if not _can_craft(current_recipe):
		return

	for ingredient in current_recipe.ingredients:
		if ingredient.material:
			player_inv.remove(ingredient.material, ingredient.amount)

	if current_recipe.product:
		player_inv.insert(current_recipe.product, 1)
