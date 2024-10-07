extends Selector


@onready var _path: Line2D = $Path



# selection

func select(body: Node2D) -> void:
	super(body)
	_path.show()


func deselect() -> void:
	super()
	_path.hide()


func can_select(body: Node2D) -> bool:
	return super(body) and body.resource in Save.party and not body.resource.acted_this_phase


func match_position(node: Node2D = selected) -> void:
	super(node)
	
	if selected:
		_path.points = selected.resource.path.map(func(point: Dictionary) -> Vector2:
			return Iso.from_grid(point.position)
		)
		_path.add_point(selected.position)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if mode == Mode.MENU: return
	
	if event.keycode in range(KEY_1, KEY_1 + Save.party.size()) and event.pressed:
		match_position(Save.party[event.keycode - KEY_1].node)
		get_viewport().set_input_as_handled()
	else:
		super(event)



# area

func _on_body_entered(body: Node2D) -> void:
	super(body)
	_info.write(body.resource)
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	super(body)
	if not get_body_below():
		_info.hide()
