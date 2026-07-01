extends Control

class_name CraftingUI

const IngredientUIScene: PackedScene = preload("res://crafting/scenes/ingredient_ui.tscn")

@onready var product_display: Sprite2D = $NinePatchRect/product_ui/CenterContainer/item_display
@onready var ingredients_grid: GridContainer = $NinePatchRect/ingredients_grid

var current_recipe: Recipe


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			slot.set_ingredient(ingredients[i])
			slot.visible = true
		else:
			slot.visible = false

	# In case a recipe has more ingredients than there are slots in the grid.
	for i in range(existing_slots.size(), ingredients.size()):
		var new_slot: IngredientUI = IngredientUIScene.instantiate()
		ingredients_grid.add_child(new_slot)
		new_slot.set_ingredient(ingredients[i])
