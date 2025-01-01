class_name Path
extends Node2D

const DOT_SEPARATION: int = 12

var lines: Array[Line]
var start: Vector2


func add(line: Line = null) -> void:
	if not line:
		line = Line.new()
		line.end = start
	lines.append(line)
	queue_redraw()


func remove(idx: int) -> void:
	lines.remove_at(idx)
	queue_redraw()


func has(point: Vector2) -> bool:
	for line: Line in lines:
		if line.end == point:
			return true
	return false


func clear() -> void:
	lines.clear()
	queue_redraw()



# setters

func set_end(idx: int, point: Vector2) -> void:
	lines[idx].end = point
	queue_redraw()


func set_type(idx: int, type: Line.Type) -> void:
	lines[idx].type = type
	queue_redraw()


func set_target(idx: int, target: Actor) -> void:
	lines[idx].target = target
	queue_redraw()



# drawing

func _draw() -> void:
	var from: Vector2 = start
	for line: Line in lines:
		_draw_line(line, from)
		from = line.end


func _draw_line(line: Line, from: Vector2) -> void:
	var length: int = (line.end - from).length()
	var count: int = length / DOT_SEPARATION
	var separation: float
	
	if count == 1:
		separation = length / 2.0
	else:
		separation = DOT_SEPARATION - float(DOT_SEPARATION - (length % DOT_SEPARATION)) / count
	
	var color: Color = Palette.WHITE
	
	for d: int in count:
		_draw_dot(from.move_toward(line.end, separation * (d + 1)), line.color())
	
	match line.type:
		Line.Type.MOVE:
			_draw_o(line.end, line.color())
		Line.Type.ATTACK:
			_draw_x(line.target.position, line.color())
			_draw_o(line.end, line.color())


func _draw_dot(point: Vector2, color: Color) -> void:
	draw_texture_rect_region(
		preload("res://asset/ui/path.png"),
		Rect2(point - Vector2(2, 2), Vector2(4, 4)),
		Rect2(Vector2.ZERO, Vector2(4, 4)),
		color
	)


func _draw_o(point: Vector2, color: Color) -> void:
	draw_texture_rect_region(
		preload("res://asset/ui/path.png"),
		Rect2(point - Vector2(4, 4), Vector2(8, 8)),
		Rect2(Vector2(4, 0), Vector2(8, 8)),
		color
	)


func _draw_x(point: Vector2, color: Color) -> void:
	draw_texture_rect_region(
		preload("res://asset/ui/path.png"),
		Rect2(point - Vector2(4, 4), Vector2(8, 8)),
		Rect2(Vector2(12, 0), Vector2(8, 8)),
		color
	)



# line class

class Line:
	enum Type {MOVE, ATTACK, NONE}
	
	var end: Vector2
	var type: Type
	
	var target: Actor
	
	func color() -> Color:
		match type:
			Type.MOVE: return Palette.WHITE
			Type.ATTACK: return Palette.RED
			_: return Color(Palette.WHITE, 0.5)
