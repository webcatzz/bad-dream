extends Camera2D

const CENTER := Rect2(75, 50, 450, 300)
const LIMIT := Vector2(75, 50)

const SPEED: int = 250
const ACCEL: float = 0.1

@export var tracking: Node2D

var pull: Vector2
var velocity: Vector2
var movable: bool = true: set = set_movable



# movement

func _process(delta: float) -> void:
	velocity = velocity.lerp(pull, ACCEL)
	position = (position + velocity * delta).clamp(tracking.position - LIMIT, tracking.position + LIMIT)


func set_movable(value: bool) -> void:
	movable = value
	set_process_unhandled_input(value)
	set_process(value)
	pull = Vector2.ZERO



# mouse movement

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if CENTER.has_point(event.global_position):
			pull = Vector2.ZERO
		else:
			pull = CENTER.get_center().direction_to(event.global_position) * SPEED


func _ready() -> void:
	get_window().mouse_exited.connect(set_movable.bind(false))
	get_window().mouse_entered.connect(set_movable.bind(true))



# keyboard movement

#func _unhandled_key_input(event: InputEvent) -> void:
	#pull = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
