extends Control

var day_timers = {
	1: 180,  # 3:00
	2: 240,  # 4:00
	3: 240,  # 4:00
	4: 300,  # 5:00
	5: 300   # 5:00
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

#SOUND EFFECTS
@onready var office_bg_music = $OfficeBgMusic
@onready var day_bg_music = $DayBgMusic
@onready var typewriter_sound = $TypewriterSound
@onready var button_click_sound = $ButtonClickSound
@onready var open_folder_sound = $OpenFolderSound

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
	
	_setup_audio()

	play_day_intro()

func _setup_audio():
	# load music
	office_bg_music.stream = load("res://Assets/Sounds/office_bg_music.mp3")
	day_bg_music.stream = load("res://Assets/Sounds/day_bg_music.mp3")
	typewriter_sound.stream = load("res://Assets/Sounds/typewriter2.mp3")
	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")
	open_folder_sound.stream = load("res://Assets/Sounds/open_folder1.wav")

	# both music tracks loop
	office_bg_music.stream.loop = true
	day_bg_music.stream.loop = true

	# office music always full volume
	office_bg_music.volume_db = 0.0

	# day_bg_music volume increases per day
	# day 1 = 20%, day 2 = 40%, day 3 = 60%, day 4 = 80%, day 5 = 100%
	var day_volume_percent = GameState.current_day * 0.2  # 0.2, 0.4, 0.6, 0.8, 1.0
	day_bg_music.volume_db = linear_to_db(day_volume_percent)

	office_bg_music.play()
	day_bg_music.play()

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
	
	var times_up_sfx = AudioStreamPlayer.new()
	times_up_sfx.stream = load("res://Assets/Sound/times_up.mp3")
	add_child(times_up_sfx)
	times_up_sfx.play()
	
	var tween = create_tween()
	tween.tween_property(time_up_label, "modulate:a", 1.0, 0.3)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	
	var tween_out = create_tween()
	tween_out.tween_property(time_up_label, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	time_up_label.visible = false
	fade_layer.visible = false
	
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
		open_folder_sound.play()
		dish_report_ref.show()

func _on_peak_season():
	button_click_sound.play()
	var guide = load("res://Scenes/peak_season_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _on_ingredients():
	#button_click_sound.play()
	var guide = load("res://Scenes/ingredients_guide.tscn").instantiate()
	add_child(guide)
	guide.show()

func _on_price_tier():
	button_click_sound.play()
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

func play_day_intro():
	timer_running = false
	fade_layer.visible = true
	fade_rect.color = Color(0, 0, 0, 0)  # start transparent
	
	# text starts invisible then fades in
	day_transition_label.text = "DAY " + str(GameState.current_day)
	day_transition_label.modulate.a = 0.0
	day_transition_label.visible = true
	
	typewriter_sound.play()
	
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
	
	office_bg_music.stop()
	day_bg_music.stop()
	
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
