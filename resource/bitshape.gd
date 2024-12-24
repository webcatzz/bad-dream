class_name BitShape
extends BitMap

@export var offset: Vector2i


func get_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i]
	for y: int in get_size().y:
		for x: int in get_size().x:
			if get_bit(x, y):
				tiles.append(offset + Vector2i(x, y))
	return tiles


func _to_string() -> String:
	var string: String
	for y: int in get_size().y:
		for x: int in get_size().x:
			string += "x" if get_bit(x, y) else "."
		string += "\n"
	return string
