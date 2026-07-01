extends Panel

class_name RecipeUI

@onready var recipe_name_label = $NinePatchRect/Label
var recipe: Recipe

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_recipe(new_recipe: Recipe) -> void:
	recipe = new_recipe
	if is_node_ready():
		update_display()

func update_display() -> void:
	if not recipe:
		return

	recipe_name_label.text = recipe.name
