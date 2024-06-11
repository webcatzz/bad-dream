extends Label


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		visible_characters = 0
		
		while visible and visible_ratio != 1:
			visible_characters += 1
			await get_tree().create_timer(0.075).timeout
