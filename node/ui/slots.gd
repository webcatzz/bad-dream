@tool class_name Slots extends Control


@export var max: int = 1:
	set(val):
		max = max(val, 1)
		update()

@export var value: int:
	set(val):
		value = min(val, max)
		update()


func _ready() -> void:
	update()


func update() -> void:
	custom_minimum_size = Vector2(max * 6 + max - 1, 6)
	queue_redraw()


func _draw() -> void:
	for slot: int in max:
		if slot >= value:
			draw_texture_rect_region(
				preload("res://asset/ui/slot.png"),
				Rect2(Vector2(slot * 7, 0), Vector2(6, 6)),
				Rect2(Vector2.ZERO, Vector2(6, 6))
			)
		else:
			draw_texture_rect_region(
				preload("res://asset/ui/slot.png"),
				Rect2(Vector2(slot * 7, 0), Vector2(6, 6)),
				Rect2(Vector2(6, 0), Vector2(6, 6))
			)


static func from(value: int, max: int) -> Slots:
	var slots: Slots = Slots.new()
	slots.max = max
	slots.value = value
	return slots
