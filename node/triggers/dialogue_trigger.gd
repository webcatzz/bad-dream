class_name DialogueTrigger extends Trigger


@export_multiline var text: String
@export var screen_position: Vector2i


func trigger() -> void:
	super()
	monitorable = false
	await Dialogue.bubble(Data.get_leader(), text, screen_position)
	monitorable = true
