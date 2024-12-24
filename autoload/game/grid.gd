class_name IsoGrid
extends AStarGrid2D

var space: PhysicsDirectSpaceState2D
var tilemap: TileMapLayer



# coords

func tile_to_point(tile: Vector2i) -> Vector2:
	return Vector2(
		(tile.x + tile.y) * 16,
		(tile.y - tile.x) * 8
	)


func point_to_tile(point: Vector2) -> Vector2i:
	point.x /= 32
	point.y /= 16
	return Vector2i(
		point.x - point.y,
		point.x + point.y
	)


func snap(point: Vector2) -> Vector2:
	return tilemap.map_to_local(tilemap.local_to_map(point))



# helper

func is_point_open(id: Vector2i) -> bool:
	return is_in_boundsv(id) && not is_point_solid(id)


func get_actor_at(id: Vector2i) -> Actor:
	var params: PhysicsPointQueryParameters2D = point_params(id)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	for collision: Dictionary in space.intersect_point(params):
		if collision.collider is Actor:
			return collision.collider
	return null



# cursor

func get_cursor_point() -> Vector2:
	return snap(tilemap.get_global_mouse_position())


func get_cursor_tile() -> Vector2i:
	return point_to_tile(get_cursor_point())



# generation

func generate(from: TileMapLayer):
	tilemap = from
	space = tilemap.get_world_2d().direct_space_state
	
	region = Rect2i() # note: always includes (0, 0)
	for cell: Vector2i in tilemap.get_used_cells():
		var tile: Vector2i = point_to_tile(tilemap.map_to_local(cell))
		region = region.expand(tile)
	region = region.expand(region.end + Vector2i.ONE)
	
	update()
	read_collisions()


func read_collisions() -> void:
	for x in region.size.x: for y in region.size.y:
		var tile: Vector2i = Vector2i(x, y) + region.position
		var params: PhysicsPointQueryParameters2D = point_params(tile)
		params.collision_mask = 0b1
		
		if space.intersect_point(params) || tilemap.get_cell_source_id(tilemap.local_to_map(tile_to_point(tile))) == -1:
			set_point_solid(tile, true)



# parameters

func point_params(tile: Vector2i) -> PhysicsPointQueryParameters2D:
	var params := PhysicsPointQueryParameters2D.new()
	params.position = tile_to_point(tile)
	return params



# init

func _init() -> void:
	diagonal_mode = DIAGONAL_MODE_NEVER
	cell_shape = CELL_SHAPE_ISOMETRIC_RIGHT
	cell_size = Vector2(32, 16)
	offset = Vector2(-16, -8)
