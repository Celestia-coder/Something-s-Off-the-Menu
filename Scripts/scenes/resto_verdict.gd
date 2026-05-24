extends Control

# reference to dish report so we can go back to it
var dish_report_ref = null

# tracks which verdict the player selected before confirming
var pending_verdict = ""

@onready var resto_name_label = $DishReportPanel/TopSection/TitleContainer/RestaurantNameLabel
@onready var close_btn = $DishReportPanel/TopSection/CloseButton
@onready var verdict_stamp = $DishReportPanel/TopSection/FinalVerdict/Frame/StampContainer/VerdictStamp
@onready var confirmation = $DishReportPanel/TopSection/FinalVerdict/Frame/Confirmation
@onready var yes_btn = $DishReportPanel/TopSection/FinalVerdict/Frame/Confirmation/YesButton
@onready var no_btn = $DishReportPanel/TopSection/FinalVerdict/Frame/Confirmation/NoButton
@onready var clear_btn = $DishReportPanel/BottomSection/ClearToOperateButton
@onready var shutdown_btn = $DishReportPanel/BottomSection/ShutDownButton
@onready var left_btn = $LeftNextButton

func _ready():
	close_btn.pressed.connect(_on_close)
	clear_btn.pressed.connect(_on_clear_to_operate)
	shutdown_btn.pressed.connect(_on_shutdown)
	yes_btn.pressed.connect(_on_yes)
	no_btn.pressed.connect(_on_no)
	left_btn.pressed.connect(_on_left)

	# hide stamp and confirmation by default
	verdict_stamp.hide()
	confirmation.hide()

	# set resto name
	#var resto = GameState.get_current_resto()
	#resto_name_label.text = resto.name + " Restaurant"

func _on_clear_to_operate():
	pending_verdict = "CLEAR TO OPERATE"
	confirmation.show()

func _on_shutdown():
	pending_verdict = "SHUT DOWN"
	confirmation.show()

func _on_yes():
	confirmation.hide()

	# load the correct stamp image based on verdict
	var stamp_path = ""
	if pending_verdict == "CLEAR TO OPERATE":
		stamp_path = "res://Assets/Stamps/clear_to_operate_stamp.png"
	else:
		stamp_path = "res://Assets/Stamps/shutdown_stamp.png"

	var texture = load(stamp_path)
	if texture:
		verdict_stamp.texture = texture

	# show stamp and lock verdict buttons
	verdict_stamp.show()
	clear_btn.disabled = true
	shutdown_btn.disabled = true

	# save verdict to gamestate
	#GameState.save_verdict(pending_verdict)

func _on_no():
	# player changed their mind, hide confirmation
	confirmation.hide()
	pending_verdict = ""

func _on_left():
	# go back to dish report at dish 5
	hide()
	if dish_report_ref:
		dish_report_ref.current_dish_index = 4
		dish_report_ref.load_dish(4)
		dish_report_ref.show()

func _on_close():
	hide()
