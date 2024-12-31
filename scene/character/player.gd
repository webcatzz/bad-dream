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
			_on_turn_accept()
	
	else:
		if event.is_action_pressed("click"):
			walk_to(get_global_mouse_position())



# battle

func take_turn() -> void:
	path.start = position
	cursor_path.start = position
	cursor_path.add()
	_on_turn_click()
	
	listening = true
	await exhausted
	listening = false
	
	position = path.lines.back().end
	path.clear()
	cursor_path.clear()


func _on_turn_hover() -> void:
	var point: Vector2 = get_global_mouse_position()
	var target: CollisionObject2D = Game.grid.at(point)
	cursor_path.set_end(0, point)
	point = Game.grid.snap(point)
	
	if can_stand(point):
		cursor_path.set_type(0, Path.Line.Type.MOVE)
	elif can_attack(target):
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
			cursor_path.start = path.lines.back().end
			_on_turn_hover()
			break


func _on_turn_accept() -> void:
	exhausted.emit()



# init

func _ready() -> void:
	super()
	Game.player = self
