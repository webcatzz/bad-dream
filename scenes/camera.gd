extends Camera2D

const SPEED: float = 250

var input: Vector2


func _unhandled_key_input(event: InputEvent) -> void:
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED


func _process(delta: float) -> void:
	position += input * delta
