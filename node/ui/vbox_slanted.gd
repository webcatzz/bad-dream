@tool
class_name SlantedVBoxContainer extends VBoxContainer

@export var offset: int = 4:
	set(value):
		offset = value
		notification(NOTIFICATION_SORT_CHILDREN)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		
		var current_offset: float
		
		for c in get_children():
			c.position.x += current_offset
			current_offset += offset
