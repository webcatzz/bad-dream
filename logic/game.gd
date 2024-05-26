extends Node


var data: Resource
const DATA_PATH: String = "user://save.tres"

var pause_menu: CanvasLayer



# data

## Saves user data.
func save() -> void:
	ResourceSaver.save(data, data.resource_path)

## Loads user data.
func load() -> void:
	if ResourceLoader.exists(DATA_PATH):
		data = load(DATA_PATH)
	else:
		data = Resource.new()
		data.set_script(load("res://data/save.gd"))
		data.take_over_path(DATA_PATH)



# initializing

func _ready() -> void:
	Game.load()
	
	pause_menu = load("res://node/ui/pause_menu.tscn").instantiate()
	add_child(pause_menu)



# pausing

func pause():
	get_tree().paused = true
	pause_menu.visible = true


func unpause():
	get_tree().paused = false
	pause_menu.visible = false
