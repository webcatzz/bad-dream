extends AStarGrid2D


var _space_state: PhysicsDirectSpaceState2D = Game.get_tree().current_scene.get_world_2d().direct_space_state


func _init(region: Rect2i) -> void:
	self.region = region
	diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	update()
	
	# generating from collisions
	for x in region.size.x: for y in region.size.y:
		var point: Vector2i = Vector2i(x, y) + region.position
		
		var collisions: Array[Dictionary] = query_point(point)
		if collisions:
			for collision: Dictionary in collisions:
				if not collision.collider is ActorNode:
					set_point_solid(point, true)
					break


## Returns true if the point collides with something.
func is_point_travellable(point: Vector2i) -> bool:
	return (
		region.has_point(point) and
		not is_point_solid(point) and
		not query_point(point)
	)


## Returns [param ray]'s collision point or [param ray] if there are no collisions.
func collide_ray(from: Vector2i, ray: Vector2i) -> Vector2i:
	if not ray: return ray
	
	var max_idx: int = ray.abs().max_axis_index()
	var min_idx: int = ray.abs().min_axis_index()
	var last_ray: Vector2i = Vector2i.ZERO
	
	for i: int in range(1, absi(ray[max_idx]) + 1):
		var current_ray: Vector2i = ray.sign()
		current_ray[max_idx] *= i
		current_ray[min_idx] *= ray[min_idx] * i / ray[max_idx]
		
		if not is_point_travellable(from + current_ray): return last_ray
		else: last_ray = current_ray
	
	return ray


## Returns an [Array] of all collisions at [param point].
func query_point(point: Vector2i) -> Array[Dictionary]:
	var _query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	_query.position = Iso.from_grid(point)
	return _space_state.intersect_point(_query)


## Returns a [Dictionary] containing data about the ray collision. See [method PhysicsDirectSpaceState2D.intersect_ray].
func query_ray(from: Vector2i, ray: Vector2i) -> Dictionary:
	return _space_state.intersect_ray(PhysicsRayQueryParameters2D.create(
		Iso.from_grid(from),
		Iso.from_grid(from + ray)
	))


# Returns high cost if the point collides with a body.
func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	return 999 if query_point(to_id) else 1
