extends NavigationRegion2D


func generate() -> void:
	var navpoly := NavigationPolygon.new()
	
	for x: int in Game.grid.region.size.x: for y: int in Game.grid.region.size.y:
		var tile: Vector2i = Vector2i(x, y) + Game.grid.region.position
		if not Game.grid.is_point_solid(tile):
			var point: Vector2 = Iso.from_grid(tile)
			navpoly.add_outline([
				point - Vector2(16, 0),
				point - Vector2(8, 0),
				point + Vector2(16, 0),
				point + Vector2(8, 0),
			])
	
	navpoly.agent_radius = 4
	NavigationServer2D.bake_from_source_geometry_data(navpoly, NavigationMeshSourceGeometryData2D.new());
	navigation_polygon = navpoly
