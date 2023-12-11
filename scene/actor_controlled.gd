extends ActorNode

var listening: bool = true
var input: Vector2
var path: Array
var can_open_action_menu: bool = true
var splash: Splash

@onready var path_node: Line2D = $WhileSelected/Path
@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var action_menu: Control = $WhileSelected/ActionMenu


func _ready() -> void:
	super()
	Battle.started.connect(set_listening.bind(false))
	Battle.ended.connect(set_listening.bind(true))
	# action selection
	var actionlist: ItemList = action_menu.get_child(1)
	for a in data.actions: actionlist.add_item(a.name)


func _unhandled_key_input(event: InputEvent) -> void:
	if Battle.active:
		if Battle.current == data: handle_battle_input(event)
	elif listening:
		# bug: normalization + to_iso() seem to cancel out two-key movement
		input = Iso.to_iso(Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_down") - Input.get_action_strength("move_up")).normalized()) * 4
		if input: data.facing = Iso.get_direction(input)

func set_listening(value: bool) -> void: listening = value


# handles movement outside of battle
func _physics_process(_delta: float) -> void:
	if not Battle.active:
		if input and listening: velocity = input
		else: velocity = Vector2.ZERO
		move_and_slide()


# handles movement + other input inside of battle
func handle_battle_input(event: InputEvent) -> void:
	# action ui (blocks other input)
	if action_menu.visible:
		if event.is_action_pressed("ui_cancel"):
			if action_menu.current_tab == 0: action_menu.visible = false
			else: action_menu.current_tab = 0
		return
	# movement
	if has_speed_left():
		for direction: String in ["up", "down", "left", "right"]:
			if event.is_action_pressed("move_" + direction):
				var vector: Vector2i = Iso.from_string(direction)
				collision_checker.target_position = vector
				collision_checker.force_raycast_update()
				if !collision_checker.is_colliding():
					move(data.position + vector)
					update_path()
				return
	# other stuff
	if event.is_action_pressed("shift") and path.size() > 1: # reversing movement
		shorten_path()
		move(path[-1].position)
		data.facing = path[-1].facing
	elif event.is_action_pressed("ui_accept"):
		if can_open_action_menu: action_menu.visible = true
		else: end_turn()

func has_speed_left() -> bool: return path.size() - 1 < data.speed

func update_steps() -> void: $WhileSelected/Steps.text = str(data.speed - path.size() + 1)

func update_path() -> void:
	path.append({"position": data.position, "facing": data.facing})
	path_node.add_point(data.position)
	update_steps()

func shorten_path() -> void:
	path.remove_at(path.size() - 1)
	path_node.remove_point(path.size())
	update_steps()


func take_turn() -> void:
	update_path()
	await data.turn_ended
	path = []
	path_node.clear_points()
	action_menu.visible = false

func end_turn() -> void:
	data.turn_ended.emit()


func focus_action_menu() -> void:
	action_menu.get_current_tab_control().find_next_valid_focus().grab_focus()

func action_selected(idx: int) -> void:
	if splash: splash.queue_free()
	splash = data.actions[idx].get_node()
	splash.data.cause = data
	add_child(splash)

func take_action(idx: int) -> void:
	splash.start()
	if data.actions[idx].delay or not has_speed_left():
		data.focusing = true
		end_turn()
	else:
		action_menu.visible = false
		can_open_action_menu = false
		await data.turn_ended
		can_open_action_menu = true

func action_list_closed() -> void:
	if splash:
		splash.queue_free()
		splash = null
