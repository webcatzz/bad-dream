@tool class_name SlantedVBoxContainer extends VBoxContainer
## Sorts children vertically with an incremental horizontal offset.


@export var offset: int = 4: ## Amount to increment horizontal offset by.
	set(value): offset = value; notification(NOTIFICATION_SORT_CHILDREN)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var max_offset: int = offset * get_child_count()
		
		var width: int = get_minimum_size().x + max_offset
		var child_width: int = get_minimum_size().x + offset
		custom_minimum_size.x = width
		
		var current_offset: int = 0
		for child: Control in get_children():
			fit_child_in_rect(child, Rect2(
				current_offset,
				child.position.y,
				child_width,
				child.size.y
			))
			current_offset += offset
