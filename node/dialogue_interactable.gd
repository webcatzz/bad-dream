extends Interactable


signal progressed

@export_multiline var text: String

var awaiting_input: bool = false

@onready var _log: VBoxContainer = $Panel/VBox/Wrapper/Log


func interact() -> void:
	monitorable = false
	
	for line: String in text.split("\n", false):
		var label := TypedLabel.new()
		_log.add_child(label)
		await label.type(line)
		
		awaiting_input = true
		await progressed
		awaiting_input = false
		
		label.theme_type_variation = &"LabelSmall"
	
	for child: Node in _log.get_children():
		child.queue_free()
	
	monitorable = true



# internal

func _unhandled_key_input(event: InputEvent) -> void:
	if awaiting_input and event.is_action_pressed("ui_accept"):
		progressed.emit()
