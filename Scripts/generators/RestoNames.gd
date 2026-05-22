extends Node

# all possible resto names in the game
var names = [
	"Cozy Cravings",
	"Golden Spoon Eatery",
	"Soulplate Bistro",
	"Moonlight Kitchen",
	"Savor Street"
]

# returns a shuffled subset of names based on how many restos are needed
func get_shuffled_names(count):
	var shuffled = names.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)
