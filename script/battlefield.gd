class_name BattleField extends AStarGrid2D


var space: PhysicsDirectSpaceState2D = Game.get_tree().current_scene.get_world_2d().direct_space_state
var tile_shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new()


func generate() -> void:
	for x in region.size.x: for y in region.size.y:
		var tile: Vector2i = Vector2i(x, y) + region.position
		set_point_solid(tile, false)
		
		for collider: Node2D in check_tile(tile):
			if not collider is ActorNode:
				set_point_solid(tile, true)
				break


func check_tile(tile: Vector2i, params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()) -> Array[Node2D]:
	var colliders: Array[Node2D] = []
	
	params.shape = tile_shape
	params.transform.origin = tile
	for dict: Dictionary in space.intersect_shape(params):
		colliders.append(dict.collider)
	
	return colliders


func get_actors_in(polygon: PackedVector2Array) -> Array[Actor]:
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = ConvexPolygonShape2D.new()
	params.shape.points = polygon
	
	return filter_actors(space.intersect_shape(params))


func filter_actors(collisions: Array[Dictionary]) -> Array[Actor]:
	var actors: Array[Actor]
	
	for dict: Dictionary in collisions:
		if dict.collider is ActorNode:
			actors.append(dict.collider.resource)
	
	return actors



# internal

func _init(region: Rect2i) -> void:
	self.region = region
	diagonal_mode = DIAGONAL_MODE_NEVER
	update()
	
	tile_shape.points = [Vector2(-16, 0), Vector2(0, -8), Vector2(16, 0), Vector2(0, 8)]
	
	generate()
