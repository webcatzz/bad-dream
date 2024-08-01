class_name Enemy extends Actor


enum MoveType {
	ROOK,
	BISHOP,
	KNIGHT,
	KING,
	QUEEN,
}

@export var move_type: MoveType
@export var move_limit: int = 1
@export var ai: GDScript
