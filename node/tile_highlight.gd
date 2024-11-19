class_name TileHighlight extends Node2D


var shape: BitShape


func _draw() -> void:
	for x: int in shape.get_size().x: for y: int in shape.get_size().y:
		if shape.get_bit(x, y):
			var point: Vector2 = Iso.from_grid(Vector2i(x, y))
			draw_colored_polygon(Iso.get_tile_points(Vector2i(x, y)), Color(1, 1, 1, 0.063))
