class_name ActorType
extends CharacterData

@export var traits: Array[Actor.Trait]

@export var ai: GDScript = load("res://resource/enemy_ai/enemy_ai.gd")


func _init() -> void:
	traits.sort.call_deferred()
