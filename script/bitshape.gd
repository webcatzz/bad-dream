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
