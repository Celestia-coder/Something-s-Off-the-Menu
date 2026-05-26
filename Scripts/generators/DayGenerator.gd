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
	var range_val = fraudulent_range[day]
	var fraud_count = randi_range(range_val[0], range_val[1])
	var fraud_flags = []
	for i in range(resto_count[day]):
		fraud_flags.append(i < fraud_count)
	fraud_flags.shuffle()

	# track used dish names across ALL restos in this day
	var day_used_names = []

	for i in range(names.size()):
		var resto = generate_resto(names[i], day, fraud_flags[i], day_used_names)
		restaurants.append(resto)

	return restaurants

@warning_ignore("unused_parameter")
func generate_resto(resto_name, day, is_fraud, day_used_names):
	var fake_count = fake_per_fraudulent[day] if is_fraud else 0
	var legit_count = 5 - fake_count
	var dishes = []

	for i in range(fake_count):
		var dish = get_unique_dish(true, day, day_used_names)
		if dish:
			dishes.append(dish)
			day_used_names.append(dish.name)

	for i in range(legit_count):
		var dish = get_unique_dish(false, day, day_used_names)
		if dish:
			dishes.append(dish)
			day_used_names.append(dish.name)

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
	
	# DEBUG — remove after testing
	print("=== ", resto_name, " ===")
	print("Intended fraud: ", is_fraud)
	print("Actual status: ", actual_status)
	for dish in dishes:
		var v = AC3.validate(dish)
		var violation_type = "none"
		if v.price > 0: violation_type = "price"
		elif v.season > 0: violation_type = "season"
		elif v.allergen > 0: violation_type = "allergen"
		elif v.ingredient > 0: violation_type = "ingredient"
		print("  - ", dish.name,
			" | price: ", dish.reported_price,
			" | season: ", dish.reported_season,
			" | allergens: ", dish.reported_allergens,
			" | ingredients: ", dish.reported_ingredients,
			" | violation: ", violation_type)
	print("---")

	return {
		"name": resto_name,
		"dishes": dishes,
		"actual_status": actual_status
	}
	

func get_unique_dish(is_fake, day, used_names):
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
		
	# fallback — pick any unused dish from database directly
	for dish in DishDatabase.dishes:
		if dish.name not in used_names:
			var fallback = dish.duplicate(true)
			BacktrackingSearch._init_reported_fields(fallback)
			return fallback
	return null
