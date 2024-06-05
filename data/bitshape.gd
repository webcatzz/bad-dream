class_name BitShape extends BitMap


@export var offset: Vector2i


## Returns a new bitshape rotated to face the same direction as [param vector].
## [param vector] should be one of the [Vector2i] direction constants other than [constant Vector2i.DOWN].
func turned(vector: Vector2i) -> BitShape:
	var bits: BitShape = BitShape.new()
	var size: Vector2i = get_size()
	
	# grabbing true bits
	var active_bits: Array[Vector2i] = []
	for x: int in size.x: for y: int in size.y:
		if get_bit(x, y):
			active_bits.append(Vector2i(x, y))
	
	# setting new grid size
	bits.create(Vector2i(size.y, size.x) if vector.x else size)
	
	# rotating points in grid
	var end: Vector2i = size - Vector2i.ONE
	for point: Vector2i in active_bits:
		
		point = Iso.rotate_grid_vector(point, vector)
		match vector:
			Vector2i.LEFT: point.x += end.y
			Vector2i.RIGHT: point.y += end.x
			Vector2i.UP: point += end
		
		bits.set_bitv(point, true)
	
	# setting offset
	bits.offset = Iso.rotate_grid_vector(offset, vector)
	match vector:
		Vector2i.LEFT: bits.offset.x -= end.y
		Vector2i.RIGHT: bits.offset.y -= end.x
		Vector2i.UP: bits.offset -= end
	
	return bits



# internal

func _to_string() -> String:
	var string: String
	
	for y: int in get_size().y:
		for x: int in get_size().x:
			string += "#" if get_bit(x, y) else "_"
		
		string += "\n"
	
	return string
