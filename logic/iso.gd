extends Node
## Helper object for isometric vectors.


const VECTOR: Vector2i = Vector2i(16, 8)

const UP: Vector2i = Vector2i(-16, -8)
const DOWN: Vector2i = VECTOR
const LEFT: Vector2i = Vector2i(-16, 8)
const RIGHT: Vector2i = Vector2i(16, -8)



# directions

## Rotates a vector to face one of the direction vectors.
func turn(vector: Vector2i, direction: Vector2i) -> Vector2i:
	vector.x = abs(vector.x) if direction in [RIGHT, DOWN] else -abs(vector.x)
	vector.y = abs(vector.y) if direction in [LEFT, DOWN] else -abs(vector.y)
	return vector


## Returns the direction a vector is facing.
func get_direction(vector: Vector2i) -> Vector2i:
	if vector.x < 0:
		return UP if vector.y < 0 else LEFT
	else:
		return RIGHT if vector.y < 0 else DOWN




# axis

func is_x_axis(vector: Vector2i) -> bool:
	vector = get_direction(vector)
	return vector == LEFT or vector == RIGHT




# coordinate conversion

## Converts cartesian coordinates to isometric coordinates.
func from_cart(coord: Vector2i) -> Vector2i:
	return Vector2i(coord.x + coord.y, coord.y - coord.x) * VECTOR


## Converts isometric coordinates to cartesian coordinates.
func to_cart(vector: Vector2i) -> Vector2i:
	vector /= VECTOR
	var x: int = (vector.x - vector.y) / 2
	return Vector2i(x, vector.x - x)



# movement

# bug: does not snap to closest point when moving diagonally along a tile boundary
## Snaps a vector to the isometric grid.
func snap(vector: Vector2i) -> Vector2i:
	var snapped: Vector2i = vector.snapped(VECTOR)
	if snapped.y % 16 == 0: snapped.x = snappedi(snapped.x, 32)
	else: snapped.x = snappedi(snapped.x - 16, 32) + 16
	return snapped


## Isometric equivalent to [method Vector2.normalize].
func normalize(vector: Vector2) -> Vector2i:
	vector.x /= 2
	vector.normalized()
	vector.x *= 2
	return vector



# index conversion

func to_idx(direction: Vector2i) -> int:
	if direction == Iso.DOWN: return 0
	if direction == Iso.UP: return 1
	if direction == Iso.LEFT: return 2
	if direction == Iso.RIGHT: return 3
	return -1



# string conversion

## Converts a string to a direction vector.
func from_string(direction: String) -> Vector2i:
	match direction.to_lower():
		"up": return UP
		"down": return DOWN
		"left": return LEFT
		"right": return RIGHT
		_: return Vector2i.ZERO
