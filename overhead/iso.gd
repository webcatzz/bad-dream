class_name Iso

const VECTOR: Vector2i = Vector2(16, 8)

const UP: Vector2i = Vector2(-16, -8)
const DOWN: Vector2i = VECTOR
const LEFT: Vector2i = Vector2(-16, 8)
const RIGHT: Vector2i = Vector2(16, -8)


static func turn_vector(vector: Vector2i, direction: Vector2i) -> Vector2i:
	vector.x = abs(vector.x) if direction in [UP, RIGHT] else -abs(vector.x)
	vector.y = abs(vector.y) if direction in [DOWN, RIGHT] else -abs(vector.y)
	return vector


static func get_direction(vector: Vector2i) -> Vector2i:
	if vector.x < 0: return LEFT if vector.y < 0 else DOWN
	else: return UP if vector.y < 0 else RIGHT


static func to_iso(coord: Vector2i) -> Vector2i:
	return Vector2i(coord.x + coord.y, coord.y - coord.x) * VECTOR


static func from_iso(vector: Vector2i) -> Vector2i:
	vector /= VECTOR
	var x: int = (vector.x - vector.y) / 2
	return Vector2(x, vector.x - x)


static func snap(vector: Vector2) -> Vector2i:
	var snapped: Vector2i = vector.snapped(VECTOR)
	
	if snapped.y % 16 == 0: snapped.x = snappedi(snapped.x, 32)
	else: snapped.x = snappedi(snapped.x - 16, 32) + 16
	
	return snapped


static func from_string(direction: String) -> Vector2i:
	match direction.to_lower():
		"up": return UP
		"down": return DOWN
		"left": return LEFT
		"right": return RIGHT
		_: return Vector2.ZERO
