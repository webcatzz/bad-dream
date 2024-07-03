class_name BitPath extends BitMap


@export var spill: int ## How far the shape extends beyond the path.
var position: Vector2i ## Top-leftmost point in the path's bounds.


func update() -> void:
	var path: Dictionary = _get_path_data()
	
	path.bounds = path.bounds.grow(spill)
	create(path.bounds.size + Vector2i.ONE)
	
	for point: Vector2i in path.points:
		set_bitv(point - path.bounds.position, true)
	
	if spill:
		grow_mask(spill, Rect2i(Vector2i.ZERO, get_size()))
	
	# TODO: remove action cause position from bitmap



# internal

func _get_path_data() -> Dictionary:
	var path: Array[Dictionary] = Battle.current_actor.path
	if path.size() == 0: path = [{"position": Battle.current_actor.position}]
	
	var bounds: Rect2i = Rect2i(path[0].position, Vector2i.ZERO)
	var points: Array[Vector2i] = []
	points.resize(path.size())
	
	for i: int in path.size():
		points[i] = path[i].position
		bounds = bounds.expand(points[i])
	
	position = bounds.position
	
	return {"points": points, "bounds": bounds}


func _to_string() -> String:
	var string: String = ""
	
	for y: int in get_size().y:
		for x: int in get_size().x:
			string += "#" if get_bit(x, y) else "_"
		
		string += "\n"
	
	return string
