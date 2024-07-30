class_name Iso extends Node
## Helper class for isometric vectors.


const VECTOR: Vector2i = Vector2i(16, 8)

const UP: Vector2i = Vector2i(-16, -8)
const DOWN: Vector2i = VECTOR
const LEFT: Vector2i = Vector2i(-16, 8)
const RIGHT: Vector2i = Vector2i(16, -8)



# grid coordinates

static func from_grid(coord: Vector2i) -> Vector2:
	return Vector2(
		(coord.x + coord.y) * 16,
		(coord.y - coord.x) * 8
	)


static func to_grid(vector: Vector2) -> Vector2i:
	vector /= Vector2(32, 16)
	return Vector2i(
		vector.x - vector.y,
		vector.x + vector.y
	)



# snapping

static func snap(vector: Vector2) -> Vector2:
	vector = vector.snapped(Vector2(16, 8))
	
	if posmod(snappedi(int(vector.x), 16), 32):
		vector.y = snappedf(vector.y, 16) - 8
	else:
		vector.y = snappedf(vector.y, 16)
	
	return vector
