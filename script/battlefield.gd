class_name BattleField extends AStarGrid2D


var space: PhysicsDirectSpaceState2D = Game.get_tree().current_scene.get_world_2d().direct_space_state
var tile_shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new()



# tiles

func collide_tile(tile: Vector2i) -> Array[Node2D]:
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = tile_shape
	params.transform.origin = tile
	
	var colliders: Array[Node2D] = []
	
	for collision: Dictionary in space.intersect_shape(params):
		colliders.append(collision.collider)
	
	return colliders


func collide_ray(ray: Vector2i, from: Vector2i) -> Vector2i:
	var last_ray: Vector2i = Vector2i.ZERO
	var new_ray: Vector2i = Vector2i.ZERO
	var unit: Vector2i = ray.sign()
	
	for i: int in range(1, absi(ray[ray.abs().max_axis_index()]) + 1):
		new_ray = last_ray + unit
		
		if is_tile_open(from + new_ray):
			last_ray = new_ray
		else:
			return last_ray
	
	return ray


func is_tile_open(tile: Vector2i) -> bool:
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = tile_shape
	params.transform.origin = tile
	
	return not space.intersect_shape(params, 1)



# something else

func find_actors_in(polygons: Array[PackedVector2Array], offset: Vector2) -> Array[Actor]:
	var actors: Array[Actor] = []
	
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = ConvexPolygonShape2D.new()
	params.transform.origin = offset
	
	for polygon: PackedVector2Array in polygons:
		params.shape.points = polygon
		
		for collision: Dictionary in space.intersect_shape(params):
			if collision.collider is ActorNode:
				actors.append(collision.collider.resource)
	
	return actors



# updating

func update_region() -> void:
	region = Rect2i(Save.player.position, Vector2i.ZERO)
	for actor: Actor in Save.party + Game.battle.enemies:
		region.expand(actor.position)
	region.grow_individual(8, 8, 9, 9)
	
	update()
	update_collision()


func update_collision() -> void:
	for x in region.size.x: for y in region.size.y:
		var tile: Vector2i = Vector2i(x, y) + region.position
		set_point_solid(tile, false)
		
		for collider: Node2D in collide_tile(tile):
			if not collider is ActorNode:
				set_point_solid(tile, true)
				break



# internal

func _init() -> void:
	diagonal_mode = DIAGONAL_MODE_NEVER
	tile_shape.points = [Vector2(-16, 0), Vector2(0, -8), Vector2(16, 0), Vector2(0, 8)]
	update_region()
