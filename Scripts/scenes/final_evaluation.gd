extends Control

@onready var fade_layer = $FadeLayer
@onready var fade_rect = $FadeLayer/FadeRect
@onready var day_transition_label = $FadeLayer/FadeRect/DayTransitionLabel
@onready var correct_score = $FinalEvaluationPanel/MiddleSection/CorrectReportsContainer/CorrectScore
@onready var false_score = $FinalEvaluationPanel/MiddleSection/FalseViolationsContainer/FalseScore
@onready var critical_score = $FinalEvaluationPanel/MiddleSection/CriticalViolationsContainer/CriticalScore
@onready var verdict_stamp = $FinalEvaluationPanel/MiddleSection/InvestigationSummary2/Frame/StampContainer/VerdictStamp
@onready var supervisor_note = $FinalEvaluationPanel/BottomSection/SupervisorNote
@onready var accuracy_label = $FinalEvaluationPanel/MiddleSection/InvestigationSummary2/FinalAccuracy
@onready var close_btn = $FinalEvaluationPanel/TopSection/CloseButton

#SOUND EFFECTS
@onready var outro_music = $OutroMusic
@onready var button_click_sound = $ButtonClickSound

func _ready():
	close_btn.pressed.connect(_on_close)
	
	outro_music.stream = load("res://Assets/Sounds/outro1.mp3")
	outro_music.stream.loop = true
	outro_music.play()
	
	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")

	var results = ScoreManager.compute()

	correct_score.text = str(results.correct_reports)
	false_score.text = str(results.false_violations)
	critical_score.text = str(results.critical_violations)
	accuracy_label.text = str(results.accuracy) + "%"

	var stamp_path = ""
	match results.rating:
		"Master Inspector":
			stamp_path = "res://Assets/Stamps/master_stamp.png"
		"Good Inspector":
			stamp_path = "res://Assets/Stamps/good_stamp.png"
		"Rookie":
			stamp_path = "res://Assets/Stamps/rookie_stamp.png"
		"Fired":
			stamp_path = "res://Assets/Stamps/fired_stamp.png"
	var texture = load(stamp_path)
	if texture:
		verdict_stamp.texture = texture

	supervisor_note.text = results.supervisor_note

	play_final_intro()

func play_final_intro():
	fade_layer.visible = true
	fade_rect.color = Color(0, 0, 0, 1)
	day_transition_label.text = "DAY 6 — FINAL EVALUATION"
	day_transition_label.modulate.a = 1.0
	day_transition_label.visible = true

	await get_tree().create_timer(2.0).timeout 

	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 1.0)
	await tween.finished

	day_transition_label.visible = false
	fade_layer.visible = false

func _on_close():
	button_click_sound.play()
	GameState.current_day = 1
	GameState.current_resto_index = 0
	GameState.days = []
	GameState.verdicts = []
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
