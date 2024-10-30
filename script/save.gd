extends Node


var file: ConfigFile = ConfigFile.new()

var party: Array[Actor]
var leader: Actor:
	get: return party[0]


func read() -> void:
	file.load("user://save.cfg")
	
	for actor_name: String in file.get_value("main", "party", ["woodcarver"]):
		var actor: Actor = load("res://resource/actor/%s.tres" % actor_name)
		actor.initialize_traits()
		party.append(actor)


func write() -> void:
	for actor: Actor in party:
		actor.deinitialize_traits()
	
	file.save("user://save.cfg")



# internal

func _ready() -> void:
	read()
