extends Node

var party: Array[Actor] = [load("res://data/actor/party/woodcarver.tres")]

var master_volume: float = 1
var music_volume: float = 1
var sfx_volume: float = 1


func _ready() -> void: load_data()


func save_data() -> void:
	var file: ConfigFile = ConfigFile.new()
	for actor in party:
		file.set_value("party", actor.resource_path.get_file().trim_suffix(".tres"), res_to_dict(actor, [
			"name", "health",
		]))
	for setting: String in ["master_volume", "music_volume", "sfx_volume"]:
		file.set_value("settings", setting, get(setting))
	file.save("res://data/saved.cfg")

func res_to_dict(res: Resource, properties: PackedStringArray) -> Dictionary:
	var dict: Dictionary = {}
	for key in properties: dict[key] = res[key]
	return dict

func load_data() -> bool:
	var file: ConfigFile = ConfigFile.new()
	if file.load("res://data/saved.cfg") == OK:
		party = []
		for key in file.get_section_keys("party"):
			var actor: Actor = load("res://data/actor/party/" + key + ".tres")
			var properties: Dictionary = file.get_value("party", key)
			for property: String in properties: actor[property] = properties[property]
			party.append(actor)
		for key in file.get_section_keys("settings"):
			set(key, file.get_value("settings", key))
		return true
	else: return false

func reset_data() -> void: DirAccess.remove_absolute("res://data/saved.cfg")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()
