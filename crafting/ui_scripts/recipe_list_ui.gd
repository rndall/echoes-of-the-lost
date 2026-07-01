extends Control

class_name RecipeListUI

@onready var grid_container = $GridContainer

var recipe_ui_instances: Array[RecipeUI] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_recipe_uis()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _setup_recipe_uis() -> void:
	var all_recipes = RecipeManager.get_all_recipes()
	
	for i in range(grid_container.get_child_count()):
		var recipe_ui = grid_container.get_child(i) as RecipeUI
		if recipe_ui and i < all_recipes.size():
			recipe_ui.set_recipe(all_recipes[i])
			recipe_ui_instances.append(recipe_ui)
		elif recipe_ui:
			recipe_ui.queue_free()
