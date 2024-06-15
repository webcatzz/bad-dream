extends Action


@export var required_path: BitMap


func start() -> void:
	shape.update()
	
	var matches_required_path: bool = true
	
	if shape.get_size() == required_path.get_size():
		for x: int in shape.get_size().x: for y: int in shape.get_size().y:
			if shape.get_bit(x, y) != required_path.get_bit(x, y):
				if Vector2i(x, y) != cause.position - shape.position:
					matches_required_path = false
					break
	else:
		matches_required_path = false
	
	if matches_required_path: super()
	else: finished.emit()
