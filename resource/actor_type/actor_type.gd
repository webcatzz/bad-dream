class_name ActorType
extends CharacterData

@export var traits: Array[Actor.Trait]


func _init() -> void:
	traits.sort.call_deferred()