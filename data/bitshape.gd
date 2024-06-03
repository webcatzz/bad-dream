class_name BitShape extends BitMap


@export var offset: Vector2i


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
		
		# offset = (vector.y, end.x - vector.x)
		# 
		bits.set_bitv(point, true)
	
	# setting offset
	bits.offset = Iso.rotate_grid_vector(offset, vector)
	match vector:
		Vector2i.LEFT: bits.offset.x -= end.y
		Vector2i.RIGHT: bits.offset.y -= end.x
		Vector2i.UP: bits.offset -= end
	
	print(bits)
	return bits



# internal


func _to_string() -> String:
	var string: String
	
	for y: int in get_size().y:
		for x: int in get_size().x:
			string += "#" if get_bit(x, y) else "_"
		
		string += "\n"
	
	return string




# internal

func _rotate_vector(vector: Vector2i, to: Vector2i, grid_max: Vector2i = Vector2i.ZERO) -> Vector2i:
	match to:
		Vector2i.LEFT:
			return Vector2i(grid_max.y - vector.y, vector.x)
		Vector2i.RIGHT:
			return Vector2i(vector.y, grid_max.x - vector.x)
		Vector2i.UP:
			return grid_max - vector
		_:
			return vector
