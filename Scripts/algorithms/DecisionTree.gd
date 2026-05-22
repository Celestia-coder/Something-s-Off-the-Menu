extends Node

# simple decision tree structure
var tree = {
	"feature":"allergen",
	"threshold":1,

	"true":"SHUT DOWN",

	"false":{
		"feature":"combined",
		"threshold":2,

		"true":"SHUT DOWN",
		"false":"CLEAR TO OPERATE"
	}
}

func classify(v):
	# combine non-allergen violations
	v["combined"] = (
		v["price"] +
		v["season"] +
		v["ingredient"]
	)

	return traverse(tree, v)

func traverse(node, data):
	# final result
	if typeof(node) == TYPE_STRING:
		return node

	var feature = node["feature"]

	# true branch
	if data[feature] >= node["threshold"]:
		return traverse(
			node["true"],
			data
		)

	# false branch
	return traverse(
		node["false"],
		data
	)
