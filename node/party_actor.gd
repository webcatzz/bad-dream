extends ActorNode
## Controllable node representation of an [Actor].

var listening: bool = true
var input: Vector2

var path: Array
@onready var path_node: Line2D = $WhileSelected/Path

@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var action_menu: Control = $WhileSelected/ActionMenu


func _ready() -> void:
	super()
	Battle.started.connect(snap_position)
	Battle.started.connect(set_listening.bind(false))
	Battle.ended.connect(set_listening.bind(true))
	# action selection
	var actionlist: ItemList = action_menu.get_child(1)
	for a in data.actions: actionlist.add_item(a.name)


func _unhandled_key_input(event: InputEvent) -> void:
	if Battle.active:
		if Battle.current_actor == data:
			handle_battle_input(event)
	elif listening:
		input = Iso.normalize(Iso.from_cart(Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		))) * 8
		if input: data.facing = Iso.get_direction(input)

func set_listening(value: bool) -> void:
	listening = value

func snap_position() -> void:
	data.position = Iso.snap(position)

## Handles movement outside of battle.
func _physics_process(_delta: float) -> void:
	if not Battle.active:
		if listening: velocity = input
		else: velocity = Vector2.ZERO
		move_and_slide()

## Handles movement and other input inside of battle.
func handle_battle_input(event: InputEvent) -> void:
	# action ui (blocks other input)
	if action_menu.visible:
		if event.is_action_pressed("ui_cancel"):
			if action_menu.current_tab == 0: action_menu.visible = false
			else: action_menu.current_tab = 0
		get_viewport().set_input_as_handled()
		return
	
	# movement
	if data.can_move():
		for direction: String in ["up", "down", "left", "right"]:
			if event.is_action_pressed("move_" + direction):
				var vector: Vector2i = Iso.from_string(direction)
				collision_checker.target_position = vector
				collision_checker.force_raycast_update()
				if !collision_checker.is_colliding():
					move(data.position + vector)
					data.tiles_traveled += 1
					extend_path()
				return
	
	# reversing movement
	if event.is_action_pressed("shift") and data.tiles_traveled:
		data.tiles_traveled -= 1
		backtrack_path()
		move(path[-1].position)
		data.facing = path[-1].facing
	
	# opening action menu / ending turn
	elif event.is_action_pressed("ui_accept"):
		if data.can_act(): action_menu.visible = true
		else: data.end_turn()

func update_steps() -> void:
	$WhileSelected/Steps.text = str(data.tiles_per_turn - data.tiles_traveled)

## Extends [member path] to include the current position.
func extend_path() -> void:
	path.append({"position": data.position, "facing": data.facing})
	path_node.add_point(data.position)
	update_steps()

## Shortens [member path] by one and updates [member position] accordingly.
func backtrack_path() -> void:
	path.remove_at(path.size() - 1)
	path_node.remove_point(path.size())
	update_steps()


func take_turn() -> void:
	extend_path()
	
	await data.turn_ended
	path.clear()
	path_node.clear_points()
