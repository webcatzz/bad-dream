extends PanelContainer


var current_action: String


#func _ready() -> void:
	#for control: Control in $VBox.get_children():
		#if control is HBoxContainer:
			#control
			#control.get_child(-1).pressed.connect(_on_button_pressed.bind(control.action))


func _on_button_pressed(action: String) -> void:
	current_action = action
	$KeyPopup.popup_centered()


func _unhandled_key_input(event: InputEvent) -> void:
	if current_action:
		InputMap.action_erase_events(current_action)
		InputMap.action_add_event(current_action, event)
		current_action = ""
