extends Control

# timer duration per day in seconds based on game mechanics
var day_timers = {
	1: 300,  # 5:00
	2: 510,  # 8:30
	3: 420,  # 7:00
	4: 510,  # 8:30
	5: 420   # 7:00
}

var time_remaining = 0
var timer_running = false

@onready var day_label = $DayLabel
@onready var timer_label = $TimerLabel
@onready var option_btn = $OptionMenuButton
@onready var folder_btn = $FolderButton
@onready var peak_season_btn = $PeakseasonGuide
@onready var ingredients_btn = $IngredientsGuide
@onready var price_tier_btn = $PriceTierGuide

func _ready():
	option_btn.pressed.connect(_on_option)
	folder_btn.pressed.connect(_on_folder)
	peak_season_btn.pressed.connect(_on_peak_season)
	ingredients_btn.pressed.connect(_on_ingredients)
	price_tier_btn.pressed.connect(_on_price_tier)

	# update day label
	day_label.text = "DAY " + str(GameState.current_day)

	# set timer for current day
	time_remaining = day_timers[GameState.current_day]
	timer_running = true
	_update_timer_label()

func _process(delta):
	if not timer_running:
		return

	time_remaining -= delta

	if time_remaining <= 0:
		time_remaining = 0
		timer_running = false
		_on_timer_end()

	_update_timer_label()

func _update_timer_label():
	# format as MM:SS
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_end():
	# day is over, move to next day
	GameState.advance_day()
	_end_day()

func _on_option():
	# pause game and show option menu
	get_tree().paused = true
	var option_menu = load("res://Scenes/option_menu.tscn").instantiate()
	add_child(option_menu)
	option_menu.show()

func _on_folder():
	var dish_report = load("res://Scenes/dish_report_popup.tscn").instantiate()
	add_child(dish_report)
	# open() is handled by _ready() test data for now
	# once gamestate is wired, replace with dish_report.open()

func _on_peak_season():
	# open peak season guide as popup
	var guide = load("res://Scenes/peak_season_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _on_ingredients():
	# open ingredients guide as popup
	var guide = load("res://Scenes/ingredients_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _on_price_tier():
	# open price tier guide as popup
	var guide = load("res://Scenes/price_tier_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _end_day():
	if GameState.current_day > 5:
		# all days done, go to final evaluation
		get_tree().change_scene_to_file("res://Scenes/final_evaluation.tscn")
	else:
		# reload desk for the next day
		get_tree().change_scene_to_file("res://Scenes/desk.tscn")
