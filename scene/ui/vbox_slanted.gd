@tool
class_name SlantedVBoxContainer extends VBoxContainer

@export var offset: int = 4:
	set(value):
		offset = value
		notification(NOTIFICATION_SORT_CHILDREN)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var i: int = 0
		for c in get_children():
			c.position.x += i
			i += offset
