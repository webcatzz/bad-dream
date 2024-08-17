extends HBoxContainer


@export var label: String = "Action":
	set(value):
		label = value
		$Label.text = label

@export var action: String = "interact":
	set(value):
		action = value
		var event: InputEventKey = InputMap.action_get_events(action)[0]
		
		if event.keycode:
			$Key.text = event.as_text_keycode()
		elif event.physical_keycode:
			$Key.text = event.as_text_physical_keycode()
		else:
			$Key.text = event.as_text_key_label()


func _ready() -> void:
	label = label
	action = action
