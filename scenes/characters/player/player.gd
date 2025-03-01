class_name Player
extends Actor

signal num_pressed

var listening: bool = true

var actor_viewed: Actor

@onready var path: Path = $Path
@onready var cursor_path: Node2D = $CursorPath



# input

func _unhandled_input(event: InputEvent) -> void:
	if not listening:
		get_viewport().set_input_as_handled()
		
		if Game.battle and event is InputEventKey:
			if event.keycode >= KEY_1 and event.keycode <= KEY_9:
				num_pressed.emit(event.keycode - KEY_1)
	
	elif Game.battle:
		get_viewport().set_input_as_handled()
		
		if event is InputEventMouseMotion:
			_on_turn_hover()
		elif event.is_action_pressed("click"):
			_on_turn_click()
		elif event.is_action_pressed("right_click"):
			_on_turn_right_click()
		elif event.is_action_pressed("ui_accept"):
			turn_ended.emit()
	
	else:
		if event.is_action_pressed("click") or event is InputEventMouseMotion and Input.is_action_pressed("click"):
			walk_to(get_global_mouse_position())



# battle

func _turn_logic() -> void:
	path.start = position
	cursor_path.start = position
	cursor_path.add()
	_on_turn_hover()
	
	listening = true
	await turn_ended
	listening = false
	
	cursor_path.clear()
	cursor_path.show()
	
	while path.lines:
		var line: Path.Line = path.lines.pop_front()
		path.start = line.end
		path.queue_redraw()
		
		await cross(line.end)
		if line.type == Path.Line.Type.ATTACK:
			line.target.actor_view.show()
			await strike(line.target, await num_pressed)
			line.target.actor_view.hide()
	
	animator.queue("exhausted")



# battle → input

func _on_turn_hover() -> void:
	var point: Vector2 = cursor_path.start + (get_global_mouse_position() - cursor_path.start).limit_length(MAX_STOP_LENGTH) * Vector2(1, 0.75)
	var target: Actor = Game.battle.grid.at(point)
	
	# path point
	cursor_path.set_end(0, point)
	cursor_path.set_target(0, null)
	point = Grid.snap(point)
	
	# actor view
	_set_actor_view(target if target is Actor else null)
	
	# path type
	if Game.battle.grid.ray(cursor_path.start, point):
		cursor_path.set_type(0, Path.Line.Type.NONE)
	if can_stand(point):
		cursor_path.set_type(0, Path.Line.Type.MOVE)
	elif can_strike(Game.battle.grid.at(point)):
		var stand_point: Vector2 = point - calc_unit(point - cursor_path.start)
		cursor_path.set_end(0, stand_point)
		cursor_path.set_target(0, target)
		cursor_path.set_type(0, Path.Line.Type.ATTACK if can_stand(stand_point) else Path.Line.Type.NONE)
	else:
		cursor_path.set_type(0, Path.Line.Type.NONE)


func _on_turn_click() -> void:
	if not cursor_path.visible or cursor_path.lines.front().type == Path.Line.Type.NONE:
		return
	
	var line: Path.Line = cursor_path.lines.pop_back()
	line.end = Grid.snap(line.end)
	path.add(line)
	
	cursor_path.visible = path.lines.size() < MAX_STOPS
	cursor_path.start = line.end
	cursor_path.add()
	_on_turn_hover()


func _on_turn_right_click() -> void:
	var point: Vector2 = Grid.snap(get_global_mouse_position())
	
	while path.lines:
		var line: Path.Line = path.lines.pop_back()
		if line.end == point or line.type == line.Type.ATTACK and line.target.position == point:
			break
	
	path.queue_redraw()
	cursor_path.show()
	cursor_path.start = path.lines.back().end if path.lines else path.start
	_on_turn_hover()


func _set_actor_view(target: Actor) -> void:
	if actor_viewed:
		actor_viewed.actor_view.hide()
		actor_viewed = null
	if target:
		actor_viewed = target
		actor_viewed.actor_view.show()



# battle → adjacency

func on_actor_adjacency_changed(actor: Actor, adjacent: bool) -> void:
	pass # todo add reaction prompt



# init

func _ready() -> void:
	super()
	Game.player = self
