extends Control

@onready var resume_btn = $OptionMenuContainer/ResumeButton
@onready var restart_btn = $OptionMenuContainer/RestartButton
@onready var main_menu_btn = $OptionMenuContainer/MainMenuButton

#SOUND EFFECTS
@onready var button_click_sound = $ButtonClickSound

func _ready():
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	main_menu_btn.pressed.connect(_on_main_menu)
	
	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")

func _on_resume():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	hide()

func _on_restart():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/desk.tscn")

func _on_main_menu():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
