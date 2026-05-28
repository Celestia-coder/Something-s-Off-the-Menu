extends Control

@onready var play_btn = $MenuButtonContainer/PlayButton
@onready var tutorial_btn = $MenuButtonContainer/TutorialButton
@onready var exit_btn = $MenuButtonContainer/ExitButton
@onready var menu_bg_music = $MenuBgMusic
@onready var button_click_sound = $ButtonClickSound

func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	tutorial_btn.pressed.connect(_on_tutorial)
	exit_btn.pressed.connect(_on_exit)
	
	menu_bg_music.stream = load("res://Assets/Sounds/menu_bg_music.mp3")
	menu_bg_music.stream.loop = true
	menu_bg_music.play()

	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")

func _on_play():
	# generate all 5 days before going to desk
	button_click_sound.play()
	GameState.start_game()
	get_tree().change_scene_to_file("res://Scenes/desk.tscn")

func _on_tutorial():
	# TODO: add tutorial scene later
	button_click_sound.play()
	pass

func _on_exit():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
