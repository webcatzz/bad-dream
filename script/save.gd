extends Node


var file: ConfigFile = ConfigFile.new()

var player: Actor
var party: Array[Actor]


func read() -> void:
	file.load("user://save.cfg")
	
	for actor_name: String in file.get_value("main", "party", ["woodcarver"]):
		var actor: Actor = load("res://resource/actor/%s.tres" % actor_name)
		party.append(actor)
	
	_on_party_changed()



# internal

func _ready() -> void:
	read()


func _on_party_changed() -> void:
	player = party[0]


func _get_filename(resource: Resource) -> String:
	var filename: String = resource.resource_path.get_file()
	return filename.substr(0, filename.rfind("."))
