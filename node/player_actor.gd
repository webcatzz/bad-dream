class_name PlayerActorNode extends PartyActorNode


# input
enum InputMode {FREE, GRID}
var input_mode: InputMode
var input: Vector2



# data

func _ready() -> void:
	super()
	listening = true


func _on_data_set() -> void:
	super()
	data.battle_exited.connect(_on_battle_exited)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if listening: match input_mode:
		InputMode.FREE: _handle_free_input(event)
		InputMode.GRID: _handle_battle_input(event)



# free movement

func _handle_free_input(event: InputEvent) -> void:
	# interaction
	if event.is_action_pressed("ui_accept"):
		for area: Area2D in interaction_area.get_overlapping_areas():
			if area is Trigger:
				area.trigger()
				break
	
	# movement
	else:
		input = Vector2(Iso.from_grid(Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		))).normalized() * 128
		
		if input:
			data.facing = Iso.to_grid(Iso.get_direction(input))
			get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if not data.in_battle:
		velocity = input if listening else Vector2.ZERO
		move_and_slide()



# battle

func _on_battle_entered() -> void:
	listening = false
	input_mode = InputMode.GRID
	super()


func _on_battle_exited() -> void:
	camera.make_current()
	input_mode = InputMode.FREE
	listening = true
