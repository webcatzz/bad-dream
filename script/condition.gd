class_name Condition extends Resource


enum Type {
	BURN
}

@export var type: Type
@export var duration: int = 1


func add(actor: Actor) -> void:
	pass


func remove(actor: Actor) -> void:
	pass
