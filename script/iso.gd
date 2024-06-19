class_name Iso extends Node
## Helper object for isometric vectors.


const VECTOR: Vector2i = Vector2i(16, 8)

const UP: Vector2i = Vector2i(-16, -8)
const DOWN: Vector2i = VECTOR
const LEFT: Vector2i = Vector2i(-16, 8)
const RIGHT: Vector2i = Vector2i(16, -8)



# directions

## Returns the direction [param vector] is facing.
static func get_direction(vector: Vector2i) -> Vector2i:
	if vector.x < 0:
		return UP if vector.y < 0 else LEFT
	else:
		return RIGHT if vector.y < 0 else DOWN


## Returns true if the vector is oriented along the x axis.
static func is_x_axis(vector: Vector2i) -> bool:
	vector = get_direction(vector)
	return vector == LEFT or vector == RIGHT



# grid coordinates

## Converts cartesian coordinates to isometric coordinates.
static func from_grid(coord: Vector2i) -> Vector2:
	return Vector2i(coord.x + coord.y, coord.y - coord.x) * VECTOR


## Converts isometric coordinates to cartesian coordinates.
static func to_grid(vector: Vector2i) -> Vector2i:
	vector /= VECTOR
	var x: int = (vector.x - vector.y) / 2
	return Vector2i(x, vector.x - x)


static func rotate_grid_vector(vector: Vector2i, to: Vector2i) -> Vector2i:
	match to:
		Vector2i.LEFT:
			return Vector2i(-vector.y, vector.x)
		Vector2i.RIGHT:
			return Vector2i(vector.y, -vector.x)
		Vector2i.UP:
			return -vector
		_:
			return vector
