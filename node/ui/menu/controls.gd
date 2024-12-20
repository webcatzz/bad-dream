extends VBoxContainer


const ACTIONS: Dictionary = { # fix [String, String]
	"Interact": "ui_accept",
	"Cancel": "ui_cancel",
	
	"Move up": "move_up",
	"Move down": "move_down",
	"Move left": "move_left",
	"Move right": "move_right",
	"Backtrack": "undo",
	
	"Pause": "pause",
	"Inventory": "inventory",
	"Screenshot": "screenshot",
}


@onready var _grid: GridContainer = $Grid


func populate() -> void:
	for action: String in ACTIONS:
		var label := Label.new()
		label.text = action
		_grid.add_child(label)
		
		var events: Array[InputEvent] = InputMap.action_get_events(ACTIONS[action])
		for i: int in _grid.columns - 1:
			var button := Button.new()
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.custom_minimum_size.x = 64
			button.set_meta("action", ACTIONS[action])
			button.pressed.connect(rebind.bind(button))
			
			if i < events.size():
				button.text = events[i].as_text()
				button.set_meta("event", events[i])
			else:
				button.text = "..."
			
			_grid.add_child(button)


func rebind(button: Button) -> void:
	if button.has_meta("event"):
		InputMap.action_erase_event(button.get_meta("action"), button.get_meta("event"))
	button.text = "Press a key..."
	
	var event: InputEvent = await button.gui_input
	accept_event()
	
	if event.keycode == KEY_BACKSPACE:
		unbind(button)
	else:
		for child: Node in _grid.get_children():
			if child.has_meta("event") and child.get_meta("event").keycode == event.keycode:
				if button.has_meta("event"):
					event = button.get_meta("event")
				else:
					unbind(button)
					return
		
		InputMap.action_add_event(button.get_meta("action"), event)
		button.text = event.as_text()
		button.set_meta("event", event)


func unbind(button: Button) -> void:
	button.text = "..."
	button.remove_meta("event")


func reset() -> void:
	InputMap.load_from_project_settings()
	
	for child: Node in _grid.get_children():
		child.queue_free()
	await get_tree().process_frame
	populate()
	
	$Reset.grab_focus()


func _gui_input(event: InputEvent) -> void:
	print(event)


func _ready() -> void:
	populate()
