class_name Condition extends Resource


enum Type {
	BURN,
	SPEED,
	DOOM,
}

@export var type: Type
@export var duration: int = 1
@export var strength: int = 1

var actor: Actor


func apply() -> void:
	match type:
		Type.SPEED:
			actor.reoriented.connect(_speed_listener)


func unapply() -> void:
	match type:
		Type.SPEED:
			actor.reoriented.disconnect(_speed_listener)



# getters

func name() -> String:
	return Type.keys()[type].capitalize()



# internal

func _speed_listener() -> void:
	pass
