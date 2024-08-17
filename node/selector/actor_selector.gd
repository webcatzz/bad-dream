extends Selector


var hold_started: int
var hold_duration: int

@onready var _ui: TabContainer = $UI
@onready var _info: InfoPanel = $UI/Info
@onready var _action_menu: Control = $UI/ActionMenu
@onready var _path: Line2D = $Path



# selection

func select(body: Node2D) -> void:
	super(body)
	_path.show()


func deselect() -> void:
	super()
	_ui.current_tab = 0
	_path.hide()


func can_select(body: Node2D) -> bool:
	return super(body) and body.resource in Save.party


func match_position(node: Node2D = selected) -> void:
	super(node)
	
	if selected:
		_path.points = selected.resource.path.map(func(point: Dictionary) -> Vector2:
			return Iso.from_grid(point.position)
		)



# action menu

func open_action_menu() -> void:
	auto_select()
	mode = Mode.ACT
	
	Game.current_battle.open_action_menu(selected.resource)



func _on_action_menu_chosen(resource: Resource) -> void:
	if resource:
		print(resource)
	else:
		deselect()



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_pressed("undo"):
		Game.current_battle.history.undo()
		get_viewport().set_input_as_handled()
	
	elif selected or can_select(get_body_below()):
		if Input.is_action_just_pressed("interact"):
			hold_started = Time.get_ticks_msec()
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_released("interact"):
			hold_duration = Time.get_ticks_msec() - hold_started
			get_viewport().set_input_as_handled()
			
			if hold_duration > 500:
				open_action_menu()
			else:
				deselect() if selected else auto_select()
		else:
			super(event)
	
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
	
	if actor in Save.party or Save.file.get_value("bestiary", actor.name, false):
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
			_info.add_label("No traits.\nA tabula rasa.", &"SmallLabelMuted")
		
		_info.add_spacer()
		
		if actor.conditions:
			_info.add_label("Conditions", &"SmallLabelMuted")
			for condition: Condition in actor.conditions:
				var label: Control = preload("res://node/ui/condition_label.tscn").instantiate()
				label.write(condition)
				_info.add_control(label)
		
		if actor in Save.party:
			_info.add_spacer(true)
			
			var deselect_input: Control = preload("res://node/ui/input_label.tscn").instantiate()
			deselect_input.label = "Select"
			_info.add_control(deselect_input)
			
			var action_menu_input: Control = preload("res://node/ui/input_bar.tscn").instantiate()
			action_menu_input.label = "Open actions"
			_info.add_control(action_menu_input)
	
	else:
		_info.add_label("???", &"BigLabelMuted").size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		var unlock_input: Control = preload("res://node/ui/input_bar.tscn").instantiate()
		unlock_input.label = "Study"
		unlock_input.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_info.add_control(unlock_input)
	
	_ui.show()


func _on_body_exited(body: Node2D) -> void:
	if not get_body_below():
		_ui.hide()
