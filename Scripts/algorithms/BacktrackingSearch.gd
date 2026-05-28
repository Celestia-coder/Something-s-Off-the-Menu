extends Node

# goes through these in order, but shuffled in generate_fake
# so violations are spread across all types
var variables = [
	"reported_price",
	"reported_season",
	"reported_allergens",
	"reported_ingredients"
]

var seasons = [
	"Spring",
	"Summer",
	"Autumn",
	"Winter",
	"All Year"
]

var tier_ranges = {
	"A": [100, 499],
	"B": [500, 999],
	"C": [1000, 2000]
}

# vanillin and collagen are from the dessert dishes
var all_allergens = [
	"Gluten", "Dairy", "Eggs",
	"Shellfish", "Fish", "Soy", "Tree Nuts",
	"Vanillin", "Collagen"
]

# fake ingredients to swap in for ingredient violations
# these are plausible but wrong ingredients
var fake_ingredients = [
	"Carrot", "Potato", "Onion", "Celery",
	"Spinach", "Pepper", "Ginger", "Garlic",
	"Broccoli", "Cabbage", "Turnip", "Radish"
]

func generate_legit():
	var base = DishDatabase.dishes.pick_random().duplicate(true)
	_init_reported_fields(base)
	# 0 = no violations
	return backtrack(base, variables.duplicate(), 0, 0)

func generate_fake(day):
	var base = DishDatabase.dishes.pick_random().duplicate(true)
	_init_reported_fields(base)
	# shuffle so violations arent always price
	var shuffled = variables.duplicate()
	shuffled.shuffle()
	
	if day >= 4 and randf() < 0.5:
		shuffled.erase("reported_allergens")
		shuffled.push_front("reported_allergens")
	
	# 1 = exactly one violation
	return backtrack(base, shuffled, 0, 1, day)

func _init_reported_fields(dish):
	# set all reported fields to correct values as starting point
	# backtracking will overwrite whichever one becomes the violation
	var price_range = tier_ranges[dish.tier]
	dish.reported_name = dish.name
	dish.reported_price = (price_range[0] + price_range[1]) / 2
	dish.reported_season = dish.season
	dish.reported_allergens = dish.allergens.duplicate()
	dish.reported_ingredients = dish.ingredients.duplicate()

func backtrack(dish, vars, index, target_violations, day = 1):
	# all variables assigned, check if violation count matches target
	if index >= vars.size():
		var v = AC3.validate(dish)
		if total(v) == target_violations:
			return dish
		return null

	var variable = vars[index]
	var domain = get_domain(dish, variable, day, target_violations)

	for value in domain:
		var copy = dish.duplicate(true)
		copy[variable] = value

		var partial = AC3.validate(copy)

		# prune if violations already exceed target
		if total(partial) <= target_violations:
			var result = backtrack(copy, vars, index + 1, target_violations, day)
			if result != null:
				return result

	# no valid value found, backtrack
	return null

func get_domain(dish, variable, day, target):
	match variable:
		"reported_price":
			var price_range = tier_ranges[dish.tier]
			var correct = (price_range[0] + price_range[1]) / 2

			if target == 0:
				return [correct]

			var wrong_price
			match day:
				1: wrong_price = price_range[1] + 200
				3: wrong_price = int(price_range[1] * 1.2)
				4: wrong_price = price_range[1] + 10
				_: wrong_price = price_range[1] + 50

			var domain = [wrong_price, correct]
			domain.shuffle()
			return domain

		"reported_season":
			if target == 0:
				return [dish.season]
			var wrong = seasons.duplicate()
			wrong.erase(dish.season)
			
			wrong.shuffle()
			wrong.append(dish.season)
			return wrong

		"reported_allergens":
			if target == 0:
				return [dish.allergens]
			var fake_options = []
			if dish.allergens.size() > 0 and dish.allergens[0] != "None":
				var hidden = dish.allergens.duplicate()
				hidden.pop_back()
				fake_options.append(hidden)
			for a in all_allergens:
				if a not in dish.allergens:
					var false_added = dish.allergens.duplicate()
					if false_added.size() > 0 and false_added[0] == "None":
						false_added = [a]
					else:
						false_added.append(a)
					fake_options.append(false_added)
					break
			
			fake_options.shuffle()
			fake_options.append(dish.allergens)
			return fake_options

		"reported_ingredients":
			if target == 0:
				return [dish.ingredients]
			var fake_options = []
			if dish.ingredients.size() > 0:
				var available_fakes = []
				for f in fake_ingredients:
					if f not in dish.ingredients:
						available_fakes.append(f)
				if available_fakes.size() > 0:
					for replace_index in range(dish.ingredients.size()):
						var swapped = dish.ingredients.duplicate()
						swapped[replace_index] = available_fakes[randi() % available_fakes.size()]
						fake_options.append(swapped)
						break
			fake_options.append(dish.ingredients)
			return fake_options

	return []

func total(v):
	# sum of all violation counts
	return (
		v.allergen +
		v.price +
		v.season +
		v.ingredient
	)
