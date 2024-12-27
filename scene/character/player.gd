class_name Player
extends Actor

var listening: bool = true



# movement

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if listening:
			walk_to(get_global_mouse_position())
		else:
			get_viewport().set_input_as_handled()



# init

func _ready() -> void:
	super()
	Game.player = self
