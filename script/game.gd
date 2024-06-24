extends Node


# data

var data: Resource


## Saves game data to the specified file.
func save(file: int) -> void:
	data.prepare_for_save()
	ResourceSaver.save(data, get_save_path(file))


## Loads game data from the specified file.
func load(file: int) -> void:
	var path: String = get_save_path(file)
	if ResourceLoader.exists(path):
		data = load(path)
	else:
		data = Resource.new()
		data.set_script(load("res://resource/save.gd"))
		data.created()


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

func get_root() -> Node2D:
	return get_node("/root/Root")



# internal

func _ready() -> void:
	data = load("res://resource/save.tres")
	
	add_child(_pause_menu)



# debug

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P and event.shift_pressed:
		var layer: CanvasLayer = CanvasLayer.new()
		var input: LineEdit = LineEdit.new()
		input.anchor_right = Control.ANCHOR_END
		layer.add_child(input)
		get_root().add_child(layer)
		input.grab_focus()
		
		await input.text_submitted
		
		var command: String = input.text
		layer.queue_free()
		
		if command:
			var script: GDScript = GDScript.new()
			script.source_code = "static func run():" + command
			script.reload()
			script.run()
