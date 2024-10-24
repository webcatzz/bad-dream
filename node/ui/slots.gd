@tool class_name Slots extends Control


@export var max_value: int = 1:
	set(val): max_value = max(val, 1); _update()

@export var value: int:
	set(val): value = min(val, max_value); _update()

@export var fill_color: Color = Palette.TEXT_NORMAL:
	set(val): fill_color = val; _update()

@export var border_color: Color = Palette.TEXT_NORMAL:
	set(val): border_color = val; _update()


func set_values(value: int, max_value: int) -> void:
	self.max_value = max_value
	self.value = value



# internal

func _ready() -> void:
	_update()


func _update() -> void:
	custom_minimum_size = Vector2(max_value * 6 + max_value - 1, 6)
	queue_redraw()


func _draw() -> void:
	for slot: int in max_value:
		draw_texture_rect_region(
			preload("res://asset/ui/slot.png"),
			Rect2(Vector2(slot * 7, 0), Vector2(6, 6)),
			Rect2(Vector2.ZERO if slot >= value else Vector2(6, 0), Vector2(6, 6)),
			border_color if slot >= value else fill_color
		)
