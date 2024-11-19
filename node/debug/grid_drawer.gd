extends Node2D


func _ready() -> void:
	z_index = 128
	modulate.a = 0.075
	Game.grid.changed.connect(queue_redraw)


func _draw() -> void:
	# grid
	draw_set_transform(Iso.from_grid(Game.grid.region.position) - Vector2(16, 0))
	
	for x: int in Game.grid.region.size.x + 1:
		draw_dashed_line(
			Iso.RIGHT * x,
			Iso.from_grid(Vector2i(x, Game.grid.region.size.y)),
			Palette.WHITE
		)
		draw_string(
			load("res://asset/ui/font/small.tres"),
			Iso.RIGHT * x + Vector2(4, -8),
			str(x + Game.grid.region.position.x),
			HORIZONTAL_ALIGNMENT_CENTER
		)
	
	for y: int in Game.grid.region.size.y + 1:
		draw_dashed_line(
			Iso.DOWN * y,
			Iso.from_grid(Vector2i(Game.grid.region.size.x, y)),
			Palette.WHITE
		)
		draw_string(
			load("res://asset/ui/font/small.tres"),
			Iso.from_grid(Vector2i(Game.grid.region.size.x, y)) + Vector2(8, 0),
			str(y + Game.grid.region.position.y)
		)
	
	draw_set_transform(Vector2.ZERO)
	
	# origin
	draw_circle(Vector2.ZERO, 3, Palette.BLUE, false)
	
	# solid
	for x: int in Game.grid.region.size.x: for y: int in Game.grid.region.size.y:
		var tile: Vector2i = Vector2i(x, y) + Game.grid.region.position
		if Game.grid.is_point_solid(tile):
			var point: Vector2 = Iso.from_grid(tile)
			draw_line(point - Vector2(8, 0), point + Vector2(8, 0), Palette.RED)
			draw_line(point - Vector2(0, 4), point + Vector2(0, 4), Palette.RED)


func set_alpha(value: float) -> void:
	modulate.a = value
