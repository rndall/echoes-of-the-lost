extends Panel

class_name IngredientUI

const INSUFFICIENT_ALPHA := 0.4

@onready var item_display: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_label: Label = $CenterContainer/Panel/Label

var ingredient: Ingredient
var player_has: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_ingredient(new_ingredient: Ingredient, has_amount: int = 0) -> void:
	ingredient = new_ingredient
	player_has = has_amount
	if is_node_ready():
		update_display()


func update_display() -> void:
	if not ingredient or not ingredient.material:
		return

	item_display.texture = ingredient.material.texture
	amount_label.text = "%d/%d" % [player_has, ingredient.amount]

	var has_enough := player_has >= ingredient.amount
	item_display.modulate.a = 1.0 if has_enough else INSUFFICIENT_ALPHA
