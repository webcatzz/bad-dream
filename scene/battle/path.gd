extends Node2D

const DOT_SEPARATION: int = 12

@export var points: PackedVector2Array : set = _set_points

var dots: PackedVector2Array


func add_point(point: Vector2) -> void:
	points.append(point)
	_update_dots()


func remove_point() -> void:
	points.remove_at(points.size() - 1)
	_update_dots()


func get_simple() -> PackedVector2Array:
	var simple: PackedVector2Array
	
	simple.append(points[0])
	for i: int in range(1, points.size() - 1):
		if points[i] - points[i - 1] != points[i + 1] - points[i]:
			simple.append(points[i])
	simple.append(points[-1])
	
	return simple


func _set_points(value: PackedVector2Array) -> void:
	points = value
	_update_dots()


func _update_dots() -> void:
	dots.clear()
	var simple: PackedVector2Array = get_simple()
	
	for i: int in simple.size() - 1:
		dots.append(simple[i])
		
		var length: int = (simple[i + 1] - simple[i]).length()
		var count: int = length / DOT_SEPARATION
		var separation: float
		
		if count == 1:
			separation = length / 2.0
		else:
			separation = DOT_SEPARATION - float(DOT_SEPARATION - (length % DOT_SEPARATION)) / count
		
		for d: int in count:
			dots.append(simple[i].move_toward(simple[i + 1], separation * (d + 1)))
	
	queue_redraw()


func _draw() -> void:
	if points:
		for dot: Vector2 in dots:
			_draw_dot(dot)
		_draw_target(points[-1])


func _draw_dot(point: Vector2) -> void:
	draw_texture_rect_region(
		preload("res://asset/ui/path.png"),
		Rect2(point - Vector2(2, 2), Vector2(4, 4)),
		Rect2(Vector2.ZERO, Vector2(4, 4))
	)


func _draw_target(point: Vector2) -> void:
	draw_texture_rect_region(
		preload("res://asset/ui/path.png"),
		Rect2(point - Vector2(4, 4), Vector2(8, 8)),
		Rect2(Vector2(4, 0), Vector2(8, 8))
	)
