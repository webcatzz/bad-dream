@tool
class_name Slots
extends Control

const SIZE: int = 4

@export var value: int : set = _set_value
@export var max_value: int = 1 : set = _set_max_value


func set_values(value: int, max_value: int) -> void:
	self.max_value = max_value
	self.value = value


func _set_value(val: int) -> void:
	value = clampi(val, 0, max_value)
	_update()


func _set_max_value(value: int) -> void:
	max_value = maxi(value, 1)
	_update()


func _update() -> void:
	custom_minimum_size = Vector2(max_value * SIZE + max_value - 1, SIZE)
	queue_redraw()


func _draw() -> void:
	for slot: int in max_value:
		draw_texture_rect_region(
			preload("res://asset/ui/slots.png"),
			Rect2(Vector2(slot * (SIZE + 1), 0), Vector2(SIZE, SIZE)),
			Rect2(Vector2(SIZE, 0) if slot >= value else Vector2.ZERO, Vector2(SIZE, SIZE))
		)
