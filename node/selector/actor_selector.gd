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
	
	var key_stats: VBoxContainer = _info.create_list()
	_info.add_control(key_stats)
	
	var will: HBoxContainer = _info.create_slice("Will")
	will.add_child(Slots.from(actor.will, actor.max_will))
	key_stats.add_child(will)
	
	var stamina: HBoxContainer = _info.create_slice("Stamina")
	stamina.add_child(Slots.from(actor.stamina, actor.max_stamina))
	key_stats.add_child(stamina)
	
	#_info.add_control(_info.create_label("Stamina: %s" % actor.stamina, &"SmallLabel"))
	
	if actor.traits:
		var traits: VBoxContainer = _info.create_list("Traits")
		for trait_type: Trait.Type in actor.traits:
			var label: Control = preload("res://node/ui/trait_label.tscn").instantiate()
			label.write(trait_type)
			traits.add_child(label)
		_info.add_control(traits)
	else:
		_info.add_control(_info.create_label("No traits.\nA tabula rasa.", &"SmallLabelMuted"))
	
	if actor.conditions:
		var conditions: VBoxContainer = _info.create_list("Conditions")
		for condition: Condition in actor.conditions:
			var label: Control = preload("res://node/ui/condition_label.tscn").instantiate()
			label.write(condition)
			conditions.add_child(label)
	
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	if not _area.monitoring or not _area.has_overlapping_bodies():
		_info.hide()
