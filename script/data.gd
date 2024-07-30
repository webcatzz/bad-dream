extends Node


var party: Array[Actor]

var file: ConfigFile = ConfigFile.new()
var config: ConfigFile = ConfigFile.new()


func load_file(idx: int) -> void:
	file.load("user://file_" + str(idx) + ".cfg")
	
	# party list
	for actor_name: String in file.get_value("file", "party", ["woodcarver"]):
		pass



# config

func load_config() -> void:
	file.load("user://config.cfg")



# internal

func _ready() -> void:
	load_config()
	load_file(-1)
