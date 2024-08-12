extends Selector


@onready var _info: PanelContainer = $Info
@onready var _path: Line2D = $Path


func select(body: Node2D) -> void:
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
	body.set_will_visible(true)
	
	var actor: Actor = body.resource
	_info.set_title(actor.name)
	_info.set_footer("Enemy actor" if actor is Enemy else "Party actor")
	
	if actor.traits:
		var traits: VBoxContainer = _info.add_list("Traits")
		for trait_type: Trait.Type in actor.traits:
			var label: Control = preload("res://node/ui/trait_label.tscn").instantiate()
			label.write(trait_type)
			traits.add_child(label)
	else:
		var label: Label = Label.new()
		label.text = "No traits.\nA tabula rasa."
		label.theme_type_variation = &"SmallLabelMuted"
		_info.add_control(label)
	
	if actor.conditions:
		var conditions: VBoxContainer = _info.add_list("Conditions")
		for condition: Condition in actor.conditions:
			var label: Control = preload("res://node/ui/condition_label.tscn").instantiate()
			label.write(condition)
			conditions.add_child(label)
	
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	body.set_will_visible(false)
	
	if not _area.monitoring or not _area.has_overlapping_bodies():
		_info.hide()
