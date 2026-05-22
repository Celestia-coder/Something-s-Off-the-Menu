extends Node

# number of restos per day
var resto_count = {
	1: 1,
	2: 2,
	3: 2,
	4: 3,
	5: 3
}

# how many restos can be fraudulent per day [min, max]
var fraudulent_range = {
	1: [0, 1],
	2: [0, 2],
	3: [0, 2],
	4: [1, 2],
	5: [1, 3]
}

# how many fake dishes a fraudulent resto gets per day
var fake_per_fraudulent = {
	1: 1,
	2: 1,
	3: 2,
	4: 2,
	5: 3
}

func generate_day(day):
	var restaurants = []
	var names = RestoNames.get_shuffled_names(resto_count[day])

	# pick a random fraudulent count within the allowed range
	var range_val = fraudulent_range[day]
	var fraud_count = randi_range(range_val[0], range_val[1])

	# mark which restos are fraudulent then shuffle
	# so the fraud ones arent always first
	var fraud_flags = []
	for i in range(resto_count[day]):
		fraud_flags.append(i < fraud_count)
	fraud_flags.shuffle()

	for i in range(names.size()):
		var resto = generate_resto(names[i], day, fraud_flags[i])
		restaurants.append(resto)

	return restaurants

@warning_ignore("unused_parameter")
func generate_resto(resto_name, day, is_fraud):
	var fake_count = fake_per_fraudulent[day] if is_fraud else 0
	var legit_count = 5 - fake_count

	var dishes = []
	var used_names = []

	# generate fake dishes first
	for i in range(fake_count):
		var dish = get_unique_dish(true, day, used_names)
		if dish:
			dishes.append(dish)
			used_names.append(dish.name)

	# fill the rest with legit dishes
	for i in range(legit_count):
		var dish = get_unique_dish(false, day, used_names)
		if dish:
			dishes.append(dish)
			used_names.append(dish.name)

	# shuffle so fake dishes arent always in the same position
	dishes.shuffle()

	# accumulate violations across all 5 dishes
	var total_violations = {
		"allergen": 0,
		"price": 0,
		"season": 0,
		"ingredient": 0
	}
	for dish in dishes:
		var v = AC3.validate(dish)
		total_violations.allergen += v.allergen
		total_violations.price += v.price
		total_violations.season += v.season
		total_violations.ingredient += v.ingredient

	# decision tree determines the actual status based on total violations
	var actual_status = DecisionTree.classify(total_violations)

	return {
		"name": resto_name,
		"dishes": dishes,
		"actual_status": actual_status
	}

func get_unique_dish(is_fake, day, used_names):
	# retry if backtracking returns null or dish name is already used in this resto
	var attempts = 0
	while attempts < 20:
		var dish
		if is_fake:
			dish = BacktrackingSearch.generate_fake(day)
		else:
			dish = BacktrackingSearch.generate_legit()

		if dish != null and dish.name not in used_names:
			return dish

		attempts += 1

	# gave up after 20 tries
	return null
