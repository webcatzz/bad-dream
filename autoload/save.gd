extends Node

var file: ConfigFile = ConfigFile.new()



# loading

func read() -> void:
	file.load("user://save.cfg")



# saving

func write() -> void:
	file.save("user://save.cfg")



# init

func _ready() -> void:
	read()
