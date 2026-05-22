extends Node


func _ready():

	var dish = DishDatabase.dishes[0].duplicate(true)

	dish.reported_price = 5000
	dish.reported_season = dish.season
	dish.reported_allergens = dish.allergens

	print(
		AC3.validate(dish)
	)
