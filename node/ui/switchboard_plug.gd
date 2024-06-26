extends Node2D


const WIGGLE = 1

var _previous_position: Vector2

@onready var _wire: Line2D = $Wire


func _ready() -> void:
	get_tree().create_tween().tween_property(self, "position:x", 300, 1).set_trans(Tween.TRANS_QUAD)


func _process(_delta: float) -> void:
	var moved: Vector2 = position - _previous_position
	_previous_position = position
	
	for i: int in range(1, _wire.get_point_count()):
		_wire.points[i] = _wire.points[i].lerp(Vector2(0, 32 * i), 0.05 / i)
	
	return
	
	if moved.length_squared() > 4:
		for i: int in range(1, _wire.get_point_count()):
			_wire.points[i] -= moved * pow(i, 2) * 0.005
	else:
		for i: int in range(1, _wire.get_point_count()):
			_wire.points[i] = _wire.points[i].lerp(Vector2(0, 32 * i), 0.05 / i)
