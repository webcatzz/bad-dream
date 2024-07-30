@tool extends HBoxContainer


@export var label: String:
	set(value):
		label = value
		$Label.text = label
@export var action: String


func _ready() -> void:
	$Key.text = InputMap.action_get_events(action)[0].as_text_keycode()
