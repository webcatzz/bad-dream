extends VBoxContainer


const ACTIONS: Dictionary = { # fix [String, String]
	"Interact": "ui_accept",
	"Cancel": "ui_cancel",
	
	"Move up": "move_up",
	"Move down": "move_down",
	"Move left": "move_left",
	"Move right": "move_right",
	
	"Inventory": "inventory",
	"Backtrack": "undo",
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
			if i < events.size():
				var button := Button.new()
				button.text = events[i].as_text()
				button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				button.custom_minimum_size.x = 64
				button.set_meta("action", ACTIONS[action])
				button.set_meta("event", events[i])
				button.pressed.connect(unbind.bind(button))
				_grid.add_child(button)
			else:
				_grid.add_child(Control.new())


func unbind(button: Button) -> void:
	InputMap.action_erase_event(button.get_meta("action"), button.get_meta("event"))
	button.gui_input.connect(rebind.bind(button), CONNECT_ONE_SHOT)


func rebind(event: InputEvent, button: Button) -> void:
	InputMap.action_add_event(button.get_meta("action"), event)
	button.text = event.as_text()
	button.set_meta("event", event)
	accept_event()


func reset() -> void:
	InputMap.load_from_project_settings()
	
	for child: Node in _grid.get_children():
		child.queue_free()
	await get_tree().process_frame
	populate()
	
	$Reset.grab_focus()


func _ready() -> void:
	populate()
