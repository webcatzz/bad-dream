extends Node2D


const _RADIUS: float = 12
const _CHANGE: float = 0.25

var _radius: float = _RADIUS
var _time: float = 0


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, Color("#b8aab0"))


func _process(delta: float) -> void:
	_time += delta
	_radius = _RADIUS + sin(_time) * _CHANGE
	queue_redraw()
