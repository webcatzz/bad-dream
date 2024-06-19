extends CanvasLayer
## Dialogue manager.


signal progressed ## Emitted when a new line is begun.


func bubble(actor: Actor, string: String, position: Vector2) -> void:
	var label: DialogueBubble = DialogueBubble.new()
	label.position = position
	
	label.speaker_pos = actor.node.global_position
	
	add_child(label)
	await label.run(string)
