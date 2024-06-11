class_name DialogueTrigger extends Trigger


@export_multiline var text: String


func trigger() -> void:
	super()
	monitorable = false
	await Dialogue.small(text, Vector2(200, 200))
	monitorable = true
