extends ActorNode


func take_turn() -> void:
	var target: Actor = Game.data.get_leader()
	
	var path: PackedVector2Array = Battle.astar.get_point_path(data.position, target.position)
	if path:
		path.remove_at(0)
		path.resize(min(data.tiles_per_turn, path.size() - 1))
		
		# moving through path
		if path:
			for point: Vector2i in path:
				data.move(point)
				await get_tree().create_timer(0.2).timeout
			data.end_turn()
		else:
			super()
