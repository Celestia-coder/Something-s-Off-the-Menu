extends Control

@onready var correct_score = $FinalEvaluationPanel/MiddleSection/CorrectReportsContainer/CorrectScore
@onready var false_score = $FinalEvaluationPanel/MiddleSection/FalseViolationsContainer/FalseScore
@onready var critical_score = $FinalEvaluationPanel/MiddleSection/CriticalViolationsContainer/CriticalScore
@onready var verdict_stamp = $FinalEvaluationPanel/MiddleSection/InvestigationSummary2/Frame/StampContainer/VerdictStamp
@onready var supervisor_note = $FinalEvaluationPanel/BottomSection/SupervisorNote
@onready var accuracy_label = $FinalEvaluationPanel/MiddleSection/InvestigationSummary2/FinalAccuracy
@onready var close_btn = $FinalEvaluationPanel/TopSection/CloseButton

func _ready():
	close_btn.pressed.connect(_on_close)
	
	var results = ScoreManager.compute()
	
	# update investigation summary counts
	correct_score.text = str(results.correct_reports)
	false_score.text = str(results.false_violations)
	critical_score.text = str(results.critical_violations)
	accuracy_label.text = str(results.accuracy) + "%"

	# load stamp based on accuracy rating
	var stamp_path = ""
	match results.rating:
		"Master Inspector":
			stamp_path = "res://Assets/Stamps/master_stamp.png"
		"Good Inspector":
			stamp_path = "res://Assets/Stamps/good_stamp.png"
		"Rookie":
			stamp_path = "res://Assets/Stamps/rookie_stamp.png"
		"Fired":
			stamp_path = "res://Assets/Stamps/shutdown_stamp.png"

	var texture = load(stamp_path)
	if texture:
		verdict_stamp.texture = texture

	# set supervisor note based on rating
	supervisor_note.text = results.supervisor_note

func _on_close():
	queue_free()
