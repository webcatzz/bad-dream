class_name BitPath extends BitShape


@export var spill: int


func update() -> void:
	var path: Dictionary = _get_path_data()
	
	path.bounds = path.bounds.grow(spill)
	
	create(path.bounds.size + Vector2i.ONE)
	offset -= path.bounds.size + Vector2i.LEFT
	
	for point: Vector2i in path.points:
		set_bitv(point + Vector2i(spill, spill), true)
	
	grow_mask(1, Rect2i(Vector2i.ZERO, get_size()))



# internal

func _get_path_data() -> Dictionary:
	var path: Array[Dictionary] = Battle.current_actor.path
	
	var bounds: Rect2i = Rect2i(Iso.to_grid(path[0].position), Vector2i.ZERO)
	var points: Array[Vector2i] = []
	points.resize(path.size() - 1)
	
	for i: int in path.size() - 1:
		points[i] = Iso.to_grid(path[i].position)
		bounds = bounds.expand(points[i])
	
	return {
		"points": points,
		"bounds": bounds,
	}
