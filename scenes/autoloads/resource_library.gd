extends Node

var actor_types: Array[ActorType]


func get_actor_type(traits: Array[Actor.Trait]) -> ActorType:
	for actor_type: ActorType in actor_types:
		if actor_type.traits == traits:
			return actor_type
	return null



# loading

func _ready() -> void:
	actor_types.assign(load_folder("res://resources/actor_type/"))


func load_folder(path: String) -> Array[Resource]:
	var resources: Array[Resource]
	
	for filename: String in DirAccess.get_files_at(path):
		if filename.ends_with(".tres"):
			resources.append(load(path + filename))
	
	return resources
