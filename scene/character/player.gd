class_name Player
extends Actor



# movement

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		walk_to(get_global_mouse_position())


func set_movable(value: bool) -> void:
	set_process_unhandled_input(value)



# temp

func _ready() -> void:
	super()
	Game.player = self
