extends Node



# pausing

var _pause_menu: CanvasLayer = load("res://node/ui/pause_menu.tscn").instantiate()


func pause() -> void:
	get_tree().paused = true
	_pause_menu.visible = true


func unpause() -> void:
	get_tree().paused = false
	_pause_menu.visible = false



# internal

func _ready() -> void:
	add_child(_pause_menu)



# debug

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P and event.shift_pressed:
		var layer: CanvasLayer = CanvasLayer.new()
		var input: LineEdit = LineEdit.new()
		input.anchor_right = Control.ANCHOR_END
		layer.add_child(input)
		get_tree().current_scene.add_child(layer)
		input.grab_focus()
		
		await input.text_submitted
		
		var command: String = input.text
		layer.queue_free()
		
		if command:
			var script: GDScript = GDScript.new()
			script.source_code = "static func run():" + command
			script.reload()
			script.run()
