extends Node2D


func _draw() -> void:
	if not Battle.active: return
	
	var mouse_pos: Vector2 = get_local_mouse_position().snapped(Vector2(16, 8))
	
	for x in Battle.field.region.size.x: for y in Battle.field.region.size.y:
		var point: Vector2i = Vector2i(x, y) + Battle.field.region.position
		
		if not Battle.field.is_point_solid(point):
			draw_circle(Iso.from_grid(point), 2, Color.RED)
		if not Battle.field.is_point_travellable(point):
			draw_circle(Iso.from_grid(point), 2, Color.ORANGE)
		
		if Iso.from_grid(point) == mouse_pos:
			draw_string(
				ThemeDB.get_project_theme().default_font,
				Iso.from_grid(point) + Vector2(8, 3),
				str(point),
				0, -1, 10
			)


func _process(_delta: float) -> void:
	queue_redraw()
