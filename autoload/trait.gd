extends Node

enum Type {
	ANIMA,
	ONE,
	TWO,
	THREE,
}

var sets: Dictionary = {}


func add(type: Type, actor: Actor) -> void:
	match type:
		Type.ANIMA: actor.friendly = true


func remove(type: Type, actor: Actor) -> void:
	match type:
		Type.ANIMA: actor.friendly = false



# getters

func get_actor_data(trait_set: Array[Type]) -> ActorData:
	return load("res://resource/character/actor/%s.tres" % sets[trait_set])


func type_name(type: Type) -> String:
	return Type.keys()[type]



# init

func _ready() -> void:
	for actor_name: String in FileAccess.get_file_as_string("res://resource/character/actor/list.txt").split("\n", false):
		sets[load("res://resource/character/actor/%s.tres" % actor_name).traits] = actor_name
