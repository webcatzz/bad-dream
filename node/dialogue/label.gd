class_name DialogueLabel extends Label
## Specialized label for typing out dialogue.


var awaiting_input: bool ## Whether the label is awaiting input to continue (e.g. at the end of a line).


## Runs dialogue line-by-line.
func run(string: String) -> void:
	grab_focus()
	
	for line: String in string.split("\n", false):
		await type(line)
		
		awaiting_input = true
		await Dialogue.progressed
		awaiting_input = false


## Types out a string, pausing at punctuation.
func type(string: String = text) -> void:
	visible_characters = 0
	text = string
	
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
	theme_type_variation = &"DialogueLabel"
	autowrap_mode = TextServer.AUTOWRAP_WORD
	focus_mode = Control.FOCUS_ALL
	visible_characters = 0


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if awaiting_input:
			Dialogue.progressed.emit()
		else:
			visible_characters = text.length()
		
		accept_event()
