extends ActorNode
## Controllable node representation of an [Actor].


# input
enum InputState {FREE, GRID}
var input_state: InputState
var input: Vector2
var listening: bool = true

# battle
signal battle_state_changed
enum BattleState {MOVING, CHOOSING_ACTION}
var battle_state: BattleState

# nodes
@onready var path: Line2D = $DuringTurn/Path
@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var action_menu: Control = $DuringTurn/ActionMenu
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	super()
	# battle
	Battle.started.connect(_on_battle_entered)
	Battle.ended.connect(_on_battle_exited)
	# path
	data.path_extended.connect(_on_path_extended)
	data.path_backtracked.connect(_on_path_backtracked)


func _unhandled_key_input(event: InputEvent) -> void:
	if listening: match input_state:
		InputState.FREE: _handle_free_input(event)
		InputState.GRID: _handle_battle_input(event)



# free movement

func _handle_free_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for area: Area2D in interaction_area.get_overlapping_areas():
			if area is Trigger:
				area.trigger()
				break
	
	else:
		input = Vector2(Iso.from_grid(Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		))).normalized() * 128
		
		if input:
			data.facing = Iso.to_grid(Iso.get_direction(input))
			get_viewport().set_input_as_handled()


# Handles movement outside of battle.
func _physics_process(_delta: float) -> void:
	if input_state == InputState.FREE:
		velocity = input if listening else Vector2.ZERO
		move_and_slide()



# in battle

## Starts the actor's turn. Called by [member data].
func take_turn() -> void:
	listening = true
	data.extend_path()
	
	await data.turn_ended
	path.clear_points()
	listening = false


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
		var vector: Vector2i = Vector2i.ZERO
		
		if event.is_action_pressed("move_up"): vector = Vector2i.UP
		elif event.is_action_pressed("move_down"): vector = Vector2i.DOWN
		elif event.is_action_pressed("move_left"): vector = Vector2i.LEFT
		elif event.is_action_pressed("move_right"): vector = Vector2i.RIGHT
		
		if vector:
			collision_checker.target_position = Iso.from_grid(vector)
			collision_checker.force_raycast_update()
			if not collision_checker.is_colliding():
				data.extend_path()
				data.move(data.position + vector)
			
			get_viewport().set_input_as_handled()
			return
	
	# backtracking
	if event.is_action_pressed("shift") and data.tiles_traveled:
		data.backtrack_path()
		get_viewport().set_input_as_handled()
	
	# opening action menu / ending turn
	elif event.is_action_pressed("ui_accept"):
		if data.can_act(): action_menu.visible = true
		else: data.end_turn()
		
		get_viewport().set_input_as_handled()


# Updates [member path] to match the path in [member data].
func _on_path_changed() -> void:
	path.clear_points()
	for point: Dictionary in data.path:
		path.add_point(Iso.from_grid(point.position))
	
	$DuringTurn/Steps.text = str(data.tiles_per_turn - data.tiles_traveled)


func _on_path_extended() -> void:
	path.add_point(Iso.from_grid(data.path[-1].position))


func _on_path_backtracked() -> void:
	path.remove_point(data.path.size())


func _on_battle_entered() -> void:
	listening = false
	data.position = Iso.to_grid(position)
	input_state = InputState.GRID


func _on_battle_exited() -> void:
	input_state = InputState.FREE
	listening = true
