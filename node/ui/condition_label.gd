extends PanelContainer


@onready var _name: Label = $Margins/HBox/Name
@onready var _duration: Slots = $Margins/HBox/Duration
@onready var _color: ColorRect = $Color


func write(condition: Condition) -> void:
	_name.text = condition.name()
	_duration.set_values(condition.duration_left, condition.duration)
	_color.color = condition.color()
