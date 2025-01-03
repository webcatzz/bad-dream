class_name Item
extends Resource

@export var name: String
@export var sprite: Texture2D

@export var shape: BitMap


# print

func _to_string() -> String:
	return "Item(%s)" % name
