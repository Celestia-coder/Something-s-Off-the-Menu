extends Node

# goes through these in order
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

func generate_legit():
	var base = DishDatabase.dishes.pick_random().duplicate(true)
	# 0 = no violations
	return backtrack(base, 0, 0)

func generate_fake(day):
	var base = DishDatabase.dishes.pick_random().duplicate(true)
	# 1 = exactly one violation
	return backtrack(base, 0, 1, day)

func backtrack(dish, index, target_violations, day = 1):
	# all variables assigned, check if violation count matches target
	if index >= variables.size():
		var v = AC3.validate(dish)
		if total(v) == target_violations:
			return dish
		return null

	var variable = variables[index]
	var domain = get_domain(dish, variable, day, target_violations)

	for value in domain:
		var copy = dish.duplicate(true)
		copy[variable] = value

		var partial = AC3.validate(copy)

		# prune if violations already exceed target
		if total(partial) <= target_violations:
			var result = backtrack(copy, index + 1, target_violations, day)
			if result != null:
				return result

	# no valid value found, backtrack
	return null

func get_domain(dish, variable, day, target):
	match variable:
		"reported_price":
			var price_range = tier_ranges[dish.tier]

			# midpoint avoids looping through hundreds of valid prices
			var correct = (price_range[0] + price_range[1]) / 2

			if target == 0:
				return [correct]

			# wrong price scales with day difficulty
			var wrong_price
			match day:
				1: wrong_price = price_range[1] + 200  # way off
				3: wrong_price = int(price_range[1] * 1.2)  # ~20% over
				4: wrong_price = price_range[1] + 10  # barely over
				_: wrong_price = price_range[1] + 50  # default

			# correct value at the end so backtracking can still use it
			return [wrong_price, correct]

		"reported_season":
			if target == 0:
				return [dish.season]

			# wrong seasons first, correct at the end
			var wrong = seasons.duplicate()
			wrong.erase(dish.season)
			wrong.append(dish.season)
			return wrong

		"reported_allergens":
			if target == 0:
				return [dish.allergens]

			var fake_options = []

			# hidden allergen: remove one real allergen
			if dish.allergens.size() > 0 and dish.allergens[0] != "None":
				var hidden = dish.allergens.duplicate()
				hidden.pop_back()
				fake_options.append(hidden)

			# false allergen: add one that doesnt belong
			# works for "None" dishes too
			for a in all_allergens:
				if a not in dish.allergens:
					var false_added = dish.allergens.duplicate()
					# replace "None" instead of appending to it
					if false_added.size() > 0 and false_added[0] == "None":
						false_added = [a]
					else:
						false_added.append(a)
					fake_options.append(false_added)
					break

			# correct value at the end so backtracking can still use it
			fake_options.append(dish.allergens)
			return fake_options

		"reported_ingredients":
			if target == 0:
				return [dish.ingredients]

			# remove one ingredient as the violation
			var fake = dish.ingredients.duplicate()
			if fake.size() > 0:
				fake.pop_back()

			# correct value at the end so backtracking can still use it
			return [fake, dish.ingredients]

	return []

func total(v):
	# sum of all violation counts
	return (
		v.allergen +
		v.price +
		v.season +
		v.ingredient
	)
