extends Selector


@onready var _info: InfoPanel = $Info
@onready var _path: Line2D = $Path



# selection

func select(body: Node2D) -> void:
	super(body)
	_path.show()


func deselect() -> void:
	super()
	_path.hide()


func can_select(body: Node2D) -> bool:
	return super(body) and body.resource in Save.party and not body.resource.is_exhausted()


func match_position(node: Node2D = selected) -> void:
	super(node)
	
	if selected:
		_path.points = selected.resource.path.map(func(point: Dictionary) -> Vector2:
			return Iso.from_grid(point.position)
		)



# action menu

func open_action_menu() -> void:
	if not selected: auto_select()
	mode = Mode.ACT
	
	Game.battle.action_menu.open(selected.resource)


func _on_action_activated(action: Action) -> void:
	if action:
		selected.resource.send_action(action)
		await get_tree().create_timer(1).timeout
	deselect()



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_pressed("undo"):
		Game.battle.history.undo()
		get_viewport().set_input_as_handled()
	
	elif Input.is_action_pressed("end_phase"):
		$ConfirmEndPhase.popup_centered()
		get_viewport().set_input_as_handled()
	
	elif event.pressed and event.keycode >= KEY_1 and event.keycode <= KEY_4:
		match event.keycode:
			KEY_1: match_position(Save.party[0].node)
			KEY_2: if Save.party.size() > 1: match_position(Save.party[1].node)
			KEY_3: if Save.party.size() > 2: match_position(Save.party[2].node)
			KEY_4: if Save.party.size() > 3: match_position(Save.party[3].node)
		get_viewport().set_input_as_handled()
	
	elif mode != Mode.ACT:
		super(event)


func _on_interact_held() -> void:
	if selected: open_action_menu()


func move(motion: Vector2i) -> void:
	if selected.resource.can_move() and not selected.test_move(selected.transform, Iso.from_grid(motion)):
		Game.battle.history.add_motion(selected.resource, motion)



# area

func _on_body_entered(body: Node2D) -> void:
	super(body)
	
	_info.write(body.resource)
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	super(body)
	
	if not get_body_below():
		_info.hide()
