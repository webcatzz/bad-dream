extends Node


# data

var data: Resource


## Saves game data to the specified file.
func save(file: int) -> void:
	data.save()


## Loads game data from the specified file.
func load(file: int) -> void:
	var path: String = get_save_path(file)
	if ResourceLoader.exists(path):
		data = load(path)
	else:
		data = Resource.new()
		data.set_script(load("res://data/save.gd"))
		data.take_over_path(path)
		data.created()
	randomize()


## Returns a savefile path.
func get_save_path(file: int) -> String:
	return "user://save_" + str(file) + ".tres"



# pausing

var _pause_menu: CanvasLayer = load("res://node/ui/pause_menu.tscn").instantiate()


func pause() -> void:
	get_tree().paused = true
	_pause_menu.visible = true


func unpause() -> void:
	get_tree().paused = false
	_pause_menu.visible = false



# misc

func tween_opacity(item: CanvasItem, from: float, to: float, duration: float) -> void:
	if from == 0:
		item.visible = true
	
	item.modulate.a = from
	await get_tree().create_tween().tween_property(item, "modulate:a", to, duration).finished
	
	if to == 0:
		item.visible = false



# internal

func _ready() -> void:
	Game.load(-1)
	
	add_child(_pause_menu)
