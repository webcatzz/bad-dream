extends ActorNode

var listening: bool = true
var input: Vector2

@onready var path: Line2D = $WhileSelected/Path
@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var action_ui: Control = $WhileSelected/ActionUI


func _ready():
	super()
	Battle.started.connect(set_listening.bind(false))
	Battle.ended.connect(set_listening.bind(true))
	action_ui.draw.connect(action_ui.get_child(0).grab_focus)


func _unhandled_key_input(event: InputEvent):
	if Battle.active:
		if Battle.current == data: handle_battle_input(event)
	elif listening:
		# bug: normalization + to_iso() seem to cancel out two-key movement
		input = Iso.to_iso(Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_down") - Input.get_action_strength("move_up")).normalized()) * 4

func set_listening(value: bool): listening = value


# handles movement outside of battle
func _physics_process(_delta):
	if !Battle.active:
		if input and listening: velocity = input
		else: velocity = Vector2.ZERO
		move_and_slide()


# handles movement + other input inside of battle
func handle_battle_input(event: InputEvent):
	# action ui (blocks other input)
	if action_ui.visible:
		if event.is_action_pressed("ui_cancel"): action_ui.visible = false
		return
	# movement
	if path.get_point_count() - 1 < data.speed:
		for direction: String in ["up", "down", "left", "right"]:
			if event.is_action_pressed("move_" + direction):
				var vector: Vector2i = Iso.from_string(direction)
				collision_checker.target_position = vector
				await get_tree().process_frame
				if !collision_checker.is_colliding():
					move(data.position + vector)
					path.add_point(data.position)
					update_steps()
				return
	# other stuff
	if event.is_action_pressed("shift"): # reversing movement
		if path.get_point_count() > 1:
			path.remove_point(path.get_point_count() - 1)
			update_steps()
		move(path.get_point_position(path.get_point_count() - 1))
		data.facing *= -1
	elif event.is_action_pressed("ui_accept"): # opening action ui
		action_ui.visible = true


func take_turn():
	path.add_point(data.position)
	update_steps()
	await data.turn_ended
	path.clear_points()
	action_ui.visible = false

func end_turn():
	data.turn_ended.emit()


func update_steps(): $WhileSelected/Steps.text = str(data.speed - path.get_point_count() + 1)
