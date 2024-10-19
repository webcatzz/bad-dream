@tool class_name Slots extends Control


@export var max: int = 1:
	set(val): max = max(val, 1); _update()

@export var value: int:
	set(val): value = min(val, max); _update()

@export var fill_color: Color = Palette.TEXT_NORMAL:
	set(val): fill_color = val; _update()

@export var border_color: Color = Palette.TEXT_NORMAL:
	set(val): border_color = val; _update()


func set_values(value: int, max: int) -> void:
	self.max = max
	self.value = value



# internal

func _ready() -> void:
	_update()


func _update() -> void:
	custom_minimum_size = Vector2(max * 6 + max - 1, 6)
	queue_redraw()


func _draw() -> void:
	for slot: int in max:
		draw_texture_rect_region(
			preload("res://asset/ui/slot.png"),
			Rect2(Vector2(slot * 7, 0), Vector2(6, 6)),
			Rect2(Vector2.ZERO if slot >= value else Vector2(6, 0), Vector2(6, 6)),
			border_color if slot >= value else fill_color
		)
