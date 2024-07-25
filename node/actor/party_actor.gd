class_name PartyActorNode extends ActorNode
## Controllable node representation of an [Actor].


# input
var listening: bool

# nodes
@onready var _action_menu: Control = $DuringTurn/ActionMenu
@onready var _backtrack_timer: Timer = $DuringTurn/BacktrackTimer



# data

func _ready() -> void:
	super()
	# defeat effects
	if data.is_defeated(): _on_defeated()
	# battle signals
	data.battle_entered.connect(_on_battle_entered)
	data.battle_exited.connect(_on_battle_exited)
	# backtracking
	data.path_backtracked.connect(advance_animation.bind(-1))
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
			Data.get_leader().node.SPEED / 60
		)
		
		set_animation("move" if Data.get_leader().node.input else "idle")



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
		
		if vector and Battle.field.is_point_travellable(data.position + vector):
			data.extend_path()
			data.move(vector)
			advance_animation()
			
			get_viewport().set_input_as_handled()
			return
	
	# backtracking
	if event.is_action_pressed(&"backtrack") and data.tiles_traveled:
		data.backtrack_path()
		_backtrack_timer.start()
		get_viewport().set_input_as_handled()
		
		# TODO: when actions_per_turn > 1, disable backtracking past the point an action is used
	
	elif event.is_action_released(&"backtrack"):
		_backtrack_timer.stop()
		get_viewport().set_input_as_handled()
	
	# opening action menu
	elif event.is_action_pressed(&"ui_accept") and not data.current_action:
		_action_menu.visible = true
		get_viewport().set_input_as_handled()


func _on_battle_entered() -> void:
	$Collision.set_disabled.call_deferred(false)
	_do_battle_setup()


func _do_battle_setup() -> void:
	data.position = Iso.to_grid(position.snapped(Vector2(8, 8))).clamp(Battle.field.region.position, Battle.field.region.end)
	
	_sprite.stop()
	set_animation("move")
	_sprite.frame = 1


func _on_battle_exited() -> void:
	$Collision.set_disabled.call_deferred(true)


func _on_backtrack_timer_timeout() -> void:
	if data.tiles_traveled: data.backtrack_path()
	else: _backtrack_timer.stop()
