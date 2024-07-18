class_name PlayerActorNode extends PartyActorNode


# input
enum InputMode {FREE, GRID}
var input_mode: InputMode
var input: Vector2

# party path
const PARTY_PATH_OFFSET = 4 ## Multiplied by a party member's index in the party to calculate their offset in [member party_path].
var party_path: PackedVector2Array ## Path that party members follow.

# nodes
@onready var camera: Camera2D = $Camera
@onready var _interaction_area: Area2D = $InteractionArea



# data

func _ready() -> void:
	super()
	# controls
	listening = true
	camera.make_current()
	# party path
	party_path.resize(PARTY_PATH_OFFSET * Data.party.size())
	party_path.fill(position)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if listening: match input_mode:
		InputMode.FREE: _handle_free_input(event)
		InputMode.GRID: _handle_battle_input(event)



# free movement & party path

func _handle_free_input(event: InputEvent) -> void:
	# interaction
	if event.is_action_pressed("ui_accept"):
		for area: Area2D in _interaction_area.get_overlapping_areas():
			if area is Trigger:
				area.trigger()
				get_viewport().set_input_as_handled()
				break
	
	# movement
	else:
		input = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down"),
		)
		
		if input:
			data.facing = data.calculate_facing(input)
			velocity = Iso.from_grid(input).normalized() * 96
			if not velocity.x: velocity.y *= 0.875
			
			set_animation("move")
			_sprite.play()
			get_viewport().set_input_as_handled()
		else:
			velocity = Vector2.ZERO
			set_animation("idle")


func _physics_process(_delta: float) -> void:
	if listening and input_mode == InputMode.FREE:
		move_and_slide()
		
		# party path
		if party_path[-1].distance_squared_to(position) > 256:
			party_path.remove_at(0)
			party_path.append(position)


func get_party_path_position(actor: Actor) -> Vector2:
	return party_path[PARTY_PATH_OFFSET * Data.party.find(actor, 1)]



# battle

func _on_battle_entered() -> void:
	listening = false
	input = Vector2.ZERO
	input_mode = InputMode.GRID
	_do_battle_setup()


func _on_battle_exited() -> void:
	camera.make_current()
	camera.reset_smoothing()
	input = Vector2.ZERO
	input_mode = InputMode.FREE
	party_path.fill(position)
	listening = true
