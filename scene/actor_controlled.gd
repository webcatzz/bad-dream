extends ActorNode

var listening: bool = true
var input: Vector2

@onready var path: Line2D = $WhileSelected/Path
@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var action_menu: Control = $WhileSelected/ActionMenu

var can_open_action_menu: bool = true
var focusing: bool = true
var splash: Splash


func _ready():
	super()
	Battle.started.connect(set_listening.bind(false))
	Battle.ended.connect(set_listening.bind(true))
	# action selection
	var actionlist: ItemList = action_menu.get_child(1)
	for a in data.actions: actionlist.add_item(a.name)


func _unhandled_key_input(event: InputEvent):
	if Battle.active:
		if Battle.current == data: handle_battle_input(event)
	elif listening:
		# bug: normalization + to_iso() seem to cancel out two-key movement
		input = Iso.to_iso(Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_down") - Input.get_action_strength("move_up")).normalized()) * 4

func set_listening(value: bool): listening = value


# handles movement outside of battle
func _physics_process(_delta):
	if not Battle.active:
		if input and listening: velocity = input
		else: velocity = Vector2.ZERO
		move_and_slide()


# handles movement + other input inside of battle
func handle_battle_input(event: InputEvent):
	# action ui (blocks other input)
	if action_menu.visible:
		if event.is_action_pressed("ui_cancel"):
			if action_menu.current_tab == 0: action_menu.visible = false
			else: action_menu.current_tab = 0
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
		move(path.get_point_position(path.get_point_count() - 1), true)
	elif event.is_action_pressed("ui_accept"):
		if can_open_action_menu: action_menu.visible = true
		else: end_turn()

func update_steps(): $WhileSelected/Steps.text = str(data.speed - path.get_point_count() + 1)


func take_turn():
	path.add_point(data.position)
	update_steps()
	await data.turn_ended
	path.clear_points()
	action_menu.visible = false

func end_turn():
	data.turn_ended.emit()


func focus_action_menu():
	await get_tree().process_frame
	action_menu.get_current_tab_control().find_next_valid_focus().grab_focus()

func action_selected(idx: int):
	if splash: splash.queue_free()
	splash = data.actions[idx].get_node()
	add_child(splash)

func take_action(idx: int):
	await get_tree().process_frame # stops interact input immediately re-opening action menu
	splash.start()
	if data.actions[idx].delay or path.get_point_count() > data.speed:
		focusing = true
		end_turn()
	else:
		action_menu.visible = false
		can_open_action_menu = false
		await data.turn_ended
		can_open_action_menu = true
		

func action_list_closed():
	if splash:
		splash.queue_free()
		splash = null
