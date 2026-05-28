extends Control

var current_slide = 0

var slides = [
{
	"image": "res://Assets/Tutorial/slide_1.png",
	"caption": "This is your workspace. Every day, restaurant folders appear on your desk. Use the reference guides to inspect each case before time runs out."
},
{
	"image": "res://Assets/Tutorial/slide_2.png",
	"caption": "Each workday has a global time limit.\n\nDay 1 — 1 Folder — 3:00\nDay 2 — 2 Folders — 4:00\nDay 3 — 2 Folders — 4:00\nDay 4 — 3 Folders — 5:00\nDay 5 — 3 Folders — 5:00\n\nUnfinished folders count against your final score."
},
{
	"image": "res://Assets/Tutorial/slide_3.png",
	"caption": "Each folder contains 5 dishes.\n\nCheck the ingredients, allergens, price, and peak season using your reference guides.\n\nIf the report is correct, mark it Verified.\nIf you find a violation, mark it Suspicious."
},
{
	"image": "res://Assets/Tutorial/slide_4.png",
	"caption": "After inspecting all 5 dishes, stamp the restaurant verdict.\n\nSHUT DOWN\n• 1 or more allergen violations\n• OR 2+ combined violations across ingredients, price, and season\n\nCLEAR TO OPERATE\n• 0 violations\n• OR exactly 1 ingredient, price, or season violation"
},
{
	"image": "res://Assets/Tutorial/slide_5.png",
	"caption": "Three guides are always available.\n\n• Seasonal Guide — verifies peak season\n• Ingredient Guide — verifies ingredients and allergens\n• Price Tier Guide — verifies price accuracy"
},
{
	"image": "res://Assets/Tutorial/slide_6.png",
	"caption": "All verdicts are revealed on Day 6.\n\nCorrect Shutdown: +100\nCorrect Clear: +50\nMissed Fraud: −50\nWrong Shutdown: −75\n\nInspector Ratings\n\n90–100% — Master Inspector\n70–89% — Good Inspector\n50–69% — Rookie Inspector\nBelow 50% — Fired"
}
]

@onready var title_label = $TutorialPanel/TitleLabel
@onready var slide_counter = $TutorialPanel/SlideCounter
@onready var slide_image = $TutorialPanel/SlideImage
@onready var slide_caption = $TutorialPanel/SlideCaptionContainer/SlideCaption
@onready var right_btn = $RightNextButton
@onready var left_btn = $LeftNextButton
@onready var close_btn = $CloseButton

#SOUND EFFECTS
@onready var button_click_sound = $ButtonClickSound

func _ready():
	right_btn.pressed.connect(_on_right)
	left_btn.pressed.connect(_on_left)
	close_btn.pressed.connect(_on_close)

	title_label.text = "HOW TO PLAY"
	load_slide(current_slide)
	
	button_click_sound.stream = load("res://Assets/Sounds/button_click.mp3")

func load_slide(index):
	var slide = slides[index]

	slide_image.texture = load(slide.image)
	slide_caption.text = slide.caption
	slide_counter.text = str(index + 1) + " / " + str(slides.size())

	left_btn.visible = index > 0
	right_btn.visible = index < slides.size() - 1

func _on_right():
	if current_slide < slides.size() - 1:
		button_click_sound.play()
		current_slide += 1
		load_slide(current_slide)
	else:
		_on_close()

func _on_left():
	if current_slide > 0:
		button_click_sound.play()
		current_slide -= 1
		load_slide(current_slide)

func _on_close():
	button_click_sound.play()
	await get_tree().create_timer(0.2).timeout
	queue_free()
