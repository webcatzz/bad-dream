class_name ActorData
extends CharacterData

@export var traits: PackedStringArray
@export var is_friendly: bool



# virtual

func _init() -> void:
	traits.sort.call_deferred()
