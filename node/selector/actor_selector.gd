extends Selector


@onready var _path: Line2D = $Path



# selection

func select(body: Node2D) -> void:
	super(body)
	_path.show()


func deselect() -> void:
	super()
	_path.hide()


func deselect_delayed() -> void:
	await get_tree().create_timer(1).timeout
	deselect()


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
	elif event.is_action_pressed("interact") and not can_select(get_body_below()):
		confirm_end_phase()
		get_viewport().set_input_as_handled()
	else:
		super(event)



# end phase

func confirm_end_phase() -> void:
	$EndPhaseConfirm.position = -$EndPhaseConfirm.size/2
	$EndPhaseConfirm.show()
	$EndPhaseConfirm/VBox/Buttons/Yes.grab_focus()
	mode = Mode.MENU


func _on_end_phase_confirmed(value: bool) -> void:
	$EndPhaseConfirm.hide()
	if value:
		Game.battle.end_phase()
	else:
		mode = Mode.MOVE



# area

func _on_body_entered(body: Node2D) -> void:
	super(body)
	_info.write(body.resource)
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	super(body)
	if not get_body_below():
		_info.hide()



# move

func move_to(tile: Vector2i) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", Iso.from_grid(tile), 0.1)
	await tween.finished
