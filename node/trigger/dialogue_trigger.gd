class_name DialogueTrigger extends Trigger


@export_multiline var text: String
@export var screen_position: Vector2i
@export var speaker_path: NodePath


func trigger() -> void:
	super()
	monitorable = false
	
	await Dialogue.bubble(
		get_node(speaker_path) if speaker_path else Data.get_leader().node,
		text,
		screen_position
	)
	
	monitorable = true
