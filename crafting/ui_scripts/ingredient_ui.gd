extends Panel

class_name IngredientUI

@onready var item_display: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_label: Label = $CenterContainer/Panel/Label

var ingredient: Ingredient


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_ingredient(new_ingredient: Ingredient) -> void:
	ingredient = new_ingredient
	if is_node_ready():
		update_display()


func update_display() -> void:
	if not ingredient or not ingredient.material:
		return

	item_display.texture = ingredient.material.texture
	amount_label.text = str(ingredient.amount)
