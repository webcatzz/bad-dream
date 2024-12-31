class_name Player
extends Actor

signal point_clicked(tile: Vector2i)

var listening: bool = true

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
	
	while path.lines:
		var line: Path.Line = path.lines.pop_front()
		path.start = line.end
		path.queue_redraw()
		
		position = line.end
		if line.type == Path.Line.Type.ATTACK:
			attack(Game.grid.at(line.end))
		
		await get_tree().create_timer(0.05).timeout
	
	exhausted.emit()
	
	path.clear()


func _on_turn_hover() -> void:
	var point: Vector2 = get_global_mouse_position()
	cursor_path.set_end(0, point)
	point = Game.grid.snap(point)
	
	#if Game.grid.ray(cursor_path.start, point):
		#cursor_path.set_type(0, Path.Line.Type.NONE)
	if can_stand(point):
		cursor_path.set_type(0, Path.Line.Type.MOVE)
	elif can_attack(Game.grid.at(point)):
		cursor_path.set_type(0, Path.Line.Type.ATTACK)
	else:
		cursor_path.set_type(0, Path.Line.Type.NONE)


func _on_turn_click() -> void:
	if cursor_path.lines.front().type == Path.Line.Type.NONE:
		return
	
	var line: Path.Line = cursor_path.lines.pop_back()
	line.end = Game.grid.snap(line.end)
	path.add(line)
	
	cursor_path.start = line.end
	cursor_path.add()
	_on_turn_hover()


func _on_turn_right_click() -> void:
	var point: Vector2 = Game.grid.snap(get_global_mouse_position())
	for i: int in path.lines.size():
		if path.lines[i].end == point:
			path.remove(i)
			cursor_path.start = path.lines.back().end if path.lines else path.start
			_on_turn_hover()
			break



# init

func _ready() -> void:
	super()
	Game.player = self
