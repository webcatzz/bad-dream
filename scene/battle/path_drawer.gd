extends Node2D

var actor: Actor
var stops: Array[Vector2i]
var points: PackedVector2Array


func clear() -> void:
	actor = null
	stops.clear()
	points.clear()


func _draw() -> void:
	if not actor: return
	
	draw_area(stops.back(), actor.stamina - points.size())
	
	# path
	if points.size() > 1:
		draw_polyline(points, actor.color, 6)
	
	# stops
	for i: int in range(1, stops.size()):
		draw_circle(Game.grid.tile_to_point(stops[i]), 6, actor.color)


func draw_area(from: Vector2i, size: int) -> void:
	for x: int in range(-size, size + 1):
		for y: int in range(-size, size + 1):
			var tile: Vector2i = from + Vector2i(x, y)
			if Game.grid.is_point_open(tile) and Game.grid.get_id_path(from, tile).size() - 1 <= size:
				draw_colored_polygon(Game.grid.get_tile_vertices(tile), Color(0, 0, 1, 0.05))
