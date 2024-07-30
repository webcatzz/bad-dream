@tool extends ProgressBar


@export var slots: int = 1:
	set(val):
		slots = val
		max_value = slots
		custom_minimum_size.x = slots * 6 + slots - 1
