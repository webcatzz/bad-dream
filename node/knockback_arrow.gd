@tool extends Line2D


func set_end(knockback: Vector2i) -> void:
	var end: Vector2 = Iso.from_grid(knockback)
	set_point_position(1, end - Vector2(6, 3) * end.sign())
	queue_redraw()



# internal

func _draw() -> void:
	var end: Vector2 = get_point_position(1)
	draw_colored_polygon([
		end,
		end - Vector2(0, 5 * sign(end.y)),
		end - Vector2(10 * sign(end.x), 0),
	], default_color)
