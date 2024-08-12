extends HBoxContainer


@export var label: String = "Action"
@export var action: String


func _ready() -> void:
	$Label.text = label
	var event: InputEventKey = InputMap.action_get_events(action)[0]
	
	if event.keycode:
		$Key.text = event.as_text_keycode()
	elif event.physical_keycode:
		$Key.text = event.as_text_physical_keycode()
	else:
		$Key.text = event.as_text_key_label()
