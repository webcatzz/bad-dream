extends Node


var party: Array[Actor]

var file: ConfigFile = ConfigFile.new()
var settings: ConfigFile = ConfigFile.new()


## Loads game data from the specified file.
func load_file(idx: int) -> void:
	file.clear()
	file.load("user://file_" + str(idx) + ".cfg")
	
	# setting seed
	seed(file.get_value("file", "seed", randi()))
	
	# loading party
	for actor_name: String in file.get_value("file", "party", ["woodcarver"]):
		var actor: Actor = load("res://resource/actor/" + actor_name + ".tres")
		party.append(actor)
		
		if file.has_section(actor_name):
			for key: String in file.get_section_keys(actor_name):
				actor[key] = file.get_value(actor_name, key)
	
	# loading scene
	get_tree().change_scene_to_file(file.get_value("world", "path", "res://world/test.tscn"))
	await get_tree().process_frame
	await get_tree().process_frame
	Game.spawn_party(file.get_value("world", "position", Vector2.ZERO))


## Saves game data to the specified file.
func save_file(idx: int) -> void:
	# saving party list
	file.set_value("file", "party", party.map(func(actor: Actor) -> String:
		return actor.name
	))
	
	# saving party members
	for actor: Actor in party:
		file.set_value(actor.name, "health", actor.health)
	
	# saving seed
	file.set_value("file", "seed", randi())
	
	# world scene
	file.set_value("world", "path", get_tree().current_scene.scene_file_path)
	file.set_value("world", "position", party[0].node.position)
	
	# saving!
	file.save("user://file_" + str(idx) + ".cfg")
	settings.save("user://settings.cfg")



# flags

func set_flag(key: String, value: Variant) -> void:
	file.set_value("flags", key, value)


func get_flag(key: String) -> Variant:
	return file.get_value("flags", key, false)


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
	settings.load("user://settings.cfg")
	load_file.call_deferred(-1)
