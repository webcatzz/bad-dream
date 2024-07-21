extends Node


var party: Array[Actor]
var inventory: Array[Item]

var file: ConfigFile = ConfigFile.new()
var settings: ConfigFile = ConfigFile.new()


## Loads game data from the specified file.
func load_file(idx: int) -> void:
	file.clear()
	file.load("user://file_" + str(idx) + ".cfg")
	
	# setting seed
	seed(file.get_value("file", "seed", randi()))
	
	# party list
	for actor_name: String in file.get_value("file", "party", ["woodcarver"]):
		var actor: Actor = load("res://resource/actor/" + actor_name + ".tres")
		actor.initialize()
		party.append(actor)
		# actor data
		if file.has_section(actor_name):
			for key: String in file.get_section_keys(actor_name):
				actor[key] = file.get_value(actor_name, key)
	
	# inventory
	var inventory_dict: Dictionary = file.get_value("file", "inventory", {})
	for item_name: String in inventory_dict:
		var item: Item = load("res://resource/item/" + item_name + ".tres")
		item.count = inventory_dict[item_name]
		inventory.append(item)
	
	# changing scene
	Game.change_world(
		file.get_value("world", "name", "test"),
		file.get_value("world", "position", Vector2.ZERO)
	)
	
	# debug
	if get_flag("draw_astar"):
		get_tree().root.add_child(load("res://node/astar_draw.gd").new())


## Saves game data to the specified file.
func save_file(idx: int) -> void:
	# party list
	file.set_value("file", "party", party.map(func(actor: Actor) -> String:
		return actor.name
	))
	
	# actor data
	for actor: Actor in party:
		for attribute: Attribute.Type in actor.attributes:
			Attribute.remove(attribute, actor)
		
		file.set_value(actor.name, "health", actor.health)
	
	# inventory
	var inventory_dict: Dictionary = {}
	for item: Item in inventory:
		inventory_dict[item.name] = item.count
	file.set_value("file", "inventory", inventory_dict)
	
	# saving seed
	file.set_value("file", "seed", randi())
	
	# world scene
	file.set_value("world", "name", Game.get_world_name())
	file.set_value("world", "position", party[0].node.position)
	
	# saving!
	file.save("user://file_" + str(idx) + ".cfg")
	settings.save("user://settings.cfg")



# inventory

func has_item(item_name: String) -> bool:
	for item: Item in inventory:
		if item.name == item_name:
			return true
	return false


func add_item(item_name: String) -> void:
	for item: Item in inventory:
		if item.name == item_name:
			item.count += 1
			return
	inventory.append(load("res://resource/item/" + item_name + ".tres"))


func remove_item(item_name: String) -> void:
	for item: Item in inventory:
		if item.name == item_name:
			item.count -= 1
			if not item.count: inventory.erase(item)
			return



# flags

func set_flag(key: String, value: Variant) -> void:
	file.set_value("flags", key, value)


func get_flag(key: String, default: Variant = false) -> Variant:
	return file.get_value("flags", key, default)


func incr_flag(key: String, value: int = 1) -> void:
	file.set_value("flags", key, file.get_value("flags", key, 0) + value)



# shortcuts

func get_leader() -> Actor:
	return party[0]


func get_party_undefeated() -> Array[Actor]:
	return party.filter(func(actor: Actor) -> bool:
		return not actor.is_defeated()
	)



# settings

func set_setting(setting: String, value: Variant) -> void:
	settings.set_value("settings", setting, value)


func get_setting(setting: String) -> Variant:
	return settings.get_value("settings", setting)


func set_volume(type: String, value: float) -> void:
	settings.set_value("volume", type, value)
	AudioServer.set_bus_volume_db(["master", "music", "sfx"].find(type), linear_to_db(value))


func get_volume(type: String) -> float:
	return settings.get_value("volume", type, 1)



# internal

func _ready() -> void:
	if settings.load("user://settings.cfg") != OK:
		settings.load("res://resource/default_settings.cfg")
	
	AudioServer.set_bus_volume_db(0, linear_to_db(Data.get_volume("master")))
	AudioServer.set_bus_volume_db(1, linear_to_db(Data.get_volume("music")))
	AudioServer.set_bus_volume_db(2, linear_to_db(Data.get_volume("sfx")))
