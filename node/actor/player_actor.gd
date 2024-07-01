class_name PlayerActorNode extends PartyActorNode


# input
enum InputMode {FREE, GRID}
var input_mode: InputMode
var input: Vector2

# party path
const PARTY_PATH_OFFSET = 4 ## Multiplied by a party member's index in the party to calculate their offset in [member party_path].
var party_path: PackedVector2Array ## Path that party members follow.

# nodes
@onready var interaction_area: Area2D = $InteractionArea
@onready var camera: Camera2D = $Camera



# data

func _ready() -> void:
	super()
	listening = true
	camera.make_current()
	
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
		for area: Area2D in interaction_area.get_overlapping_areas():
			if area is Trigger:
				area.trigger()
				break
	
	# movement
	else:
		input = Iso.from_grid(Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)).normalized() * 112
		
		if input:
			data.facing = Iso.to_grid(Iso.get_direction(input))
			get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if input_mode == InputMode.FREE:
		velocity = input if listening else Vector2.ZERO
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
	input_mode = InputMode.GRID
	data.position = Iso.to_grid(position)


func _on_battle_exited() -> void:
	camera.make_current()
	camera.reset_smoothing()
	input = Vector2.ZERO
	input_mode = InputMode.FREE
	listening = true
