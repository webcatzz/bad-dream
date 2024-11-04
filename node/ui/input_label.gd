@tool extends Label


@export var action: String


func _ready() -> void:
	if Engine.is_editor_hint():
		text = "Key"
	else:
		text = InputMap.action_get_events(action)[0].as_text()
