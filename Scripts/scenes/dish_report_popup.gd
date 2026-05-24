extends Control

var current_dish_index = 0
var dishes = []
var resto_name = ""

# stores the player's mark per dish, empty string means not yet judged
var dish_marks = ["", "", "", "", ""]

@onready var dish_name_label = $DishReportPanel/TopSection/TitleContainer/DishNameLabel
@onready var resto_name_label = $DishReportPanel/TopSection/TitleContainer/RestaurantNameLabel
@onready var dish_counter_label = $DishReportPanel/TopSection/DishCounterLabel
@onready var status_label = $DishReportPanel/TopSection/StatusLabel
@onready var dish_image = $DishReportPanel/MiddleSection/DishImage
@onready var ingredients_list = $DishReportPanel/MiddleSection/IngredientsListLabel
@onready var allergens_list = $DishReportPanel/MiddleSection/AllergensListLabel
@onready var season_list = $DishReportPanel/MiddleSection/PeakseasonListLabel
@onready var price_list = $DishReportPanel/MiddleSection/PriceListLabel
@onready var verified_btn = $DishReportPanel/BottomSection/VerifiedButton
@onready var suspicious_btn = $DishReportPanel/BottomSection/SuspiciousButton
@onready var close_btn = $DishReportPanel/TopSection/CloseButton
@onready var left_btn = $DishReportPanel/LeftNextButton
@onready var right_btn = $DishReportPanel/RightNextButton

func _ready():
	verified_btn.pressed.connect(_on_verified)
	suspicious_btn.pressed.connect(_on_suspicious)
	close_btn.pressed.connect(_on_close)
	left_btn.pressed.connect(_on_left)
	right_btn.pressed.connect(_on_right)

	# TEMP TEST — remove after confirming UI works
	dishes = [
		{
			"name": "Peach Cream Pudding",
			"reported_name": "Peach Cream Pudding",
			"reported_ingredients": ["Peach", "Egg", "Cheese", "Tofu"],
			"reported_allergens": ["Eggs", "Dairy", "Soy"],
			"reported_season": "Summer",
			"reported_price": 100
		},
		{
			"name": "Carbonara",
			"reported_name": "Carbonara",
			"reported_ingredients": ["Pasta", "Milk", "Bacon", "Cheese"],
			"reported_allergens": ["Gluten", "Dairy"],
			"reported_season": "All Year",
			"reported_price": 750
		},
		{
			"name": "Chestnut Cake",
			"reported_name": "Chestnut Cake",
			"reported_ingredients": ["Chestnut", "Egg", "Milk", "Chocolate"],
			"reported_allergens": ["Tree Nuts", "Eggs", "Dairy"],
			"reported_season": "Autumn",
			"reported_price": 600
		},
		{
			"name": "Kale Pork Ramen",
			"reported_name": "Kale Pork Ramen",
			"reported_ingredients": ["Ramen Noodles", "Pork", "Kale", "Egg"],
			"reported_allergens": ["Gluten", "Eggs"],
			"reported_season": "Winter",
			"reported_price": 300
		},
		{
			"name": "Mackerel Asparagus Bowl",
			"reported_name": "Mackerel Asparagus Bowl",
			"reported_ingredients": ["Mackerel", "Asparagus", "Rice", "Mushroom"],
			"reported_allergens": ["Fish"],
			"reported_season": "Spring",
			"reported_price": 800
		}
	]
	resto_name = "Roswell"
	current_dish_index = 0
	show()
	load_dish(current_dish_index)

func open():
	var resto = GameState.get_current_resto()
	dishes = resto.dishes
	resto_name = resto.name
	current_dish_index = 0
	dish_marks = ["", "", "", "", ""]
	show()
	load_dish(current_dish_index)

func load_dish(index):
	var dish = dishes[index]

	# update counter and status
	dish_counter_label.text = "Dish " + str(index + 1) + " of 5"

	# show status if already judged, empty if not yet
	var mark = dish_marks[index]
	status_label.text = "Status: " + mark if mark != "" else ""

	# update dish info
	dish_name_label.text = dish.reported_name.to_upper()
	resto_name_label.text = resto_name + " Restaurant"
	ingredients_list.text = "\n".join(dish.reported_ingredients)

	if dish.reported_allergens.size() == 0 or dish.reported_allergens[0] == "None":
		allergens_list.text = "None"
	else:
		allergens_list.text = "\n".join(dish.reported_allergens)

	season_list.text = dish.reported_season
	price_list.text = "₱ " + str(dish.reported_price)

	# load dish image
	var filename = dish.name.to_lower().replace(" ", "_") + ".png"
	var texture = load("res://assets/dishes/" + filename)
	if texture:
		dish_image.texture = texture

	_update_buttons(index)

func _update_buttons(index):
	var already_judged = dish_marks[index] != ""

	# disable verdict buttons if dish already judged
	verified_btn.disabled = already_judged
	suspicious_btn.disabled = already_judged

	# left arrow — hidden on first dish
	left_btn.visible = index > 0

	# right arrow — hidden until current dish is judged
	# on dish 5, still shows if judged (leads to verdict popup)
	right_btn.visible = already_judged and index < 4 or (already_judged and index == 4)

func _on_verified():
	dish_marks[current_dish_index] = "Verified"
	#GameState.save_dish_mark(current_dish_index, "Verified")
	_update_buttons(current_dish_index)
	status_label.text = "Status: Verified"
	if current_dish_index < 4:
		current_dish_index += 1
		load_dish(current_dish_index)
	else:
		# last dish judged, auto open verdict
		_open_verdict()

func _on_suspicious():
	dish_marks[current_dish_index] = "Suspicious"
	#GameState.save_dish_mark(current_dish_index, "Suspicious")
	_update_buttons(current_dish_index)
	status_label.text = "Status: Suspicious"
	if current_dish_index < 4:
		current_dish_index += 1
		load_dish(current_dish_index)
	else:
		# last dish judged, auto open verdict
		_open_verdict()

func _on_left():
	if current_dish_index > 0:
		current_dish_index -= 1
		load_dish(current_dish_index)

func _on_right():
	if current_dish_index == 4:
		_open_verdict()
	else:
		current_dish_index += 1
		load_dish(current_dish_index)

func _open_verdict():
	hide()
	var verdict_popup = load("res://Scenes/resto_verdict.tscn").instantiate()
	get_tree().root.add_child(verdict_popup)
	verdict_popup.dish_report_ref = self  # this line passes the reference
	verdict_popup.show()

func _on_close():
	hide()
	
	
