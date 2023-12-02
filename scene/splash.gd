class_name Splash extends Area2D

enum Shape {SQUARE}

var shape: Shape
var size: int


func _init(shape: Shape = Shape.SQUARE, size: int = 1, pos: Vector2 = Vector2.ZERO):
	self.shape = shape
	self.size = size
	position = Iso.to_iso(pos)
	
	var tile = load("res://scene/tile_highlight.tscn")
	match shape:
		Shape.SQUARE:
			var area: Array = range(-size/2, size - size/2)
			for y in area: for x in area:
				var t = tile.instantiate()
				t.position = Iso.to_iso(Vector2i(x, y))
				add_child(t)


func _ready():
	get_parent().data.facing_changed.connect(turn)


func turn(direction: Vector2):
	Iso.turn_vector(position, direction)
