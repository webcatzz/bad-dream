extends Node


var input: Vector2
var can_input: bool = true:
	set(value):
		can_input = value
		if not can_input: input = Vector2.ZERO



# input

func _unhandled_key_input(event: InputEvent):
	if can_input:
		input = Iso.from_grid(Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down"),
		))



# debug

var command_history: PackedStringArray
var history_idx: int

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		$Console.show()
		$Console/Input.grab_focus()
		history_idx = command_history.size()
		get_viewport().set_input_as_handled()


func _console_run(command: String) -> void:
	$Console.hide()
	$Console/Input.clear()
	
	var script: GDScript = GDScript.new()
	script.source_code = "static func run():" + command
	script.reload()
	script.run()
	
	command_history.append(command)


func _console_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			$Console.hide()
			$Console/Input.clear()
		elif event.keycode == KEY_UP and event.pressed and command_history:
			history_idx = max(history_idx - 1, 0)
			$Console/Input.text = command_history[history_idx]
		elif event.keycode == KEY_SHIFT:
			get_viewport().set_input_as_handled()
