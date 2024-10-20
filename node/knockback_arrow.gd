extends Line2D


func set_end(knockback: Vector2i) -> void:
	var end: Vector2 = Iso.from_grid(knockback)
	set_point_position(1, end - Vector2(6, 3) * end.sign())
	
	$Head.position = end
	if knockback.x < 0: $Head.flip_h = true
	if knockback.y < 0: $Head.flip_v = true
