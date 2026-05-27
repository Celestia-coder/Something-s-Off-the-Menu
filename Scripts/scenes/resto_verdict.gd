extends Control

var dish_report_ref = null
var pending_verdict = ""
var stamped_verdict = ""

@onready var resto_name_label = $DishReportPanel/TopSection/TitleContainer/RestaurantNameLabel
@onready var close_btn = $DishReportPanel/TopSection/CloseButton
@onready var verdict_stamp = $DishReportPanel/TopSection/FinalVerdict/Frame/StampContainer/VerdictStamp
@onready var confirmation = $DishReportPanel/TopSection/FinalVerdict/Frame/Confirmation
@onready var yes_btn = $DishReportPanel/TopSection/FinalVerdict/Frame/Confirmation/YesButton
@onready var no_btn = $DishReportPanel/TopSection/FinalVerdict/Frame/Confirmation/NoButton
@onready var clear_btn = $DishReportPanel/BottomSection/ClearToOperateButton
@onready var shutdown_btn = $DishReportPanel/BottomSection/ShutDownButton
@onready var left_btn = $LeftNextButton
@onready var right_btn = $RightNextButton

func _ready():
	close_btn.pressed.connect(_on_close)
	clear_btn.pressed.connect(_on_clear_to_operate)
	shutdown_btn.pressed.connect(_on_shutdown)
	yes_btn.pressed.connect(_on_yes)
	no_btn.pressed.connect(_on_no)
	left_btn.pressed.connect(_on_left)
	right_btn.pressed.connect(_on_right)

	verdict_stamp.hide()
	confirmation.hide()
	right_btn.hide()

	# set resto name from gamestate
	var resto = GameState.get_current_resto()
	resto_name_label.text = resto.name

func _on_clear_to_operate():
	pending_verdict = "CLEAR TO OPERATE"
	confirmation.show()

func _on_shutdown():
	pending_verdict = "SHUT DOWN"
	confirmation.show()

func _on_yes():
	confirmation.hide()
	stamped_verdict = pending_verdict

	var stamp_path = ""
	if pending_verdict == "CLEAR TO OPERATE":
		stamp_path = "res://Assets/Stamps/clear_to_operate_stamp.png"
	else:
		stamp_path = "res://Assets/Stamps/shutdown_stamp.png"

	var texture = load(stamp_path)
	if texture:
		verdict_stamp.texture = texture

	verdict_stamp.show()
	clear_btn.disabled = true
	shutdown_btn.disabled = true
	right_btn.show()

	# save verdict to gamestate
	GameState.save_verdict(pending_verdict)

func _on_no():
	confirmation.hide()
	pending_verdict = ""

func _on_left():
	hide()
	if dish_report_ref:
		dish_report_ref.current_dish_index = 4
		dish_report_ref.load_dish(4)
		dish_report_ref.show()

func _on_right():
	if not GameState.is_last_resto():
		GameState.unlock_next_resto()
		hide()
		if dish_report_ref:
			dish_report_ref.open()
			dish_report_ref.show()
	else:
		GameState.advance_day()
		hide()
		_end_day()

func _end_day():
	var desk = get_tree().root.get_node("Desk")
	if GameState.current_day > 5:
		await desk.play_day_outro()
		get_tree().change_scene_to_file("res://Scenes/final_evaluation.tscn")
	else:
		await desk.play_day_outro()
		get_tree().change_scene_to_file("res://Scenes/desk.tscn")

func _on_close():
	queue_free()
