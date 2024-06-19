extends ActorNode


func take_turn() -> void:
	var target: Actor = Game.data.get_leader()
	
	var path: PackedVector2Array = Battle.astar.get_point_path(data.position, target.position)
	path.remove_at(0)
	if path.size() > data.tiles_per_turn: path.resize(data.tiles_per_turn)
	
	# moving through path
	for point: Vector2i in path:
		data.move(point)
		await get_tree().create_timer(0.2).timeout
	
	data.turn_ended.emit()
