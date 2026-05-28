extends Node

# PRICE TIER RANGES
var tier_ranges = {
	"A": [100, 499],
	"B": [500, 999],
	"C": [1000, 2000]
}

# REPORTED INCONSISTENCY
var arcs = [
	["reported_price", "tier"],
	["reported_season", "season"],
	["reported_allergens", "allergens"],
	["reported_ingredients", "ingredients"]
]

func validate(dish):
	# each domain only has one value since the report is already filled out
	var domains = {
		"reported_price": [dish.reported_price],
		"reported_season": [dish.reported_season],
		"reported_allergens": [dish.reported_allergens],
		"reported_ingredients": [dish.reported_ingredients]
	}

	# duplicate so the original arcs list stays unchanged
	var queue = arcs.duplicate()

	var violations = {
		"allergen": 0,
		"season": 0,
		"price": 0,
		"ingredient": 0
	}

	while queue.size() > 0:
		var arc = queue.pop_front()
		var xi = arc[0]  # reported field
		var xj = arc[1]  # actual dish field to check against

		if revise(dish, domains, xi, xj, violations):
			# no valid value left, stop early
			if domains[xi].is_empty():
				return violations

	return violations

func revise(dish, domains, xi, xj, violations):
	var revised = false

	for value in domains[xi].duplicate():
		if not consistent(dish, value, xi, xj):
			domains[xi].erase(value)
			revised = true

			# track which violation type was found
			match xi:
				"reported_price":
					violations.price += 1
				"reported_season":
					violations.season += 1
				"reported_allergens":
					violations.allergen += 1
				"reported_ingredients":
					violations.ingredient += 1

	return revised

func consistent(dish, value, xi, xj):
	match xi:
		# price must be within the tier range
		"reported_price":
			var price_range = tier_ranges[dish[xj]]
			return value >= price_range[0] and value <= price_range[1]

		# season must match exactly
		"reported_season":
			return value == dish[xj]

		# check both ways:
		# real allergen missing from report = hidden
		# extra allergen in report = false
		"reported_allergens":
			for allergen in dish[xj]:
				if allergen != "None" and allergen not in value:
					return false
			for allergen in value:
				if allergen != "None" and allergen not in dish[xj]:
					return false
			return true

		# same logic as allergens but for ingredients
		"reported_ingredients":
			for ingredient in dish[xj]:
				if ingredient not in value:
					return false
			for ingredient in value:
				if ingredient not in dish[xj]:
					return false
			return true

	return true
