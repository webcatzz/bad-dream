class_name Item
extends Resource

@export var name: String
@export var sprite: Texture2D



# print

func _to_string() -> String:
	return "Item(%s)" % name
