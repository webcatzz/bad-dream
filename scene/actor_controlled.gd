extends ActorNode

var listening: bool = true
var input: Vector2

@onready var path: Line2D = $Path


func _ready():
	super()
	Battle.started.connect(set_listening.bind(false))
	Battle.ended.connect(set_listening.bind(true))


func _unhandled_key_input(event: InputEvent):
	if Battle.active:
		if Battle.current == data:
			if path.get_point_count() - 1 < data.speed:
				for direction in ["up", "down", "left", "right"]:
					if event.is_action_pressed("move_" + direction):
						move(data.position + Iso.from_string(direction))
						path.add_point(data.position)
						update_steps()
						return
			if event.is_action_pressed("shift"):
				if path.get_point_count() > 1:
					path.remove_point(path.get_point_count() - 1)
					update_steps()
				move(path.get_point_position(path.get_point_count() - 1))
			elif event.is_action_pressed("ui_accept"):
				data.turn_ended.emit()
	elif listening:
		input = Iso.to_iso(Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_down") - Input.get_action_strength("move_up")).normalized()) * 4


func _physics_process(delta):
	if input and listening: velocity = input
	else: velocity = Vector2.ZERO
	move_and_slide()


func set_listening(value: bool):
	listening = value


func take_turn():
	path.add_point(data.position)
	update_steps()
	await data.turn_ended
	path.clear_points()


func update_steps():
	$StepsLabel.text = str(data.speed - path.get_point_count() + 1)
	print(path.points)
