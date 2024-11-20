class_name TypedLabel extends Label


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
	
	focus_mode = FOCUS_NONE


func skip() -> void:
	visible_characters = text.length()



# internal

func _ready() -> void:
	autowrap_mode = TextServer.AUTOWRAP_WORD
	visible_characters = 0
