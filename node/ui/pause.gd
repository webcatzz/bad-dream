extends TabContainer


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = !visible
		get_viewport().set_input_as_handled()
