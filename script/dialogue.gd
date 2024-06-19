extends CanvasLayer
## Dialogue manager.


signal progressed ## Emitted when a new line is begun.


func small(string: String, position: Vector2) -> void:
	var label: DialogueBubble = DialogueBubble.new()
	label.position = position
	label.tail = position
	add_child(label)
	await label.run(string)


func say(actor: Actor, text: String) -> void:
	pass
