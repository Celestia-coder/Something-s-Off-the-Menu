extends Control

@onready var close_btn = $PeakSeasonPanel/TopSection/CloseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_btn.pressed.connect(_on_close)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_close():
	queue_free()
