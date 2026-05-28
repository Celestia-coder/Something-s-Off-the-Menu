extends Control

@onready var close_btn = $PeakSeasonPanel/TopSection/CloseButton

#SOUND EFFECTS
@onready var button_click_sound = $ButtonClickSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_close():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	queue_free()
