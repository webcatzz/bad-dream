extends Node

@onready var actor_types: ResourcePreloader = $ActorTypes


func get_actor_type(traits: Array[Actor.Trait]) -> ActorType:
	for key: String in actor_types.get_resource_list():
		var actor_type: ActorType = actor_types.get_resource(key)
		if actor_type.traits == traits:
			return actor_type
	return null


func get_actor_types() -> Array[ActorType]:
	var array: Array[ActorType]
	for key: String in actor_types.get_resource_list():
		array.append(actor_types.get_resource(key))
	return array
