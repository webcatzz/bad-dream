extends LineEdit


var history: PackedStringArray
var history_idx: int


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		Menus.open(Menus.Menu.CONSOLE)
		grab_focus()
		history_idx = history.size()
		get_viewport().set_input_as_handled()


func run() -> void:
	var script: GDScript = GDScript.new()
	script.source_code = "static func run():" + text
	script.reload()
	script.run()
	
	history.append(text)
	clear()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Menus.close()
			clear()
		elif event.pressed:
			if event.keycode == KEY_UP and history:
				history_idx = max(history_idx - 1, 0)
				text = history[history_idx]
			elif event.keycode == KEY_ENTER:
				run()
