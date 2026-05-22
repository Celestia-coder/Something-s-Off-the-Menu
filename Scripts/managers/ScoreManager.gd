extends Node

# points per action based on game mechanics
const CORRECT_SHUTDOWN = 100
const CORRECT_CLEAR = 50
const MISSED_FRAUD = -50
const WRONG_SHUTDOWN = -75

# supervisor notes per rating
var supervisor_notes = {
	"Master Inspector": "Outstanding work, Inspector. Your attention to detail is unmatched. The bureau is proud to have you.",
	"Good Inspector": "You have shown dedication to the standards of the bureau. Continue to improve your judgment and attention to detail. Keep up the good work!",
	"Rookie": "You still have much to learn, Inspector. Review the guidelines carefully and trust the reference books.",
	"Fired": "Your performance is below acceptable standards. The bureau can no longer trust your judgment. You are dismissed."
}

func compute():
	var all_verdicts = GameState.get_all_verdicts()

	var correct_reports = 0
	var false_violations = 0
	var critical_violations = 0
	var total_score = 0
	var total_restos = 0
	var correct_restos = 0

	# loop through all days
	for day_verdicts in all_verdicts:
		# loop through all restos per day
		for resto in day_verdicts:
			total_restos += 1

			var player = resto.player_verdict
			var actual = resto.actual_status

			# unfinished restos (timer ran out) count as missed
			if player == "":
				if actual == "SHUT DOWN":
					critical_violations += 1
					total_score += MISSED_FRAUD
				else:
					correct_restos += 1
				continue

			# compare player verdict vs actual status
			if player == actual:
				correct_restos += 1
				if player == "SHUT DOWN":
					total_score += CORRECT_SHUTDOWN
				else:
					total_score += CORRECT_CLEAR
			else:
				if player == "SHUT DOWN" and actual == "CLEAR TO OPERATE":
					total_score += WRONG_SHUTDOWN
				elif player == "CLEAR TO OPERATE" and actual == "SHUT DOWN":
					total_score += MISSED_FRAUD

			# dish-level counts for investigation summary
			var dishes = GameState.days[all_verdicts.find(day_verdicts)][day_verdicts.find(resto)].dishes
			for i in range(dishes.size()):
				var dish = dishes[i]
				var mark = resto.player_dish_marks[i] if i < resto.player_dish_marks.size() else ""
				var is_fake = _dish_is_fake(dish)

				if mark == "Suspicious" and is_fake:
					correct_reports += 1
				elif mark == "Verified" and not is_fake:
					correct_reports += 1
				elif mark == "Suspicious" and not is_fake:
					false_violations += 1
				elif mark == "Verified" and is_fake:
					critical_violations += 1

	var accuracy = int((float(correct_restos) / float(total_restos)) * 100)
	var rating = _get_rating(accuracy)

	return {
		"correct_reports": correct_reports,
		"false_violations": false_violations,
		"critical_violations": critical_violations,
		"total_score": total_score,
		"accuracy": accuracy,
		"rating": rating,
		"supervisor_note": supervisor_notes[rating]
	}

func _dish_is_fake(dish):
	# a dish is fake if ac3 finds any violation in it
	var v = AC3.validate(dish)
	return (v.allergen + v.price + v.season + v.ingredient) > 0

func _get_rating(accuracy):
	if accuracy >= 90:
		return "Master Inspector"
	elif accuracy >= 70:
		return "Good Inspector"
	elif accuracy >= 50:
		return "Rookie"
	else:
		return "Fired"
