extends Control

@onready var resume_btn = $OptionMenuContainer/ResumeButton
@onready var restart_btn = $OptionMenuContainer/RestartButton
@onready var main_menu_btn = $OptionMenuContainer/MainMenuButton

func _ready():
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	main_menu_btn.pressed.connect(_on_main_menu)

func _on_resume():
	get_tree().paused = false
	hide()

func _on_restart():
	get_tree().paused = false
	#GameState.start_game()
	get_tree().change_scene_to_file("res://Scenes/desk.tscn")

func _on_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
