class_name Player
extends Actor



# movement

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		walk_to(get_global_mouse_position())


func set_movable(value: bool) -> void:
	set_process_unhandled_input(value)



# init

func _ready() -> void:
	super()
	Game.player = self
