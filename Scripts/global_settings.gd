extends Node

func _ready() -> void:
	# 1. Change the actual window size to your target resolution
	DisplayServer.window_set_size(Vector2i(1600, 900))
	
	# 2. Tell the engine how to scale the UI elements up to the new size
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	
	# 3. Prevent your gorgeous pixel art from stretching or distorting
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	
	# 4. Center the window on the user's desktop monitor after resizing
	DisplayServer.window_set_position(DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() / 2) - (DisplayServer.window_get_size() / 2))
