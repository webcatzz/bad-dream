extends ResourcePreloader


func get_resource_by_traits(traits: PackedStringArray) -> ActorData:
	for key: String in get_resource_list():
		var type: ActorData = get_resource(key)
		if type.traits == traits: return type
	return get_resource("default")
