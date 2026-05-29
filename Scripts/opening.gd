extends Control

@onready var scroll_container = $ScrollContainer
@onready var office_bg_music = $OfficeBgMusic
@onready var typewriter_sound = $TypewriterSound
@onready var button_click_sound = $ButtonClickSound

var full_text = "City Food Safety Investigation Bureau\nInternal Briefing — New Field Investigator\n\nYear 2143.\n\nThe city's restaurant industry has grown faster than anyone can regulate. Supply chains blur. Ingredient labels lie. Nobody checks.\n\nThree years ago, the Tainted Harvest Scandal changed that.\n\nForty-six people were hospitalized. Seven did not come home.\n\nHidden allergens. Falsified ingredients. Dishes falsely claimed to be at peak quality. Restaurants had been committing food fraud for years — and the city had no one watching.\n\nThe Bureau was established the following month. You are one of six investigators hired this quarter.\n\nEach morning, complaint folders arrive on your desk. Each folder is a restaurant under investigation. Inside: five dish reports.\n\nCross-reference every claim. Verify every allergen, every price, every peak season. Find the inconsistency. Stamp the folder.\n\nYou will not be told whether you were right. Not until the end of the week.\n\nDo not let them slip through.\n\n— Bureau Chief, City Food Safety Investigation Bureau\n\n— Day 1 Begins —\n\n\n\n"

var char_index = 0
var typing_speed = 0.02
var typing_timer = 0.0
var is_typing = true

@onready var letter_text = $ScrollContainer/LetterText
@onready var skip_btn = $SkipButton
@onready var begin_btn = $BeginButton

func _ready():
	skip_btn.pressed.connect(_on_skip)
	begin_btn.pressed.connect(_on_begin)
	letter_text.text = ""
	begin_btn.visible = false

	# ADDED - load and play sounds
	office_bg_music.stream = load("res://Assets/Sounds/office_bg_music.mp3")
	office_bg_music.stream.loop = true
	office_bg_music.volume_db = -10.0
	office_bg_music.play()

	typewriter_sound.stream = load("res://Assets/Sounds/typewriter1.mp3")
	typewriter_sound.stream.loop = true
	typewriter_sound.play()

	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")

func _process(delta):
	if not is_typing:
		return
	typing_timer += delta
	if typing_timer >= typing_speed:
		typing_timer = 0.0
		if char_index < full_text.length():
			char_index += 1
			letter_text.text = full_text.substr(0, char_index)
			scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
		else:
			is_typing = false
			begin_btn.visible = true
			# ADDED - stop typewriter when done
			typewriter_sound.stop()

func _on_skip():
	is_typing = false
	char_index = full_text.length()
	letter_text.text = full_text
	begin_btn.visible = true
	# ADDED
	button_click_sound.play()
	typewriter_sound.stop()

func _on_begin():
	# ADDED
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/desk.tscn")
