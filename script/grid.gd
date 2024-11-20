extends AStarGrid2D


signal changed

var space: PhysicsDirectSpaceState2D
var tilemap: TileMapLayer
var tile_shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new()


func generate(tilemap: TileMapLayer) -> void:
	self.tilemap = tilemap
	space = tilemap.get_world_2d().direct_space_state
	
	region = Rect2i()
	for cell: Vector2i in tilemap.get_used_cells():
		var tile: Vector2i = Iso.to_grid(tilemap.map_to_local(cell))
		region = region.expand(tile)
	region = region.expand(region.end + Vector2i.ONE)
	
	update()
	read_collisions()


func read_collisions() -> void:
	for x in region.size.x: for y in region.size.y:
		var tile: Vector2i = Vector2i(x, y) + region.position
		var params: PhysicsShapeQueryParameters2D = tile_params(tile)
		params.collision_mask = 0b1
		
		if space.intersect_shape(params) || tilemap.get_cell_source_id(tilemap.local_to_map(Iso.from_grid(tile))) == -1:
			set_point_solid(tile, true)
	
	changed.emit()



# cursor

func get_hovered_point() -> Vector2:
	return Iso.snap(Game.get_global_mouse_position())


func get_hovered_tile() -> Vector2i:
	var point: Vector2 = get_hovered_point()
	if is_in_boundsv(point):
		return get_point_position(point)
	else:
		return Iso.to_grid(point)



# collisions

func collide_tile(tile: Vector2i) -> Array[Dictionary]:
	return space.intersect_shape(tile_params(tile))


func collide_ray(from: Vector2i, ray: Vector2i) -> Vector2i:
	var last_ray: Vector2i = Vector2i.ZERO
	var new_ray: Vector2i
	var unit: Vector2i = ray.sign()
	
	for i: int in absi(ray[ray.abs().max_axis_index()]):
		new_ray = last_ray + unit
		
		if is_tile_open(from + new_ray):
			last_ray = new_ray
		else:
			return last_ray
	
	return ray


func collide_action(action: Action, cause: Actor) -> Array[Actor]:
	var actors: Array[Actor] = []
	var shape: BitShape = action.shape.rotated(cause.facing)
	
	var params := PhysicsPointQueryParameters2D.new()
	params.collision_mask = 0b10
	
	for x: int in shape.get_size().x: for y: int in shape.get_size().y:
		if shape.get_bit(x, y):
			params.position = Iso.from_grid(cause.position)
			
			for collision: Dictionary in space.intersect_point(params):
				actors.append(collision.collider.resource)
	
	return actors


func is_tile_open(tile: Vector2i) -> bool:
	return not is_point_solid(tile)



# pathing

func path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	return get_point_path(from, to).slice(1)



# parameters

func point_params(tile: Vector2i) -> PhysicsPointQueryParameters2D:
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.position = Iso.from_grid(tile)
	return params


func tile_params(tile: Vector2i) -> PhysicsShapeQueryParameters2D:
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.transform.origin = Iso.from_grid(tile)
	params.shape = tile_shape
	return params



# internal

func _init() -> void:
	diagonal_mode = DIAGONAL_MODE_NEVER
	cell_shape = CELL_SHAPE_ISOMETRIC_RIGHT
	cell_size = Vector2(32, 16)
	offset = -Iso.VECTOR
	tile_shape.points = [Vector2(-14, 0), Vector2(0, -7), Vector2(14, 0), Vector2(0, 7)]
