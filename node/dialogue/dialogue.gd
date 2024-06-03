extends CanvasLayer


## Emitted when a new line is begun.
signal progressed


func small(string: String, position: Vector2) -> void:
	var label: DialogueBubble = DialogueBubble.new()
	label.position = position
	add_child(label)
	await label.run(string)
