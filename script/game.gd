extends Node


const PALETTE: Dictionary = {
	"red": Color("#945b28"),
	
	"yellow": Color("#eadb74"),
	"orange": Color("#c19c4d"),
	"brown": Color("#8a6b3e"),
	"dark_brown": Color("#523a2a"),
	"darker_brown": Color("#211919"),
	
	"light_green": Color("#a0b335"),
	"dark_green": Color("#537c44"),
	
	"light_blue": Color("#6bb9b6"),
	"teal": Color("#57627a"),
	"blue": Color("#596faf"),
	"dark_blue": Color("#423c56"),
	
	"white": Color("#b8aab0"),
	"gray": Color("#79707e"),
	"black": Color("#070505"),
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

var command_history: PackedStringArray
var history_idx: int

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		$Console.show()
		$Console/Input.grab_focus()
		history_idx = command_history.size()
		get_viewport().set_input_as_handled()


func console_run(command: String) -> void:
	$Console.hide()
	$Console/Input.clear()
	
	var script: GDScript = GDScript.new()
	script.source_code = "static func run():" + command
	script.reload()
	script.run()
	
	command_history.append(command)


func console_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			$Console.hide()
			$Console/Input.clear()
		elif event.keycode == KEY_UP and event.pressed and command_history:
			history_idx = max(history_idx - 1, 0)
			$Console/Input.text = command_history[history_idx]
		elif event.keycode == KEY_SHIFT:
			get_viewport().set_input_as_handled()
