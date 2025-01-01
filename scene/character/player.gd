class_name Player
extends Actor

var listening: bool = true

var max_stops: int = 3
var max_stop_length: int = 80

@onready var path: Path = $Path
@onready var cursor_path: Node2D = $CursorPath



# input

func _unhandled_input(event: InputEvent) -> void:
	if not listening:
		get_viewport().set_input_as_handled()
	
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
		if event.is_action_pressed("click"):
			walk_to(get_global_mouse_position())



# battle

func take_turn() -> void:
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
		
		position = line.end
		if line.type == Path.Line.Type.ATTACK:
			attack(line.target)
		
		await get_tree().create_timer(0.05).timeout
	
	path.clear()
	
	animator.play("exhausted")


func _on_turn_hover() -> void:
	var point: Vector2 = get_global_mouse_position()
	point = cursor_path.start + (point - cursor_path.start).limit_length(max_stop_length) * Vector2(1, 0.5)
	
	cursor_path.set_end(0, point)
	point = Grid.snap(point)
	
	if Game.battle.grid.ray(cursor_path.start, point):
		cursor_path.set_type(0, Path.Line.Type.NONE)
	if can_stand(point):
		cursor_path.set_type(0, Path.Line.Type.MOVE)
	elif can_attack(Game.battle.grid.at(point)):
		cursor_path.set_type(0, Path.Line.Type.ATTACK)
		cursor_path.set_end(0, point - calc_facing(point - cursor_path.start))
		cursor_path.set_target(0, Game.battle.grid.at(point))
	else:
		cursor_path.set_type(0, Path.Line.Type.NONE)


func _on_turn_click() -> void:
	if not cursor_path.visible or cursor_path.lines.front().type == Path.Line.Type.NONE:
		return
	
	var line: Path.Line = cursor_path.lines.pop_back()
	line.end = Grid.snap(line.end)
	path.add(line)
	
	cursor_path.visible = path.lines.size() < max_stops
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



# init

func _ready() -> void:
	super()
	Game.player = self
