extends ActorNode
## Controllable node representation of an [Actor].


# input
enum InputState {FREE, GRID}
var input_state: InputState
var input: Vector2
var listening: bool = true

# path
var path: Array
@onready var path_node: Line2D = $WhileSelected/Path

@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var action_menu: Control = $WhileSelected/ActionMenu


func _ready() -> void:
	super()
	Battle.started.connect(_on_battle_entered)
	Battle.ended.connect(_on_battle_exited)


func _unhandled_key_input(event: InputEvent) -> void:
	if listening: match input_state:
		
		InputState.FREE:
			input = Iso.normalize(Iso.from_cart(Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			))) * 8
			if input: data.facing = Iso.get_direction(input)
		
		InputState.GRID:
			_handle_battle_input(event)


# Handles movement outside of battle.
func _physics_process(_delta: float) -> void:
	if input_state == InputState.FREE:
		velocity = input if listening else Vector2.ZERO
		move_and_slide()



# in battle

## Starts the actor's turn. Called by [member data].
func take_turn() -> void:
	listening = true
	_extend_path()
	
	await data.turn_ended
	listening = false
	path.clear()
	path_node.clear_points()


# Handles movement and other input inside of battle.
func _handle_battle_input(event: InputEvent) -> void:
	# action ui (blocks other input)
	if action_menu.visible:
		if event.is_action_pressed("ui_cancel"):
			if action_menu.current_tab: action_menu.current_tab = 0
			else: action_menu.visible = false
		
		get_viewport().set_input_as_handled()
		return
	
	# movement
	if data.can_move():
		for direction: String in ["up", "down", "left", "right"]:
			if event.is_action_pressed("move_" + direction):
				var vector: Vector2i = Iso.from_string(direction)
				
				collision_checker.target_position = vector
				collision_checker.force_raycast_update()
				if not collision_checker.is_colliding():
					move(data.position + vector)
					data.tiles_traveled += 1
					_extend_path()
				
				get_viewport().set_input_as_handled()
				return
	
	# backtracking
	if event.is_action_pressed("shift") and data.tiles_traveled:
		data.tiles_traveled -= 1
		_backtrack_path()
		move(path[-1].position)
		data.facing = path[-1].facing
		
		get_viewport().set_input_as_handled()
	
	# opening action menu / ending turn
	elif event.is_action_pressed("ui_accept"):
		if data.can_act(): action_menu.visible = true
		else: data.end_turn()
		
		get_viewport().set_input_as_handled()


# Extends [member path] to include the current position.
func _extend_path() -> void:
	path.append({"position": data.position, "facing": data.facing})
	path_node.add_point(data.position)
	_update_traveled_counter()


# Shortens [member path] by one and updates [member position] accordingly.
func _backtrack_path() -> void:
	path.remove_at(path.size() - 1)
	path_node.remove_point(path.size())
	_update_traveled_counter()


# Displays the remaining number of travelable tiles.
func _update_traveled_counter() -> void:
	$WhileSelected/Steps.text = str(data.tiles_per_turn - data.tiles_traveled)


func _on_battle_entered() -> void:
	listening = false
	data.position = Iso.snap(position)
	input_state = InputState.GRID


func _on_battle_exited() -> void:
	input_state = InputState.FREE
	listening = true
