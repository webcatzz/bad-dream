class_name Position extends Resource


## Real coordinates.
var position: Vector2i

## Isometric grid coordinates.
var coords: Vector2i:
	get: return Iso.to_grid(position)
	set(value): position = Iso.from_grid(value)

var facing: Vector2i
