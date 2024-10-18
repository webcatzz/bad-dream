extends Node2D


const _RADIUS: float = 20
const _CHANGE: float = 0.5

var _radius: float = _RADIUS
var _time: float = 0


func _draw() -> void:
	var radius: float = _radius + sin(_time) * _CHANGE
	draw_circle(Vector2.ZERO, radius, Color.WHITE)
	draw_colored_polygon([
		Vector2(-radius, 0),
		Vector2(radius, 0),
		Vector2(0, -get_viewport().size.y/2)
	], Color(1, 1, 1, 0.1))


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func expand(value: int) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "_radius", _RADIUS + value, 0.05)
