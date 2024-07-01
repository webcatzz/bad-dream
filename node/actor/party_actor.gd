class_name PartyActorNode extends ActorNode
## Controllable node representation of an [Actor].


# input
var listening: bool

# nodes
@onready var path: Line2D = $DuringTurn/Path
@onready var action_menu: Control = $DuringTurn/ActionMenu
@onready var collision_checker: RayCast2D = $CollisionChecker
@onready var _backtrack_timer: Timer = $DuringTurn/BacktrackTimer



# data

func _ready() -> void:
	_on_data_set()
	
	_backtrack_timer.timeout.connect(_on_backtrack_timer_timeout)
	_walk_cycle_timer.timeout.connect(_advance_walk_cycle)


func _on_data_set() -> void:
	super()
	# path
	data.path_extended.connect(_on_path_extended)
	data.path_backtracked.connect(_on_path_backtracked)
	# battle
	data.battle_entered.connect(_on_battle_entered)
	data.battle_exited.connect(_on_battle_exited)
	# defeated
	if data.is_defeated():
		_on_defeated()


# following leader
func _physics_process(_delta: float) -> void:
	if not data.in_battle:
		var old_position: Vector2 = global_position
		
		global_position = global_position.lerp(
			Data.get_leader().node.get_party_path_position(data),
			0.1
		)
		_on_facing_changed(Iso.to_grid(Iso.get_direction(
			Data.get_leader().node.global_position - global_position
		)))
		
		_walk_cycle_timer.paused = (global_position - old_position).length_squared() < 2


func _advance_walk_cycle() -> void:
	_sprite.frame_coords.x = (_sprite.frame_coords.x + 1) % _sprite.hframes



# battle

## Starts the actor's turn. Called by [member data].
func take_turn() -> void:
	listening = true
	
	await data.turn_ended
	
	listening = false
	path.clear_points()


func _unhandled_key_input(event: InputEvent) -> void:
	if listening: _handle_battle_input(event)


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
		
		if vector and Battle.astar.region.has_point(data.position + vector):
			collision_checker.target_position = Iso.from_grid(vector)
			collision_checker.force_raycast_update()
			if not collision_checker.is_colliding():
				data.extend_path()
				data.move(vector)
				_advance_walk_cycle()
			
			get_viewport().set_input_as_handled()
			return
	
	# backtracking
	if event.is_action_pressed("shift") and data.tiles_traveled:
		data.backtrack_path()
		_backtrack_timer.start()
		get_viewport().set_input_as_handled()
		
		# TODO: when actions_per_turn > 1, disable backtracking past the point an action is used
	
	elif event.is_action_released("shift"):
		_backtrack_timer.stop()
		get_viewport().set_input_as_handled()
	
	# opening action menu
	elif event.is_action_pressed("ui_accept") and not data.current_action:
		action_menu.visible = true
		get_viewport().set_input_as_handled()


func _on_battle_entered() -> void:
	$Collision.set_disabled.call_deferred(false)
	data.move.call_deferred(Data.get_leader().position)


func _on_battle_exited() -> void:
	$Collision.set_disabled.call_deferred(true)


func _on_path_extended() -> void:
	path.add_point(Iso.from_grid(data.path[-1].position))


func _on_path_backtracked() -> void:
	path.remove_point(data.path.size())


func _on_backtrack_timer_timeout() -> void:
	if data.tiles_traveled: data.backtrack_path()
	else: _backtrack_timer.stop()
