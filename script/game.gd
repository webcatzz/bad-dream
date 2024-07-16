extends Node


const PALETTE: Dictionary = {
	"red": Color("#945b28"),
	"yellow": Color("#eadb74"),
	"light_green": Color("#a0b335"),
	"dark_green": Color("#537c44"),
	"blue": Color("#596faf"),
	
	"black": Color("#070505"),
	"white": Color("#b8aab0"),
}

@onready var _pause_menu: CanvasLayer = $PauseMenu


# pausing


func pause() -> void:
	get_tree().paused = true
	_pause_menu.visible = true


func unpause() -> void:
	get_tree().paused = false
	_pause_menu.visible = false



# world

func change_world(world_name: String, position: Vector2 = Vector2.ZERO) -> void:
	get_tree().change_scene_to_file("res://world/" + world_name + ".tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	Game.spawn_party(position)


func get_world_name() -> String:
	var filename: String = get_tree().current_scene.scene_file_path.get_file()
	return filename.substr(0, filename.length() - 5)


func spawn_party(position: Vector2) -> void:
	for i: int in range(Data.party.size() - 1, -1, -1):
		if not Data.party[i].node:
			Data.party[i].node = load("res://node/actor/party_actor.tscn" if i else "res://node/actor/player_actor.tscn").instantiate()
			Data.party[i].node.data = Data.party[i]
		
		Data.party[i].node.position = position
		get_tree().current_scene.add_child(Data.party[i].node)



# game over

func over() -> void:
	get_tree().change_scene_to_file("res://node/ui/game_over.tscn")



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
