class_name Condition extends Resource


enum Type {
	BURN,
	SPEED,
	DOOM,
}

@export var type: Type
@export var duration: int = 1


func add(actor: Actor) -> void:
	match type:
		Type.SPEED:
			actor.path_extended.connect(_speed_listener.bind(actor))


func remove(actor: Actor) -> void:
	match type:
		Type.SPEED:
			actor.path_extended.disconnect(_speed_listener)



# getters

func name() -> String:
	return Type.keys()[type].capitalize()



# internal

func _speed_listener(actor: Actor) -> void:
	pass
