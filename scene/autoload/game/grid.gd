class_name Grid
extends AStarGrid2D

const UP := Vector2(-14, -7)
const DOWN := Vector2(14, 7)
const LEFT := Vector2(-10, 10)
const RIGHT := Vector2(10, -10)

var space: PhysicsDirectSpaceState2D
var tilemap: VTileMap



# coords

static func tile_to_point(tile: Vector2i) -> Vector2:
	return tile.x * RIGHT + tile.y * DOWN


static func point_to_tile(point: Vector2) -> Vector2i:
	var coords: Vector2
	coords.x = (Grid.DOWN.x * point.y - Grid.DOWN.y * point.x) / (Grid.DOWN.x * Grid.RIGHT.y - Grid.DOWN.y * Grid.RIGHT.x)
	coords.y = (point.x - coords.x * Grid.RIGHT.x) / Grid.DOWN.x
	return coords.round()


static func snap(point: Vector2) -> Vector2:
	return tile_to_point(point_to_tile(point))



# query

func is_point_open(id: Vector2i) -> bool:
	return is_in_boundsv(id) && not is_point_solid(id)


func at(point: Vector2) -> CollisionObject2D:
	var params := PhysicsPointQueryParameters2D.new()
	params.position = point
	params.collide_with_areas = true
	params.collision_mask = 0b1
	
	var collisions: Array[Dictionary] = space.intersect_point(params)
	return collisions.front().collider if collisions else null


func ray(from: Vector2, to: Vector2) -> bool:
	var params := PhysicsRayQueryParameters2D.create(from, to)
	return true if space.intersect_ray(params) else false



# generation

func generate(from: VTileMap) -> void:
	tilemap = from
	space = tilemap.get_world_2d().direct_space_state
	
	region = Rect2i() # note: always includes (0, 0)
	for cell: VTileMapCell in tilemap.cells:
		region = region.expand(cell.coords)
	region = region.expand(region.end + Vector2i.ONE)
	
	update()
	read_collisions()


func read_collisions() -> void:
	for x in region.size.x: for y in region.size.y:
		var tile: Vector2i = Vector2i(x, y) + region.position
		var params := PhysicsPointQueryParameters2D.new()
		params.position = Grid.tile_to_point(tile)
		params.collision_mask = 0b1
		
		if space.intersect_point(params) or not tilemap.get_cell(tile):
			set_point_solid(tile, true)



# outline

static func get_point_vertices(point: Vector2) -> PackedVector2Array:
	return [
		point + Vector2(-12, 2),
		point + Vector2(-2, -8),
		point + Vector2(12, -1),
		point + Vector2(2, 9),
	]


static func outline(points: PackedVector2Array) -> Array[PackedVector2Array]:
	var outlines: Array[PackedVector2Array]
	for point: Vector2 in points:
		outlines.append(get_point_vertices(point))
	
	if outlines.size() > 1:
		var a: int = 0
		while a < outlines.size():
			var merge: bool = false
			
			var b: int = a + 1
			while b < outlines.size():
				var merged: Array[PackedVector2Array] = Geometry2D.merge_polygons(outlines[a], outlines[b])
				if merged.size() == 2:
					b += 1
				else:
					outlines[a] = merged.pop_front()
					outlines.remove_at(b)
					outlines.append_array(merged)
					merge = true
			
			if not merge:
				a += 1
	
	return outlines



# init

func _init(tilemap: VTileMap) -> void:
	diagonal_mode = DIAGONAL_MODE_NEVER
	cell_shape = CELL_SHAPE_ISOMETRIC_RIGHT
	cell_size = Grid.DOWN * 2
	offset = Grid.UP
	generate(tilemap)
