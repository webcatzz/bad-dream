extends AStarGrid2D


var _space_state: PhysicsDirectSpaceState2D = Game.get_root().get_world_2d().direct_space_state
var _point_query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()


func _init(region: Rect2i) -> void:
	self.region = region
	diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	update()
	generate()


# Sets all points in [member region] that collide with a body to solid.
func generate() -> void:
	for x in region.size.x: for y in region.size.y:
		var point: Vector2i = Vector2i(x, y) + region.position
		
		var collisions: Array[Dictionary] = _get_point_collisions(point)
		if collisions:
			for collision: Dictionary in collisions:
				if not collision.collider is ActorNode:
					set_point_solid(point, true)
					break


func is_point_travellable(point: Vector2i) -> bool:
	return (
		region.has_point(point) and
		not is_point_solid(point) and
		not _get_point_collisions(point)
	)


# Returns high cost if the point collides with a body.
func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	return 999 if _get_point_collisions(to_id) else 1


# Returns true if the point collides with a body.
func _get_point_collisions(point: Vector2i) -> Array[Dictionary]:
	_point_query.position = Iso.from_grid(point)
	return _space_state.intersect_point(_point_query)
