extends Sprite2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = event.position


func _ready() -> void:
	get_window().mouse_entered.connect(Input.set_mouse_mode.call_deferred.bind(Input.MOUSE_MODE_HIDDEN))
	get_window().mouse_exited.connect(Input.set_mouse_mode.call_deferred.bind(Input.MOUSE_MODE_VISIBLE))
