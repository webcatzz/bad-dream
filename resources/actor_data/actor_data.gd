class_name ActorData
extends CharacterData

@export var traits: PackedStringArray:
	set(value):
		traits = value
		traits.sort()
