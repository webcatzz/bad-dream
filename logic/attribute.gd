class_name Attribute extends Resource
## Wrapper for [Actor]s' attributes.


enum Type {
	PEP_TALK,
}

@export var type: Type

var target: Actor ## The [Actor] this attribute belongs to.


func start() -> void:
	match type:
		Type.PEP_TALK:
			for actor: Actor in Battle.order:
				actor.actions_per_turn += 1


func end() -> void:
	match type:
		Type.PEP_TALK:
			for actor: Actor in Battle.order:
				actor.actions_per_turn -= 1



# internal

func _to_string() -> String:
	return Type.keys()[type]
