extends PanelContainer


@onready var _name: Label = $HBox/Name
@onready var _duration: Slots = $HBox/Duration


func write(condition: Condition) -> void:
	_name.text = condition.name()
	_duration.set_values(condition.duration_left, condition.duration)
	#_color.color = condition.color()
