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

# tracks active dish index
var active_dish_index = 0

# maps category name to its button
var category_button_map = {}

@onready var pasta_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/PastaButton
@onready var desserts_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/DessertsButton
@onready var seafood_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/SeafoodButton
@onready var steaks_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/SteaksButton
@onready var noodles_btn = $IngredientsGuidePanel/MiddleSection/CategorySection/NoodlesButton

@onready var category_label = $IngredientsGuidePanel/MiddleSection/DishInfoSection/DishList/CategoryLabel

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

	# map category names to their buttons
	category_button_map = {
		"Pasta": pasta_btn,
		"Desserts": desserts_btn,
		"Seafood": seafood_btn,
		"Steaks": steaks_btn,
		"Noodles": noodles_btn
	}

	# connect category buttons
	for cat in category_button_map:
		var category = cat
		category_button_map[cat].pressed.connect(func(): _on_category(category))

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

	# update category label on the left panel
	category_label.text = category

	# toggle active/inactive frames on category buttons
	for cat in category_button_map:
		var btn = category_button_map[cat]
		var is_active = cat == category
		btn.get_node("DefaultFrame").visible = not is_active
		btn.get_node("DefaultCategoryLabel").visible = not is_active
		btn.get_node("ActiveFrame").visible = is_active
		btn.get_node("ActiveCategoryLabel").visible = is_active

	# update dish list buttons
	for i in range(dish_buttons.size()):
		if i < current_dishes.size():
			dish_buttons[i].get_node("DefaultDishLabel").text = current_dishes[i].name
			dish_buttons[i].get_node("ActiveDishLabel").text = current_dishes[i].name
			dish_buttons[i].show()
		else:
			dish_buttons[i].hide()

	# select first dish by default
	_on_dish(0)

func _on_dish(index):
	if index >= current_dishes.size():
		return

	active_dish_index = index
	var dish = current_dishes[index]

	# toggle active/inactive frames on dish buttons
	for i in range(dish_buttons.size()):
		if i < current_dishes.size():
			var is_active = i == active_dish_index
			dish_buttons[i].get_node("DefaultFrame").visible = not is_active
			dish_buttons[i].get_node("DefaultDishLabel").visible = not is_active
			dish_buttons[i].get_node("ActiveFrame").visible = is_active
			dish_buttons[i].get_node("ActiveDishLabel").visible = is_active

	# update dish info panel
	dish_title.text = dish.name
	dish_description.text = dish.description
	ingredients_list.text = "\n".join(dish.ingredients)

	if dish.allergens.size() == 0 or dish.allergens[0] == "None":
		allergens_list.text = "None"
	else:
		allergens_list.text = "\n".join(dish.allergens)

func _on_close():
	queue_free()
