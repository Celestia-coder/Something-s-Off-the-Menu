extends Control

var current_dish_index = 0
var dishes = []
var resto_name = ""

# stores the player's mark per dish, empty string means not yet judged
var dish_marks = ["", "", "", "", ""]

var verdict_popup_ref = null

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

func open():
	# get current resto data from gamestate
	var resto = GameState.get_current_resto()
	dishes = resto.dishes
	resto_name = resto.name
	current_dish_index = 0
	dish_marks = ["", "", "", "", ""]
	# reset verdict popup ref for new resto
	verdict_popup_ref = null
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
	resto_name_label.text = resto_name
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
	right_btn.visible = already_judged and index < 4 or (already_judged and index == 4)

func _on_verified():
	dish_marks[current_dish_index] = "Verified"
	GameState.save_dish_mark(current_dish_index, "Verified")
	_update_buttons(current_dish_index)
	status_label.text = "Status: Verified"
	_disable_verdict_buttons()
	if current_dish_index < 4:
		current_dish_index += 1
		load_dish(current_dish_index)
	else:
		_open_verdict()

func _on_suspicious():
	dish_marks[current_dish_index] = "Suspicious"
	GameState.save_dish_mark(current_dish_index, "Suspicious")
	_update_buttons(current_dish_index)
	status_label.text = "Status: Suspicious"
	_disable_verdict_buttons()
	if current_dish_index < 4:
		current_dish_index += 1
		load_dish(current_dish_index)
	else:
		_open_verdict()

func _disable_verdict_buttons():
	verified_btn.disabled = true
	suspicious_btn.disabled = true
	# re-enable after 0.3 seconds
	await get_tree().create_timer(0.3).timeout
	_update_buttons(current_dish_index)

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
	if verdict_popup_ref == null:
		verdict_popup_ref = load("res://Scenes/resto_verdict.tscn").instantiate()
		get_tree().root.add_child(verdict_popup_ref)
		verdict_popup_ref.dish_report_ref = self
	# restore stamp if already verdicted
	if verdict_popup_ref.stamped_verdict != "":
		verdict_popup_ref.clear_btn.disabled = true
		verdict_popup_ref.shutdown_btn.disabled = true
		verdict_popup_ref.right_btn.show()
		verdict_popup_ref.verdict_stamp.show()
	verdict_popup_ref.show()

func _on_close():
	hide()
