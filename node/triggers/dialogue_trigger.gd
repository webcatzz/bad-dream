class_name DialogueTrigger extends Trigger


@export_multiline var text: String


func trigger() -> void:
	super()
	monitorable = false
	await Dialogue.bubble(Game.data.get_leader(), text, Vector2(100, 200))
	monitorable = true
