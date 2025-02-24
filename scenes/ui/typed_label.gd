class_name TypedLabel
extends Label


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
			await get_tree().create_timer(0.05).timeout


func skip() -> void:
	visible_characters = text.length()



# init

func _ready() -> void:
	visible_characters = 0
