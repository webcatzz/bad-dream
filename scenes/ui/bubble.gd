@tool
extends Control

const SPEED: float = 0.1
const DETAIL_COUNT: int = 16
const DETAIL_RADIUS: float = 0.3
const DETAIL_SEPARATION: float = TAU / DETAIL_COUNT

var _angle: float


func _draw() -> void:
	var center: Vector2 = size / 2.0
	var radius: float = center[center.min_axis_index()]
	draw_circle(center, radius, Palette.WHITE)
	
	var small_radius: float = radius * DETAIL_RADIUS
	for i: int in DETAIL_COUNT:
		draw_circle(center + Vector2.from_angle(_angle + i * DETAIL_SEPARATION) * radius, small_radius, Palette.WHITE)


func _process(delta: float) -> void:
	_angle += delta * SPEED
	queue_redraw()
