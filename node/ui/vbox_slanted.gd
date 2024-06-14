@tool class_name SlantedVBoxContainer extends VBoxContainer
## Sorts children vertically with an incremental horizontal offset.


@export var offset: int = 4: ## Amount to increment horizontal offset by.
	set(value): offset = value; notification(NOTIFICATION_SORT_CHILDREN)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for i: int in get_child_count():
			get_child(i).position.x = offset * i
