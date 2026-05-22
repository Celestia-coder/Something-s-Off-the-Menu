extends Node

# current day the player is on
var current_day = 1

# current resto tab the player is on per day
var current_resto_index = 0

# all generated data for all 5 days
# structure: days[day_index][resto_index] = { name, dishes, actual_status }
var days = []

# stores player progress per day per resto
# structure: verdicts[day_index][resto_index] = {
#     player_dish_marks: [],
#     player_verdict: "",
#     actual_status: ""
# }
var verdicts = []

func start_game():
	current_day = 1
	current_resto_index = 0
	days = []
	verdicts = []

	# generate all 5 days upfront
	for day in range(1, 6):
		var restos = DayGenerator.generate_day(day)
		days.append(restos)

		# prepare empty verdict slots for each resto
		var day_verdicts = []
		for resto in restos:
			day_verdicts.append({
				"player_dish_marks": [],
				"player_verdict": "",
				"actual_status": resto.actual_status
			})
		verdicts.append(day_verdicts)

func get_current_restos():
	# returns the restos for the current day
	return days[current_day - 1]

func get_current_resto():
	# returns the active resto the player is inspecting
	return days[current_day - 1][current_resto_index]

func save_dish_mark(dish_index, mark):
	# store verified or suspicious for a dish
	var day_verdicts = verdicts[current_day - 1][current_resto_index]
	# fill with empty strings if not yet initialized
	while day_verdicts.player_dish_marks.size() <= dish_index:
		day_verdicts.player_dish_marks.append("")
	day_verdicts.player_dish_marks[dish_index] = mark

func save_verdict(verdict):
	# lock in the player's resto verdict
	verdicts[current_day - 1][current_resto_index].player_verdict = verdict

func is_resto_finished(resto_index):
	# check if a verdict has been submitted for this resto
	return verdicts[current_day - 1][resto_index].player_verdict != ""

func unlock_next_resto():
	# move to the next resto tab
	current_resto_index += 1

func advance_day():
	current_day += 1
	current_resto_index = 0

func is_last_resto():
	# check if this is the final resto for the current day
	return current_resto_index >= days[current_day - 1].size() - 1

func get_all_verdicts():
	# used by scoremanager on day 6
	return verdicts
