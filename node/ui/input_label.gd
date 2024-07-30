extends HBoxContainer


@export var action: String
@export var label: String


func _ready() -> void:
	$Key.text = InputMap.action_get_events(action)[0].as_text_keycode()
	$Label.text = label if label else action.capitalize()
