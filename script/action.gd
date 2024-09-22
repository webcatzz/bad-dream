class_name Action extends Resource


enum Type {
	NONE,
	HEALING,
}

@export var name: String
@export_multiline var description: String
@export var cost: int = 1

@export var strength: int
@export var type: Type
@export var condition: Condition

@export var shape: BitShape
@export var knockback: Vector2i
