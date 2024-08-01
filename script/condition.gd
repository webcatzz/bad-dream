class_name Condition extends Resource


enum Type {
	BURN
}

@export var type: Type
@export var duration: int = 1


func add(_actor: Actor) -> void:
	pass


func remove(_actor: Actor) -> void:
	pass
