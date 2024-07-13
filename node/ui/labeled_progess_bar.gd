@tool extends ProgressBar


@export var show_value: bool:
	set(state):
		show_value = state
		custom_minimum_size.y = 12 if show_value else 0


func _draw() -> void:
	if show_value:
		draw_string(
			load("res://asset/ui/improv_gold.tres"), Vector2(0, 8),
			str(value) + "/" + str(max_value),
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, Game.PALETTE.white
		)
