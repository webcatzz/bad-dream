class_name BitShape extends BitMap


@export var offset: Vector2i


func to_polygons() -> Array[PackedVector2Array]:
	var polygons: Array[PackedVector2Array] = opaque_to_polygons(Rect2i(Vector2i.ZERO, get_size()), 0)
	var iso_offset: Vector2 = Iso.from_grid(offset)
	
	for polygon: PackedVector2Array in polygons:
		for i: int in polygon.size():
			polygon[i] = Iso.from_grid(polygon[i]) + iso_offset
			polygon[i].x -= 16
	
	return polygons


func rotated(facing: Vector2i) -> BitShape:
	var shape: BitShape = duplicate()
	var size: Vector2i = get_size()
	var end: Vector2i = size - Vector2i.ONE
	
	# grabbing true bits' coords
	var true_bits: Array[Vector2i] = []
	for x: int in size.x: for y: int in size.y:
		if get_bit(x, y):
			true_bits.append(Vector2i(x, y))
	
	# setting new size
	shape.create(Vector2i(size.y, size.x) if facing.x else size)
	
	# rotating grid coords
	for coord: Vector2i in true_bits:
		coord = Iso.rotate_grid_vector(coord, facing)
		match facing:
			Vector2i.LEFT: coord.x += end.y
			Vector2i.RIGHT: coord.y += end.x
			Vector2i.UP: coord += end
		shape.set_bitv(coord, true)
	
	# rotating offset
	shape.offset = Iso.rotate_grid_vector(offset, facing)
	match facing:
		Vector2i.LEFT: shape.offset.x -= end.y
		Vector2i.RIGHT: shape.offset.y -= end.x
		Vector2i.UP: shape.offset -= end
	
	return shape
