extends CanvasLayer
## Dialogue manager.


signal progressed ## Emitted when a new line is begun.


func bubble(speaker: Node, string: String, position: Vector2) -> void:
	var label: DialogueBubble = DialogueBubble.new()
	label.speaker = speaker
	label.position = position
	
	add_child(label)
	await label.run(string)
