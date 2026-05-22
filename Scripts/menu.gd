extends Control

@onready var play_button: Button = $MenuButtonContainer/PlayButton
@onready var tutorial_button: Button = $MenuButtonContainer/TutorialButton
@onready var exit_button: Button = $MenuButtonContainer/ExitButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/desk_view.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/desk_view.tscn")


#func _on_exit_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Scenes/desk_view.tscn")
	
func _on_exit_button_pressed():
	$DishReport/ItemPopUp.open_report()
