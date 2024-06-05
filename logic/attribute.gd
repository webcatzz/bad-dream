class_name Attribute extends Resource
## Wrapper for [Actor]s' attributes.


enum Type {
	PRESENCE,
}

@export var type: Type

var target: Actor ## The [Actor] this attribute belongs to.


func start() -> void:
	match type:
		Type.PRESENCE:
			pass


func end() -> void:
	match type:
		Type.PRESENCE:
			pass



# internal

func _to_string() -> String:
	return Type.keys()[type]
