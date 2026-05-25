extends Control

# dishes grouped by category
var categories = {
	"Pasta": [],
	"Noodles": [],
	"Seafood": [],
	"Steaks": [],
	"Desserts": []
}

# currently selected dishes based on category
var current_dishes = []

@onready var pasta_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/PastaButton
@onready var desserts_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/DessertsButton
@onready var seafood_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/SeafoodButton
@onready var steaks_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/SteaksButton
@onready var noodles_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/NoodlesButton

@onready var dish_buttons = [
	$IngredientsGuidePanel/MiddleSection/DishInfoSection/DishList/Dish1,
	$IngredientsGuidePanel/MiddleSection/DishInfoSection/DishList/Dish2,
	$IngredientsGuidePanel/MiddleSection/DishInfoSection/DishList/Dish3,
	$IngredientsGuidePanel/MiddleSection/DishInfoSection/DishList/Dish4
]

@onready var dish_title = $IngredientsGuidePanel/MiddleSection/DishInfoSection/DishInfoSection/DishTitle
@onready var dish_description = $IngredientsGuidePanel/MiddleSection/DishInfoSection/DishInfoSection/DishDescription
@onready var ingredients_list = $IngredientsGuidePanel/MiddleSection/DishInfoSection/DishInfoSection/DishIngredients/IngredientsList
@onready var allergens_list = $IngredientsGuidePanel/MiddleSection/DishInfoSection/DishInfoSection/DishAllergens/AllergensList
@onready var close_btn = $IngredientsGuidePanel/TopSection/CloseButton

func _ready():
	close_btn.pressed.connect(_on_close)
	pasta_btn.pressed.connect(func(): _on_category("Pasta"))
	desserts_btn.pressed.connect(func(): _on_category("Desserts"))
	seafood_btn.pressed.connect(func(): _on_category("Seafood"))
	steaks_btn.pressed.connect(func(): _on_category("Steaks"))
	noodles_btn.pressed.connect(func(): _on_category("Noodles"))

	# connect dish buttons with their index
	for i in range(dish_buttons.size()):
		var index = i
		dish_buttons[i].pressed.connect(func(): _on_dish(index))

	# group dishes from database by category
	for dish in DishDatabase.dishes:
		if dish.category in categories:
			categories[dish.category].append(dish)

	# show pasta by default
	_on_category("Pasta")

func _on_category(category):
	current_dishes = categories[category]

	for i in range(dish_buttons.size()):
		if i < current_dishes.size():
			dish_buttons[i].get_node("DishLabel").text = current_dishes[i].name
			dish_buttons[i].show()
		else:
			dish_buttons[i].hide()

	# show first dish by default when switching categories
	_on_dish(0)

func _on_dish(index):
	if index >= current_dishes.size():
		return

	var dish = current_dishes[index]

	dish_title.text = dish.name
	dish_description.text = dish.description
	ingredients_list.text = "\n".join(dish.ingredients)

	if dish.allergens.size() == 0 or dish.allergens[0] == "None":
		allergens_list.text = "None"
	else:
		allergens_list.text = "\n".join(dish.allergens)

func _on_close():
	queue_free()
