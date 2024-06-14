class_name PartyActorNode extends ActorNode
## Controllable node representation of an [Actor].


# input
var listening: bool:
	set(value):
		listening = value
		#print(self.data, ".listening = ", value)

# nodes
@onready var path: Line2D = $DuringTurn/Path
@onready var action_menu: Control = $DuringTurn/ActionMenu
@onready var collision_checker: RayCast2D = $CollisionChecker



# data

func _ready() -> void:
	_on_data_set()


func _on_data_set() -> void:
	super()
	# path
	data.path_extended.connect(_on_path_extended)
	data.path_backtracked.connect(_on_path_backtracked)
	# battle
	data.battle_entered.connect(_on_battle_entered)


# following leader
func _physics_process(delta: float) -> void:
	if not data.in_battle:
		var node: PlayerActorNode = Game.data.get_leader().node
		global_position = global_position.lerp(node.party_path[node.PARTY_PATH_OFFSET * Game.data.party.find(data, 1)], 0.1)



# battle

## Starts the actor's turn. Called by [member data].
func take_turn() -> void:
	listening = true
	
	await data.turn_ended
	
	path.clear_points()
	listening = false


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


func _on_battle_entered() -> void:
	data.position = Iso.to_grid(position)


func _on_path_extended() -> void:
	path.add_point(Iso.from_grid(data.path[-1].position))


func _on_path_backtracked() -> void:
	path.remove_point(data.path.size())
