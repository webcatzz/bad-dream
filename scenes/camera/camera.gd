extends Camera2D

const SPEED: int = 250
const LIMIT := Vector2(75, 50)

@export var tracking: Node2D

var input: Vector2



# movement

func set_movable(value: bool) -> void:
	set_process_unhandled_input(value)
	set_process(value)
	input = Vector2.ZERO


func _process(delta: float) -> void:
	position += input * delta
	if tracking: position = position.clamp(tracking.position - LIMIT, tracking.position + LIMIT)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
