extends Control

@onready var play_btn = $MenuButtonContainer/PlayButton
@onready var tutorial_btn = $MenuButtonContainer/TutorialButton
@onready var exit_btn = $MenuButtonContainer/ExitButton

#SOUND EFFECTS
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
	button_click_sound.play()
	GameState.start_game()
	get_tree().change_scene_to_file("res://Scenes/opening.tscn")

func _on_tutorial():
	button_click_sound.play()
	var tutorial = load("res://Scenes/tutorial.tscn").instantiate()
	add_child(tutorial)
	tutorial.show()

func _on_exit():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
