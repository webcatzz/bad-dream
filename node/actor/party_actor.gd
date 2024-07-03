class_name PartyActorNode extends ActorNode
## Controllable node representation of an [Actor].


# input
var listening: bool

# nodes
@onready var _action_menu: Control = $DuringTurn/ActionMenu
@onready var _collision_checker: RayCast2D = $CollisionChecker
@onready var _backtrack_timer: Timer = $DuringTurn/BacktrackTimer



# data

func _ready() -> void:
	super()
	# defeat effects
	if data.is_defeated(): _on_defeated()
	# battle signals
	data.battle_entered.connect(_on_battle_entered)
	data.battle_exited.connect(_on_battle_exited)
	# timers
	_backtrack_timer.timeout.connect(_on_backtrack_timer_timeout)



# movement

func _unhandled_key_input(event: InputEvent) -> void:
	if listening: _handle_battle_input(event)


# following leader
func _physics_process(_delta: float) -> void:
	if not data.in_battle:
		
		data.facing = Iso.to_grid(Iso.get_direction(
			Data.get_leader().node.global_position - global_position
		))
		
		global_position = global_position.move_toward(
			Data.get_leader().node.get_party_path_position(data),
			1.875
		)
		
		if Data.get_leader().node.input:
			_set_sprite_move()
		else:
			_set_sprite_idle()



# battle

## Starts the actor's turn and waits for it to end. Called by [member data].
func take_turn() -> void:
	listening = true
	await data.turn_ended
	listening = false


# Handles movement and other input inside of battle.
func _handle_battle_input(event: InputEvent) -> void:
	# action ui (blocks other input)
	if _action_menu.visible:
		if event.is_action_pressed(&"ui_cancel"):
			if _action_menu.current_tab: _action_menu.current_tab = 0
			else: _action_menu.visible = false
		
		get_viewport().set_input_as_handled()
		return
	
	# movement
	if data.can_move():
		var vector: Vector2i = Vector2i.ZERO
		
		if event.is_action_pressed(&"move_up"): vector = Vector2i.UP
		elif event.is_action_pressed(&"move_down"): vector = Vector2i.DOWN
		elif event.is_action_pressed(&"move_left"): vector = Vector2i.LEFT
		elif event.is_action_pressed(&"move_right"): vector = Vector2i.RIGHT
		
		if vector and Battle.astar.is_point_travellable(data.position + vector):
			data.extend_path()
			data.move(vector)
			_advance_sprite_frame()
			
			get_viewport().set_input_as_handled()
			return
	
	# backtracking
	if event.is_action_pressed(&"shift") and data.tiles_traveled:
		data.backtrack_path()
		_backtrack_timer.start()
		get_viewport().set_input_as_handled()
		
		# TODO: when actions_per_turn > 1, disable backtracking past the point an action is used
	
	elif event.is_action_released(&"shift"):
		_backtrack_timer.stop()
		get_viewport().set_input_as_handled()
	
	# opening action menu
	elif event.is_action_pressed(&"ui_accept") and not data.current_action:
		_action_menu.visible = true
		get_viewport().set_input_as_handled()


func _on_battle_entered() -> void:
	$Collision.set_disabled.call_deferred(false)
	data.move.call_deferred(Data.get_leader().position)
	
	_sprite.stop()
	_set_sprite_move()
	_sprite.frame = 1


func _on_battle_exited() -> void:
	$Collision.set_disabled.call_deferred(true)


func _on_backtrack_timer_timeout() -> void:
	if data.tiles_traveled: data.backtrack_path()
	else: _backtrack_timer.stop()
