extends Control

var day_timers = {
	1: 300,  # 5:00
	2: 510,  # 8:30
	3: 420,  # 7:00
	4: 510,  # 8:30
	5: 420   # 7:00
}

var time_remaining = 0
var timer_running = false
var dish_report_ref = null

@onready var day_label = $DayLabel
@onready var timer_label = $TimerLabel
@onready var option_btn = $OptionMenuButton
@onready var folder_btn = $FolderButton
@onready var peak_season_btn = $PeakseasonGuide
@onready var ingredients_btn = $IngredientsGuide
@onready var price_tier_btn = $PriceTierGuide
@onready var fade_layer = $FadeLayer
@onready var fade_rect = $FadeLayer/FadeRect
@onready var day_transition_label = $FadeLayer/FadeRect/DayTransitionLabel
@onready var time_up_label = $FadeLayer/FadeRect/TimeUpLabel 

func _ready():
	option_btn.pressed.connect(_on_option)
	folder_btn.pressed.connect(_on_folder)
	peak_season_btn.pressed.connect(_on_peak_season)
	ingredients_btn.pressed.connect(_on_ingredients)
	price_tier_btn.pressed.connect(_on_price_tier)

	if GameState.days.is_empty():
		GameState.start_game()

	day_label.text = "DAY " + str(GameState.current_day)
	time_remaining = day_timers[GameState.current_day]
	_update_timer_label()

	play_day_intro()

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
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_end():
	timer_running = false
	fade_layer.visible = true
	fade_rect.color = Color(0, 0, 0, 0)
	time_up_label.modulate.a = 1.0
	time_up_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(time_up_label, "modulate:a", 1.0, 0.3)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	
	var tween_out = create_tween()
	tween_out.tween_property(time_up_label, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	time_up_label.visible = false
	fade_layer.visible = false
	# ADDED end
	
	GameState.advance_day()
	_end_day()

func _on_option():
	get_tree().paused = true
	var option_menu = load("res://Scenes/option_menu.tscn").instantiate()
	add_child(option_menu)
	option_menu.show()

func _on_folder():
	if dish_report_ref == null or not is_instance_valid(dish_report_ref):
		dish_report_ref = load("res://Scenes/dish_report_popup.tscn").instantiate()
		add_child(dish_report_ref)
		dish_report_ref.open()
	else:
		dish_report_ref.show()

func _on_peak_season():
	var guide = load("res://Scenes/peak_season_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _on_ingredients():
	var guide = load("res://Scenes/ingredients_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _on_price_tier():
	var guide = load("res://Scenes/price_tier_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _end_day():
	if GameState.current_day > 5:
		await play_day_outro()
		get_tree().change_scene_to_file("res://Scenes/final_evaluation.tscn")
	else:
		await play_day_outro()
		get_tree().change_scene_to_file("res://Scenes/desk.tscn")

# ADDED - fade in animation when a new day starts
func play_day_intro():
	timer_running = false
	fade_layer.visible = true
	fade_rect.color = Color(0, 0, 0, 0)  # start transparent
	
	# text starts invisible then fades in
	day_transition_label.text = "DAY " + str(GameState.current_day)
	day_transition_label.modulate.a = 0.0
	day_transition_label.visible = true
	
	var tween_in = create_tween()
	tween_in.tween_property(day_transition_label, "modulate:a", 1.0, 1.0)
	await tween_in.finished
	
	await get_tree().create_timer(1.0).timeout
	
	# text fades out
	var tween_out = create_tween()
	tween_out.tween_property(day_transition_label, "modulate:a", 0.0, 1.0)
	await tween_out.finished
	
	day_transition_label.visible = false
	fade_layer.visible = false
	timer_running = true

func play_day_outro():
	timer_running = false
	fade_layer.visible = true
	day_transition_label.visible = false
	
	fade_rect.color = Color(0, 0, 0, 0) # start transparent
	
	# fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.0)
	await tween.finished
	
	# show text on black screen
	day_transition_label.text = "DAY " + str(GameState.current_day - 1) + " ENDED"
	day_transition_label.modulate.a = 1.0 
	day_transition_label.visible = true
	await get_tree().create_timer(1.5).timeout
