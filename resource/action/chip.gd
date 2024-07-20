extends Action


func run(cause: Actor) -> void:
	affected = _get_affected_actors(cause)
	
	if affected:
		for actor: Actor in affected:
			if actor.attributes:
				var attribute: Attribute.Type = actor.attributes.pop_back()
				Attribute.remove(attribute, actor)
				actor.node.emit_text("- " + Attribute.Type.keys()[attribute].to_lower())
			else:
				actor.node.emit_text("No attributes!")
	else:
		cause.node.emit_text("No targets!")


func _get_affected_actors(cause: Actor) -> Array[Actor]:
	var actors: Array[Actor]
	var target_points: Array[Vector2i] = []
	
	var path: Array[Vector2i] = []
	path.assign(cause.path.map(func(dict: Dictionary) -> Vector2i:
		return dict.position
	))
	path.append(cause.position)
	
	for point: Vector2i in path:
		var square_points: Array[Vector2i] = [
			point + Vector2i(1, 0),
			point + Vector2i(2, 0),
			point + Vector2i(2, 1),
			point + Vector2i(2, 2),
			point + Vector2i(1, 2),
			point + Vector2i(0, 2),
			point + Vector2i(0, 1)
		]
		var square_points_in_path: int = 0
		
		for point2: Vector2i in path:
			if point2 in square_points:
				square_points_in_path += 1
		
		if square_points_in_path == 7:
			target_points.append(point + Vector2i(1, 1))
	
	for actor: Actor in Battle.order:
		if actor.position in target_points:
			actors.append(actor)
	
	return actors
