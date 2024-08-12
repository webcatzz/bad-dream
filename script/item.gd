class_name Item extends Resource


@export var name: String
@export var sprite: Texture2D
@export_multiline var description: String

@export var shape: BitMap
var position: Vector2i # used by party inventories


func get_points() -> Array[Vector2i]:
	var points: Array[Vector2i]
	
	for x: int in shape.get_size().x: for y: int in shape.get_size().y:
		if shape.get_bit(x, y):
			points.append(Vector2i(x, y))
	
	return points
