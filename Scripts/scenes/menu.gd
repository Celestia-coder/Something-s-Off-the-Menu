extends Control

@onready var play_btn = $MenuButtonContainer/PlayButton
@onready var tutorial_btn = $MenuButtonContainer/TutorialButton
@onready var exit_btn = $MenuButtonContainer/ExitButton

func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	tutorial_btn.pressed.connect(_on_tutorial)
	exit_btn.pressed.connect(_on_exit)

func _on_play():
	# generate all 5 days before going to desk
	GameState.start_game()
	get_tree().change_scene_to_file("res://Scenes/desk.tscn")

func _on_tutorial():
	# TODO: add tutorial scene later
	pass

func _on_exit():
	get_tree().quit()
