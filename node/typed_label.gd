class_name TypedLabel extends Label


func type(string: String = text) -> void:
	visible_characters = 0
	text = string
	grab_focus()
	
	while true:
		visible_characters += 1
		
		if visible_characters >= text.length():
			break
		elif text[visible_characters - 1] in ".,?!":
			await get_tree().create_timer(0.5).timeout
		else:
			await get_tree().create_timer(0.04).timeout



# internal 

func _init() -> void:
	autowrap_mode = TextServer.AUTOWRAP_WORD
	focus_mode = FOCUS_ALL
	visible_characters = 0


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and visible_characters < text.length():
		visible_characters = text.length()
		accept_event()
