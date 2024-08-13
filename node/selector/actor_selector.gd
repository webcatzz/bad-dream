extends Selector


@onready var _info: InfoPanel = $Info
@onready var _path: Line2D = $Path


func select(body: Node2D) -> void:
	if body.resource in Save.party:
		super(body)
		_path.show()


func deselect() -> void:
	super()
	_path.hide()


func match_position(node: Node2D = selected) -> void:
	super(node)
	
	if mode == Mode.MOVE:
		_path.points = selected.resource.path.map(func(point: Dictionary) -> Vector2:
			return Iso.from_grid(point.position)
		)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_pressed("undo"):
		Game.current_battle.history.undo()
		get_viewport().set_input_as_handled()
	else:
		super(event)


func move(motion: Vector2i) -> void:
	if selected.resource.can_move() and not selected.test_move(selected.transform, Iso.from_grid(motion)):
		Game.current_battle.history.add_motion(selected.resource, motion)



# area

func _on_body_entered(body: Node2D) -> void:
	var actor: Actor = body.resource
	_info.set_title(actor.name)
	_info.set_footer("Enemy actor" if actor is Enemy else "Party actor")
	
	var will: HBoxContainer = _info.add_slice()
	will.add_child(_info.create_label("Will", &"SmallLabelMuted"))
	will.add_child(Slots.from(actor.will, actor.max_will))
	var stamina: HBoxContainer = _info.add_slice()
	stamina.add_child(_info.create_label("Stamina", &"SmallLabelMuted"))
	stamina.add_child(Slots.from(actor.stamina, actor.max_stamina))
	
	_info.add_spacer()
	
	if actor.traits:
		_info.add_label("Traits", &"SmallLabelMuted")
		for trait_type: Trait.Type in actor.traits:
			var label: Control = preload("res://node/ui/trait_label.tscn").instantiate()
			label.write(trait_type)
			_info.add_control(label)
	else:
		_info.add_control(_info.create_label("No traits.\nA tabula rasa.", &"SmallLabelMuted"))
	
	_info.add_spacer()
	
	if actor.conditions:
		_info.add_label("Conditions", &"SmallLabelMuted")
		for condition: Condition in actor.conditions:
			var label: Control = preload("res://node/ui/condition_label.tscn").instantiate()
			label.write(condition)
			_info.add_control(label)
	
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	if not _area.monitoring or not _area.has_overlapping_bodies():
		_info.hide()
