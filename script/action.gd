class_name Action extends Resource


enum Type {
	NONE
}

@export var name: String
@export_multiline var description: String
@export var cost: int = 1

@export var type: Type
@export var damage: int
@export var condition: Condition
