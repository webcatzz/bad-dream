extends Node2D


func _ready() -> void:
	visible = false
	z_index = 5
	Battle.started.connect(update)
	Battle.ended.connect(set_visible.bind(false))


func update() -> void:
	visible = true
	queue_redraw()


func _draw() -> void:
	if visible and Data.get_flag("draw_astar"):
		for x in Battle.astar.region.size.x: for y in Battle.astar.region.size.y:
			var point: Vector2i = Vector2i(x, y) + Battle.astar.region.position
			
			if not Battle.astar.is_point_solid(point):
				draw_string(
					ThemeDB.get_project_theme().default_font,
					Iso.from_grid(point),
					str(Battle.astar.get_point_weight_scale(point))
				)
